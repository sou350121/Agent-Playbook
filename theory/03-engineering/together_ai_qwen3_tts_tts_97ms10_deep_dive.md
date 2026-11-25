---
auto_generated: true
---

# Together AI 上线 Qwen3 TTS：一门声音说十种语言，97ms 出首包音频 (Qwen3 TTS on Together AI: One Voice, Ten Languages, 97ms First Audio)

> 🔍 本文由 Moltbot 自动生成 | 2026-11-25
>
> **项目/工具**: Qwen3 TTS（12Hz 1.7B）· Together AI 托管服务
> **链接**: https://www.together.ai/blog/qwen3-tts
> **核心定位**: 一个把「谁在说」和「怎么说」拆开的开源 TTS——同一音色可换语气、换语言，托管在 Together 上并针对实时语音 agent 调优到 97ms 首包。

## ⚡ 快速判断（30 秒读完这段就够了）

## ⚡ 快速判斷（30 秒讀完這段就夠了）

- **一句話定位**：Qwen 开源（Apache 2.0）的 1.7B 指令可控 TTS，Together AI 提供 Serverless 托管，$20 / 100 万字符，首音频低至 97ms。
- **現在值得用嗎**：看场景——只要你的产品需要「一个品牌声音、多语言、可情绪调节」的实时语音，这是目前少见的一条腿走通的方案；纯中文单场景 TTS 没必要换。
- **適合場景**：跨语言客服/订单通知、实时语音 agent（LLM 边生成边说话）、需要统一品牌音色的多市场产品。
- **不適合場景**：需要词级时间戳做字幕对齐、需要 opus/aac/flac 输出、需要声音克隆（官方只给 9 个预设音色）。
- **與前版/竞品核心差異**：主流 TTS 是「一个 voice ID = 一种语言 + 一种情绪」；Qwen3 TTS 是「voice 管身份、instructions 管情绪、language 管语种」三者正交解耦。

## 是什么 / 解决什么问题

语音产品的老痛点是音色绑定：换语言要换模型、换情绪要换说话人，多语言产品最后往往变成「每个市场一套声音」，品牌一致性被技术细节吃掉。传统流程里，同一个商业推广用德语和日语念出来像是两个人——因为多数 TTS 的音色身份和语种是耦合的。

Qwen3 TTS 的设计恰好反着来。据 Together AI 官方 blog（2026-11-20 发布），模型把语音拆成三个相互独立的维度：`voice` 决定"是谁在说"，`instructions` 用自然语言描述"怎么说"（如 "excited and upbeat"、"angry and impatient"、"sad and disappointed"），`language` 决定文本语种。九个预设音色，每一个都支持全部十种语言：中文、英语、日语、韩语、德语、法语、俄语、葡萄牙语、西班牙语、意大利语。

Together AI 这边解决的是另一半问题：延迟。他们把 serving stack 针对 TTS 调优，使得流式请求下首包音频低至 97ms。这个数字对语音 agent 是关键门槛——人类对话的轮次间隙容忍度大约在几百毫秒量级，超过就会出现「对面在迟疑」的体感。官方没有公布 97ms 的硬件配置与并发条件，这一点需要在实际部署中自行验证（见下文局限）。

## 技术架构拆解

### 核心设计决策

- **身份 / 表达 / 语种三维解耦**：这是整篇文章里最值得记住的一点。voice 是"人"，instructions 是"表演"，language 是"台词"。三者组合的最坏情况是声学模型要为 9 × 10 × N 种情绪组合都保持音色一致，官方只宣称音色跨语言保持，情绪跨语种一致性未做量化声明。
- **小模型路线（1.7B，12Hz）**：模型卡显示的 `Qwen3-TTS-12Hz-1.7B` 命名暗示了 12Hz 的离散音频 token 帧率与 1.7B 参数量。低帧率意味着单位时间 token 数少，对首包延迟和流式友好；1.7B 让它有资格跑在消费级推理集群上，也因此能以 Serverless 形式计价。
- **双流式通道**：HTTP SSE（文本已知时用）与 WebSocket（文本还在生成时用）。这不是两个 API 的花样，而是对应两种真实拓扑——批量文本排程 vs. LLM token 流实时对接。
- **按字符计价，而不是按秒**：$20 / 1M 字符，对文本侧可控的成本模型；TTS 行业里按音频秒计价更常见，按字符计价的差别在于成本可预估性。
- **Apache 2.0 开源权重**：Hugging Face 上可取，托管只是加速选项，不是唯一入口。

### 与前版/竞品的关键差异

| 维度 | 常见托管 TTS（单语单情绪 voice） | Qwen3 TTS on Together |
|------|------------|------------|
| 音色身份 | 每种语言/情绪一个 voice ID | 9 个 voice，各支持 10 语种 |
| 情绪控制 | 选预置情绪模型或克隆样本 | 自然语言指令（instructions 字段） |
| 首包延迟 | 厂商差异大，通常数百 ms 起 | 官方称低至 97ms（流式） |
| 实时对接 | 多数只给 HTTP 一次性返回 | HTTP SSE + WebSocket append/commit |
| 计价 | 常见按音频秒 | $20 / 1M 字符 |
| 开源 | 多数闭源 | Apache 2.0，权重公开 |
| 词级时间戳 | 通常支持 | **不支持**（官方明确） |
| 音频格式 | 通常含压缩格式 | wav / mp3 / raw(PCM) / mulaw；**无 opus/aac/flac** |

### 架构/信息流图

```
              ┌───────────────────────────────┐
  LLM 输出流  →│  WebSocket: input_text_buffer.append → commit │
  （token 级）└───────────────────────────────┘
                              │  按句切分后合成
                              ▼
                   ┌────────────────────┐
 参数三元组 ──────→ │  Qwen3-TTS-12Hz-1.7B │ → base64 PCM(24kHz) delta 事件
 voice / language  └────────────────────┘        │
 instructions                                    ▼
                                          TTS 音频 → 播放器 / 电话链路
```

HTTP 路径则是：完整文本 + 三元组 → `stream=True, response_format="raw"` → SSE `conversation.item.audio_output.delta` 事件逐块返回 base64 PCM，每块为 24kHz 16-bit 单声道。

## 实用评估

### 什么场景值得用

- **多市场单一品牌音色**：电商订单通知、物流播报、跨境客服开场白。官方给出的例子正是同一条订单更新在英/西/德/日四语下保持 aiden 音色，这类需求过去需要给每个市场单独挑人。
- **实时语音 agent**：WebSocket 的 append/commit 语义天然匹配「LLM 边说边生成」——服务端等整句拼齐才合成，避免半句合成的断句怪音。对做语音前端的产品，这是省掉一层自研排队的收益。
- **情绪可调的交互叙事**：客服安抚、游戏 NPC、有声内容。instructions 用自然语言而非枚举情绪标签，覆盖面更宽。

### 什么场景不值得用

- **需要词级时间戳**：官方明确不支持 `alignment=word`。做字幕卡拉OK、逐词高亮的场景直接排除。
- **需要压缩音频格式**：不支持 opus/aac/flac。只有 wav/mp3/raw/mulaw，对带宽敏感的电话链路可能要自己做转码。
- **需要声音克隆/品牌定制音色**：只有 9 个预设。要求「必须是某位真人声音」的合规场景不适用。
- **中文方言重度场景**：预设里粤语没有覆盖，中文方言只有北京话（dylan）与四川话（eric），且其它语种都是标准语。吴语、粤语业务需另寻方案。
- **强确定性 SLA 的实时链路**：97ms 是"as little as"，官方未给出 p95 与并发条件。对延迟极敏感的对话产品，必须自测后再定。

### 迁移成本

- **从其它托管 TTS 迁移**：SDK 调用形态很标准（`client.audio.speech.create(...)`），主要改动在参数映射——把原来按情绪挑选 voice 的逻辑改成 `voice + instructions` 组合；情绪映射表需要按业务重新调。
- **实时链路改造**：若原来用一次性 HTTP 返回，切到 WebSocket append/commit 需要调整状态机（句子边界检测、断线重连、失败事件 `conversation.item.tts.failed` 的处理）。工作量约 1–3 人日，视现有链路成熟度。
- **自托管路线**：Apache 2.0 权重可取，但 97ms 是 Together 调优后的 servering 数字，自托管想复现需要自己啃推理优化。

## 对你的意义

如果你的 Agent + UI 方向涉及语音前端，这条更新值得放进候选清单而不是立即替换。理由很具体：你的关注点是 agent builder / visual workflow / chat UI，语音作为 chat UI 的一等入口迟早要接上；Qwen3 TTS 的价值不在音质军备竞赛，而在**接口语义**——voice / instructions / language 三分法把「品牌声音管理」变成配置问题而不是集采问题，这跟 visual workflow 的抽象思路是同构的。

建议路径：先用 Serverless 拿预设音色跑通一条「订单通知 + 情绪切换」的最小链路，实测你的目标语种（中/英/日）的首包延迟分布；如果你的语音链路需要 opus 或词级时间戳，直接判定不适用，别在后期才发现。语音 agent 的架构选型细节，建议对照 `theory/03-engineering` 下已有的 agent harness 条目一起看。

## 关键代码/配置片段

最小调用（来自官方 blog 示例原文）：

```python
from together import Together
client = Together()
response = client.audio.speech.create(
    model="Qwen/Qwen3-TTS-12Hz-1.7B",
    input="Well, that changes everything.",
    voice="aiden",                                     # who speaks
    language="en",                                     # the language of the text
    extra_body={"instructions": "excited and upbeat"},  # how to say it
    response_format="mp3",
)
response.write_to_file("excited.mp3")
```

⚠️ 官方特别提醒：Python SDK 里 `instructions` 必须放在 `extra_body` 中，**字段拼错会被静默跳过、不报错**。这是最容易踩的坑。

WebSocket 逐片送文本（节选官方示例）：

```python
URL = (
    "wss://api.together.ai/v1/audio/speech/websocket"
    "?model=Qwen/Qwen3-TTS-12Hz-1.7B&voice=aiden&language=en"
    "&response_format=pcm&sample_rate=24000"
)
# append 文本片段 → commit → 收到 conversation.item.audio_output.delta 事件
await ws.send(json.dumps({"type": "input_text_buffer.append", "text": "Your order has shipped. "}))
await ws.send(json.dumps({"type": "input_text_buffer.append", "text": "It should arrive on Thursday."}))
await ws.send(json.dumps({"type": "input_text_buffer.commit"}))
```

参数约束（官方文档口径）：`response_format` 限 `wav/mp3/raw/mulaw`；`sample_rate` 为 24000（默认）或 8000；支持 9 个音色 aiden / ryan / vivian / serena / uncle_fu / dylan / eric / ono_anna / sohee；官方建议**用音色的母语使用效果最佳**（例如 vivian/serena/uncle_fu 是中文母语，ono_anna 日语，sohee 韩语）。

> TODO: 音质客观指标（MOS / WER / 说话人相似度）官方 blog 未给出，若需量化对比需自行评测或查阅 Qwen 模型卡。

---
[← Back to Deep Dives](./README.md)
