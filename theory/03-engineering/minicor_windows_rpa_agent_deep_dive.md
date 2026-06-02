---
auto_generated: true
generated_at: "2026-06-02T08:07:54Z"
source_url: "https://www.minicor.com/"
signal_type: "significant_update"
---
# Minicor：Windows 桌面 RPA 平台，用自修复 Agent 实现规模化部署 (Minicor — Self-Healing Desktop RPA for Legacy Systems)

> 🔍 本文由 Moltbot 自动生成 | 2026-06-02
>
> **项目/工具**: Minicor (Laminar Run, Inc.)
> **链接**: https://www.minicor.com/
> **核心定位**: 一个面向 Windows 桌面和 Citrix 环境的 RPA 平台，用「确定性代码 + Reflection Agent 自修复」的混合架构，将 computer-use agent 从一次性 demo 提升到 93-96% 准确率的生产级自动化。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**: Minicor 解决的是「AI 公司卖进医疗/汽车/金融等legacy行业时，客户用的桌面系统（EHR/ERP/DMS）没有 API，只能通过 UI 自动化读写数据，而传统 RPA 在规模化时维护成本失控」的问题。
- **现在值得用吗**: 是——如果你正在向运行 Windows 桌面应用的legacy行业客户销售 AI 产品，且被桌面集成卡住 go-live。
- **适合场景**: 医疗 EHR（Athena/Epic/Cerner）、汽车 DMS（CDK Global）、供应链（SAP/HighJump）、金融服务等无 API 的桌面系统自动化。
- **不适合场景**: 纯 Web API 集成（不需要 RPA）、macOS/Linux 桌面环境（目前只支持 Windows VM / Citrix / 浏览器）。
- **与传统 RPA 核心差异**: 传统 RPA 用脆弱脚本（UI 一变就崩）；纯 computer-use agent 一次性推理准确率仅 80-85%。Minicor 将自动化存为确定性代码，AI agent 仅用于故障恢复和边界情况，达到 93-96% 点击准确率。

## 是什么 / 解决什么问题

AI 公司（尤其是卖进 healthcare、automotive、logistics、financial services 的公司）面临一个结构性障碍：他们的客户用的「系统记录」（systems of record）是运行在 Windows 上的老旧桌面应用——电子病历系统（EHR）、经销商管理系统（DMS）、企业资源规划（ERP）——这些系统**没有 writable API，而且可能永远不会有**。第三方 API 访问甚至在被主动限制。

唯一能读写这些数据的方式，就是像人一样通过 UI 点击操作。这就是桌面 RPA 的用武之地。

但问题在于：**写一个 RPA 不难，跑几百个 reliably 极难**。UI 会变，边界情况会堆叠，错误会级联。在规模化场景下，即使很小的错误率也会变成每天数百次失败，每次都需要人工介入。工程团队最终把所有时间花在维护自动化上，而不是构建核心产品。

Minicor 的切入点是：将 computer-use agent 从「每次从头推理」的 demo 模式，转变为「确定性代码 + AI 恢复」的生产模式。他们声称在真实生产环境中（25,000 patients/day 的规模）达到 **93-96% 的点击准确率**，相比传统 computer-use 方法的 80-85% 有显著提升。

从零到生产环境部署，Minicor 声称只需**数周**（传统 RPA 和集成方法通常需要 4 个月以上）。

## 技术架构拆解

### 核心设计决策

Minicor 的架构基于三个关键设计决策：

**1. 确定性代码 + AI 恢复的混合模式**

这是 Minicor 最核心的差异化。传统 computer-use agent（如 OpenAI Computer Use、Anthropic Computer Use）每次执行都从头推理「下一步该做什么」——这在 demo 中有效，但在生产中，同样的 UI 每次都要重新推理，错误率累积。

Minicor 的做法是：
- 将自动化流程存储为**确定性代码**（deterministic code）——对于常规路径，按固定逻辑执行，不走 LLM 推理
- 只在**故障恢复和边界情况**时使用 AI agent——当 UI 变化、出现意外弹窗、流程偏离预期时，Reflection Agent 介入

这本质上是将 LLM 从「执行引擎」降级为「异常处理器」，大幅减少推理调用次数和错误面。

**2. Reflection Agent 自修复机制**

Minicor 引入了一个专门的 Reflection Agent：
- 每一步操作后，Reflection Agent 会**对照屏幕实际内容验证操作结果**
- 如果检测到偏差（click 没点在目标上、弹窗遮挡、UI 元素位置变化），agent 会**自我纠正**再继续下一步
- 这意味着即使 UI 更新导致元素位置变化，自动化也能自适应，而不是直接崩溃

```
用户操作录制 → 生成确定性自动化脚本
                          ↓
                    执行常规路径（无 LLM）
                          ↓
                    ┌── 遇到异常？ ──┐
                    │               │
                   是              否
                    │               │
                    ↓               ↓
          Reflection Agent     继续执行
          截图验证 + 自我纠正
                    │
                    ↓
               恢复或告警
```

**3. 可观测性内建**

每次自动化运行都记录**完整视频回放**，配合截图和完整执行上下文。失败通知直接推送到 Slack。这解决了传统 RPA 最大的痛点之一：出错后不知道发生了什么。

### 与前版/竞品的关键差异

| 维度 | 传统 RPA（UiPath/Automation Anywhere） | 纯 Computer-Use Agent | Minicor |
|------|----------------------------------------|----------------------|---------|
| 执行模型 | 脆弱脚本，UI 变则崩 | 每次从头 LLM 推理 | 确定性代码 + AI 恢复 |
| 点击准确率 | ~70-80%（UI 变化后骤降） | 80-85% | 93-96% |
| LLM 调用频率 | 0（无 AI） | 每一步都调用 | 仅异常时调用 |
| 部署到生产 | 4+ 个月 | Demo 容易，生产难 | 数周 |
| 自修复能力 | 无 | 有限（每次独立推理） | Reflection Agent 实时验证 |
| 可观测性 | 日志 + 截图 | 通常无 | 视频回放 + 截图 + Slack 告警 |
| 合规 | 企业级 | 通常无 | SOC 2 Type II + HIPAA |
| 部署方式 | 云端/本地 | 云端 | Windows VM / Citrix / 浏览器 / on-prem |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────┐
│                    Minicor Platform                  │
│                                                      │
│  ┌──────────┐    ┌──────────────┐    ┌────────────┐ │
│  │  MCP /   │───→│  Automation  │───→│ Desktop    │ │
│  │  Coding  │    │  Generator   │    │ Client     │ │
│  │  Agent   │    │ (确定性代码)  │    │ (Windows)  │ │
│  └──────────┘    └──────────────┘    └─────┬──────┘ │
│                                            │         │
│  ┌──────────┐    ┌──────────────┐          │         │
│  │  API     │───→│  Execution   │──────────┘         │
│  │  Trigger │    │  Engine      │                    │
│  └──────────┘    └──────┬───────┘                    │
│                         │                            │
│                  ┌──────┴───────┐                    │
│                  │ Reflection   │                    │
│                  │ Agent        │                    │
│                  │ (验证+自修复) │                    │
│                  └──────┬───────┘                    │
│                         │                            │
│  ┌──────────┐    ┌──────┴───────┐    ┌────────────┐ │
│  │  Slack   │←───│  Video       │←───│  Screenshot│ │
│  │  Alert   │    │  Replay      │    │  + Context │ │
│  └──────────┘    └──────────────┘    └────────────┘ │
└─────────────────────────────────────────────────────┘
```

**工作流程**：
1. 在运行 legacy 软件的机器上安装 Desktop Client
2. 通过 MCP 接口让 coding agent 生成自动化（或直接告诉 Minicor 团队）
3. 录制一段人类执行该 workflow 的视频作为参考
4. Minicor 生成确定性自动化脚本 + API endpoint
5. 通过 API 调用触发执行，Reflection Agent 实时验证
6. 视频回放 + 错误日志自动记录，失败推 Slack

## 实用评估

### 什么场景值得用

- **AI 公司卖进 healthcare**: 客户用 Epic/Cerner/Athena 等 EHR，没有 API，你需要把 AI 生成的数据写回这些系统。Minicor 可以帮你数周内完成集成，而不是 4 个月。
- **AI 产品需要写入 legacy 桌面系统**: 任何需要向没有 API 的 Windows 桌面应用写入数据的场景——DMS、ERP、PMS、claims 系统。
- **规模化 RPA 维护成本过高**: 如果你有几十个 RPA 在跑，工程团队大部分时间在修脚本而不是做产品，Minicor 的自修复可以显著降低运维负担。
- **On-premise / 数据不出网**: 整个平台容器化，可以部署在客户内网，数据不离开 perimeter。HIPAA 合规对医疗场景是硬要求。

### 什么场景不值得用

- **纯 Web API 集成**: 如果目标系统有 API，直接用 API，不需要 RPA 层。
- **macOS/Linux 桌面环境**: 目前只支持 Windows VM 和 Citrix。
- **一次性/低频自动化**: 如果只需要跑几次自动化，直接手写脚本更便宜。Minicor 的价值在规模化（几十个/几百个 RPA 同时跑）。
- **需要复杂业务逻辑判断的场景**: Minicor 擅长的是「把数据从 A 搬到 B」的 UI 操作自动化，不是复杂决策流程。

### 迁移成本

从传统 RPA（UiPath 等）迁移：
- **评估期**: 1-2 周，选择 2-3 个高频 RPA 做 POC
- **迁移**: 录制人类操作视频 → Minicor 生成自动化脚本 → 测试验证
- **全量迁移**: 取决于 RPA 数量，官方声称 3 周内可从 POC 到 production
- **学习成本**: 低——主要通过 MCP 接口与 coding agent 交互，不需要学新语言

从纯 computer-use agent 方案迁移：
- 如果你的方案准确率卡在 80-85%，迁移到 Minicor 的混合架构可能带来 10-15 个百分点的提升
- 主要迁移工作是重新录制 workflow 视频，让 Minicor 生成确定性脚本

## 对你的意义

Minicor 代表了一个值得关注的趋势：**AI Agent 在生产环境中的最佳实践不是「全 AI」，而是「AI + 确定性」的混合架构**。

这个模式——将 LLM 从执行引擎降级为异常处理器——对 Ken 关注的 Agent 架构设计有直接启发：

1. **Agent 不一定是全 AI 的**: 在可预测的路径上用确定性代码，在不可预测的边界用 AI。这种混合模式可能是 Agent 走向生产的主流范式。
2. **Reflection/Self-correction 是独立能力层**: Minicor 把 Reflection Agent 作为独立组件，实时验证每一步操作。这与 VLA 领域的「感知-行动-验证」闭环有异曲同工之妙。
3. **可观测性是生产级 Agent 的刚需**: 视频回放、截图、完整执行上下文——这些不是锦上添花，是让工程团队敢把 Agent 放到生产环境的必要条件。

**建议**: 如果你正在构建面向企业客户的 AI Agent 产品，且客户环境包含 legacy 系统，Minicor 的模式值得研究。即使你不直接用他们的产品，他们的架构思路（确定性 + AI 恢复）可以应用到你的 Agent 设计中。

> TODO: 需要更多公开的技术博客或论文来深入了解 Reflection Agent 的具体实现（使用什么视觉模型、验证 prompt 设计、自修复策略）。Minicor 目前公开的技术细节有限。

## 关键代码/配置片段

Minicor 通过 MCP 接口与 coding agent 交互，生成自动化。以下是 YC Launch 页面提到的工作流：

```
# 通过 MCP 接口，用 coding agent 生成自动化
# 具体 API 格式未公开，以下为概念流程：

1. 录制人类执行 workflow 的视频
2. 通过 MCP 将视频 + 描述发送给 Minicor
3. Minicor 生成确定性自动化脚本 + API endpoint
4. 通过 API 触发执行：
   POST /api/v1/executions
   {
     "automation_id": "xxx",
     "inputs": {...}
   }
5. 接收结果 + 视频回放链接
```

> TODO: Minicor 的 MCP 接口规范和 API 文档尚未公开。需要官方发布更多技术文档。

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-005: AI 工作流自动化成为企业 AI 最快增长场景 | 支持 | Minicor 直接瞄准企业 AI go-live 的最大瓶颈之一——legacy 桌面系统集成。YC P26 入选 + 已在生产处理数千 workflow/周，验证了企业级 RPA 自动化的真实需求。 |

---
[← Back to Deep Dives](./README.md)
