---
auto_generated: true
generated_at: "2026-06-07T06:47:47Z"
source_url: "https://simonwillison.net/2026/Jun/2/microsofts-new-models/"
signal_type: "significant_update"
---
# Microsoft MAI 双模型发布：MAI-Thinking-1 (35B active) + MAI-Code-1-Flash (5B active) (Microsoft MAI Dual-Model Release: Thinking + Code with Clean Data)

> 🔍 本文由 Moltbot 自动生成 | 2026-06-07
>
> **项目/工具**: Microsoft MAI-Thinking-1 & MAI-Code-1-Flash
> **链接**: https://simonwillison.net/2026/Jun/2/microsofts-new-models/
> **核心定位**: Microsoft 全自研 MoE 模型家族——1T 参数的推理模型（35B active）盲测优于 Sonnet 4.6，137B 代码模型（5B active）直推 GitHub Copilot，全程使用 clean licensed data，无第三方蒸馏

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**: Microsoft 从底层用 clean licensed data 从头训练的两个 MoE 模型——MAI-Thinking-1 主攻推理（1T 总参 / 35B active），MAI-Code-1-Flash 主攻代码（137B 总参 / 5B active），已集成到 GitHub Copilot
- **现在值得用吗**: 是 — 如果你已经是 GitHub Copilot 用户，MAI-Code-1-Flash 正在自动推送给你，零成本升级；MAI-Thinking-1 目前仅对"select early partners"开放，需等待
- **适合场景**: GitHub Copilot / VS Code 代码补全（低延迟低成本）、企业级推理任务（需 early access）、对训练数据合规性有严格要求的场景
- **不适合场景**: 需要开源模型自行部署的场景（目前未开源）、需要大上下文窗口的任务（TODO: 待确认上下文长度）、非 Microsoft 生态的用户（MAI-Thinking-1 暂不公开 API）
- **与竞品核心差异**: 全 clean data 端到端自研（无第三方蒸馏），MoE 架构实现"大模型性能 + 小模型推理成本"，5B active 代码模型直推 Copilot 用户

## 是什么 / 解决什么问题

2026 年 6 月 2 日，Microsoft 在 Build 大会期间宣布了两个新的文本 LLM：**MAI-Thinking-1**（推理模型）和 **MAI-Code-1-Flash**（代码模型）。这两个模型的核心故事有三条线：

**第一，MoE 架构的极致效率。** MAI-Thinking-1 总参数量达到 1T（万亿），但采用 Mixture-of-Experts 稀疏激活设计，每次推理仅激活 35B 参数。MAI-Code-1-Flash 总参数 137B，每次推理仅激活 5B。这意味着推理成本接近 5-35B 的稠密模型，但性能对标的是 Sonnet 4.6 级别的旗舰模型。Microsoft 声称 MAI-Thinking-1 "在盲测人机对比中优于 Sonnet 4.6"——对于一个 35B active 的模型来说，这是非常激进的主张。

**第二，全 clean data 端到端自研。** Microsoft 强调两个模型都是 "from the ground up on enterprise grade, clean and commercially licensed data, without distillation from third-party models"。这意味着：(1) 没有用 OpenAI/Claude/Gemini 的输出做蒸馏训练；(2) 训练数据有商业授权。这在行业普遍依赖第三方蒸馏和灰色数据爬取的背景下，是一个明确的差异化定位——尤其对合规敏感的企业客户。

**第三，Copilot 集成优先。** MAI-Code-1-Flash 被描述为 "purpose-built for GitHub Copilot and VS Code"，已经 "rolling out to GitHub Copilot individual users in Visual Studio Code"。这是 Microsoft 将自研模型直接部署到亿级用户产品中的标志性动作。

## 技术架构拆解

### 核心设计决策

| 设计选择 | 具体方案 | 理由 |
|----------|---------|------|
| MoE 稀疏激活 | MAI-Thinking-1: 1T 总参 / 35B active; MAI-Code-1-Flash: 137B 总参 / 5B active | 推理成本接近小模型，性能接近大模型 |
| 无第三方蒸馏 | 全量从 clean data 从头训练 | 合规性、避免 "模型坍塌"（model collapse）、可控的数据质量 |
| 任务分离 | 推理模型 + 代码模型分开训练 | 避免多任务干扰，各自优化 |
| Copilot 原生集成 | MAI-Code-1-Flash 直推 VS Code | 降低 API 调用延迟和成本，直接服务终端用户 |

### 训练数据（来自技术论文 Page 80+）

根据 Simon Willison 对 MAI-Thinking-1 技术论文的阅读，训练数据 pipeline 如下：

- **专有网页爬取**: 约 1.2 万亿页面被发现和解析，经过 UT1 block list 过滤（移除成人内容和盗版域名），减少到 7940 亿页面
- **Common Crawl**: 经过相同 pipeline 处理后，包含 242 亿页面
- **AI 内容过滤**: 使用专有 AI 内容检测模型 + 人工检查，识别并移除大量 AI 生成内容的域名
- **去重**: exact-URL 和 content-level fuzzy deduplication

> ⚠️ **重要澄清**: Simon Willison 最初报道称这些模型使用了 "appropriately licensed" 数据，暗示可能避开了未授权网页爬取。但技术论文显示，**它们仍然使用了大规模公共网页爬取**（1.2 万亿 → 7940 亿），只是加了更严格的内容过滤和 AI 内容检测。这与其它主流 LLM 的数据策略在本质上相似，区别在于过滤力度和 AI 内容检测的引入。

### 架构信息流

```
                    ┌─────────────────────────────────────┐
                    │       Training Data Pipeline         │
                    │  Proprietary Crawl (1.2T → 794B)     │
                    │  Common Crawl (24.2B after filter)   │
                    │  AI-Content Detection + Dedup        │
                    └──────────────┬──────────────────────┘
                                   │
                    ┌──────────────▼──────────────────────┐
                    │      From-Scratch Training           │
                    │  No Third-Party Distillation         │
                    │  MoE Architecture                    │
                    └──────┬───────────────────────┬───────┘
                           │                       │
            ┌──────────────▼──────┐  ┌─────────────▼────────────┐
            │   MAI-Thinking-1    │  │   MAI-Code-1-Flash       │
            │   1T / 35B active   │  │   137B / 5B active       │
            │   Reasoning         │  │   Code Generation        │
            │   Early Partners    │  │   GitHub Copilot / VSCode│
            └─────────────────────┘  └──────────────────────────┘
```

### 与前版/竞品的关键差异

| 维度 | MAI-Thinking-1 | Sonnet 4.6 | GPT-4.1 |
|------|---------------|------------|---------|
| 架构 | MoE 1T/35B active | 未公开 | 未公开 |
| 训练方式 | 全自研 clean data | 含蒸馏 | 含蒸馏 |
| 推理成本 | ~35B 级别 | 旗舰级 | 旗舰级 |
| 盲测对比 | 优于 Sonnet 4.6 (Microsoft 声称) | 基准 | — |
| 可用性 | Early partners only | 公开 API | 公开 API |

| 维度 | MAI-Code-1-Flash | Claude Sonnet (Copilot) | GPT-5 Codex |
|------|-----------------|------------------------|-------------|
| 架构 | MoE 137B/5B active | 未公开 | 未公开 |
| 部署方式 | VS Code 原生推送 | API 调用 | API 调用 |
| 推理成本 | ~5B 级别 | 旗舰级 | 旗舰级 |
| 训练方式 | 全自研 clean data | 含蒸馏 | 含蒸馏 |

## 实用评估

### 什么场景值得用

- **GitHub Copilot 日常开发**: MAI-Code-1-Flash 正在自动推送给 Copilot 个人用户。如果你已经在用 Copilot，这相当于免费升级，且推理成本更低意味着 Microsoft 可以更激进地扩展功能
- **企业合规敏感场景**: 如果你的组织对训练数据来源有严格要求（金融、医疗、政府），MAI 系列的 "no distillation + licensed data" 定位是有吸引力的卖点。TODO: 需验证具体的 licensing 范围
- **低成本推理需求**: 35B active 的推理能力对标 Sonnet 4.6，如果 API 定价合理，对于需要大量推理调用的场景（如多步规划、Agent 循环），成本优势明显

### 什么场景不值得用

- **需要开源模型**: 两个模型目前均未开源，无法自行部署。如果你的场景需要 on-premise 部署或模型微调，MAI 系列暂时不适用
- **MAI-Thinking-1 的广泛可用性**: 目前仅 "select early partners"，普通开发者无法直接使用。等待开放可能需要数月
- **对 "clean data" 的实际含义存疑的场景**: 技术论文显示仍然使用了大规模网页爬取（1.2 万亿页面），只是过滤更严格。如果你的合规要求是完全不使用公共网页数据，MAI 系列也不满足

### 迁移成本

- **从 Copilot 现有模型迁移到 MAI-Code-1-Flash**: 零迁移成本——Microsoft 在后台自动推送，用户无感知切换
- **从其他 API 迁移到 MAI-Thinking-1**: 需等待 API 开放。一旦开放，迁移成本取决于 API 兼容性（TODO: 待确认是否兼容 OpenAI API 格式）

## 对你的意义

对 Ken 的 AI 应用开发方向，这个发布有几个值得关注的点：

1. **Copilot 底层模型切换是无声的**: MAI-Code-1-Flash 正在推送给个人用户。建议实际测试一下 Copilot 的代码补全质量是否有可感知的变化——特别是复杂 Agent 工作流的代码生成能力
2. **MoE 架构是降本的关键路径**: 5B active 做到旗舰级代码能力，35B active 做到优于 Sonnet 4.6——这验证了 MoE 在推理成本优化上的有效性。如果 Ken 未来考虑自部署模型，MoE 架构值得深入研究
3. **Clean data 叙事的企业价值**: Microsoft 在打 "合规" 牌。如果企业采购 AI 工具时开始将 "训练数据可追溯性" 作为硬要求（对应假设 A-005），这会影响 AI 工具链的竞争格局

## 关键代码/配置片段

当前无可用的公开代码片段（模型未开源，API 未开放）。以下引用来自 Microsoft 官方声明：

> "We trained MAI-Thinking-1 from the ground up on enterprise grade, clean and commercially licensed data, without distillation from third-party models."
> — Microsoft AI

> "MAI-Code-1-Flash is built end-to-end by Microsoft using clean and appropriately licensed data."
> — Microsoft AI

> MAI-Thinking-1 "is preferred to Sonnet 4.6 in our blind human side-by-side evaluations"
> — Microsoft AI

---

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-002: Agentic Coding 在初级任务达 80% 成功率 | 支持 | MAI-Code-1-Flash 直推 GitHub Copilot，5B active 模型专注代码生成，降低 Agentic Coding 的推理成本门槛 |
| A-004: 推理模型在 Agent 任务展现持续优势 | 支持 | MAI-Thinking-1 盲测优于 Sonnet 4.6，35B active 推理模型证明 MoE 架构可在保持低成本的同时提供强推理能力 |

---
[← Back to Deep Dives](./README.md)
