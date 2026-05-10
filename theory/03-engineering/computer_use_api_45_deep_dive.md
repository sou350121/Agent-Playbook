---
auto_generated: true
generated_at: "2026-05-10T05:46:44Z"
source_url: "https://reflex.dev/blog/computer-use-is-45x-more-expensive-than-structured-apis/"
signal_type: "significant_update"
---
# Computer Use 比结构化 API 贵 45 倍 (Computer Use is 45x More Expensive Than Structured APIs)

> 🔍 本文由 Moltbot 自动生成 | 2026-05-10
>
> **项目/工具**: Reflex 0.9 + browser-use 0.12 + Claude Sonnet/Haiku
> **链接**: https://reflex.dev/blog/computer-use-is-45x-more-expensive-than-structured-apis/
> **核心定位**: 一篇来自 Reflex 团队的实测基准报告，量化了「视觉 Agent（截图+点击）」与「结构化 API Agent（HTTP 工具调用）」在相同管理后台任务上的成本差距——前者是后者的 45 倍。

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句話定位**：Reflex 团队用同一套管理后台、同一模型（Claude Sonnet），对比了「视觉 Agent 截图操作 UI」和「API Agent 直接调 HTTP 端点」两种路径，发现视觉路径成本是 API 路径的 **45 倍**（token）和 **51 倍**（耗时）。
- **现在值得用吗**：是——如果你正在为内部工具选型 Agent 交互方式，这篇文章给出了第一个公开、可复现的量化数据。
- **适合场景**：内部工具/自建系统的 Agent 化（优先 API 路径）；第三方 SaaS / 遗留系统（视觉 Agent 是唯一选择）。
- **不适合场景**：需要低成本、高确定性、低延迟的批量操作任务——视觉 Agent 在这些场景下表现不佳。
- **与竞品/前版核心差异**：此前关于 Computer Use 的讨论多为定性（"慢"、"贵"、"不稳定"），本文首次给出了带标准差的量化对比数据。

## 是什么 / 解决什么问题

大多数团队在让 AI Agent 操作没有公开 API 的 Web 应用时，默认选择视觉 Agent（browser-use、Anthropic Computer Use 等），因为为每个内部工具编写 MCP 或 REST 接口是另一项工程投入。视觉 Agent 的成本通常被视为「固定价格」——贵，但没办法。

Reflex 团队决定测量这个「固定价格」到底是多少。他们搭建了一个管理后台（基于 react-admin 的 Posters Galore demo），让两个 Agent 执行同一个任务：找到订单最多的客户 Smith，定位其最近待处理订单，接受所有待处理评论，并将订单标记为已送达。这个任务涉及三个资源、过滤、分页、跨实体查找和读写操作——是典型的内部工具日常工作。

**Path A（视觉 Agent）**：Claude Sonnet 通过 browser-use 0.12 的 Vision 模式，截图 + 点击操作 UI。
**Path B（API Agent）**：Claude Sonnet 通过 tool-use 直接调用应用的后端 HTTP 端点（由 Reflex 0.9 自动生成）。

两者调用的是同一套应用逻辑，唯一的变量是交互界面。

## 技术架构拆解

### 核心设计决策

1. **同一模型、同一数据集、同一任务**：控制变量，确保对比公平。两个 Agent 都使用 Claude Sonnet，数据集固定（900 客户、600 订单、324 评论），任务完全相同。
2. **API 端点自动生成**：Reflex 0.9 的插件从应用事件处理器自动生成 HTTP 端点，Agent 看到的是 `list_customers`、`update_order` 等结构化工具，约 30 行 REST 接口。这消除了「编写 API 层」的工程成本变量。
3. **多次运行取统计**：API 路径运行 5 次，视觉路径运行 3 次（因为每次视觉运行耗时 14-22 分钟，成本太高）。报告均值 ± 样本标准差。
4. **视觉 Agent 需要 14 步引导**：原始 6 句任务描述下，视觉 Agent 只找到了 4 条待处理评论中的 1 条——它没有分页信号，看不到折叠区域下方的内容。团队不得不重写 prompt 为 14 条逐步引导指令（明确标注侧栏项、标签页、表单字段），视觉 Agent 才完成任务。这 14 条指令本身就是工程成本，且不体现在 token 计数中。

### 与前版/竞品的关键差异

| 维度 | 视觉 Agent (Sonnet + browser-use) | API Agent (Sonnet) | API Agent (Haiku) |
|------|-----------------------------------|--------------------|--------------------|
| 步骤/调用数 | 53 ± 13 | 8 ± 0 | 8 ± 0 |
| 墙钟时间 | 1003s ± 254s (~17 分钟) | 19.7s ± 2.8s | 7.7s ± 0.5s |
| 输入 token | 550,976 ± 178,849 | 12,151 ± 27 | 9,478 ± 809 |
| 输出 token | 37,962 ± 10,850 | 934 ± 418 | 19 ± 52 |
| 成本倍率 (vs API Sonnet) | **45x** | 1x | ~0.78x |
| 耗时倍率 (vs API Sonnet) | **51x** | 1x | ~0.39x |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────────┐
│                    Application Logic (Shared)               │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐    │
│  │ list_cust│  │filter_by │  │accept_rev│  │mark_deliv│    │
│  │_omers    │  │status    │  │iews      │  │er        │    │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘    │
└───────────────┬──────────────────────────┬──────────────────┘
                │                          │
    ┌───────────▼──────────┐  ┌───────────▼──────────┐
    │   Path A: Vision     │  │   Path B: API        │
    │                      │  │                      │
    │  Screenshot → LLM    │  │  HTTP Tool Call      │
    │  → Click → Repeat    │  │  → Structured Resp   │
    │                      │  │  → Next Call         │
    │  53 steps, 551k tok  │  │  8 steps, 12k tok    │
    │  1003s wall-clock    │  │  19.7s wall-clock    │
    └──────────────────────┘  └──────────────────────┘
```

### 关键发现：方差差异

视觉 Agent 的另一个关键问题是**高方差**：
- 3 次运行中，墙钟时间跨度 749s 到 1257s（相差 68%）
- 输入 token 跨度 407k 到 751k（相差 84%）
- 最短运行 43 个循环，最长 68 个循环

API 路径则完全没有这个问题：5 次运行全部精确 8 次工具调用，输入 token 变化仅 ±27。结构化响应给了 Agent 确定性路径，没有偏离的理由。

## 实用评估

### 什么场景值得用视觉 Agent

- **第三方 SaaS 产品**：你无法修改的系统，视觉 Agent 是唯一选择。
- **遗留系统**：没有 API、文档缺失、修改成本极高的老系统。
- **一次性/低频任务**：每天只跑几次，token 成本不敏感。
- **快速原型验证**：先验证 Agent 能否完成某类任务，再决定是否需要投入 API 层。

### 什么场景不值得用视觉 Agent

- **高频批量操作**：45x token 成本在规模化时是致命的。
- **需要确定性的生产环境**：高方差意味着 SLA 难以保证——有时 12 分钟完成，有时 21 分钟。
- **分页/列表类操作**：视觉 Agent 无法感知折叠区域下方的数据，需要额外引导。
- **多步骤复杂工作流**：每一步的截图-推理-点击循环都会累积误差和延迟。

### 迁移成本

从视觉 Agent 迁移到 API Agent 的成本取决于你是否控制目标系统：

| 场景 | 迁移成本 | 说明 |
|------|----------|------|
| 自建系统（如 Reflex 应用） | 极低 | Reflex 0.9 自动生成 HTTP 端点，约 30 行代码 |
| 有 API 但非 Agent 友好 | 中等 | 需要包装为 tool-use 格式，但逻辑已存在 |
| 第三方 SaaS / 遗留系统 | 极高/不可能 | 你无法修改，视觉 Agent 是唯一选项 |

### 对 Haiku 的观察

Haiku 无法完成视觉路径——具体原因是 browser-use 0.12 的结构化输出 schema，Haiku 无法可靠生成（视觉和纯文本模式都不行）。但在 API 路径上，Haiku 在 8 秒内、不到 10k 输入 token 完成了任务，这是测试过的最便宜配置。这暗示了一个混合策略：**视觉路径用 Sonnet，API 路径用 Haiku**。

## 对你的意义

这篇文章对 Ken 的两条线都有直接参考价值：

**AI 应用开发线**：
- 这是第一个公开的 Computer Use vs API Agent 量化对比，可以直接引用到你的 Agent-Playbook 中。
- 如果你正在评估 browser-use、Anthropic Computer Use 等工具，这篇文章给出了成本基线。
- Reflex 0.9 的自动生成 API 端点能力值得关注——如果你的 Agent 需要操作自建系统，这可以大幅降低 API 层工程成本。

**VLA 研究线**（间接关联）：
- 这篇报告的核心论点——「更好的模型会缩小每步成本，但不会缩小步骤数，因为步骤数由界面决定」——与 VLA 领域的触觉研究有哲学层面的共鸣。VLA 中，更好的视觉模型不会减少需要的截图数，更好的触觉传感器也不会减少需要的交互轮次。界面设计（无论是 API 还是传感器模态）决定了效率上限。

**建议**：立即关注 Reflex 0.9 的 API 自动生成能力。如果你的 Agent 项目涉及内部工具操作，API 路径的成本优势是决定性的。

## 关键代码/配置片段

文章未提供具体代码，但描述了 API 路径的核心结构：

> Path B runner 将自动生成的端点塑造成一个约 30 行的 REST 工具接口，Agent 看到的是 `list_customers`、`update_order` 等工具名。

原始数据仓库可复现：
- 种子数据生成
- 修补后的 react-admin demo
- 两个 Agent 脚本
- 原始结果数据

> TODO: 具体代码仓库 URL 未在文章中明确给出，需从 Reflex 官方渠道获取。

---
[← Back to Deep Dives](./README.md)
