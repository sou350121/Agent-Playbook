---
auto_generated: true
generated_at: "2026-09-21T05:45:44Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/introducing-amazon-sagemaker-hyperpod-inference-gateway/"
signal_type: "blog_post"
---
# Amazon SageMaker HyperPod Inference Gateway：GPU 感知路由，终结 K8s 轮询调度的 GPU 浪费 (GPU-Aware Inference Routing on HyperPod)

> 🔍 本文由 Moltbot 自动生成 | 2026-09-21
>
> **项目/工具**: Amazon SageMaker HyperPod Inference Gateway
> **链接**: https://aws.amazon.com/blogs/machine-learning/introducing-amazon-sagemaker-hyperpod-inference-gateway/
> **核心定位**: 把 Kubernetes 默认的「轮询/最少连接」负载均衡，换成读得懂 GPU 内部状态的智能路由——单次 addon 安装、零应用改动，官方称首 token 延迟最高降 82%（基准表中部分场景 TTFT P95 降幅达 97–98%）。

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句話定位**：一个 EKS 原生 addon，用实时 GPU 遥测（KV cache、队列深度、LoRA 驻留、前缀缓存命中）替代无脑轮询，把每个推理请求投放到最合适的 pod。
- **現在值得用嗎**：看场景。如果你已经在 HyperPod/EKS 上跑 vLLM/SGLang/TGI 多副本 LLM 推理，且面临**混合 GPU 机型、突发流量、共享 prompt 前缀**三类情况，几乎必然值得装；反之若是完全均质的集群 + 稳定流量，收益接近零。
- **適合場景**：多模型同集群路由、LoRA adapter 共享基座、多轮对话/文档 Q&A 的共享前缀负载、GPU 机型不统一的存量集群。
- **不適合場景**：非 EKS/K8s 环境（如裸机、Ray 集群）、只用单一模型单副本、追求跨集群/跨区域调度（这属于尚未 GA 的 Tier 2）。
- **與前版/競品核心差異**：它不是新平台，而是把开源 [Gateway API Inference Extension](https://github.com/kubernetes-sigs/gateway-api-inference-extension) 的内在机制包装成 AWS 托管 addon，无需 sidecar、无需 service mesh、无需改客户端代码。

## 是什么 / 解决什么问题

在大规模 GPU 集群上跑 LLM 推理很贵，而更让人心痛的是：**默认的 Kubernetes 负载均衡正在默默浪费你最贵的资源**。round-robin 和 least-connections 这类算法对 GPU 内部状况一无所知——哪个 pod 的 KV cache 已经饱和、哪个正卡在长上下文生成的中途、哪个内存里已经加载好了本次请求需要的 LoRA adapter，它们完全看不见。

后果是：请求被均匀地塞进正在忙的 pod，而空闲算力却晾在一边。AWS 官方博客描述，流量高峰时首 token 延迟（TTFT）会飙到 4 秒以上，GPU 利用率变得忽高忽低不可预测，运维只能靠**过度配置**来兜底——用真金白银买来一批其实没在干活的 GPU。

**Amazon SageMaker HyperPod Inference Gateway** 正是针对这个痛点：它是一个 Kubernetes-native、GPU-aware 的路由系统，作为单个 EKS 托管 addon 部署到你现有的 HyperPod 基础设施上，利用实时 GPU 信号为每个推理请求挑选最合适的 pod。官方给出的招牌案例是一句很直白的话：**「一个等首 token 等了 4.4 秒的聊天用户，现在不到 800 ms 就能看到第一个字。」**（4.4s → <0.8s，约 82% 降幅）

关键在于**零侵入**：不改模型服务器，不改客户端应用，不加 sidecar，不需要 service mesh。网关对外暴露标准 OpenAI 兼容端点，你现有的客户端代码原封不动就能用。

## 技术架构拆解

### 核心设计决策

- **完全建立在 K8s 原生原语之上**：不是「与 K8s 并列的另一个平台」，而是「就是 K8s」——Gateway API conformant，配置靠一个 CRD（`InferenceGatewayConfig`）声明，`kubectl` / GitOps / Helm / ArgoCD 全部照常工作。
- **两层架构，先做本地、再做全局**：Tier 1（每集群网关）今天 GA；Tier 2（Global Inference Router）做跨集群/跨区域协调，尚未发布。先解决单集群内最痛的 GPU 盲路由问题。
- **把「路由决策」下沉为「多因子加权评分」**：智能层 Endpoint Picker（EPP）消费每个推理 pod 暴露的实时 Prometheus 指标，用加权评分算法选后端。每个 scorer 权重可配置，从而针对「延迟敏感的对话」或「吞吐优先的批处理」分别调优。
- **开放而非锁定**：底层是官方 Kubernetes Gateway API 及其 Inference Extension；对任何 OpenAI 兼容模型服务器（vLLM、SGLang、TGI 等）都适用。
- **优雅降级是显式设计的一等公民**：从单 pod 失败到区域级故障，每一层都有定义好的降级行为与恢复路径（见下表），而不是「一崩全崩」。

### 五个评分因子（EPP 的核心）

| Scorer | 作用 | 解决的问题 |
|--------|------|-----------|
| KV cache utilization | 避开 KV 内存接近打满的 pod | 长上下文请求堆积 |
| Queue depth | 避开请求积压深的 pod | 突发流量下的排队雪崩 |
| LoRA adapter residency | 优先已加载目标 adapter 的 pod | 消除 adapter 换入换出延迟 |
| Prefix cache hit rate | 优先可能命中 prompt 前缀缓存的 pod | 多轮对话/文档 Q&A 重复计算 |
| Running requests | 均衡全集群活跃工作 | 整体负载倾斜 |

### 与前版/竞品的關鍵差異

| 维度 | K8s 默认负载均衡（round-robin / least-conn） | Inference Gateway |
|------|--------------------------------------------|-------------------|
| GPU 内部可见性 | 无 | 实时 Prometheus 遥测（KV cache、队列、LoRA、前缀缓存） |
| 混合 GPU 机型 | 会把请求塞给已过载的小显存 pod | 实时检测不均衡并避让 |
| 突发流量 | 单一副本在过载/空闲间震荡 | 把请求导向有容量的 pod |
| 共享 prompt 前缀 | 无感知，重复计算 | Prefix Cache Hit Rate scorer 命中缓存 |
| 多模型同集群 | 需应用侧自行分路由 | Body-Based Router 读请求 body 的 model 字段自动分流 |
| 接入成本 | — | 单个 EKS addon + 一个 CRD，零代码改动 |

### 架构/信息流图

```
                    ┌─────────────── Tier 1: 每集群网关（EKS managed addon）──────────────┐
   HTTPS 请求        │                                                                      │
   (OpenAI 兼容) ───▶ │  Envoy Gateway  ──▶  Body-Based Router (BBR)  ──▶  Endpoint Picker  │
                    │   (L7 代理/单私有入口)   (读 body 的 model 字段分池)     (EPP 智能层)     │
                    │                                                              │        │
                    └──────────────────────────────────────────────────────────┼────────┘
                                                                               │ 加权评分
                                                                               ▼
                     ┌─────────────── 模型服务 pod 集群（vLLM / SGLang / TGI ...）───────────────┐
                     │  pod A (KV 85%, 队列深)      pod B (已装 LoRA-X, 空闲)     pod C (...)   │
                     │      ✗ 避开                       ✓ 命中                          ...      │
                     └───────────────────────────────────────────────────────────────────────┘
                                          ▲ 每个 pod 暴露实时 Prometheus 指标
                                          └────────────── EPP 消费并评分 ──────────────

   ┌──── Tier 2: Global Inference Router (GIR) — coming soon ────┐
   │  跨集群/跨区域协调 · 跨集群故障转移(35s 内) · 全局限流 · 成本分层流量整形  │
   └──────────────────────────────────────────────────────────────┘
```

Tier 1 由三个组件构成，全部基于开源 Gateway API Inference Extension：**Envoy Gateway**（终止 HTTPS、每集群单一私有端点）、**Body-Based Router / BBR**（检查每个 OpenAI 兼容请求 body、提取 `model` 字段、路由到正确模型池）、**Endpoint Picker / EPP**（智能层，消费 Prometheus 指标并加权评分选后端）。

### 优雅降级矩阵（官方原文）

| 故障范围 | 行为 | 恢复方式 |
|---------|------|---------|
| Pod 失败 | EPP 剔除指标过期的 pod，路由到健康 pod | 指标恢复时自动回归 |
| 模型池耗尽 | 返回 HTTP 429 + Retry-After 头 | 自动扩缩容补充容量 |
| 集群失败 | GIR 检测到心跳过期，35 秒内重定向流量 | 重新引入时渐进放量 |
| 区域失败 | 跨区域路由自动激活 | 延迟升高，但可用性不受影响 |

> TODO: 「集群失败 / 区域失败」两行依赖 Tier 2（GIR），而 GIR 官方标注为 "coming soon"、尚未 GA；因此这两条在当前的 Tier 1 单集群部署中暂不可用，需待 Tier 2 发布后验证。

## 实用评估

### 什么场景值得用

- **混合 GPU 机型的存量集群**：生产 GPU 集群很少均质。小显存机型在大机型轻松处理的流量下先饱和，轮询却继续往过载 pod 上怼。基准测试中该场景收益最猛（Llama-3.1-8B 的 TTFT P95 降 97%）。
- **突发（bursty）流量**：这是绝大多数 LLM 工作负载的常态。基准中 Llama-3.1-70B 突发场景 TTFT P95 降 94%、P99 降 98%，吞吐 +12%。
- **共享 prompt 前缀的负载**：多轮对话、文档 Q&A 有共同前缀，Prefix Cache Hit Rate scorer 把它们导向已缓存前缀的 pod，避免重复计算。
- **多模型 / LoRA 共享基座**：BBR 让一个网关服务多模型；LoRA Affinity Scorer 把 adapter 请求导向已驻留该 adapter 的 pod，消除换入延迟。

### 什么场景不值得用

- **完全均质集群 + 稳定流量**：官方自己承认——在「均质集群 + 稳定流量」下各副本利用率几乎一致，网关表现与轮询**持平**（Comparable 即在 run-to-run 方差内）。这种情况装了基本白装。
- **非 EKS/K8s 环境**：它是 EKS managed addon，强绑定 HyperPod/EKS。裸机或非 K8s 编排集群用不上。
- **单模型单副本**：没有「在哪放」的优化空间。
- **需要跨集群/跨区域智能调度**：那是尚未 GA 的 Tier 2，现在买不到。
- **强合规/离线环境**：需要能访问 EKS addon 生命周期与 Prometheus/CloudWatch 链路。

### 迁移成本

极低，官方目标是「5 分钟上手」：

1. `aws eks create-addon` 安装 `amazon-sagemaker-hyperpod-inference`（`v2.0.0-eksbuild.1`）；
2. 给现有模型 pod 打一个 label（如 `app: vllm-llama`）供网关发现；
3. 应用一个 `InferenceGatewayConfig` CRD 声明模型与路由行为；
4. 客户端继续打标准 OpenAI 兼容端点，**无需改 SDK、推理流量无需 SigV4 签名**。

没有 sidecar、没有 service mesh、没有应用代码改动——这是它最大的卖点，也意味着试错成本几乎为零。

## 对你的意义

如果你的 Agent/RAG 工作负载已经跑在托管 K8s 上并且是多副本 LLM 推理，这个更新值得**立即在小集群试点**：接入成本几乎为零，收益主要来自「你的集群有多不均质」。但有几个判断点：

- **别被 82% 这个数字单独牵着走**。它是「4.4s → <0.8s」这个特定案例的降幅；基准表里混合 GPU 场景的 TTFT P95 降幅其实更大（97–98%），突发场景也不弱。数字波动大，取决于工作负载与集群均质程度。
- **注意 headline 与基准表的张力**：hero 文案说「up to 82%」，而基准表出现 94–98% 的降幅，两者口径并不一致（前者像单点案例、后者是聚合基准）。引用时建议只引用你**自己场景**对应的那一行，别混用。
- **LoRA 路由和前缀缓存这两点对 Agent 场景最实用**：多轮 agent 对话天然共享前缀，若能命中 prefix cache，是实打实的重复计算消除。
- **观望点**：Tier 2（GIR）决定它能否成为「多集群推理网关」的完整答案，目前未 GA。若你的诉求是跨区域成本优化，先别急着下结论。

**结论**：单集群、多副本、GPU 机型不齐的团队 → 立即试；均质稳定集群 → 跳过；跨集群调度 → 等 Tier 2。

## 关键代码/配置片段

以下均直接引自 AWS 官方博客（2026-09-21 发布），未经改写。

安装 addon（Step 1）：

```bash
aws eks create-addon \
  --cluster-name my-hyperpod-cluster \
  --addon-name amazon-sagemaker-hyperpod-inference \
  --addon-version v2.0.0-eksbuild.1 \
  --configuration-values '{"inferenceGateway": {"enabled": true}, "inferenceOperator": {"enabled": true}}'
```

给模型 pod 打 label（Step 2，网关据此发现后端）：

```yaml
spec:
  template:
    metadata:
      labels:
        app: vllm-llama   # The gateway matches on this
```

声明网关配置（Step 3，单一 CRD 定义整个路由拓扑）：

```yaml
apiVersion: inference.sagemaker.aws.amazon.com/v1alpha1
kind: InferenceGatewayConfig
metadata:
  name: my-gateway
spec:
  tls: {}
  bbr:
    enabled: true
  schedulers:
    - name: llama-70b
      modelName: "llama-3.1-70b"
      modelSelector:
        matchLabels:
          app: vllm-llama
      targetPort: 8000
      scheduler: llm-d
```

发请求（Step 4，标准 OpenAI 兼容端点，客户端零改动）：

```bash
curl -X POST "http://<gateway-endpoint>/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -d '{"model": "llama-3.1-70b", "messages": [{"role": "user", "content": "What is Kubernetes?"}], "max_tokens": 100}'
```

### 官方基准数据（引官方博客表格，对同副本的 K8s 轮询基线，默认路由配置、无调优）

| 工作负载条件 | TTFT P95 | TTFT P99 | 吞吐 |
|-------------|----------|----------|------|
| Mixed GPU generations (Llama-3.1-8B) | –97% | –97% | +8% |
| Mixed GPU generations (Qwen3-32B) | –98% | –97% | +50% |
| Bursty traffic (Llama-3.1-70B) | –94% | –98% | +12% |
| Bursty traffic (Qwen3-235B) | Comparable | –89% | Comparable |
| Shared prompt prefix (Llama-3.1-8B) | –26% | –43% | Comparable |
| Uniform fleet, steady traffic (Qwen3-235B) | Comparable | Comparable | Comparable |

> 测试环境：4 个模型（8B–235B），部署于 p5.48xlarge（H100）与 g5（A10G）；流量经内部 ALB，路径与生产请求一致；专用客户端节点组生成负载、模型服务器隔离运行。「Comparable」= 差异落在 run-to-run 方差内。来源：AWS 官方博客（2026-09-21）。

---
[← Back to Deep Dives](./README.md)
