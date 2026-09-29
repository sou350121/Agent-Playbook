---
auto_generated: true
generated_at: "2026-09-29T05:45:53Z"
source_url: "https://www.anthropic.com/claude-sonnet-5-5"
signal_type: "blog_post"
---
# Claude Sonnet 5.5 发布：Terminal-Bench 4.0 达 70.6%，快 30% 更便宜 (Claude Sonnet 5.5: Terminal-Bench 4.0 Hits 70.6%, 30% Faster and Cheaper)

> 🔍 本文由 Moltbot 自动生成 | 2026-09-29
>
> **项目/工具**: Claude Sonnet 5.5（Anthropic，Claude 5.5 家族第二个模型）
> **链接**: https://www.anthropic.com/claude-sonnet-5-5
> **核心定位**: 面向"定义良好的日常任务 + 修 bug + 文档/幻灯片/表格生产"的中端模型，在 agentic coding 上相比 Sonnet 5 出现数量级跃升，同时提速 30%+、单任务成本最多降 30%。

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句話定位**：Sonnet 5.5 是 Opus 5.5 之下、Haiku 之上的中端主力，把 agentic coding 从"能跑"推到"接近 Opus"，同时用更少 token 把单任务成本压下来。
- **現在值得用嗎**：值得——尤其当你的 Agent 任务是"明确范围 + 多步工具调用"（写代码、修 bug、做报表）。前提是你已有 Sonnet 5 的接入路径，迁移成本很低。
- **適合場景**：Agentic coding、批量文档/幻灯片生成、长程任务、图像理解、需要低成本高并发的日常推理。
- **不適合場景**：开放式、需要持续判断的复杂研究型工作（官方明确说 Opus 5.5 仍明显更强）；需要更低延迟/更低价的高并发场景（应等 Haiku 5.5）；对网络安全类能力的深度使用（高风险请求会被自动回退到 Sonnet 5）。
- **與前版核心差異**：Terminal-Bench 4.0 从 Sonnet 5 的 10.3% 跃到 70.6%；生成速度 +30%+；价格不变但 token 用量大幅减少，单任务成本最多降 30%。

## 是什么 / 解决什么问题

Anthropic 的 Claude 5.5 家族此前已有 Opus 5.5（主打需要谨慎判断的复杂工作），Sonnet 5.5 是该家族的第二名成员，定位是"更快、更便宜"的补充，专门覆盖**范围明确、可拆解的日常工作**：修 bug、生成打磨好的文档/幻灯片/表格，以及需要多步工具调用的编码任务。官方同时预告 Haiku 5.5 将在未来数周内加入家族，补齐高并发/成本敏感场景。

这一代的核心矛盾不是"模型不够强"，而是**强模型用起来太贵、太慢**。Sonnet 5 在 agentic coding 上只有 10.3%（Terminal-Bench 4.0），说明上一代中端模型在命令行多步任务上几乎是"不能打"的。Sonnet 5.5 一次性把这个指标拉到 70.6%，直接逼近 Opus 5.5 的 66.4%——等于把"能可靠跑 Agent 任务"的能力从旗舰下放到了中端价位。

更关键的是成本结构的变化：Sonnet 5.5 **单价与 Sonnet 5 完全一致**，但完成同样的工作所需 token 大幅减少，官方测试显示单任务成本最多降低 30%。也就是说这次升级不是"降价"，而是通过提升 token 效率来降本。

## 技术架构拆解

### 核心设计决策

- **能力分层而非一刀切**：Opus 5.5 负责"开放式、需持续判断"的复杂任务，Sonnet 5.5 负责"范围明确的日常任务"，两者在评测曲线上互补（Sonnet 5.5 在低 effort 下性价比最高，在低 effort/中 effort 下可压过 Sonnet 5 的最佳成绩）。
- **effort 级别可调**：通过 effort level 在"成本/速度"与"质量"之间做权衡。Claude Code 与自家 App 默认 Medium，Claude Platform 默认 High。低档更快更省，高档推理更久、自检更充分。
- **token 效率优先**：官方强调 Sonnet 5.5 在 head-to-head 中会**批量合并工具调用**（batched tool calls），步骤更少，从而在单价不变的前提下降低单任务成本。
- **安全能力前置**：因为其网络安全能力与 Opus 5 相当，Sonnet 5.5 成为**首个带 cyber safeguards + 回退机制**的 Sonnet 模型；同时是首个加入"防推理蒸馏分类器"的 Sonnet（防止通过大量假账号工业化抽取推理能力）。
- **preserved thinking 扩展**：模型的 thinking 无法与创建它的账号解耦，跨账号搬运对话会受影响（对多数开发者无感）。

### 与前版/竞品的关键差异

| 维度 | Sonnet 5 | Sonnet 5.5 | Opus 5.5 | GPT-6 Sol |
|------|----------|-----------|----------|-----------|
| Terminal-Bench 4.0（agentic coding） | 10.3% | **70.6%** | 66.4%¹ | — |
| FrontierCode 1.1 (Main) | 42.4% | **46.2%** (Max)² | 54.4% | 49.3% / 52.1% (Xhigh) |
| CursorBench 4.0 | 34.1% | **55.5%** | 57.8% | — |
| GDPval-AA v2.1（知识工作） | 1449 | **1844** | 1846 | 1487⁴ |
| AA-Briefcase v1.1 | 1359 | **1811** | 1822 | 1483⁴ |
| Humanity's Last Exam（with tools） | 54.9% | **64.5%** | 67.7% | — |
| OSWorld 2.1（computer use，partial） | 57.0% | **80.1%** | 81.8% | — |
| Chartography（图表识别，no tools） | 15.6% | **61.6%** | 64.4% | 53.6%⁴ |
| 生成速度 | 基准 | **+30%+** | 未公开 | 未公开 |
| 输入价格 / 1M tokens | $2 | $2 | $4 | 未公开 |
| 输出价格 / 1M tokens | $10 | $10 | $20 | 未公开 |

> ¹ 表注：Terminal-Bench 与 OpenAI 未公开 GPT-6 Sol 成绩，故列 GPT-5.6 Sol。
> ² GPT-6 Sol 的 FrontierCode 给出两组数（49.3% / 52.1% Xhigh），此处按原表照录。
> ³ GDPval-AA / AA-Briefcase 为知识工作评测分数（非百分比）。
> ⁴ 上述竞品数字均来自 Anthropic 官方博文表格，属厂商自测口径。

### 架构/信息流图

```
┌──────────────────────────────────────────────────────────────┐
│                    Claude 5.5 家族分层                         │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│   Opus 5.5            Sonnet 5.5             Haiku 5.5        │
│   (复杂/需判断)        (日常/多步工具)         (高并发/成本敏感) │
│   $4 / $20            $2 / $10                (数周内加入)     │
│       │                   │                        │         │
│       └───────────┬───────┴────────────────────────┘         │
│                   ▼                                          │
│            ┌─────────────┐                                   │
│            │ effort level │  Low / Medium / High              │
│            │  (成本⇄质量)  │  默认: Claude Code/App = Medium   │
│            └──────┬───────┘        Claude Platform = High     │
│                   ▼                                          │
│     ┌──────────────────────────────────────────────┐         │
│     │ Agent 运行时特性                              │         │
│     │  • batched tool calls（步骤更少）             │         │
│     │  • long-horizon 任务支持                      │         │
│     │  • 图像/截图理解                              │         │
│     └──────────────────────────────────────────────┘         │
│                   ▼                                          │
│     ┌──────────────────────────────────────────────┐         │
│     │ 安全层                                        │         │
│     │  • cyber safeguards + 高风险回退 Sonnet 5     │         │
│     │  • 防推理蒸馏分类器（首个 Sonnet）            │         │
│     │  • preserved thinking（thinking 绑定账号）    │         │
│     └──────────────────────────────────────────────┘         │
└──────────────────────────────────────────────────────────────┘
```

## 实用评估

### 什么场景值得用

- **多步命令行 Agent 任务**：Terminal-Bench 4.0 的 70.6% 意味着在 CI/CD 修复、脚本化运维、shell 环境下的多步任务中，Sonnet 5.5 已具备"可依赖"的完成率，而 Sonnet 5 的 10.3% 基本不可用。若你在跑 SWE 类或 terminal 类 Agent，这是最直接的升级理由。
- **真实 IDE 编码会话**：CursorBench 4.0 拿到 55.5%，与 Opus 5.5 的 57.8% 仅差约 2 个点，说明它在真实 Cursor 会话任务上接近旗舰，成本却低一半。
- **批量文档/幻灯片/报表生产**：官方内部测试中，把某公司季度财报材料 + 电话会议记录 + 幻灯片模板交给它，一次产出 10 页 operating review，两名专家判定初稿"可直接发送"。适合需要大量产出、人工只做轻量校对的团队。
- **长程 + 图像理解**：是首个仅凭截图通关 Pokémon Red 的 Sonnet 模型；OSWorld 2.1 达 80.1%、图表识别 61.6%，适合带视觉的 computer-use / GUI Agent。
- **成本敏感的日常推理**：同样单价下 token 用量更低，且低 effort 即可超过 Sonnet 5 最佳成绩，适合把高并发日常任务从"能省就省"转为"用得起好模型"。

### 什么场景不值得用

- **开放式、需持续判断的复杂工作**：官方自己承认，即使 Sonnet 5.5 在部分评测上持平 Opus 5.5，"benchmark 只反映能力的一个侧面"，Opus 5.5 在复杂开放式任务上仍明显更强。研究型、长链条探索任务不要用它替代 Opus。
- **极低成本/极高并发场景**：Haiku 5.5 数周内发布，价格敏感型应用应等 Haiku 而非硬上 Sonnet。
- **深度网络安全任务**：高风险 cyber 请求会被**自动回退到 Sonnet 5**，等于该能力被"降级"，需要高级能力的团队要走 Cyber Verification Program 申请。
- **跨账号临时搬运对话的工作流**：preserved thinking 扩展后，thinking 与账号绑定，跨账号/中途换号会受影响（Claude Code 中会话中途切号需查迁移文档）。
- **数据留存敏感场景**：需注意 Sonnet 5.5 支持 zero data retention（与 Opus 5.5、Sonnet 5 一致），但部署选择（AWS/GCP/Azure/Claude Platform）仍需结合合规评估。

### 迁移成本

| 从 | 到 | 工作量 | 注意事项 |
|----|----|--------|----------|
| Sonnet 5 | Sonnet 5.5 | 低 | 若"thinking off"运行，需改用新的 `between_tools` 设置（保持前置思考关闭）后再迁移 |
| Opus 5.5 | Sonnet 5.5 | 中 | 仅适合把"范围明确"的下游任务下放；开放式任务勿迁移 |
| 其他模型 | Sonnet 5.5 | 中 | 可用模型 ID `claude-sonnet-5-5` 接入 |
| 不改 prompt 直接换模型 | Sonnet 5.5 | 极低 | Slack 测试显示：不改任何 prompt，几乎全部离线 Slackbot evals 变好，步骤更少、输出 token 少约 14% |

预估工作量：
- 换模型 ID + 适配 `between_tools`：约 0.5–2 小时。
- 校验 effort level 默认值（Claude Code/App = Medium，Platform = High）：约 0.5 小时。
- 在自己的 Agent 任务集上跑 A/B（成本 vs 质量）：1–2 天。

## 对你的意义

对 Ken 的 AI 应用开发追踪，这条发布有几个实操信号：

- **中端模型正在吞掉"能跑 Agent"的门槛**：Terminal-Bench 从 10.3% → 70.6% 不是线性改进，而是让中端价位第一次胜任多步终端 Agent。如果你在做 Agent + UI 的工程栈，模型选型时"默认用旗舰"的成本假设需要重估。
- **effort level 成了新的调参维度**：不再是"选模型"二选一，而是"选模型 × 选 effort"。这与多 Agent 编排（不同子任务用不同 effort/成本档）天然契合——值得在你的 Playbook 里作为一个设计模式记录。
- **批量化工具调用是降本关键**：官方点名 "batched tool calls → 更少步骤 → 更低成本"。如果你的 Agent 框架还在串行调用工具，换 Sonnet 5.5 + 合并工具调用会有直接的 token/成本收益。
- **安全前置**：Sonnet 5.5 首个带 cyber safeguards 与防蒸馏分类器，说明安全能力正在从旗舰下放到中端。这对你关注的"评估与安全"方向是一个可追踪的基线条目。

**建议**：立即试用。把一条你现有的 Sonnet 5 Agent 流水线换成 `claude-sonnet-5-5`，重点对比（1）相同任务下的 token 消耗与步骤数，（2）在 terminal/修 bug 任务上的成功率。注意先处理 `between_tools` 迁移项。

## 关键代码/配置片段

以下模型 ID、定价与迁移项均来自官方博文原文，未做编造：

```text
# 模型 ID（Claude Platform）
claude-sonnet-5-5

# 定价（USD / 1M tokens）
Cache reads   : $0.20
Cache writes  : $2.50
Input tokens  : $2
Output tokens : $10

# 对比 Opus 5.5:  input $4 / output $20 / cache writes $5 / cache reads $0.20
```

```text
# 迁移注意（来自官方 migration guide 标题：Turn thinking off）
# 若你此前以 "thinking off" 方式运行 Sonnet，
# 迁移到 Sonnet 5.5 前需切换到新的 between_tools 设置，
# 以保持 "up-front thinking 关闭" 的行为。
# 参考: https://platform.claude.com/docs/en/models/sonnet-5-5/migration-guide#turn-thinking-off
```

```text
# effort level 默认值
Claude Code / Claude 自家 App : Medium
Claude Platform               : High
# 低档 → 更快、token 更少；高档 → 推理更久、自检更充分
```

```text
# 可用平台
Amazon Web Services / Google Cloud / Microsoft Azure / Claude Platform
# 均支持 zero data retention
```

---
[← Back to Deep Dives](./README.md)
