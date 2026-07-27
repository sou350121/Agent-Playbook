---
auto_generated: true
generated_at: "2026-07-27T06:47:58Z"
source_url: "https://www.36kr.com/p/3906062371263874"
signal_type: "significant_update"
---
# 谷歌 Gemini 4 开跑，一夜三连发 (Google Gemini 4 Training Begins, Triple Release Overnight)

> 🔍 本文由 Moltbot 自动生成 | 2026-07-27
>
> **项目/工具**: Google Gemini 3.6 Flash / 3.5 Flash-Lite / 3.5 Flash Cyber
> **链接**: https://blog.google/innovation-and-ai/models-and-research/gemini-models/gemini-3-6-flash-3-5-flash-lite-3-5-flash-cyber/
> **核心定位**: Google 一夜发布三款 Gemini 模型——3.6 Flash（主力提效）、3.5 Flash-Lite（极速低价）、3.5 Flash Cyber（安全专精），同时宣布 Gemini 4 预训练启动；核心信号是**降低 Agent 运行成本**，让生产级 AI Agent 更快、更聪明、更便宜。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：Google 发布 Gemini 3.6 Flash 等三款模型，核心卖点是**Token 效率大幅提升 + 价格下降**，同时宣布 Gemini 4 预训练启动
- **現在值得用嗎**：是——3.6 Flash 和 3.5 Flash-Lite 即日起可用，价格比前代更低、性能更强
- **適合場景**：多步 Agent 工作流、编码任务（DeepSWE +12pp）、知识工作（文档解析/数据分析）、高频低延迟场景（Flash-Lite 350 tok/s）
- **不適合場景**：需要旗舰推理能力的复杂科学/数学任务（Gemini 3.5 Pro 尚未发布）、网络安全漏洞修复（Flash Cyber 仅限政府/受信任伙伴）
- **與前版核心差異**：3.6 Flash 输出 Token 减少 17%（编码任务最高 65%），价格更低；Flash-Lite 速度 350 tok/s 且性能超越上一代旗舰 3 Flash

## 是什么 / 解决什么问题

生产级 AI Agent 面临三个核心痛点：**Token 消耗过大导致成本失控、推理延迟影响用户体验、多步工作流的可靠性不足**。Google 此次发布的三款模型，每一条都针对这些痛点而来。

Gemini 3.6 Flash 是本次发布的"C位"——它直接回应了开发者对 3.5 Flash 的反馈。关键突破不在于"更强"，而在于**"更省的同时更强"**：按 Artificial Analysis Index 测算，输出 Token 减少 17%；在 DeepSWE 编码基准上最高节省 65%。同时，它完成多步任务需要的推理步骤和工具调用也更少。这意味着 Agent 不仅跑得更快，而且"绕的弯路更少"。

Gemini 3.5 Flash-Lite 走的是另一条路：**极致速度 + 极致低价**。输出速度 350 Token/秒，价格低至输入 $0.3/百万 Token、输出 $2.5/百万 Token。更令人意外的是，它在多项编码和 Agent 测试上击败了体量更大的 Gemini 3 Flash——这种"轻量款反杀旗舰款"的现象，暗示 Google 在模型架构效率上取得了实质性突破。

Gemini 3.5 Flash Cyber 则是安全领域的专精模型，嵌入 CodeMender 代码安全智能体中，专攻漏洞发现和修复。由于技术的"双重用途"性质，它仅限政府和受信任伙伴使用。

与此同时，Google 宣布已启动"史上最激进的一次预训练"——Gemini 4。按 Google 常规的 6 个月训练节奏，年底可能就能看到。

## 技术架构拆解

### 核心设计决策

| 决策 | 理由 | 效果 |
|------|------|------|
| **减少输出 Token 冗余** | 前代模型存在"过度 verbose"问题，多步任务中重复表达 | 输出 Token 减少 17%，编码任务最高 65% |
| **减少推理步骤和工具调用** | 多步 Agent 工作流中不必要的中间步骤增加延迟和成本 | 完成任务更快、更可靠 |
| **Flash-Lite 性能超越上代旗舰** | 架构效率提升 > 模型规模 | Flash-Lite 在 SWE-Bench Pro 上 54.2% vs 3 Flash 的 49.6% |
| **Cyber 模型专精化** | 通用模型在安全任务上精度不足且成本高 | 用更轻的模型，干最需要精度的活 |
| **Computer Use 内置化** | 前代需额外集成，增加开发复杂度 | 3.6 Flash 和 Flash-Lite 均内置 Computer Use 客户端工具 |

### 与前版/竞品的关键差异

| 维度 | Gemini 3.5 Flash | Gemini 3.6 Flash | Gemini 3.5 Flash-Lite |
|------|-----------------|-----------------|----------------------|
| **输入价格** (`/M tok) | 未公布（高于 3.6） | `1.50 | $0.30 |
| **输出价格** (`/M tok) | 未公布（高于 3.6） | `7.50 | $2.50 |
| **输出速度** | 标准 | 标准 | **350 tok/s** |
| **Token 效率** | 基线 | **-17% 输出** | 显著优于 3.1 Flash-Lite |
| **DeepSWE** | 37% | **49%** | N/A |
| **MLE Bench** | 49.7% | **63.9%** | N/A |
| **OSWorld-Verified** | 78.4% | **83.0%** | 74.0% |
| **SWE-Bench Pro** | N/A | N/A | **54.2%** (vs 3 Flash 49.6%) |
| **GDPval-AA v2** | 1349 | **1421** | 1140 |
| **Computer Use** | 需集成 | **内置** | **内置** |
| **可用范围** | 现有 | **即日起** | **即日起** |

### 架构/信息流图

```
                    ┌─────────────────────────────────────┐
                    │       Gemini 4 (预训练中)            │
                    │    "史上最激进预训练" / 预计年底      │
                    └─────────────────────────────────────┘
                                      │
                    ┌─────────────────┴─────────────────┐
                    │                                   │
        ┌───────────┴───────────┐       ┌───────────────┴───────────────┐
        │   Gemini 3.6 Flash    │       │    Gemini 3.5 Flash-Lite      │
        │   (主力 / 效率优先)    │       │    (极速 / 高频处理)           │
        │                       │       │                               │
        │  - 编码任务主力        │       │  - 350 tok/s 输出             │
        │  - Token 减少 17%     │       │  - $0.3/$2.5 per M tok       │
        │  - DeepSWE 49%       │       │  - 击败上代旗舰 3 Flash        │
        │  - Computer Use 内置  │       │  - 文档处理 / Agent 搜索       │
        └───────────┬───────────┘       └───────────────┬───────────────┘
                    │                                   │
        ┌───────────┴───────────┐       ┌───────────────┴───────────────┐
        │  Gemini 3.5 Pro       │       │   Gemini 3.5 Flash Cyber      │
        │  (旗舰 / 测试中)       │       │   (安全专精 / 受限访问)        │
        │                       │       │                               │
        │  - 尚未发布           │       │  - 漏洞发现与修复             │
        │  - Partner testing    │       │  - CodeMender 集成            │
        └───────────────────────┘       │  - 仅政府/受信任伙伴          │
                                        └───────────────────────────────┘
```

**多智能体编排模式**（官方演示）：

```
  ┌─────────────────┐
  │  3.6 Flash      │  ← "主脑"：拆解复杂任务、制定策略
  │  (Workhorse)    │
  └────────┬────────┘
           │ 分发子任务
    ┌──────┼──────┬────────┐
    ▼      ▼      ▼        ▼
 ┌────┐ ┌────┐ ┌────┐  ┌────┐
 │Lite│ │Lite│ │Lite│  │Lite│  ← "分身"：批量执行子任务
 └────┘ └────┘ └────┘  └────┘
 350tok/s 极速并行，抹平高并发压力
```

## 实用评估

### 什么场景值得用

| 场景 | 推荐模型 | 理由 |
|------|---------|------|
| **编码 Agent（代码迁移/PR 生成）** | 3.6 Flash | DeepSWE 37%→49%，Token 节省最高 65%，直接降低编码 Agent 成本 |
| **ML 研究自动化** | 3.6 Flash | MLE Bench 49.7%→63.9%，显著提升 ML 研究任务成功率 |
| **Computer Use / 桌面自动化** | 3.6 Flash | OSWorld-Verified 78.4%→83.0%，内置 Computer Use 工具 |
| **高频文档处理** | 3.5 Flash-Lite | 350 tok/s 速度 + $2.5/M tok 输出价格，走量场景成本极低 |
| **Agent 搜索 / 实时查询** | 3.5 Flash-Lite | 低延迟 + 高性价比，适合高并发 Agent 搜索 |
| **多智能体编排** | 3.6 Flash + Flash-Lite 组合 | 主脑拆解 + 分身执行，官方已演示 25 套设计方案批量生成 |
| **代码安全审计** | 3.5 Flash Cyber (受限) | CyberGym SOTA，但仅限政府/受信任伙伴 |

### 什么场景不值得用

| 场景 | 原因 |
|------|------|
| **需要旗舰推理能力的复杂任务** | Gemini 3.5 Pro 尚未发布，当前 Flash 系列定位效率而非极致推理 |
| **通用网络安全漏洞修复** | Flash Cyber 仅限政府和受信任伙伴，普通人暂时无法使用 |
| **对价格极度敏感但质量要求不高的场景** | Flash-Lite 虽然便宜，但如果只需要基础能力，更老的模型可能已有更低价格 |
| **需要最长上下文窗口的任务** | 官方未公布上下文窗口变化，如有超长文档需求需验证 |

### 迁移成本

| 迁移路径 | 工作量 | 说明 |
|----------|--------|------|
| **3.5 Flash → 3.6 Flash** | 极低 | API 兼容，只需修改模型名称；Token 效率自动提升 |
| **3.1 Flash-Lite → 3.5 Flash-Lite** | 极低 | API 兼容，性能全面提升（Terminal-Bench 31%→54%） |
| **其他模型 → Gemini Flash 系列** | 中等 | 需适配 Gemini API，但 Google AI Studio 和 Gemini Enterprise 提供完整工具链 |
| **引入多智能体编排** | 中高 | 需设计任务拆解逻辑和子任务分发机制，但官方有演示参考 |

## 对你的意义

这个变化对 AI 应用开发者的核心意义是：**生产级 Agent 的运行成本正在快速下降**。

具体来看：

1. **如果你的 Agent 涉及编码任务**（代码迁移、PR 生成、bug 修复），3.6 Flash 的 DeepSWE 从 37% 提升到 49%，同时 Token 消耗降低 65%——这意味着**质量和成本双向优化**，值得立即切换。

2. **如果你在做高频 Agent 场景**（文档批量处理、实时搜索、多路并发），Flash-Lite 的 350 tok/s + $2.5/M tok 输出价格提供了一个新的成本基准。用它替换之前的主力模型，可能实现数量级的成本下降。

3. **多智能体编排的"主脑+分身"模式**值得重点关注。3.6 Flash 负责拆解和决策，Flash-Lite 负责批量执行——这种架构组合可能是未来 Agent 系统的标准范式。

4. **Gemini 4 的信号**：Google 宣布"史上最激进预训练"，暗示下一代模型将有显著架构变化。如果你在做长期技术选型，需要关注 Gemini 4 的发布时间线（预计年底）。

**建议**：立即将 3.6 Flash 纳入编码 Agent 的候选模型进行 A/B 测试；将 Flash-Lite 用于高频低延迟场景的压力测试。

## 关键代码/配置片段

以下为 Google 官方文档中的关键信息摘录：

**定价对比**（来源：Google Blog）：

```
Gemini 3.6 Flash:
  Input:  $1.50 / 1M tokens
  Output: $7.50 / 1M tokens

Gemini 3.5 Flash-Lite:
  Input:  $0.30 / 1M tokens
  Output: $2.50 / 1M tokens
```

**性能基准**（来源：Google Blog + Artificial Analysis Index）：

```
编码能力:
  DeepSWE:        3.5 Flash 37% → 3.6 Flash 49%  (+12pp, Token -65%)
  SWE-Bench Pro:  3 Flash 49.6% → 3.5 Flash-Lite 54.2%  (轻量款超越旗舰)

ML 研究:
  MLE Bench:      3.5 Flash 49.7% → 3.6 Flash 63.9%  (+14.2pp)

Computer Use:
  OSWorld-Verified: 3.5 Flash 78.4% → 3.6 Flash 83.0%

知识工作:
  GDPval-AA v2:   3.5 Flash 1349 → 3.6 Flash 1421
```

**获取方式**（来源：Google Blog）：

```
开发者:
  - Google AI Studio: https://aistudio.google.com/prompts/new_chat?model=gemini-3.6-flash
  - Android Studio
  - Google Antigravity (3.6 Flash)

企业:
  - Gemini Enterprise Agent Platform
  - Gemini Enterprise app

通用用户:
  - Gemini app (3.5 Flash-Lite 已上线)
  - Google Search (3.5 Flash-Lite 陆续接入)
```

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-005: AI 工作流自动化成为企业 AI 最快增长场景 | 支持 | Google 明确将三款模型定位为"生产级 AI Agent"优化，价格/效率双降直接降低 Agent 部署门槛 |
| A-003: 多 Agent 协作框架从实验走向工程实践 | 支持 | 官方演示"3.6 Flash 主脑 + Flash-Lite 分身"多智能体编排模式，从概念验证走向生产推荐 |

---
[← Back to Deep Dives](./README.md)
