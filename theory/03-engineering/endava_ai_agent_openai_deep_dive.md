---
auto_generated: true
generated_at: "2026-06-11T03:32:05Z"
source_url: "https://openai.com/index/endava-frontiers"
signal_type: "significant_update"
---
# Endava 全面围绕 AI Agent 重构软件交付：OpenAI 企业平台嵌入全生命周期 (Endava Redesigns Software Delivery Around AI Agents)

> 🔍 本文由 Moltbot 自动生成 | 2026-06-11
>
> **项目/工具**: Endava DavaFlow + OpenAI Enterprise Platform
> **链接**: https://openai.com/index/endava-frontiers/
> **核心定位**: 全球 11,000 人技术服务商 Endava 以 OpenAI 企业平台（ChatGpt Enterprise + Codex）为核心，将 AI Agent 嵌入软件交付全生命周期——从需求分析到部署运维，从工程团队到法务/商业/管理层——打造"AI-native"软件交付模式

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**: Endava 是首个公开披露的、将 AI Agent 全面嵌入软件交付全生命周期的企业级案例——不是"用 AI 写代码"，而是"用 Agent 重构整个交付流程"
- **现在值得用吗**: 是 — 如果你在企业级软件服务/IT 外包/咨询行业，这是一个可参考的 AI 转型路线图
- **适合场景**: 大型软件交付团队（500+ 人）的 AI 转型参考、企业级 Agent 编排架构设计、非技术团队 AI 采纳策略
- **不适合场景**: 小型团队（<50 人）直接照搬（Endava 有 11,000 人和 25 年积累）、需要实时 Agent 推理的超低延迟场景
- **与前版/竞品核心差异**: 不同于 GitHub Copilot 只覆盖编码阶段，Endava 将 Agent 嵌入需求→规划→开发→部署→法务→商业的全链路；不同于传统"AI 试点项目"，这是 CTO 级别的企业级战略转型

## 是什么 / 解决什么问题

Endava 是一家 25 年历史的全球技术服务平台，服务全球企业客户，拥有 11,000 名员工。在 AI 浪潮下，Endava 面临一个根本性问题：**当 AI 能大幅提升工程产出时，软件交付的瓶颈从"写代码"转移到了"需求分析、业务规划、利益相关方协调"**。

CTO Matthew Cloke 的原话点出了核心矛盾："我们开始挑战自己：我们能不能更快地产出需求？能不能更快地为客户产出正确的业务解决方案？"

传统的 AI 采纳路径是"给开发者加一个 Copilot"，但这只解决了编码环节。Endava 的选择是更激进的路径：**以 OpenAI 企业平台（ChatGPT Enterprise + Codex）为底座，将 AI Agent 嵌入 DavaFlow 软件交付全生命周期**——从会议准备、业务规划、产品发现、软件工程到部署，"没有 DavaFlow 的任何一个环节不使用 OpenAI 技术"。

更关键的是，Endava 将 AI 采纳从工程团队扩展到了法务（AI 辅助研究和文档）、项目管理（Codex 生成治理报告）、商业团队（用 AI 生成交互式定价应用替代电子表格）。

## 技术架构拆解

### 核心设计决策

| 设计选择 | 具体方案 | 理由 |
|---------|---------|------|
| 平台选择 | OpenAI 企业平台（ChatGPT Enterprise + Codex） | 端到端企业级安全 + Codex Agent 能力 + 长期合作关系 |
| 嵌入范围 | DavaFlow 全生命周期（需求→规划→开发→部署→法务→商业） | 编码只是瓶颈的局部，需端到端重构 |
| 采纳策略 | 行为变革优先于技术部署 | "Treat AI adoption as a behavior change, not a software rollout" |
| 领导驱动 | CTO 级别带头使用，AI 能力纳入招聘/晋升标准 | 自上而下推动，避免"试点陷阱" |
| 非技术团队优先 | 法务、PM、商业团队早期介入 | 打破"AI 只是工程师的事"的认知壁垒 |

### 与典型 AI 采纳路径的关键差异

| 维度 | 典型 AI 采纳路径 | Endava 路径 |
|------|----------------|-------------|
| 覆盖范围 | 仅工程团队（编码辅助） | 全团队（工程 + 法务 + PM + 商业 + 管理层） |
| 工具定位 | 效率工具（Copilot 类） | 操作系统（"AI is becoming the operating model itself"） |
| 采纳方式 | 软件部署 + 培训 | 行为变革 + 领导示范 + 实验文化 |
| 成功指标 | 编码速度提升 | 软件交付全链路加速 |
| 组织要求 | IT 部门推动 | CTO 级别战略 + 全员 AI 能力考核 |
| Agent 使用 | 开发者个人使用 | "If I don't have an agent running in the background, I'm wasting my time" |

### DavaFlow 生命周期中的 Agent 嵌入

```
┌─────────────────────────────────────────────────────────────┐
│                    DavaFlow Lifecycle                       │
├──────────┬──────────┬──────────┬──────────┬────────────────┤
│  会议准备 │ 业务规划  │ 产品发现  │ 软件工程  │    部署运维    │
│  Agent   │  Agent   │  Agent   │  Agent   │    Agent       │
│  摘要/议程│ 需求生成  │ 用户研究  │ Codex    │  自动化监控    │
│  自动生成│  自动化   │  分析     │  编码    │                │
├──────────┴──────────┴──────────┴──────────┴────────────────┤
│              OpenAI Enterprise Platform (底座)              │
│         ChatGPT Enterprise  │  Codex Agent  │  安全层        │
├─────────────────────────────────────────────────────────────┤
│  扩展层: 法务研究 │ PM治理报告 │ 商业定价应用 │ 领导决策摘要   │
└─────────────────────────────────────────────────────────────┘
```

## 实用评估

### 什么场景值得参考

- **大型软件服务商/IT 外包企业**: Endava 的模式（11,000 人、全球交付、企业客户）与许多大型 IT 服务企业高度相似，可直接参考其转型路径
- **企业级 Agent 编排架构**: Endava 展示了如何将多个 Agent（编码 Agent、报告生成 Agent、沟通 Agent）组合到统一工作流中——这是 A-003（多 Agent 协作框架从实验走向工程实践）的活案例
- **非技术团队的 AI 采纳**: 法务用 AI 做研究、PM 用 Codex 生成治理报告、商业团队用 AI 替代电子表格——这些场景适用于任何知识密集型组织
- **领导驱动的 AI 文化**: "Leaders need to actively use AI to drive organization-wide adoption"——CTO 公开说"后台没有 Agent 跑就是在浪费时间"，这种示范效应远超任何培训

### 什么场景不值得参考

- **小型团队（<50 人）**: Endava 的转型建立在 25 年积累和 11,000 人规模上，小团队直接照搬可能过度工程化
- **需要特定 Agent 框架的场景**: Endava 使用的是 OpenAI 原生平台（ChatGPT Enterprise + Codex），如果你需要 LangGraph、CrewAI 等开源框架的可定制性，这个案例参考价值有限
- **预算敏感型组织**: OpenAI 企业平台 + Codex 的成本结构对中小企业可能不经济

### 迁移成本估算

| 阶段 | 主要工作 | 预估工作量 |
|------|---------|-----------|
| 平台接入 | OpenAI 企业账号 + SSO 集成 + 安全策略 | 2-4 周 |
| 工程团队试点 | Codex 部署 + 编码工作流重构 | 4-8 周 |
| 全链路扩展 | 需求/规划/法务/商业团队接入 | 8-12 周 |
| 文化变革 | 领导示范 + 实验文化 + 考核标准更新 | 持续（3-6 个月见效） |

## 对你的意义

这个案例对 AI 应用开发者有直接参考价值：

1. **Agent 编排是下一波企业 AI 的核心**：Endava CTO 明确说"next phase is centered around orchestration — combining models, agents, workflows, and human expertise"。如果你在做 Agent 框架或编排工具，这是市场需求的最强信号。

2. **非技术团队的 Agent 需求被低估**：Endava 的法务、PM、商业团队都在用 Agent，且效果显著。大多数 Agent 框架的文档和示例都面向开发者，这是一个差异化机会。

3. **"AI-native"的定义在演进**：从"用 AI 辅助编码"到"AI 是操作系统本身"——这个认知跃迁值得所有 AI 产品团队关注。

**建议**: 如果你在软件服务/AI 产品领域工作，值得深入研读 Endava 的完整案例（OpenAI 官网），特别是其"行为变革优先于技术部署"的理念。

## 关键引用

> "If I don't have an agent running in the background, I somehow think I'm wasting my time."
> — Matthew Cloke, CTO, Endava

> "There isn't a part of DavaFlow that doesn't use OpenAI technology."
> — Matthew Cloke, CTO, Endava

> "AI is becoming more than a productivity layer. It's becoming the operating model itself."
> — Endava 内部共识

> "Treat AI adoption as a behavior change, not a software rollout."
> — Endava AI 转型核心原则

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-003: 多 Agent 协作框架从实验走向工程实践 | 支持 | Endava 将编码 Agent、报告 Agent、沟通 Agent 嵌入全生命周期，是工程实践的直接证据 |
| A-005: AI 工作流自动化成为企业 AI 最快增长场景 | 支持 | 从工程到法务到商业的全链路自动化，且 CTO 级别战略推动 |

---
[← Back to Deep Dives](./README.md)
