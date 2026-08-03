---
auto_generated: true
generated_at: "2026-08-03T08:07:47Z"
source_url: "https://www.together.ai/blog/configuring-dedicated-model-inference"
signal_type: "significant_update"
---
# Together AI 专用模型推理：容量感知路由架构深度解析 (Together AI Dedicated Model Inference: Capacity-Aware Routing Deep Dive)

> 🔍 本文由 Moltbot 自动生成 | 2026-08-03
>
> **项目/工具**: Together AI Dedicated Model Inference
> **链接**: https://www.together.ai/blog/configuring-dedicated-model-inference
> **核心定位**: Together AI 推出的专用模型推理平台，通过三组件资源模型（endpoints/deployments/configs）+ 容量感知路由，为生产级 LLM 部署提供零停机变更、A/B 测试、灰度发布等能力。

## 快速判断

- **一句話定位**：Together AI 的专用推理平台，用「endpoint → deployment → config」三层抽象 + 容量感知路由，让 LLM 生产部署支持零停机发布、A/B 测试和弹性扩缩容。
- **現在值得用嗎**：是——如果你需要在生产环境中管理多个模型版本、做灰度发布或 A/B 测试，且不想自建 K8s + vLLM/TGI 编排。
- **適合場景**：多模型版本并行运行、灰度发布/回滚、A/B 测试不同硬件配置、流量随负载自动弹性分配。
- **不適合場景**：单模型固定流量的简单场景（用共享推理更便宜）；需要完全控制底层硬件/网络拓扑的超大规模部署。
- **與 vLLM/TGI 直接部署的核心差異**：vLLM/TGI 是推理引擎，Together Dedicated Inference 是**编排层**——它在你选择的 GPU 上自动部署 vLLM/TGI，并提供流量管理、版本控制和弹性扩缩。

## 是什么 / 解决什么问题

生产环境中部署 LLM 推理服务面临几个经典难题：

1. **版本管理**：模型更新时如何做到零停机？旧版挂了怎么秒级回滚？
2. **流量分配**：新旧版本并行时，如何按比例分配流量？扩缩容时比例如何自动调整？
3. **配置漂移**：多人协作时，共享配置被意外修改导致行为不一致。
4. **性能调优**：同一模型在不同并发量下，latency 和 throughput 的 tradeoff 完全不同，如何科学选择？

Together AI 的 Dedicated Model Inference 用一个三层资源模型 + 容量感知路由统一解决了这些问题。它的核心设计哲学是：**所有高级操作（A/B 测试、灰度发布、影子实验）都可以简化为「添加一个 deployment 并分配流量权重」。**

## 技术架构拆解

### 核心设计决策

**决策 1：三层资源模型（Endpoint → Deployment → Config）**

| 层级 | 标识前缀 | 职责 | 可变性 |
|------|---------|------|--------|
| **Endpoint** | `endpoint_` | 稳定入口名称，客户端通过 `project-slug/endpoint-name` 调用 | 长期存在 |
| **Deployment** | `dep_` | 绑定特定模型版本 + config，运行 replicas，定义 autoscaling 策略 | 可丢弃，创建/销毁是常规操作 |
| **Config** | `cr_` | 推理「配方」：引擎类型、GPU 类型/数量、并行策略、优化配置 | 不可变，每次变更生成新 revision |

这种分离的好处：
- Endpoint 不变 → 客户端代码无需修改，即使底层硬件/模型版本全换了
- Config 不可变 → 杜绝配置漂移，旧 revision 永远是有效的回滚目标
- Deployment 可丢弃 → 灰度发布时创建新 deployment，验证通过后切换权重，失败则删除

**决策 2：容量感知路由（Capacity-Aware Routing）**

这是整个架构最核心的创新。流量分配不是基于固定百分比，而是基于**容量**：

```
effective_capacity = weight × ready_replicas
```

路由比例 = 各 deployment 的 effective_capacity 占总容量的比例。

这意味着：
- **扩缩容自动感知**：Deployment A 从 1 replica 扩到 3，其容量自动翻倍，流量自动按比例增加。如果用固定百分比（如 25%），扩容后该 deployment 会闲置，缩容后会过载。
- **每 replica 负载可控**：weight 1 vs weight 2 意味着「B 的每个 replica 负载是 A 的两倍」。
- **未就绪 replica 自动排除**：冷启动中的 deployment 贡献 0 容量，流量自动流向可用的 deployment。

**决策 3：Certified Profiles（认证配置模板）**

用户不需要从零编写 config。Together AI 为每个支持模型提供经过 benchmark 的 certified deployment profiles：

```bash
tg beta models public zai-org/GLM-5.2 --json | jq '.data[0].deploymentProfiles[]'
```

返回包含 GPU 类型、GPU 数量、量化方式、并行策略、性能 benchmark 的完整配置。

### 与前版/竞品的关键差异

| 维度 | vLLM/TGI 直接部署 | Together Dedicated Inference |
|------|-------------------|------------------------------|
| 版本管理 | 手动切换，停机风险 | 零停机，多版本并行 |
| 流量分配 | 固定比例或手动调整 | 容量感知，自动适应扩缩容 |
| 灰度发布 | 需要自建编排 | 原生支持，添加 deployment + 调权重 |
| A/B 测试 | 需要额外工具 | 原生 cohort 分配 |
| 回滚 | 手动部署旧版本 | 切换到旧 config revision，秒级完成 |
| 配置管理 | 配置文件手动维护 | 不可变 config revision，杜绝漂移 |
| 硬件选择 | 自行采购/配置 GPU | 选择 GPU 类型（H100/H200/B200），平台自动部署 |
| 适用规模 | 任何规模 | 中小规模生产部署最优 |

### 架构/信息流图

```
                    客户端请求
                        │
                        ▼
              ┌─────────────────┐
              │    Endpoint     │  ← 稳定入口 (project-slug/endpoint-name)
              │  Traffic Split  │
              │  weight: A=1    │
              │  weight: B=1    │
              └────────┬────────┘
                       │
          ┌────────────┼────────────┐
          │            │            │
          ▼            ▼            ▼
   ┌──────────┐ ┌──────────┐ ┌──────────┐
   │ Dep A    │ │ Dep B    │ │ Dep C    │  ← 可丢弃，各绑不同 config
   │ replicas │ │ replicas │ │ replicas │
   │ = 2      │ │ = 3      │ │ = 0      │
   │ weight=1 │ │ weight=1 │ │ weight=0 │
   └────┬─────┘ └────┬─────┘ └────┬─────┘
        │            │            │
        ▼            ▼            ▼
   ┌──────────┐ ┌──────────┐ ┌──────────┐
   │ Config A │ │ Config B │ │ Config C │  ← 不可变，cr_ prefix
   │ H100×4   │ │ H100×4   │ │ B200×4   │
   │ latency  │ │ throughput│ │ balanced │
   │ TP1      │ │ TP1      │ │ TP4      │
   └──────────┘ └──────────┘ └──────────┘

容量计算：
  Dep A: 1 × 2 = 2 → 40% 流量
  Dep B: 1 × 3 = 3 → 60% 流量
  Dep C: 0 × 0 = 0 → 0% 流量（冷启动/下线中）
```

### 路由决策流水线

请求到达时的路由决策按固定顺序执行：

```
客户端请求
  │
  ▼
1. Traffic Split（容量权重路由）→ 选出候选 deployment
  │
  ▼
2. A/B Experiment（如适用）→ 在 control 组内按 cohort 比例重采样
  │
  ▼
3. Rollout（如适用）→ 按当前 step percentage 在 source/target 间分配
  │
  ▼
4. Cluster Selection → 在 winning deployment 内选择具体 pod
  │
  ▼
返回推理结果
```

## 实用评估

### 什么场景值得用

**场景 1：多模型版本灰度发布**
- 创建新 deployment 指向新 config revision，设置 weight=0.1（10% 流量）
- 监控指标稳定后，逐步提高 weight 到 1.0
- 出问题？设置 weight=0 立即下线，无需回滚部署

**场景 2：A/B 测试不同硬件配置**
- 同一模型，一个 deployment 用 H100×4（latency profile），一个用 B200×4（throughput profile）
- 容量感知路由自动根据实际处理能力分配流量
- 通过实测数据（而非猜测）选择最优配置

**场景 3：流量弹性场景**
- 业务高峰时 autoscaler 自动增加 replicas
- 容量感知路由自动将更多流量导向扩容后的 deployment
- 无需手动调整流量比例

**场景 4：影子实验（Shadow Testing）**
- 创建 weight=0 的 deployment，接收镜像流量
- 不影响线上用户，但可以对比新旧版本的输出质量和性能

### 什么场景不值得用

**场景 1：单模型固定流量的简单应用**
- 如果只有一个模型、不需要版本管理、流量稳定 → 直接用共享推理（Shared Inference）更便宜
- Dedicated Inference 的价值在于编排能力，简单场景用不上

**场景 2：超大规模需要完全控制底层**
- 如果需要自定义网络拓扑、跨地域部署、或直接管理 K8s 集群 → vLLM + K8s + KServe 更灵活
- Together 平台抽象了底层，代价是失去了部分控制权

**场景 3：预算极度敏感**
- Dedicated Inference 需要独占 GPU，成本高于共享推理
- 如果预算有限且可以接受排队等待 → 共享推理或自建 vLLM 集群

### 迁移成本

**从共享推理迁移到 Dedicated Inference：**
- 工作量：低。主要改动是模型参数从模型名改为 endpoint 名称
- 代码变更：`model="Qwen/Qwen3.5-9B"` → `model="my-project/my-endpoint"`
- 配置工作：选择 certified profile → 一条命令完成部署
- 风险：低。旧 endpoint 可以保持运行直到新 endpoint 验证通过

**从自建 vLLM/TGI 迁移：**
- 工作量：中等。需要重新设计部署架构
- 主要变化：从管理容器/进程变为管理 endpoint/deployment/config
- 收益：零停机发布、自动弹性、A/B 测试能力
- 风险：中。需要验证性能 benchmark 是否满足要求

## 对你的意义

如果你正在评估生产级 LLM 部署方案，Together AI 的 Dedicated Inference 代表了**推理编排层**的一个重要方向：

1. **它填补了「托管推理 API」和「自建推理集群」之间的空白**。共享推理适合原型和中小流量，自建集群适合大规模但运维成本高。Dedicated Inference 在中间提供了一个有编排能力的托管选项。

2. **容量感知路由是一个值得借鉴的设计模式**。它的核心洞察是：流量分配应该跟随实际处理能力（容量），而不是固定百分比。这个模式可以应用到任何需要弹性扩缩容的服务架构中。

3. **Config 不可变 + Deployment 可丢弃**的设计哲学值得学习。这与 Git 的 commit 模型类似——每次变更都是新对象，旧对象永远有效且可回滚。避免了配置漂移这一经典运维难题。

**建议**：如果你的团队正在构建需要多版本管理、灰度发布能力的 LLM 应用，值得花 1-2 小时跑一遍 quickstart（5 条命令），体验整个流程。benchmark 数据表明它在实际负载下的行为可预测且符合理论预期。

## 关键代码/配置片段

### 一键部署（endpoint + deployment + traffic split）

```bash
tg beta endpoints deploy zai-org/GLM-5.2 \
  --endpoint my-glm-endpoint \
  --config cr_Cd35DNpQuHM3RihtCkN59 \
  --traffic-weight 1
```

### 流量权重调整（零停机）

```bash
# 两个 deployment 各占 50%（按容量）
tg beta endpoints update $DEPLOYMENT_A --traffic-weight 1
tg beta endpoints update $DEPLOYMENT_B --traffic-weight 1

# 将 deployment B 移出流量（不缩减 replicas）
tg beta endpoints update $DEPLOYMENT_B --traffic-weight 0
```

### 客户端调用（endpoint 名称即 model 参数）

```python
resp = client.chat.completions.create(
    model="my-project/my-endpoint",  # endpoint 的限定名称就是 model 字符串
    messages=[{"role": "user", "content": "Hello!"}],
)
```

### Certified Profile 查询

```bash
# 查看模型的认证部署配置
tg beta models configs ml_CcEtnFUbitJYNja6TTR6U

# 返回示例
{
  "profileId": "profile-cabcbcec874c",
  "certifiedConfigRevisionId": "cr_Cd35DNpQuHM3RihtCkN59",
  "gpuType": "NVIDIA-B200",
  "gpuCount": 4,
  "quantization": "FP4",
  "parallelism": "TP4"
}
```

### 优化配置选择器

| Selector | Values | Tradeoff |
|----------|--------|----------|
| `accelerator_type` | H100, H200, B200 | 成本 vs 内存带宽 vs 可用性 |
| `accelerator_count` | 1, 2, 4, 8 | 模型大小 + KV Cache 余量 |
| `optimization` | latency / throughput / balanced | 核心 serving tradeoff |
| `topology` | aggregated / disaggregated | 模型在 GPU 间的切分方式 |

### 实测性能数据（Together AI 官方 benchmark）

```
模型: Qwen3.5-9B (BF16, TP1)
并发  TTFT p95    吞吐量
c=4   362 tok/s   368 ms
c=8   789 tok/s   —
c=16  1,464 tok/s 368 ms (仅上升 ~17%)

模型: Qwen3-VL-8B (BF16, TP1)
并发  TTFT p95    吞吐量
c=4   495 tok/s   323 ms
c=8   243 tok/s   — (吞吐量下降 51%)
c=16  240 tok/s   — (饱和，吞吐量减半)
```

> 数据来源：Together AI 官方博客 post，2026-08-03。Qwen3.5-9B 在并发从 4 增至 16 时吞吐量增长 4 倍且 TTFT 稳定；Qwen3-VL-8B 在并发 4 时更快，但并发 8+ 时饱和。

---
[← Back to Deep Dives](./README.md)
