---
auto_generated: true
generated_at: "2026-03-10T06:46:20Z"
source_url: "https://www.together.ai/blog/ai-native-conf-research-and-product-announcements"
signal_type: "significant_update"
---
# Together AI AI Native Conf：FlashAttention-4 与 ThunderAgent (Together AI AI Native Conf: FlashAttention-4 and ThunderAgent)

> 🔍 本文由 Moltbot 自动生成 | 2026-03-10
>
> **项目/工具**: Together AI AI Native Cloud
> **链接**: https://www.together.ai/blog/ai-native-conf-research-and-product-announcements
> **核心定位**: Together 在首届 AI Native Conf 发布 7 项研究/产品更新，覆盖 Kernels、RL 训练、推理优化三大方向，将 FlashAttention、ThunderKittens 等研究成果直接转化为生产级基础设施

---

## ⚡ 快速判斷（30 秒讀完這段就夠了）

- **一句話定位**：Together 将自家研究成果（FlashAttention、ThunderKittens 团队）直接产品化，提供从 kernel 优化到 agentic 训练的全栈 AI 基础设施
- **現在值得用嗎**：是 — 若你在跑大规模推理/RL 训练/长上下文 agent 工作负载，性能提升显著（2-4x）
- **適合場景**：长上下文推理（视频理解、coding agents）、RL 训练 rollout、实时语音 agent、多步 agentic 工作流
- **不適合場景**：小规模部署（<100 QPS）、无 GPU 集群的单机场景、预算有限无法使用 Dedicated Container Inference
- **與 [競品/前版] 核心差異**：研究团队直接运营生产系统（Tri Dao 团队），从论文到部署的转化周期远短于纯基础设施公司

---

## 是什么 / 解决什么问题

Together AI 在 2026 年首届 AI Native Conf 上发布了 7 项研究及产品更新，核心理念是"AI Native Cloud"——由实际交付过 FlashAttention、ThunderKittens 等基础研究的团队运营生产系统。这种"研究→生产"的短路径让 Together 能快速将学术突破转化为客户可用的性能提升。

这次发布覆盖三个方向：

1. **Kernels**：FlashAttention-4、Together Megakernel、together.compile
2. **Reinforcement Learning**：RL API、ThunderAgent
3. **Algorithmic Inference Optimizations**：ATLAS-2、Cache-aware Prefill-Decode Disaggregation (CPD)

核心解决的问题是：现有 AI 基础设施无法充分利用新硬件（如 NVIDIA Blackwell）的潜力，且 agentic 工作负载（多步推理、工具调用）在传统无状态推理系统中效率极低。Together 的解决方案是硬件 - 软件协同设计 + 程序感知的调度抽象。

---

## 技术架构拆解

### 核心设计决策

| 技术 | 核心设计决策 | 设计理由 |
|------|-------------|---------|
| FlashAttention-4 | 新算法 + kernel 协同设计，针对 Blackwell GPU 优化 | 移除新瓶颈，保持 tensor cores 忙碌 |
| Together Megakernel | 单 kernel 运行整个模型，针对 HBM 带宽上限优化 | 减少 kernel 启动开销，接近理论带宽上限 |
| together.compile | 启动时自动生成优化 kernel 栈，无需修改模型代码 | 降低 kernel 优化门槛，自动化专家级调优 |
| ThunderAgent | 将 agentic 工作流作为一等调度单元（first-class scheduling unit） | 解决 KV cache thrashing、跨节点内存不平衡、工具生命周期管理三大问题 |
| ATLAS-2 | 在线训练 flywheel，用接受/拒绝的 token 持续更新 speculator | 避免静态 speculator 随流量分布变化而性能退化 |
| CPD | 三级 KV-cache 层次（GPU 内存/主机 DRAM/集群分布式缓存）+ 缓存感知路由 | 分离冷/暖请求，避免大冷 prompt 阻塞多轮对话请求 |

### 与前版/竞品的关键差异

| 维度 | 传统方案 / 竞品 | Together 方案 |
|------|----------------|--------------|
| 注意力引擎 | Triton / cuDNN 9.13 | FlashAttention-4（2.7x vs Triton, 1.3x vs cuDNN） |
| 实时语音延迟 | 281ms (B200 GPU) | 77ms (3.6x 提升) |
| Kernel 优化 | 需要 GPU 专家手动调优 | together.compile 自动生成（Flux 基准 41% 提升） |
| RL 训练瓶颈 | rollout 占 70% 时间，无专门优化 | RL API 集成 speculative decoding + ThunderAgent |
| Agentic 推理 | 无状态请求序列，KV cache 频繁失效 | ThunderAgent 程序感知调度（1.5-3.6x 吞吐） |
| Speculative Decoding | 离线训练静态 speculator，性能随时间退化 | ATLAS-2 在线训练，持续适应流量分布（额外 1.2x） |
| 长上下文推理 | 冷/暖请求竞争同一预填充容量 | CPD 三级缓存 + 路由（35-40% QPS 提升） |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────────────┐
│                    Together AI Native Cloud                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐       │
│  │   Kernels    │    │      RL      │    │  Inference   │       │
│  │              │    │              │    │  Optimizations│      │
│  │ • FA-4       │    │ • RL API     │    │ • ATLAS-2    │       │
│  │ • Megakernel │    │ • ThunderAgent│   │ • CPD        │       │
│  │ • compile    │    │              │    │              │       │
│  └──────────────┘    └──────────────┘    └──────────────┘       │
│         │                   │                   │                │
│         └───────────────────┼───────────────────┘                │
│                             │                                    │
│                    ┌────────▼────────┐                           │
│                    │  Production     │                           │
│                    │  Deployment     │                           │
│                    │  (Cursor,       │                           │
│                    │   Decagon,      │                           │
│                    │   Hedra)        │                           │
│                    └────────┬────────┘                           │
│                             │                                    │
│                    ┌────────▼────────┐                           │
│                    │  Research       │                           │
│                    │  Feedback Loop  │                           │
│                    │  → Next Cycle   │                           │
│                    └─────────────────┘                           │
└─────────────────────────────────────────────────────────────────┘

ThunderAgent Agentic Workflow Scheduling:
┌─────────────────────────────────────────────────────────┐
│  Traditional (Stateless Requests)                       │
│  Request 1 → KV Compute → Tool Call → KV Thrash        │
│  Request 2 → KV Compute → Tool Call → KV Thrash        │
│  Result: Repeated context recomputation                 │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│  ThunderAgent (Program-Aware)                           │
│  Workflow A ─┬→ KV Cache (Shared) → Tool Lifecycle Mgmt │
│              └→ Cross-Node Balance → 1.5-3.6x Throughput│
│  Result: Context preserved across tool calls            │
└─────────────────────────────────────────────────────────┘
```

---

## 实用评估

### 什么场景值得用

| 场景 | 理由 | 预期收益 |
|------|------|---------|
| 长上下文推理（100K+ tokens） | CPD 三级缓存 + 缓存感知路由 | 35-40% QPS 提升，冷请求从秒级降至数百毫秒 |
| 实时语音 Agent | Megakernel 单 kernel 实现 | 281ms → 77ms，满足<100ms 硬约束 |
| RL 训练（rollout 密集型） | RL API + ThunderAgent + speculative decoding | rollout 占 70% 时间，1.8-3.9x 加速 |
| 多步 agentic 工作流（coding agents、科学发现） | ThunderAgent 程序感知调度 | 1.5-3.6x 吞吐，4.2x 磁盘内存节省 |
| 视频/图像生成规模化 | together.compile 自动 kernel 优化 | Flux 基准 41% 提升，启动时间降低 |

### 什么场景不值得用

| 场景 | 理由 |
|------|------|
| 小规模部署（<100 QPS） | 性能提升无法抵消 Dedicated Container Inference 成本 |
| 单机/无 GPU 集群 | 所有优化针对多 GPU 分布式环境设计 |
| 短期/一次性任务 | 需要持续流量才能发挥 ATLAS-2 在线训练优势 |
| 预算有限 | Together 定位高端生产环境，非入门级选择 |
| 简单问答机器人（无工具调用、无长上下文） | ThunderAgent/CPD 优势无法体现 |

### 迁移成本

从现有部署迁移到 Together 的方案：

1. **Kernels 层（FlashAttention-4/Megakernel）**：
   - 若已用 Together 平台：几乎零成本，自动受益
   - 若自建：需迁移到 Together Dedicated Container Inference
   - 工作量：1-2 周（环境适配 + 基准测试）

2. **ThunderAgent**：
   - 开源可用，但需适配现有 agent 框架
   - 需将工作流定义为"程序感知"单元（而非独立请求序列）
   - 工作量：2-4 周（取决于 agent 架构复杂度）

3. **ATLAS-2 / CPD**：
   - 需使用 Together 平台，无法独立部署
   - 迁移主要是流量切换 + 监控配置
   - 工作量：3-5 天

---

## 对你的意义

### 对 VLA 研究的启示

ThunderAgent 解决的三大问题（KV cache thrashing、跨节点内存不平衡、工具生命周期管理）在 VLA 系统中同样存在：

- VLA 的多步推理（感知→规划→执行）本质是 agentic 工作流
- 触觉 - 视觉融合需要长上下文保持
- 机器人工具（末端执行器、传感器）需要生命周期管理

**建议**：关注 ThunderAgent 开源实现，评估是否可适配 VLA 训练/推理管线。

### 对 AI 应用开发的启示

1. **Agent 框架选型**：若框架不支持"程序感知调度"，在长工作流下会遭遇性能悬崖
2. **RAG 系统**：CPD 的缓存感知路由思想可借鉴到文档检索层（热/冷查询分离）
3. **评估基准**：Together 的 benchmark 方法（混合冷/暖请求、真实流量分布）比单一 QPS 更有参考价值

### 具体建议

| 行动 | 优先级 | 理由 |
|------|-------|------|
| 阅读 ThunderAgent 论文 (arXiv:2602.13692) | 高 | 开源可用，直接启发 agent 架构设计 |
| 评估 Together Dedicated Container Inference | 中 | 若当前推理成本>性能诉求，值得 benchmark |
| 关注 together.compile beta | 低 | 尚未公开，但代表 kernel 优化自动化趋势 |
| 在 Agent-Playbook 记录 ThunderAgent 模式 | 高 | 可沉淀为"Agentic Scheduling"设计模式 |

---

## 关键代码/配置片段

### ThunderAgent 核心抽象（伪代码，基于论文描述）

```python
# Traditional: stateless requests
for request in requests:
    kv_cache = compute_kv(request.context)
    output = model.generate(kv_cache, request.prompt)
    # KV cache discarded after each request

# ThunderAgent: program-aware workflow
workflow = AgentWorkflow(id="coding_session_123")
workflow.set_context(shared_context)  # Persisted across tool calls

for step in workflow.steps:
    if step.requires_tool:
        tool_result = await workflow.call_tool(step.tool_spec)
        # KV cache preserved, tool lifecycle tracked
    else:
        output = await workflow.generate(step.prompt)
    
    workflow.update_state(output)

# Cleanup: ThunderAgent reclaims Docker sandboxes/ports automatically
workflow.complete()
```

### CPD 路由逻辑（简化）

```python
def route_request(request):
    cache_hit_rate = kv_cache.check_hit_rate(request.context_hash)
    
    if cache_hit_rate > 0.8:
        # Warm request: fetch KV blocks via RDMA
        return PREFILL_NODES_WARM
    elif cache_hit_rate > 0.3:
        # Partial hit: hybrid path
        return PREFILL_NODES_HYBRID
    else:
        # Cold request: compute new context
        return PRE_PREFILL_NODES_COLD
```

---

## 📌 AI Agent 假设追踪

*当前候选无 assumption_matches，跳过此段。*

---

## 总结

Together 此次发布不是零散的产品更新，而是一个完整的技术栈演进：

1. **底层**：FlashAttention-4、Megakernel 提供硬件级性能
2. **中层**：together.compile、RL API 降低使用门槛
3. **上层**：ThunderAgent、ATLAS-2、CPD 解决特定工作负载痛点

核心护城河不是单一技术，而是"研究→生产→反馈→研究"的飞轮速度。当 FlashAttention 团队直接运营生产系统时，从论文到部署的周期从"年"缩短到"月"。

对 Ken 的 Agent-Playbook 而言，ThunderAgent 的程序感知调度思想值得单独写一篇设计模式——它解决了当前 agent 框架普遍忽视的"跨请求状态管理"问题。

---

[← Back to Deep Dives](./README.md)
