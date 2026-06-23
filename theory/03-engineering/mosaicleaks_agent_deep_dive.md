---
auto_generated: true
generated_at: "2026-06-23T05:47:05Z"
source_url: "https://huggingface.co/blog/ServiceNow/mosaicleaks"
signal_type: "significant_update"
---
# MosaicLeaks：Agent 能否保守秘密？（MosaicLeaks: Can Your Research Agent Keep a Secret?）

> 🔍 本文由 Moltbot 自动生成 | 2026-06-23
>
> **项目/工具**: MosaicLeaks 基准测试 + PA-DR 训练方法
> **链接**: https://huggingface.co/blog/ServiceNow/mosaicleaks
> **论文**: https://arxiv.org/abs/2605.30727
> **核心定位**: ServiceNow 与 Hugging Face 联合研究，首次系统量化了 Deep Research Agent 在开放环境中通过查询日志泄露企业机密的「马赛克效应」，并提出了一种 RL 训练方法将信息泄露率从 34% 降至 9.9%。

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句話定位**：MosaicLeaks 是首个系统评估 Deep Research Agent 隐私泄露的基准测试；PA-DR 是一种结合任务奖励 + 隐私奖励的 RL 训练方法
- **現在值得用嗎**：是 — 如果你在构建或部署需要访问私有文档 + 外部工具的 research agent，这是目前唯一可量化的隐私评估框架
- **適合場景**：企业 research agent（医疗/金融/法律等敏感领域）；需要同时访问内部文档和外部 web 的多跳问答系统；Agent 安全评估流程
- **不適合場景**：纯本地 agent（不对外发查询）；单跳问答系统；不需要量化隐私风险的场景
- **與 [前版] 核心差異**：之前只能靠 prompt 指令让 agent「别泄露」，效果微弱且不一致；PA-DR 通过 RL 训练让 agent 真正学会安全搜索，泄露率降低 3 倍以上

## 是什么 / 解决什么问题

Deep Research Agent 的工作模式越来越复杂：它们需要同时访问企业私有文档（内部报告、财务数据、客户信息）和外部工具（web 搜索、API 调用）。一个看似无害的 web 查询，如果携带了来自私有文档的上下文片段，就可能被外部观察者拼接出完整的机密信息——这就是**马赛克效应（Mosaic Effect）**。

MosaicLeaks 的核心发现是：**你无法通过 prompt 让 agent 学会隐私保护，你必须通过训练让它学会。** 仅仅在 prompt 中加上「不要泄露私有信息」的指令，泄露率仅从 34.0% 降到 25.5%，且任务成功率还下降了。更令人警觉的是：单纯优化任务性能的 RL 训练反而让泄露更严重——从 34.0% 飙升到 51.7%，因为模型学会了在查询中携带更多上下文来提高检索精度，但这恰恰加剧了隐私风险。

MosaicLeaks 基准测试包含 1,001 条多跳研究链，覆盖 559 条训练链、98 条验证链、344 条测试链。每条链交替穿插本地私有文档查询和公开 web 查询，前一步的答案成为下一步的桥接实体，模拟真实企业中 agent 必须依赖内部信息才能发起有效外部搜索的场景。

## 技术架构拆解

### 核心设计决策

**1. 三层泄露度量体系**

| 泄露类型 | 观察者能看到什么 | 什么算泄露 |
|---------|----------------|-----------|
| Intent（意图泄露） | 仅 web 查询日志 | 观察者能推断出 agent 正在调查的私有研究问题或目标 |
| Answer（答案泄露） | web 查询日志 + 私有问题 | 观察者能在不看私有文档的情况下回答私有问题 |
| Full-information（全信息泄露） | 仅 web 查询日志 | 观察者能陈述可验证为真的私有事实，即使没人告诉他该找什么 |

三层递进：Intent 暴露「你在查什么」，Answer 暴露「具体答案是什么」，Full-information 是最强攻击——观察者能主动发现私有事实。

**2. 情境奖励（Situational Rewards）替代结果奖励**

传统 RL 对整个 trajectory 给一个最终分数，信用分配极其稀疏——成功轨迹可能强化了一个泄露的搜索步骤，失败轨迹可能惩罚了一个局部正确的决策。PA-DR 改为**情境奖励**：将每个 model call 与同阶段、同 hop、同可用信息的其他 call 比较。Plan call 奖励搜索正确来源并检索到正确文档；Choose call 奖励选择了包含答案的文档。这种设计有两个关键优势：
- 信用分配精确到每个决策步骤
- 样本效率提升 5-6 倍（达到 55% 任务成功率仅需 14.6 万样本 vs 结果奖励的 96.3 万）

**3. 学习型隐私奖励**

当 agent 产生 web 查询时，一个 Qwen3-4B 分类器实时评估两个风险：
- 当前查询是否直接泄露私有信息
- 将当前查询加入已有查询日志后是否产生新的马赛克泄露

PA-DR 取两者中较大的风险值作为惩罚，确保隐私成本落在「使查询日志更具揭示性」的那个具体规划决策上。

### 与前版/竞品的关键差异

| 维度 | Prompt 指令法 | 纯任务 RL | PA-DR（本文方法） |
|------|-------------|----------|------------------|
| Strict Chain Success | 44.5%（下降） | 59.3%（↑） | 58.7%（≈纯任务） |
| Answer/Full-info Leakage | 25.5%（微降） | 51.7%（↑↑） | 9.9%（↓↓） |
| 查询行为变化 | 减少查询数量 | 查询携带更多上下文 | 查询数量增加但去除敏感细节 |
| 隐私机制 | 指令遵从 | 无 | RL 内化 |
| 样本效率 | N/A | 基准 | 5-6x 提升 |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────┐
│                  Agent Harness (DRBench)             │
│                                                      │
│  ┌──────┐   ┌───────┐   ┌──────┐   ┌────────┐      │
│  │ Plan │→  │Search │→  │Choose│→  │  Read  │      │
│  └──────┘   └───────┘   └──────┘   └────────┘      │
│                                            │         │
│  ┌──────┐                                  ▼         │
│  │Resolve│←──────────────────────────── [Answer]     │
│  └──────┘                                             │
│       │                                               │
│       ▼ (web queries go external)                     │
│  ┌──────────────────────┐                             │
│  │  Adversary Observer   │                            │
│  │  (sees only query log)│                            │
│  │  → tries to infer     │                            │
│  │    private facts      │                            │
│  └──────────────────────┘                             │
└─────────────────────────────────────────────────────┘
         │
         ▼ (during PA-DR training)
┌─────────────────────────────────────────┐
│  Reward Computation                     │
│                                         │
│  Situational Task Reward:               │
│    Plan → correct source retrieval      │
│    Choose → correct doc selection       │
│                                         │
│  Privacy Reward (Qwen3-4B classifier):  │
│    Direct leak risk + Mosaic leak risk  │
│    → penalize the larger of two         │
└─────────────────────────────────────────┘
```

## 实用评估

### 什么场景值得用

- **企业 Research Agent 安全审计**：如果你的 agent 需要同时访问内部文档和外部工具（web 搜索、API），MosaicLeaks 是目前唯一可量化的隐私泄露评估框架。在部署前用 344 条测试链跑一遍，能得到具体的泄露率数字
- **Agent RL 训练管线**：PA-DR 的情境奖励设计对任何需要多步决策的 agent 训练都有参考价值——5-6x 的样本效率提升意味着训练成本的大幅降低
- **合规场景**：医疗、金融、法律等行业的 agent 部署正面临越来越严格的隐私合规要求。PA-DR 的方法论（将隐私作为可训练的 reward 而非 prompt 指令）为合规提供了技术路径
- **Agent 安全评估产品**：MosaicLeaks 的三层泄露度量体系可以作为 Agent 安全评估产品的核心指标体系

### 什么场景不值得用

- **纯本地 agent**：如果 agent 不对外发起任何查询（不 web search、不调外部 API），不存在马赛克泄露通道
- **单跳问答**：MosaicLeaks 针对多跳推理场景。单跳问答没有「查询日志累积」的问题
- **Prompt-only 方案已够用的场景**：如果业务对隐私风险容忍度较高，prompt 指令的 25.5% 泄露率可能已经足够
- **资源受限环境**：PA-DR 需要训练一个 Qwen3-4B 隐私分类器作为 reward model，还需要 RL 训练管线。这对小团队来说是一个不小的工程投入

### 迁移成本

- **评估集成**：将 MosaicLeaks 基准测试集成到现有 agent 评估管线中，主要工作是将 agent 适配到 DRBench-style harness，预计 1-2 周
- **训练集成**：如果要采用 PA-DR 的训练方法，需要搭建 RL 训练管线（包括情境奖励计算和隐私分类器），预计 3-4 周工程投入
- **推理部署**：训练好的模型可以直接部署，隐私分类器仅在训练时需要，推理阶段无额外开销

## 对你的意义

这篇研究对 Ken 的 AI 应用开发方向有直接关联：

1. **Agent 安全评估正在成为硬需求**。MosaicLeaks 是 ServiceNow（企业级 agent 厂商）与 Hugging Face 的联合研究，信号很明确——企业级 agent 部署中，隐私泄露不再是「最好有」而是「必须有」的评估维度。这与你假设 A-002（Agentic Coding 在初级任务达 80% 成功率）和 A-003（多 Agent 协作框架从实验走向工程实践）直接相关——当 agent 从实验走向工程，安全评估就是必经之路。

2. **RL 训练 agent 的隐私维度**。Ken 的团队方向之一是 RL 训练 VLA，PA-DR 的情境奖励设计方法论（step-level credit assignment vs trajectory-level）对 VLA 训练也有参考价值——多步决策中的信用分配是一个通用问题。

3. **Agent 安全工具链的机会**。MosaicLeaks 暴露了一个明确的工具链缺口：市场上还没有成熟的 Agent 隐私评估 SaaS。如果 Agent 部署越来越普遍，这个方向的工具产品会有需求。

**建议**：关注但不急于行动。MosaicLeaks 目前是一个受控基准（合成文档、固定 web 语料），离真实部署评估还有一段距离。但方法论值得深入理解——特别是情境奖励的设计思路。

## 关键数据引用

以下是论文中的核心数据（来源：Hugging Face blog post，2026-06-23）：

```
方法对比（Qwen3-4B）：

Base Model:
  Strict Chain Success: 48.7%
  Answer/Full-info Leakage: 34.0%

+ Prompt 指令:
  Strict Chain Success: 44.5%  (下降!)
  Answer/Full-info Leakage: 25.5%  (微降)

+ 纯任务 RL:
  Strict Chain Success: 59.3%  (提升)
  Answer/Full-info Leakage: 51.7%  (恶化!)

+ PA-DR (任务 + 隐私 RL):
  Strict Chain Success: 58.7%  (保持)
  Answer/Full-info Leakage: 9.9%  (降低 3.4x)
```

```
样本效率对比（达到 55% strict chain success 所需样本）：

Outcome Reward:         963k samples
Situational Task Reward: 146k samples  (6.6x 更高效)
Task + PA-DR Reward:    183k samples
```

> TODO: 论文中提到的 BrowseComp-Plus 和 DRBench 的具体细节未在 blog 中展开，需阅读完整论文 (arXiv:2605.30727) 获取数据集构建细节。
>
> TODO: PA-DR 在其他模型（如更大参数规模）上的泛化能力未在 blog 中讨论。
>
> TODO: 实际部署环境中 web 查询日志的泄露风险量化尚未有公开研究。

---
[← Back to Deep Dives](./README.md)
