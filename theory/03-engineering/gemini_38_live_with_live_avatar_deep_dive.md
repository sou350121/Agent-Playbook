---
auto_generated: true
generated_at: "2026-09-29T06:46:05Z"
source_url: "https://deepmind.google/blog/introducing-gemini-38-live-with-live-avatar/"
signal_type: "significant_update"
---
# Gemini 3.8 Live 搭载 Live Avatar：把对话式 AI 变成「会看会说」的企业级数字员工 (Gemini 3.8 Live with Live Avatar)

> 🔍 本文由 Moltbot 自动生成 | 2026-09-29
>
> **项目/工具**: Gemini 3.8 Live with Live Avatar (Google DeepMind / Google Cloud)
> **链接**: https://blog.google/innovation-and-ai/models-and-research/gemini-models/gemini-3-8-live-with-live-avatar/
> **核心定位**: 在原生 speech-to-speech 的 Live API 上叠加近实时视频生成，让对话 Agent 拥有同步唇形与表情的「可视化人格」，并支持后台异步工具调用——把语音助手升级为能同时看镜头、听声音、跑任务的实时多模态 Agent。

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句話定位**：Gemini 3.8 Live 系列新增 Live Avatar 能力，为实时对话模型加上「近实时视频人格」+ 后台异步工具调用，并正式 GA 到 Gemini Enterprise。
- **現在值得用嗎**：**看場景**。如果你在做面向客户的企业级语音/视频 Agent（客服、接待、投顾、理赔），且已押注 Google Cloud 生态，值得立即评估；否则先观望。
- **適合場景**：企业客服数字人、酒店/门店自助接待 kiosk、保险理赔视频受理、多语言呼叫中心、需要边对话边跑后台任务的语音 Agent。
- **不適合場景**：纯文本/纯语音的轻量 chatbot（用不上视频人格）、自建开源栈且不愿依赖 Google 托管、对延迟极度敏感且无法接受视频生成的额外开销、需要自托管私有化推理的团队。
- **與前版核心差異**：上一周的 Gemini 3.8 Live 只做语音—语音；Live Avatar 在其上增加**同步视频人格**、**97 语言唇形自适应**、**边对话边后台执行工具**，并通过 ADK 打通多 Agent 编排。

## 是什么 / 解决什么问题

过去一年，企业级语音 AI 的竞争焦点从「更快、更便宜」转向「更高质量的单次交互」。Gemini 3.8 Live 系列（上周发布）已经提供了原生 speech-to-speech 的实时对话底座；而本次的 **Live Avatar** 在其上叠加了一个关键能力：**近实时的可视化存在**——把低延迟流式视频生成与语音耦合起来，让模型「听着、看着、然后带着动态视觉人格说话」。

这解决的是一类具体的落地痛点：纯音频的语音 Agent 在**信任感**和**信息密度**上受限。客户在办理业务时看不到"人"，也无法向对方展示现场画面;而传统的数字人方案（预录动画 + 拼接 TTS）往往口型对不上、打断后表情僵死、多语言切换时视觉漂移明显。Live Avatar 的卖点是：**精确唇形同步 + 自然表情 + 流畅的轮次切换（turn-taking）**，并声称在 97 种语言间切换时不会降低视频保真度或引入视觉漂移。

对开发者而言，更重要的变化或许是**架构层面的**：Live Avatar 由 Gemini 的推理能力支撑，支持 **异步工具调用（asynchronous tool calling）**——Agent 可以在**继续对话的同时**在后台触发工具调用、拉取数据。官方演示里，一个酒店前台场景在对话不中断的情况下完成了入住登记;保险理赔场景则在后台跑一个 ADK Agent 团队去核对保单、套用受理规则、生成理算包。

> 关键背景：Gemini 3.8 Live with Live Avatar 现在已在 **Gemini Enterprise 正式 GA**（US 与 EU endpoint），并附带 provisioned throughput、企业合规与严格数据治理。它最早在 Google Cloud Next 2026 上预览。注意区分：同系列的 **Gemini 3.8 Live Extended Thinking 仍处于 private preview**，本次 GA 的是 Live Avatar。

## 技术架构拆解

### 核心设计决策

- **视频人格与语音强耦合**：不是"先出语音、再套动画"，而是将 near real-time 视频生成与 speech 原生配对，目标是在打断（interruption）后仍能维持上下文与视觉连续性。
- **对话与执行解耦（异步工具调用）**：工具调用与 API 调用在后台执行，模型先确认请求、继续聊天，任务在后台完成——这是"连续在场"（continuous presence）的核心，避免工具延迟冻结对话流。
- **多语言唇形自适应**：内置 97 语言理解与生成，自动语言检测，唇形与表情动态适配，官方声称跨语言切换不产生 visual drift。
- **一个模型看两路视觉**：Live visual understanding 可**同时**处理实时摄像头流与屏幕共享流（外加音频），这让"展示现场 + 看屏幕"类场景成为可能。
- **身份与可追溯的默认防线**：预置 curated avatar 库供企业直接部署;自定义头像被严格限制在 **enterprise allowlist + 验证流程**之后。所有生成的音频与视频都嵌入不可感知的 **SynthID** 水印，便于检测与溯源。

### 与前版/竞品的关键差异

| 维度 | 上周 Gemini 3.8 Live（纯语音） | 现在 Gemini 3.8 Live + Live Avatar |
|------|------------------------------|-----------------------------------|
| 输出模态 | 语音（speech-to-speech） | 语音 **+ 同步视频人格**（唇形/表情） |
| 工具调用 | 支持，但以对话流为中心 | **后台异步**执行，边聊边跑任务 |
| 视觉输入 | 音频为主 | 实时摄像头流 + 屏幕共享，**与音频并行**处理 |
| 语言 | 多语言语音 | 97 语言，**唇形/表情自适应**、切语言不漂移 |
| 身份定制 | 不适用 | 预置库 + 自定义头像（**allowlist 门禁**），参考图 + 音频样本即可 |
| 水印/合规 | — | 全量 **SynthID** 音视频水印;US/EU endpoint、企业合规 |
| 编排框架 | Live API | 可经 **ADK** 做多 Agent、会话恢复、流式工具 |

> 说明：上表基于官方 blog 与 Google Cloud GA 公告的措辞整理，其中"不漂移""精确唇形"等为**官方宣称**，尚缺独立第三方评测数据佐证。

### 架构/信息流图

```
                    ┌────────────────────────────┐
   用户摄像头流 ───▶│                            │
   用户屏幕共享 ───▶│   Gemini 3.8 Live          │
   用户语音     ───▶│   (原生 speech-to-speech)  │
                    │        + Live Avatar       │
                    │   (near real-time video)   │
                    └──────────────┬─────────────┘
                                   │
              ┌────────────────────┼────────────────────┐
              ▼                    ▼                    ▼
      同步音视频回话        后台异步工具调用       多 Agent 编排
     (唇形/表情/97语言)   ──▶ 邮箱/日历/Slack     ──▶ ADK agent team
                              / 业务 API              (保单核对/规则/理算包)
                                   │
                                   ▼
                         对话不中断，任务后台完成
                                   │
                                   ▼
                    全量输出嵌入 SynthID 水印 (可溯源)
```

ADK 侧的"双向流式"时序（官方文档示意，用户可在句中打断）：

```
User  ──▶ Agent : "Explain the history of Japan"
Agent ──▶ User  : "Sure! Japan's history is a..." (partial)
User  ──▶ Agent : "Ah, wait."
Agent ──▶ User  : "OK, how can I help?"   [interrupted: true]
```

## 实用评估

### 什么场景值得用

- **企业客服/自助接待数字人**：需要"看得见的人"来提升信任与引导体验（酒店入住、门店 kiosk、投顾/理财咨询）。
- **视频受理类流程**（保险理赔、远程定损）：用户边讲边给镜头看现场，Agent 一边对话一边后台填表、核保、出理算包——这是官方 demo 里最有说服力的用例，且**有开源代码可参考**。
- **多语言呼叫中心**：97 语言 + 自动语言检测 + 唇形自适应，对跨国业务、印度等语言密集市场有实际价值（Equal AI 自称每日处理超百万通电话、覆盖 9 种印度语言）。
- **需要"边说边做"的语音 Agent**：异步工具调用让长耗时任务（查保单、建工单、跑工作流）不再冻结对话。
- **已有 Google Cloud / Gemini Enterprise 投入的团队**：US/EU endpoint、provisioned throughput、合规与数据治理一站式可用，迁移摩擦最小。

### 什么场景不值得用

- **纯文本或纯语音 chatbot**：视频人格是纯增量成本，用不上就别付这个溢价。
- **自建/开源头优先的团队**：Live Avatar 与 Gemini Enterprise 强绑定，无法私有化自托管;要自控推理栈的团队会被锁死在 Google 生态。
- **对延迟极端敏感的产品**：近实时视频生成天然引入额外计算开销（官方未公布端到端延迟数字，**待验证**），逐帧低延迟场景需实测。
- **需要自由定制任何头像的团队**：自定义头像走 **allowlist 门禁 + 验证**，不是开箱即用;想随便生成名人/任意形象会撞合规红线。
- **预算敏感的 C 端大规模部署**：企业级 endpoint + provisioned throughput 的定价模式偏向企业采购，**成本数据官方未公开**，需向 Google 询价。

### 迁移成本

- **从"纯 Gemini Live API"迁移**：中等偏低。官方强调 ADK 让 agent code 在平台演进时保持稳定;Live API 相关逻辑可复用，主要新增的是 avatar 配置、视频流处理与视觉输入管线。
- **从第三方数字人方案迁移**：中等。需要重做口型/表达逻辑（交给 Gemini 托管）、重接工具调用为异步模式、接入 ADK 的 session/workflow 抽象。
- **从零开始**：可参考官方开源 demo（awesome-llm-apps 的 insurance_claim_live_agent_team）与 ADK live 文档，降低起步门槛。
- **合规工作量**：自定义头像需走 allowlist 与验证流程，若涉及品牌形象需预留审批时间。

## 对你的意义

对你的 **Agent + UI / RAG 工具链**方向，这次发布的真正信号不是"数字人很好看"，而是三个可复用的工程模式：

1. **对话与执行解耦**：把工具调用变成"后台异步 + 主对话不阻塞"，这是任何语音/实时 Agent 都会遇到的架构点;即使你不用 Gemini，也该在你的 Agent 编排层引入类似模式（LiveRequestQueue 式的请求队列 + 异步 tool 执行）。
2. **多模态并行的输入融合**：同时消费摄像头流 + 屏幕共享 + 音频，是"Agent 看到用户所看"的具体实现，对做 visual Agent / computer-use 的你有直接参考价值。
3. **ADK 的抽象层次**：官方明确对比了 Raw Live API 与 ADK——ADK 补齐了自动工具执行、会话恢复、统一事件模型、多 Agent 编排。这套"在流式协议之上提供 Agent 运行时"的思路，值得对照你现有 RAG/Agent 栈评估是否有等价物。

**建议：观望 + 借鉴，不必立即换栈。** 如果你团队没有押注 Google Cloud，直接迁移成本不划算;但把上面的异步工具调用与多模态融合模式抄进自己的设计文档，成本几乎为零、收益明确。

## 关键代码/配置片段

官方 blog 强调直接使用 **ADK** 配合 Gemini Live API，可绕过传统 STT 管线、直接流式音频。ADK 官方文档中明确的关键 API 名称如下（**以下为基于官方文档命名的骨架示意，非逐行可运行代码**，请以 adk.dev 文档为准）：

```text
# ADK live agent 骨架（依据 adk.dev/live 官方文档的 API 名称整理）
# 支持版本: ADK Python v0.5.0 / Java v0.2.0（Experimental）

runner.run_live( ... )        # 建立双向流式连接（Bidi streaming）
LiveRequestQueue( ... )       # 上行请求队列：与 Agent 事件异步协调
RunConfig( ... )              # 配置: voice / transcription / turn detection
StreamingMode.Bidi            # 双向流式——支持用户打断（区别于 StreamingMode.SSE）
# 事件中: events 携带 [interrupted: true] 表示上一轮被用户打断
```

"该用哪种 streaming"是官方特别提醒的常见困惑点，决策表如下（源自 ADK 官方文档）：

| 类型 | 行为 | 用户可打断? | 适用 |
|------|------|------------|------|
| Server-side streaming | 服务器单向推送 | 否 | 仪表盘/feed 更新（不在 ADK 内） |
| Token-level streaming | 逐字返回，但需等结束才能续 | 否 | 响应式文本聊天（`StreamingMode.SSE`） |
| **Bidirectional streaming** | 双方同说同听同响应 | **是** | **语音/视频对话（`runner.run_live()`）** |

官方还提供了可对标的开源实现与生产路径：`LiveKit` 集成（WebRTC / telephony，无需自建 server）、`Guardrails`（对用户与 Agent 双向内容把关）、`Evaluation`（上线前给语音对话打分）。

> TODO: 官方 blog 与 GA 公告均**未公布端到端延迟、视频分辨率、token/计费**等硬指标;如需选型请向 Google 索取 benchmark 与定价表。

---
[← Back to Deep Dives](./README.md)
