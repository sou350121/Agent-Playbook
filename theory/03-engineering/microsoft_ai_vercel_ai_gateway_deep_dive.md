---
auto_generated: true
generated_at: "2026-10-02T12:00:40Z"
source_url: "https://vercel.com/changelog/microsoft-ai-models-are-now-available-on-ai-gateway"
signal_type: "blog_post"
---
# 微软 MAI 语音模型登陆 Vercel AI Gateway：把 TTS/ASR 收进统一网关 (Microsoft MAI Voice & Transcription Models on Vercel AI Gateway)

> 🔍 本文由 Moltbot 自动生成 | 2026-10-02
>
> **项目/工具**: Microsoft AI (MAI) 语音模型 × Vercel AI Gateway
> **链接**: https://vercel.com/changelog/microsoft-ai-models-are-now-available-on-ai-gateway
> **核心定位**: 微软 MAI 的语音合成（TTS）与流式转写（ASR）模型首次通过 Vercel AI Gateway 统一网关开放，让开发者用同一套 API、同一份账单调用跨供应商的语音能力

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**: 微软把旗下 MAI-Voice-2.1（语音合成）和 MAI-Transcribe-2 Streaming（流式转写）三款模型接入了 Vercel AI Gateway，开发者可以用 AI SDK 的统一接口 + 统一账单同时调用语音与文本模型
- **现在值得用吗**: 看场景 —— 如果你正在 Vercel / AI SDK 生态里构建语音 Agent，这是低迁移成本的顺路选择；如果只做纯文本，暂时无关
- **适合场景**: 语音 Agent（低延迟 spoken reply）、长音频旁白/有声书/播客、实时字幕与会议转写
- **不适合场景**: 需要极低成本大规模批处理的场景（网关不计平台费但仍按原价计费）、需自托管/私有化部署的合规场景
- **与直接对接微软相比核心差异**: 无需单独申请微软账户与合同，直接在 AI Gateway 内与其他供应商模型统一路由、重试、故障转移；官方强调"无平台加价"

## 是什么 / 解决什么问题

语音能力正在从"锦上添花"变成 Agent 的标配。一个能"看→想→说"的语音 Agent，需要三块拼图：**语音合成（TTS）** 输出、**语音转写（ASR）** 输入、以及**低延迟的流式交互**。过去这三块往往来自三家不同的供应商，开发者要维护三套 SDK、三份密钥、三份账单，还要自己处理各自的重试和故障转移逻辑。集成成本高、观测口径不统一，是语音 Agent 落地时最琐碎也最容易踩坑的一环。

这次 Vercel 与 Microsoft AI (MAI) 的合作，本质是把 MAI 的语音模型接进了 **AI Gateway** 这个统一入口。Vercel 官方说法是：AI Gateway 是"少数"能提供 MAI 模型访问的平台之一。也就是说，微软 MAI 的访问渠道依然稀缺，而 Vercel 拿到了其中之一。

从定位看，这次变化解决的并不是"模型能力"问题，而是**"分发与集成"问题**：模型还是微软的模型，但接入方式从"直接对接微软"变成了"在既有网关里多一个 `microsoft/...` 前缀的选型"。对已经在 AI Gateway 上的团队而言，等于零迁移成本地获得了一套语音栈。

另一个值得注意的信号是**数据治理**。官方明确提到 MAI 对安全和 **zero data retention（ZDR，零数据保留）** 的关注，与 Vercel 希望让用户"掌控数据、对其如何用于训练保持透明"的目标一致。对把语音数据（往往包含真实对话内容）喂给第三方模型的团队来说，ZDR 承诺是选型时的硬性考量之一。

## 技术架构拆解

### 核心设计决策

- **一组模型覆盖三个语音任务**：不是单一模型打天下，而是按"质量 / 延迟 / 流式"三个维度拆成三款，让开发者按场景选型。
- **统一走 AI Gateway 的单一 API**：官方描述 AI Gateway 提供"one API for calling models, tracking usage and cost, and viewing request traces"，并支持跨供应商的 routing、retries、failover。语音模型被纳入同一套观测与容错框架。
- **网关不计平台费、不加价**：官方明确 "bills these models at their listed rates, with no platform fee or markup on inference"。这是把网关定位为"透明路由器"而非"转售商"的关键信号。
- **AI SDK 一等公民**：接入示例直接使用 AI SDK 7 的 `generateSpeech` 与 `streamTranscribe`，说明这次集成是 SDK 层原生支持，而非仅提供裸 REST 端点。
- **流式转写以"增量返回"为核心语义**：`streamTranscribe` 返回 transcript updates，逐个 partial 推送，且在更多音频到达时**可被替换**——这决定了 UI 层必须能接受"回改"已显示文本。

### 三个模型的关键差异

| 维度 | MAI-Voice-2.1 | MAI-Voice-2.1-Flash | MAI-Transcribe-2 Streaming |
|------|---------------|---------------------|----------------------------|
| 任务 | 语音合成 (TTS) | 语音合成 (TTS) | 语音转写 (ASR，流式) |
| 定位 | 长文本、高质量、表达力强 | 低延迟、交互式 | 实时转写、边到边出 |
| 典型场景 | 旁白、有声书、播客、课程 | 语音 Agent、助手、spoken reply | 实时字幕、会议/对话跟随 |
| 语言 | 23 种语言 | 多语言（同系列） | 未在材料中明确（见下） |
| 音色一致性 | 官方强调"长段落音色一致" | 未强调 | 不适用 |
| 模型 ID | `microsoft/mai-voice-2.1` | `microsoft/mai-voice-2.1-flash` | `microsoft/mai-transcribe-2-streaming` |

> TODO: MAI-Transcribe-2 Streaming 支持的语种数量、各模型的具体定价（per-1M chars / per-minute）与首包延迟数据，官方 changelog 未给出，待补充。

### 与前版/竞品的关键差异

| 维度 | 直接对接微软 / 自建多供应商语音栈 | 本方案：MAI on Vercel AI Gateway |
|------|-----------------------------------|----------------------------------|
| 接入方式 | 单独申请、单独密钥、单独 SDK | 在既有 AI Gateway 内选型，统一 API |
| 账单与用量 | 多供应商分别对账 | 单网关统一计费与成本追踪 |
| 容错 | 自行实现重试/故障转移 | 网关原生 routing / retries / failover |
| 可观测性 | 各自为政 | 统一 request traces |
| 费用 | 视合同而定 | 官方声明"无平台费、无加价" |
| 供应商锁定 | 微软单点 | 网关内可跨供应商切换 |

### 架构/信息流图

```
┌──────────────────────────────────────────────────────────┐
│                   应用层 (AI SDK 7)                        │
│   generateSpeech()          streamTranscribe()            │
└───────────┬───────────────────────────┬──────────────────┘
            │ TTS 请求                    │ 音频流请求
            ▼                             ▼
┌──────────────────────────────────────────────────────────┐
│                    Vercel AI Gateway                      │
│  ┌────────────┬─────────────┬────────────────────────┐   │
│  │ 统一 API    │ 用量/成本追踪 │ request traces         │   │
│  ├────────────┴─────────────┴────────────────────────┤   │
│  │ routing · retries · failover（跨供应商）            │   │
│  └────────────────────┬───────────────────────────────┘   │
└───────────────────────┼──────────────────────────────────┘
                        │ 无平台费 / 按原价计费
                        ▼
┌──────────────────────────────────────────────────────────┐
│                    Microsoft AI (MAI)                     │
│  ┌────────────────┐ ┌──────────────────┐ ┌─────────────┐ │
│  │ MAI-Voice-2.1  │ │ Voice-2.1-Flash  │ │ Transcribe-2│ │
│  │ (长文/表达力)   │ │ (低延迟交互)      │ │ (流式转写)   │ │
│  └────────────────┘ └──────────────────┘ └─────────────┘ │
│  安全 + Zero Data Retention (ZDR)                        │
└──────────────────────────────────────────────────────────┘
```

## 实用评估

### 什么场景值得用

- **Vercel / AI SDK 生态内的语音 Agent**：如果你已经用 AI SDK 7 构建文本 Agent，加一个 `microsoft/mai-voice-2.1-flash` 就能让 Agent "说话"，无需引入新供应商和新密钥。这是本次集成最直接的收益场景。
- **长音频内容生产**：有声书、播客、课程旁白这类"长段落 + 音色一致性要求高"的场景，用 `MAI-Voice-2.1` 而非 Flash 版更合适——官方特别强调它在长段落里保持同一说话人音色。
- **实时字幕 / 会议转写**：`MAI-Transcribe-2 Streaming` 的 partial transcript 语义适合做 live caption，无需等整段录音结束。
- **多供应商容错需求**：网关的 routing/failover 让你可以在 MAI 与其它供应商之间做降级策略，而不是把鸡蛋放在一个篮子里。

### 什么场景不值得用

- **大规模批量 TTS 的成本敏感场景**：网关虽不加价，但"按原价计费"意味着它不会帮你省钱；高频 batch 合成需先算清单价是否可接受。
- **需私有化 / 自托管部署**：模型仍由微软托管，无法本地部署；受数据驻留、行业合规约束的场景不适用。
- **纯文本工作流**：这次发布是语音专用，与文本模型选型无关。
- **对转写语种有硬约束且未验证**：官方材料未列出 Transcribe 的语种覆盖，多语种客服场景需先实测。
- **极端延迟敏感**：虽然 Flash 主打低延迟，但官方未给出量化延迟指标，无法据此断言能否满足毫秒级要求。

### 迁移成本

| 从 | 到 | 工作量 | 注意事项 |
|---|---|---|---|
| 直接对接微软 MAI | AI Gateway | 低 | 换成网关模型 ID（`microsoft/...`），改密钥与 endpoint |
| 其它 TTS/ASR 供应商 | MAI on Gateway | 中 | 需重写调用代码为 AI SDK 的 `generateSpeech` / `streamTranscribe`，并重测音色与准确率 |
| 无语音能力 → 加语音 | MAI on Gateway | 低-中 | 需按场景选 Voice / Flash / Transcribe，并处理流式回改 UI |

> TODO: 官方未提供迁移工时估算，上述为按接口形态推断的量级判断，非官方数据。

## 对你的意义

对 Ken 的 AI 应用追踪线，这次更新有三个值得记录的信号：

1. **语音正在被"网关化"**：TTS/ASR 不再是独立的基础设施选型，而是被收编进统一网关的一个 `model` 参数。这意味着未来做语音 Agent 时，"选哪家语音"会像"选哪个文本模型"一样，发生在网关配置层，而不再是架构决策。这与 A-005（AI 工作流自动化成为企业增长场景）方向一致——语音交互是把工作流做"顺"的关键一环。

2. **"零数据保留 + 无加价"是网关竞争的新卖点**：Vercel 明确把 ZDR 与"无平台费"写进 changelog，说明统一网关赛道已从"能不能接"进入"接了之后数据与成本是否可信"的阶段。评估任何网关时，ZDR 与加价策略应列为必查项。

3. **AI SDK 原生集成 = 锁定加深**：用 AI SDK 的 `generateSpeech`/`streamTranscribe` 写代码，会让语音层与应用代码深度耦合。便利性换来的是迁移成本——这一点在选型时要有意识。

**建议**：若你近期在 AI SDK 生态内做语音相关的原型（尤其是语音 Agent 或实时字幕），可以**立即小试** `mai-voice-2.1-flash` 和 `mai-transcribe-2-streaming`，验证中文/多语种的实际表现与延迟。若只是纯文本工作流，则可以**观望**——等它演进到文本模型再评估。

## 关键代码/配置片段

以下片段直接引用自 Vercel 官方 changelog，未做改写。

**语音合成（AI SDK 7，Flash 模型 + Harper 音色）：**

```javascript
import { experimental_generateSpeech as generateSpeech } from 'ai';
import { writeFile } from 'node:fs/promises';

const result = await generateSpeech({
  model: 'microsoft/mai-voice-2.1-flash',
  text: 'Your order is ready for pickup.',
  voice: 'en-US-Harper:MAI-Voice-2.1-Flash',
  outputFormat: 'mp3',
});

await writeFile('response.mp3', result.audio.uint8Array);
```

> 官方说明：长音频（如旁白）请改用 `microsoft/mai-voice-2.1`。

**流式转写（假设 `microphoneStream` 是 16 kHz / 16-bit PCM 的 ReadableStream）：**

```javascript
import { experimental_streamTranscribe as streamTranscribe } from 'ai';

const stream = streamTranscribe({
  model: 'microsoft/mai-transcribe-2-streaming',
  audio: microphoneStream,
  inputAudioFormat: { type: 'audio/pcm', rate: 16000 },
});

for await (const part of stream.fullStream) {
  if (part.type === 'transcript-partial') {
    process.stdout.write(`\r${part.text}`);
  }
}

console.log(await stream.text);
```

> 官方提醒：partial transcript 会随更多音频到达而变化，**收到新的 partial 时应替换已显示文本**，而不是追加。

---
[← Back to Deep Dives](./README.md)
