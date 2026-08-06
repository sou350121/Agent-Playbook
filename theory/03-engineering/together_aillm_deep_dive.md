---
auto_generated: true
generated_at: "2026-08-06T06:49:23Z"
source_url: "https://www.together.ai/blog/autoscaling-endpoints-for-llm-inference"
signal_type: "significant_update"
---
# Together AI：LLM 推理端点自动扩缩容最佳实践 (Autoscaling Endpoints for LLM Inference)

> 🔍 本文由 Moltbot 自动生成 | 2026-08-06
>
> **项目/工具**: Together AI Dedicated Model Inference
> **链接**: https://www.together.ai/blog/autoscaling-endpoints-for-llm-inference
> **核心定位**: Together AI 推出基于推理原生指标的自动扩缩容系统，解决 LLM 推理场景中经典的"GPU 利用率健康但队列积压"难题

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**：Together AI 为 Dedicated Model Inference 新增了基于 8 种推理原生指标的自动扩缩容能力，让 LLM 推理端点能像传统 Web 服务一样弹性伸缩
- **现在值得用吗**：是 — 如果你已经在 Together AI 上跑 Dedicated Inference 且流量有波动，这是必配功能；如果你在评估推理平台，这是一个差异化优势
- **适合场景**：流量有波峰波谷的生产推理服务、多租户推理平台、成本敏感的批量推理
- **不适合场景**：需要 scale-to-zero 的间歇性测试场景（不支持自动唤醒）、对冷启动时间极度敏感的低延迟 SLO 场景
- **与 K8s HPA 核心差异**：HPA 基于 CPU/内存等通用指标，对 LLM 推理是错误信号；Together AI 的 autoscaler 基于 in-flight requests、TTFT 等推理引擎原生指标，是 leading indicator

## 是什么 / 解决什么问题

LLM 推理服务的容量规划长期面临两难困境：

**Over-provision（过度配置）**：为了应对峰值流量，始终保持大量 GPU 副本空闲。在 GPU 资源紧缺的当下，这几乎不可行。

**Under-provision（配置不足）**：流量一旦超过副本批量处理能力，p95 延迟会急剧恶化。LLM 服务的降级是非线性的——副本达到并发极限时不会只是"慢一点"，而是开始排队，TTFT 可以从 200ms 暴涨到 15s。

直觉答案是"那就自动扩缩容嘛"。但对于传统无状态 Web 服务有效的 HPA（Horizontal Pod Autoscaler），在 LLM 推理场景下会打破两个核心假设：

1. **CPU 式指标会误导负载判断**：GPU 可能显示 60% 利用率，但推理引擎的请求队列已经在积压。利用率衡量的是算术强度（arithmetic intensity），而非压力。
2. **冷启动需要数分钟**：新副本需要 GPU 节点调度、拉取数十 GB 权重、加载到 VRAM、预热。等你扩好，峰值已经过去了。

Together AI 的解决方案是提供一套**推理原生指标**（inference-native metrics）的自动扩缩容系统，让扩缩容决策基于推理引擎真正理解的信号。

## 技术架构拆解

### 核心设计决策

**1. 比例控制循环（Proportional Control Loop）**

控制循环的核心逻辑是比例式的：

```
observed metric → desired replicas = ceil(N × observed/target) → timing windows dampen → clamp to bounds → GPU placement
```

举例：如果你设定每个副本 8 个 in-flight requests 为目标值，当前观测到 16 个，系统会判定需要 2 倍副本数（在 min/max 范围内）。

**2. 非对称时间窗口（Asymmetric Timing Windows）**

这是整个系统最精妙的设计：

| 窗口 | 默认值 | 设计哲学 | 错误代价 |
|------|--------|----------|----------|
| scale_up_window | 建议短（如 60s） | 快速响应压力 | 误扩 = 浪费几个 replica-minutes（便宜） |
| scale_down_window | 5 分钟 | 耐心等待流量低谷 | 误缩 = 冷启动延迟 + 立即再扩的额外成本（昂贵） |

**关键洞察**：误扩的成本只是几分钟的 GPU 费用，而误缩的成本是用户感知的延迟恶化 + 冷启动时间 + 立即再扩的连锁反应。这种非对称性要求 up-window 要激进、down-window 要保守。

**3. 推理原生指标体系**

Together AI 提供了 8 种可扩缩容指标，分为三类：

| 类别 | 指标 | 信号类型 | 适用场景 |
|------|------|----------|----------|
| **Concurrency-driven** | inflight_requests | Leading（先行） | 默认选择。鲁棒、与引擎无关 |
| **SLO-driven** | ttft (p95) | Trailing（滞后） | 有首 token 延迟 SLO |
| **SLO-driven** | e2e_latency | Trailing（滞后） | 有总完成时间 SLO |
| **SLO-driven** | decoding_speed | Trailing（滞后） | 守护每用户生成速度 |
| **SLO-driven** | throughput_per_replica | Trailing（滞后） | 持续生成管线 |
| **Efficiency-driven** | gpu_utilization | Utilization | 成本优先、容忍延迟波动 |
| **Efficiency-driven** | token_utilization | Utilization | 批量/吞吐管线接近引擎极限 |
| **Efficiency-driven** | cache_hit_rate | Utilization | 重度 prefix-cache 场景 |

### 与前版/竞品的关键差异

| 维度 | K8s HPA (CPU/Memory) | Traditional GPU Autoscaler | Together AI Inference Autoscaler |
|------|---------------------|---------------------------|----------------------------------|
| 指标来源 | 操作系统层 | CUDA 利用率 | 推理引擎内部（vLLM/TGI 指标） |
| 信号性质 | 滞后且不准确 | 滞后（算术强度≠压力） | 先行（队列深度）+ 滞后（延迟 SLO） |
| 冷启动感知 | 无 | 部分 | 完整冷启动预算（86s-145s） |
| 扩缩节奏 | 对称 | 对称 | 非对称（激进 up / 保守 down） |
| 比例控制 | 是 | 视实现 | 是（ceil(N × observed/target)） |
| 流量联动 | 无 | 无 | 自动（traffic-split 随副本数调整） |

### 架构/信息流图

```
                    ┌─────────────────────────────────────────┐
                    │         Traffic Split Router            │
                    │  (weight × ready replicas = capacity)   │
                    └──────────────┬──────────────────────────┘
                                   │
                    ┌──────────────▼──────────────────────────┐
                    │        Replica Pool (1-N)               │
                    │  ┌─────────┐  ┌─────────┐  ┌─────────┐ │
                    │  │Replica 1│  │Replica 2│  │Replica N│ │
                    │  └────┬────┘  └────┬────┘  └────┬────┘ │
                    └───────┼────────────┼────────────┼───────┘
                            │            │            │
                    ┌───────▼────────────▼────────────▼───────┐
                    │      Metrics Collector (per replica)    │
                    │  inflight │ ttft │ gpu_util │ throughput │
                    └──────────────┬──────────────────────────┘
                                   │
                    ┌──────────────▼──────────────────────────┐
                    │       Autoscaler Control Loop           │
                    │                                         │
                    │  1. Read metric → observed value        │
                    │  2. desired = ceil(N × observed/target) │
                    │  3. Apply scale_up/down windows         │
                    │  4. Clamp to [min_replicas, max_replicas]│
                    │  5. Trigger GPU placement               │
                    └─────────────────────────────────────────┘
```

## 实用评估

### 什么场景值得用

**1. 流量有波峰波谷的生产推理服务**

典型场景：面向用户的聊天应用、白天高峰夜间低谷的 API 服务。通过设置合理的 min/max 副本和 inflight_requests 指标，可以在保证 SLO 的同时显著降低成本。

**2. 多租户推理平台**

不同租户有不同的 SLA 要求。通过为不同部署设置不同的扩缩策略（低延迟租户用 ttft 指标、成本敏感租户用 gpu_utilization），实现差异化服务。

**3. 批量推理管线**

对于吞吐优先的场景，使用 token_utilization 或 throughput_per_replica 作为指标，最大化 GPU 利用率。

**4. 开发/测试环境**

通过设置 min=max=0 来完全停止部署（停止计费），需要时手动重启。适合间歇性使用的 dev endpoint。

### 什么场景不值得用

**1. 需要 scale-to-zero 自动唤醒的场景**

Together AI **不支持** scale-to-zero 自动唤醒。min_replicas=0 必须配合 max_replicas=0，此时部署进入 STOPPED 状态，请求会返回错误而非触发自动启动。如果你的场景是"偶尔有人调用、需要自动恢复"，这个方案不适合。

**2. 对冷启动极度敏感的低延迟 SLO**

冷启动时间：基础模型 86s（Qwen3.5-9B on H100），自定义微调模型 145s（18GB 权重），加上路由预热额外 26-40s。如果你的 SLO 要求 p95 < 500ms 且流量可能在 90 秒内激增 10 倍，唯一的防御是保持足够的 min_replicas 缓冲——这意味着 autoscaler 实际上无法帮你省钱。

**3. 非 Together AI 平台的推理服务**

这套 autoscaling 能力是 Together AI Dedicated Model Inference 的专属功能。如果你跑在自托管 vLLM 或 TGI 上，需要自行实现类似的逻辑（但本文的指标选择原则和 timing window 设计思路可以借鉴）。

### 迁移成本

**从固定副本数迁移到 autoscaling**：

- 工作量：极低。一个 PATCH 请求即可完成配置切换
- 风险：低。默认策略（inflight_requests, target=8）是保守且安全的
- 建议：先用默认值跑一周，观察 replica count、队列压力、p95 数据，再微调

**从 K8s HPA 迁移到 Together AI Autoscaler**：

- 工作量：中等。需要重新评估流量模式和 SLO，调整 min/max 副本数
- 风险：中。指标体系完全不同，需要理解 leading vs trailing 信号的区别
- 建议：并行运行一段时间，对比两种策略下的 p95 和成本数据

## 关键代码/配置片段

### 基础配置（一个 PATCH 搞定）

```bash
tg beta endpoints update "$DEPLOYMENT_ID" \
  --min-replicas 1 --max-replicas 6 \
  --scale-up-window 60s --scale-down-window 300s \
  --scaling-metric ttft --scaling-target 500 --scaling-percentile p95
```

### 停止部署（节省 dev 环境成本）

```bash
tg beta endpoints update dep_abc123 --min-replicas 0 --max-replicas 0 # explicit stop
```

### 冷启动时间基准（1×H100, warm cluster）

| 场景 | 实测时间 |
|------|----------|
| 基础目录模型 (Qwen3.5-9B)，create → READY | 86s（PullImage ~30s → Starting ~30s → ready） |
| 自定义微调，18GB 新权重，create → READY | 145s |
| READY → 首个 token 通过路由 | +26-40s |
| Scale-up 1→2 replicas | ~2.5 min |
| 从 STOPPED 重启（权重已在平台侧） | ~1-2 min |

## 实验数据：三种策略对比

Together AI 团队用同一负载（Qwen3.5-9B, 1×H100/副本, 1-3 副本范围）在三种策略下做了对比实验：正弦波 12-48 RPS + 两个 80 RPS 尖峰。

| 策略 | 是否扩缩 | Replica-minutes | 请求数（错误数） | 现象 |
|------|----------|-----------------|-------------------|------|
| inflight_requests (target 8) | 1→2→3 | 26 | 40.6k (536) | 响应每个波峰；额外副本明显降低了 p95 |
| ttft p95 (target 300ms) | 未触发 | 18 | 46.4k (6) | 引擎端 TTFT 始终低于目标；未扩缩 |
| gpu_utilization (target 75%) | 未触发 | 18 | 46.5k (2) | 利用率从未超过 75%；未扩缩 |

**三个关键教训**：

1. **只有并发信号触发了扩缩**。客户端 p95 达到 3-5 秒（明显饱和），但 ttft 策略未触发——因为引擎的 continuous batching 将队列压力吸收进了总延迟而非首 token 延迟。gpu_utilization 也未触发，因为短促的突发请求让 GPU 始终低于 75% 阈值。**两个策略读取的信号看起来健康，但系统已经饱和**。这解释了为什么 inflight_requests 是默认选择。

2. **容量按预期发挥作用**。inflight 策略在保持 2 个副本期间（第 6-11 分钟），其 p95 明显低于单副本策略——在完全相同的负载下。

3. **选择策略前要知道副本的饱和点**。单个副本在 3-5s p95 下承载了 12-48 RPS 而没有崩溃，但如果你的 SLO 是 500ms，这就不可接受。

## 对你的意义

**对 AI 应用开发者**：如果你正在构建需要 LLM 推理的生产系统，这篇博客揭示了一个重要的架构原则——**推理服务的扩缩容不能用传统 Web 服务的思路**。CPU 利用率和 GPU 利用率都是错误信号。你需要关注的是推理引擎内部的队列深度和延迟分布。

**对 VLA/具身智能研究者**：虽然这篇博客聚焦于 LLM 推理，但其核心思想——用领域原生指标替代通用系统指标来做控制决策——同样适用于 VLA 模型的部署。VLA 推理有自己的特有指标（如 action token 生成延迟、多模态编码延迟），未来 VLA 推理平台的 autoscaling 也需要类似的领域感知设计。

**建议**：如果你使用 Together AI 或类似平台，立即启用 autoscaling（默认 inflight_requests 策略就是安全的起点）。如果你在自建推理基础设施，这篇博客的指标分类框架和 timing window 非对称设计思路值得直接借鉴到你的 HPA 配置中。

---
[← Back to Deep Dives](./README.md)
