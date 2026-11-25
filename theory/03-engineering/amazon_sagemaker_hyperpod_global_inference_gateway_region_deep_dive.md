---
auto_generated: true
generated_at: "2026-11-25T03:30:51Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/introducing-amazon-sagemaker-hyperpod-global-inference-gateway-one-endpoint-across-regions-and-clusters/"
signal_type: "significant_update"
---
# Amazon SageMaker HyperPod 全球推理网关：把闲置 GPU 变成弹性容量 (Global Inference Gateway: One Endpoint Across Regions and Clusters)

> 🔍 本文由 Moltbot 自动生成 | 2026-11-25
>
> **项目/工具**: Amazon SageMaker HyperPod Global Inference Gateway
> **链接**: https://aws.amazon.com/blogs/machine-learning/introducing-amazon-sagemaker-hyperpod-global-inference-gateway-one-endpoint-across-regions-and-clusters/
> **核心定位**: 在集群内 KV 缓存感知路由之上再加一层跨 Region/集群的路由层，让付费却闲置的 GPU 直接承接溢出流量，并自带故障切换

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**：SageMaker 代为运营的第二层推理网关——对跨多个 HyperPod 集群/Region 的模型提供**单一区域端点**，按负载信号打分选集群，集群挂了自动迁移流量。
- **现在值得用吗**：看场景。你**已经**在多个 HyperPod 集群跑同一模型且有峰谷不均/跨 Region 容灾需求时，几乎必上；单集群用户没必要动。
- **适合场景**：多集群同模型部署、跨 Region 溢出与容灾、想把"自建 LB + DNS + 跨区网络"这块运维包袱扔掉的小平台团队。
- **不适合场景**：单集群部署、需要网关级精细可观测性（日志/追踪）的团队、非 HyperPod（自建 K8s / EKS 裸部署）用户、需要缓存亲和性优先于负载均衡的场景。
- **与前版核心差异**：Part 1 的 Inference Gateway 只解决"集群内选 pod"；Global 层解决"选哪个集群"，客户端不再持有多端点。

## 是什么 / 解决什么问题

AWS 在 11 月 20 日发布博文，为 SageMaker HyperPod 推出 **Global Inference Gateway**。它建立在同系列前作的 Inference Gateway 之上：后者给每个集群一个 GPU 感知的端点，读取 KV 缓存利用率、队列深度等实时信号，把请求放到最合适的 pod 上。问题在于——**那只解决了集群内部**。

当模型足够大、GPU 配额需要摊到多个集群甚至多个 Region 时，运维复杂度会爆炸。博文给的具体例子很有代表性：某团队在两个 Region 的五个集群上服务四个模型，没有 Inference Gateway 时客户端要追踪 20 个端点；有了 Inference Gateway 降到 5 个（每集群一个），但**客户端仍要自己挑集群**。

自己挑集群的代价是博文明确列出的三条：峰值时请求在一个 Region 排队、另一个 Region 的 GPU 空闲；集群故障要工程师手工改配置切流量；跨 Region 分发意味着自己搭负载均衡、DNS 和跨区网络。

Global Inference Gateway 的设计目标就是消除这层"自己挑"：**一个 SageMaker 托管的端点，路由到你注册的所有集群，跨 Region 走 AWS 骨干网，自动故障切换，SigV4 + IAM 认证**。

## 技术架构拆解

### 核心设计决策

- **两层网关而非一个大网关**：集群内的 Inference Gateway 保持不变（选 pod），Global 层只选集群。这样每层的职责与故障域清晰，且单集群用户完全无感升级。
- **集群"发布"与网关"编组"解耦**：每个集群只需在其 `InferenceGatewayConfig` 里打开 `spec.globalRouting` 一次，控制器就在你账号内创建 NLB + VPC Endpoint Service + 上传 TLS 证书；网关再通过 `CreateGlobalInferenceGateway` 指定要路由的集群集合。发布与编组是两个独立决策。
- **资源留在你的账号**：NLB、VPC 端点服务、TLS 证书桶都在自己账号，SageMaker 只代为运营路由舰队（终止 TLS、认证、打分、转发）。这对合规团队是关键——跨区流量不经过不可见的黑盒。
- **PrivateLink 为唯一通路**：跨 Region 也一样，请求通过 AWS 骨干网 + PrivateLink 到达集群，不暴露公网。网关明确声明**不记录 prompt 与 completion**。
- **四信号加权打分**：权重 0.0–1.0，必须四项齐全且总和为 1.0。默认值明显偏向"就近"：RegionProximity 0.40、QueueDepth 0.25、KVHeadroom 0.20、ErrorRate 0.15。
- **失败语义收敛**：集群故障时流量迁到次优集群，未开始流式的失败请求会在另一集群重试一次；流式请求不重试；无健康集群返回 503。

### 与前版/竞品的关键差异

| 维度 | Part 1 Inference Gateway（集群内） | Global Inference Gateway（新增层） |
|------|----------------------------------|----------------------------------|
| 路由粒度 | 选 pod（KV 缓存/队列） | 选集群（跨集群/跨 Region） |
| 客户端端点数量 | 每集群一个 | 全部集群一个 |
| 故障切换 | 集群内部 | 集群级自动切换，客户端零改动 |
| 网络要求 | 集群内 | 自动 NLB + VPC Endpoint Service + PrivateLink |
| 认证 | — | SigV4 + IAM，流式单独 Action |
| 可调参数 | 集群内路由 | 四信号权重，运行中可热更 |

### 架构/信息流图

```
Client (SigV4 签名)
      │
      ▼
Global Inference Gateway  (SageMaker 运营的路由舰队: TLS 终止 / IAM 鉴权 / 限流 / 打分)
      │  四信号加权: KVHeadroom 0.20 | QueueDepth 0.25 | RegionProximity 0.40 | ErrorRate 0.15
      │
      ├── PrivateLink ──> Cluster A (Region 1) ──> Inference Gateway ──> Pod
      ├── PrivateLink ──> Cluster B (Region 1) ──> Inference Gateway ──> Pod
      └── PrivateLink ──> Cluster C (Region 2) ──> Inference Gateway ──> Pod
                                  ▲
                         每集群 metrics publisher（独立 IAM role）回流负载
```

## 实用评估

### 什么场景值得用

- **多 Region 容灾且没人愿意半夜起来切流量**：博文引用的 Bagelcode 反馈很直白——beta 测试中网关跨两个 Region 经单一端点路由，一个集群无法服务时有另一集群接上，"给了小平台团队跨 Region 故障切换，而不必自建路由层"。
- **峰谷差异明显、但不想为峰值长期多买 GPU**：把峰值溢出到另一区域的闲置容量，等于把已付款的算力用起来。
- **想砍掉自建 LB/DNS/跨区网络**：这块通常是最先腐化的运维代码，且常由少数人掌握。交给托管服务是净收益。
- **合规要求数据路径可见**：资源在自己账号、跨区走 PrivateLink、网关不存 prompt——审计链条相对干净。

### 什么场景不值得用

- **单集群**：博文自己说得很清楚——"If you serve from a single cluster, stay on that cluster's Inference Gateway endpoint."
- **需要网关级追踪/日志**：网关不记录 prompt 与 completion，这对隐私是优点，但对调试是缺点。需要请求级可观测性，得自己在上游或集群内补。
- **缓存亲和性 > 负载均衡的工作负载**：默认 0.40 的 RegionProximity 会优先就近；若你的真实瓶颈是 prefix 缓存命中（同一会话反复命中同一批 KV），集群级打散可能反而拉低命中率。博客没有讨论跨集群缓存复用，这是一个明确的盲区。
- **非 HyperPod 部署**：这是 HyperPod Inference add-on 的延伸，自建 K8s / 普通 EKS 推理栈不适用。
- **怕账单不可控**：已发布但未加入任何网关的集群**仍会被计费 NLB**。这是最容易踩的坑。

### 迁移成本

按博文的路径表，最小改动是"更新 add-on → 发布每个集群 → 建网关"，客户端从per-cluster端点切到单一端点。`AddInferenceGateway`/`RemoveInferenceGateway` 可渐进增删集群，删除网关后 per-cluster 端点继续服务——整体属于**低风险、可回滚**的迁移。真正的工作量在于前置整理：每个集群上同名 `modelName` 的 scheduler 必须配齐（漏配的模型在网关上返回 404），以及跨 Region 时两侧都要留余量。

## 对你的意义

对 Ken 的两条线，这件事的价值不在"又一个托管功能"，而在它把 **推理网关的两层抽象**变成了云厂商的标准形态：

- 如果你的 Agent 应用未来需要在多 Region 低延迟地服务同一个模型，这提供了"不写一行 LB 代码"的参考架构；即便不用 AWS，四信号加权（KV 余量 / 队列 / 邻近 / 错误率）这套打分思路也值得直接借到自建网关里。
- 对 VLA 侧的启发更明显：**长时任务 + 大模型 + 峰值抖动**是机器人推理的常态。跨集群溢出意味着"机器人车队空转时段，同一批 GPU 可以去跑离线评测"，这在自建栈里几乎没人做对。
- 建议：**观察 + 借架构，不必立即试用**。除非你已经在 HyperPod 多集群上跑模型，否则它的直接可用性为零，但它的设计决策值得抄。

## 关键代码/配置片段

权重必须四项齐全且总和为 1.0，默认偏向"就近"。若把容灾看得比邻近更重要，博文给的示例是：

```json
{"Weights": {"KVHeadroom": 0.1, "QueueDepth": 0.1, "RegionProximity": 0.1, "ErrorRate": 0.7}}
```

调用方 IAM 策略（流式单独一个 Action）：

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "sagemaker:InvokeGlobalInferenceGateway",
      "sagemaker:InvokeGlobalInferenceGatewayWithResponseStream"
    ],
    "Resource": "arn:aws:sagemaker:<region>:<account-id>:global-inference-gateway/<gateway-id>"
  }]
}
```

新增集群时，在**网关所在 Region** 调用（即使集群在另一个 Region）：

```bash
aws sagemaker add-inference-gateway \
  --identifier <gateway-name> \
  --region <region> \
  --cluster-arn arn:aws:sagemaker:<region-3>:<account-id>:cluster/<cluster-id-3> \
  --name <gateway-config-name-3> \
  --namespace inference-gateway
```

几个来自博文的踩坑提醒：`globalRouting.enabled: false` 才是彻底撤下集群的开关（`RemoveInferenceGateway` 只是暂停新请求）；跨集群 kubectl 务必带 `--context`；`--resolve-conflicts OVERWRITE` 配不全会重置 LB/TLS 设置。

> TODO: 跨集群/跨 Region 的额外延迟开销，博文未给具体数字；网关路由舰队的容量上限与配额亦未说明，需查阅 AWS 文档确认。

---
[← Back to Deep Dives](./README.md)
