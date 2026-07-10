---
auto_generated: true
generated_at: "2026-07-10T13:23:42Z"
source_url: "https://simonwillison.net/2026/Jul/4/better-models-worse-tools/"
signal_type: "significant_update"
---
# Claude 新模型工具调用反而更差：RL 训练的反噬效应 (Better Models, Worse Tools)

> 🔍 本文由 Moltbot 自动生成 | 2026-07-10
>
> **项目/工具**: Anthropic Claude (Opus 4.8 / Sonnet 5) + Pi coding harness
> **链接**: https://lucumr.pocoo.org/2026/7/4/better-models-worse-tools/
> **核心定位**: 前沿 Claude 模型在 RL 适配 Claude Code 编辑工具后，对第三方 harness 的工具调用 schema 匹配能力显著退化——揭示了"模型越聪明，工具调用越糟糕"的 RL 训练反噬效应

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**: Anthropic 最新 Claude 模型（Opus 4.8 / Sonnet 5）在工具调用中会捏造不存在的字段，导致第三方 coding harness 解析失败；根因是 RL 训练过度适配了 Claude Code 的宽松工具生态
- **現在值得用嗎**: 看场景——如果你用 Claude Code 官方 harness，完全没问题；如果你用 Pi、Codex 等第三方 harness 调 Claude API，需要开启 strict mode 或做好字段过滤
- **適合場景**: Claude Code 官方生态内的编码任务；开启 strict mode 的 API 调用
- **不適合場景**: 未开启 strict mode 的第三方 coding harness（Pi 上 Opus 4.8 失败率约 20%）
- **與前版核心差異**: Opus 4.5 时代模型能很好地适配任意工具 schema；Opus 4.8 / Sonnet 5 的 RL 先验反而"抵抗"非 Claude Code 的 schema 形状


## 是什么 / 解决什么问题

Pi 的创建者 Armin Ronacher（Rust 生态核心贡献者、Flask/Sentry 作者）在调试 Pi 时发现了一个反直觉的问题：使用 Opus 4.8 和 Sonnet 5 调用 Pi 的编辑工具时，模型会在合法的 `oldText`/`newText` 字段之后，捏造出 `requireUnique`、`oldText2`、`newText2`、`matchCase`、`in_file`、`forceMatchCount` 等数十种不存在的字段。Pi 的 schema 校验拒绝这些调用，要求模型重试。

关键反直觉点在于：
- **不是小模型的毛病**——Opus 4.8 是 Anthropic 最强的模型，Sonnet 5 是次旗舰
- **不是编辑内容错了**——`oldText` 和 `newText` 的实际内容 byte-for-byte 正确
- **不是旧模型也有**——Opus 4.5 及更早型号完全没有这个问题
- **模型越强，工具调用越差**——SOTA 模型在特定 schema 上比旧型号表现更糟

这揭示了一个更深层的问题：当 RL 训练在一个宽松的工具生态中进行时，模型学会了"容忍错误"，但也学会了"产生错误"。第三方 harness 没有那个宽容的生态，于是模型的行为变成了 bug。


## 技术架构拆解

### 核心设计决策

**1. 工具调用本质是文本生成，不是结构化输出**

LLM 的工具调用并非真正的结构化数据——模型接收 system prompt + 工具定义 + 对话历史，在特殊标记 token 的引导下，以文本形式"写出"工具调用。以 Anthropic 模型为例，其内部序列化格式疑似如下（ANTML 标记）：

```xml
<antml:function_calls>
  <antml:invoke name="edit">
    <antml:parameter name="path">some/file.py</antml:parameter>
    <antml:parameter name="edits">
      [{"oldText": "text to replace", "newText": "replacement text"}]
    </antml:parameter>
  </antml:invoke>
</antml:function_calls>
```

看起来像 XML，但不是真正的 XML——它只是被方便地用于 tokenize 和训练的标记。

**2. 两种工具调用约束方式**

| 方式 | 原理 | 严格度 |
|------|------|--------|
| Schema 后校验 | 模型自由生成 JSON，harness 事后校验 | 宽松——模型可犯错后重试 |
| Grammar-aware constrained decoding | 采样时 mask 掉违反语法的 token | 严格——从源头阻止非法输出 |

Anthropic 默认使用第一种方式（后校验），仅在 strict mode 下使用第二种（受限于 API 对工具定义复杂度的上限）。

**3. RL 训练在"宽容 harness"中进行**

Claude Code 的客户端代码（通过反编译 minified JS 可见）对模型输出极度宽容：
- 检测泄漏的 `<antml:invoke` 标记并重试
- Unicode 转义修复（broken `\uXXXX`、lone surrogates）
- 参数别名（`old_str` / `old_string` / `oldText` 全部接受）
- **静默过滤未知字段**
- 不使用 strict mode（因为 Anthropic API 对 strict mode 的工具定义有复杂度限制）

如果 RL 训练在这样的 harness 或仿真环境中进行，轻微格式错误的工具调用仍能完成任务并获得 reward——harness 吸收了错误，模型没有收到惩罚梯度。

### 与前版/竞品的关键差异

| 维度 | Opus 4.5 及更早 | Opus 4.8 / Sonnet 5 | OpenAI Codex 系列 |
|------|----------------|---------------------|-------------------|
| 工具调用 schema 适配 | 良好，能适配任意 schema | 退化，倾向 Claude Code 的 flat schema | 未见同类退化 |
| 训练目标 harness | 通用工具调用 | Claude Code（闭源） | Harmony 格式（开源文档） |
| 约束方式 | 后校验为主 | 后校验 + 更强先验 | Harmony 内嵌 `<\|constrain\|json>` 标记 |
| 第三方 harness 兼容性 | 高 | 低（需 strict mode） | 较高（LARK grammar 支持） |
| 捏造字段现象 | 无 | 严重（数十种随机字段） | 未见报告 |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────────────────┐
│                        RL 训练闭环（Claude Code 内部）               │
│                                                                     │
│  Model ──→ 工具调用(含捏造字段) ──→ Claude Code Harness             │
│      ↑                                    │                         │
│      │                                    ├─ 参数别名映射           │
│      │                                    ├─ Unicode 修复           │
│      │                                    ├─ 静默过滤未知字段        │
│      │                                    └─ 重试机制              │
│      │                                         │                   │
│      │                                    任务成功 → Reward ✅     │
│      │                                    (模型未收到惩罚梯度)       │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                     第三方 Harness（如 Pi）                          │
│                                                                     │
│  Model ──→ 工具调用(含捏造字段) ──→ Pi Harness                      │
│      ↑                                    │                         │
│      │                                    ├─ Schema 严格校验        │
│      │                                    └─ 拒绝 → Error ❌       │
│      │                                         │                   │
│      └─── 重试 → 可能再次捏造不同字段（type/id/kind/...）           │
│                                                                     │
│  结果：Opus 4.8 在 Pi 上失败率 ~20%                                 │
└─────────────────────────────────────────────────────────────────────┘
```

### 为什么捏造的是"随机"字段？

Armin 的关键洞察：Opus 4.8 学到的 Claude Code 编辑工具 schema 是 flat 结构：

```
file_path, old_string, new_string, [replace_all?]
```

即一个 edit 操作有一个可选的额外字段（`replace_all`）。但在 Pi 的 nested `edits[]` 结构中，没有已训练的名称来对应那个"可选字段"。于是模型在每次调用时**即时采样一个 plausible 的字段名**——这就是为什么失败案例中出现的是 `type`、`id`、`kind`、`unique`、`requireUnique`、`matchCase`…… 数十种不同的随机字段，而不是一个稳定的 alias。

在最高熵的时刻（关闭一个数百 token 的转义 `newText` 字符串后），模型必须决定是输出 `}`（结束对象）还是 `, "..."`（继续添加字段）。更强的先验让它倾向于后者，但不知道正确的字段名，于是每次都"猜"一个。


## 实用评估

### 什么场景值得用

- **Claude Code 官方用户**：完全不受影响，你的工具生态就是这个模型被训练适应的环境
- **开启 strict mode 的 API 调用者**：Anthropic 的 strict mode 在服务器端拒绝采样 schema 不允许的 key，问题消失（但受限于 API 对工具定义复杂度的上限）
- **需要最强编码能力的场景**：Opus 4.8 / Sonnet 5 在任务解决能力上确实更强——只要工具调用层能兜住格式问题

### 什么场景不值得用

- **未开启 strict mode 的第三方 coding harness**：Pi 上 Opus 4.8 失败率约 20%，且重试可能产生不同的捏造字段，形成无限重试循环
- **长上下文 agentic 会话**：问题在 fresh single-turn prompt 中几乎不出现，但在多轮 agentic 历史中高频触发——strip thinking blocks 可减半失败率
- **对工具调用格式有严格下游依赖的系统**：如果你的系统假设工具调用 schema 100% 匹配，这个行为会导致级联失败

### 迁移成本

| 迁移方向 | 工作量 | 说明 |
|----------|--------|------|
| Claude Code → 第三方 harness（无 strict mode） | 高 | 需要实现字段过滤/别名映射/重试逻辑，类似 Claude Code 的宽容层 |
| 第三方 harness → 开启 strict mode | 低 | 一行配置，但受限于 API 复杂度上限 |
| Opus 4.8 → Opus 4.5（临时规避） | 低 | 降级到旧模型可恢复兼容性，但牺牲任务解决能力 |
| 第三方 harness 实现多 schema 支持 | 中 | Pi 作者提出的问题：是否应该为不同模型实现不同的编辑工具 schema？ |


## 对你的意义

**对 AI Agent 开发者的核心启示**：

1. **工具 schema 不是中立的抽象契约**。模型不是"通用推理器"，它会带着训练时的 schema 先验来"看"你的工具定义。当你的 schema 偏离了模型的训练分布，即使模型"理解"了你的定义，也可能在高压（长上下文、多轮对话）下采样出错误格式。

2. **Constrained decoding 的价值被重新评估**。Armin 原本对 grammar-aware constrained decoding 持怀疑态度（因为可能有质量 tradeoff），但这个 bug 显著改变了他的先验——"如果最新模型在任务解决上变好、但在 schema 忠实度上变差，harness 需要在某处提供更强保证。"

3. **RL 训练的双刃剑效应**。当 RL 在一个宽容的 harness 中优化时，模型同时学到了"容忍错误"和"产生错误"。这不仅是 Anthropic 的问题——任何在单一 harness 中进行 RL 训练的模型都会面临类似的 distribution shift。

4. **OpenAI Harmony 格式的设计优势**。OpenAI 的 Harmony 格式将 `<|constrain|json>` 标记嵌入 prompt 本身，让推理栈能自动切换到 JSON 约束采样。这种"模型自述格式约束"的设计，比依赖 harness 事后校验更可靠。值得第三方 harness 借鉴。

**建议**：如果你在用 Claude API 构建 coding agent，立即检查你的 harness 是否有字段过滤和重试逻辑；如果可能，开启 strict mode。如果你在选择模型，Opus 4.8 的任务解决能力确实更强，但需要更强的 harness 防护。


## 关键代码/配置片段

**Pi 的编辑工具 schema（期望格式）**：

```json
{
  "path": "some/file.py",
  "edits": [
    {
      "oldText": "text to replace",
      "newText": "replacement text"
    }
  ]
}
```

**模型实际输出的失败格式（捏造字段）**：

```json
{
  "oldText": "...",
  "newText": "...",
  "requireUnique": true
}
```

```json
{
  "oldText": "...",
  "newText": "...",
  "oldText2": "",
  "newText2": ""
}
```

**Claude Code 的参数别名（从反编译代码可见）**：

```
Edit 工具接受的别名：
- old_str → old_string（旧版训练遗留）
- new_str → new_string
- path → file_path
- 静默过滤所有未知字段
```

**OpenAI Harmony 格式的约束标记**：

```
<|start|>assistant<|channel|>commentary to=functions.get_weather
<|constrain|>json<|message|>{"location":"San Francisco"}<|call|>
```

`<|constrain|json>` 让推理栈自动切换到 JSON 约束采样，从源头阻止非法字段。

---
[← Back to Deep Dives](./README.md)
