# 提示模式速查（Prompt Patterns）

> 5 大主流 prompting 范式 × 应用场景 × 何时不要用

---

## 📊 速查总表

| 模式 | 场景 | 优 | 劣 | Anthropic 推荐？ |
|------|------|----|-----|:---:|
| **Few-shot (N-shot)** | 模式提取、结构对齐 | 简单 · 解释力 | token 占用 | ✅ 3-5 shot 推荐 |
| **Chain-of-Thought (CoT)** | 数学、多步推理 | 显著提升正确率 | 慢 · token 多 | ✅ 但用 thinking 字段更好 |
| **ReAct (Reasoning + Action)** | Agent 工具调用 | 透明思考链 | 易陷入循环 | ⚠️ 已被 Tool Use 原语取代 |
| **Reflexion / Self-Critique** | 长任务复杂决策 | 自纠正 | 多轮 token 翻倍 | ⚠️ 仅长任务 |
| **XML 结构化 / Tool Use** | 严格输出格式 | 可解析 / 可类型化 | 学习成本 | ✅ Anthropic 一等公民 |

---

## 1. Few-shot Prompting

### 核心原则
📎 Anthropic 官方建议：从 1-shot 起步，按需加到 **3-5 shot**（[Claude prompt engineering best practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices)）。Claude 4.x 对 examples 中的细节敏感，**质量 > 数量**。

### 标准模板（XML 包裹推荐）
```xml
<examples>
  <example>
    <input>{example 1 input}</input>
    <output>{example 1 expected output}</output>
  </example>
  <example>
    <input>...</input>
    <output>...</output>
  </example>
</examples>

<task>
  <input>{actual user input}</input>
</task>
```

### 关键技巧
- 📎 **Diverse 不要 redundant**：4 个相似 example < 4 个覆盖不同 edge case 的 example
- 📎 **Order matters**：放最相关的 example 在最后
- 🧠 **复杂任务下，Few-shot > System prompt 描述**：举例胜过解释
- 🧠 **不要在 examples 里放幻觉**：Examples 是模型最强先验，错的 example 会成为 anchor

### 何时不用
- 🚫 已有 fine-tuned 模型：fine-tune 已经"内化"了 examples
- 🚫 输出非常自由（创意写作）：example 反而限制多样性

---

## 2. Chain-of-Thought (CoT)

### 核心原则
📎 [Wei et al. 2022](https://arxiv.org/abs/2201.11903)：在数学/推理任务中提示模型"逐步思考"，准确率显著提升（GSM8K 17% → 57%）。

### 经典触发
```
Let's think step by step.
让我们一步一步思考。
```

### 现代版本（推荐）

**Anthropic Extended Thinking**（自 Claude 3.7+）：
```python
response = client.messages.create(
    model="claude-opus-4-7",
    thinking={"type": "enabled", "budget_tokens": 16000},
    messages=[...]
)
```
📎 模型自动产出 `<thinking>` 块，**比 user-side prompt CoT 更高质量**。

**OpenAI o-series**：内置 reasoning，**不需**用户加 CoT prompt。

### 何时不用
- 🚫 简单分类 / 提取任务：CoT 反而拖慢
- 🚫 需要严格输出格式时：CoT 把无关 reasoning 混进答案
- 🚫 极度成本敏感：CoT 通常 +50%-200% token

---

## 3. ReAct (Reasoning + Action)

### 核心论点
📎 [Yao et al. 2022](https://arxiv.org/abs/2210.03629)：Agent 思考与行动交错，每一步显式 `Thought → Action → Observation → Thought ...`

### 经典模板
```
Thought: 我需要查找 X 的最新数据
Action: search_tool(query="X latest")
Observation: ...
Thought: 现在我有了数据，需要总结
Action: respond(summary="...")
```

### 2026 现状
🧠 **已被现代 Tool Use 原语取代**：
- OpenAI Function Calling / Structured Outputs
- Anthropic Tool Use API
- 这些 API **隐式做 ReAct**，不用用户在 prompt 里硬编

### 何时还要写 ReAct prompt
- ✅ 用没有 Tool Use API 的小模型（开源 7B 等）
- ✅ 教学 / 透明审查 reasoning
- 🚫 用 Claude / GPT-4+：直接用 Tool Use 原语

---

## 4. Reflexion / Self-Critique

### 核心原则
📎 [Shinn et al. 2023](https://arxiv.org/abs/2303.11366)：Agent 完成任务后，让它**反思**结果质量，再修正。

### 模板
```
Step 1: 给出初版答案
Step 2: 用一个独立 prompt 评估第 1 步答案的质量与缺陷
Step 3: 基于反思修正答案
```

### 实战形式
- **LLM-as-a-Judge**：用第二个 LLM call 评分
- **Constitutional AI**：📎 Anthropic 训练时就在做（多轮 critique-revise）
- **Best-of-N**：生成 N 次，让 LLM 选最好的

### 何时用
- ✅ 长任务、容错率高、可重试
- ✅ 评分标准复杂（不只是分类）

### 何时不用
- 🚫 实时对话：延迟翻倍
- 🚫 简单提取：纯属浪费 token
- 🚫 OpenAI o-series：内置 reasoning 已 cover

---

## 5. XML 结构化 + Tool Use（Anthropic 一等公民）

### 核心原则
📎 Anthropic 官方：**Claude 模型在训练时大量见过 XML 标签**，使用它们能显著提升结构化输出可靠性。

### 标准 XML 模式
```xml
<context>
  <user_query>{query}</user_query>
  <relevant_docs>
    <doc id="1">{doc 1 content}</doc>
    <doc id="2">{doc 2 content}</doc>
  </relevant_docs>
</context>

<instructions>
1. 只引用 <relevant_docs> 内的内容
2. 在 <answer> 标签内回答
3. 在 <citations> 标签内列出引用的 doc id
</instructions>
```

### Tool Use（结构化动作）
```python
tools = [{
    "name": "search_papers",
    "description": "Search arxiv for VLA papers",
    "input_schema": {
        "type": "object",
        "properties": {
            "query": {"type": "string"},
            "max_results": {"type": "integer"}
        },
        "required": ["query"]
    }
}]
```
📎 模型自动判断**何时**调用，**输入**符合 schema —— 比 ReAct prompt 工程化得多。

### 关键 Anthropic 提示工程铁律

1. 📎 **System prompt 放角色 + 顶层规则**，user message 放具体 input
2. 📎 **CoT in `<thinking>` tags**：让模型先想再答
3. 📎 **Pre-fill assistant message** 强制特定格式：
   ```python
   messages=[
       {"role": "user", "content": "..."},
       {"role": "assistant", "content": "<answer>"}  # ← prefill
   ]
   ```
4. 📎 **Long context (100K+ tokens)**：把指令放**最后**，因为 Claude 倾向于关注最近的 token

---

## 🧠 综合最佳实践（作者总结）

### Tier 1（必须做）
- ✅ XML 包裹结构化输入（context / instructions / examples）
- ✅ 3-5 shot examples（多样、覆盖 edge case、顺序排好）
- ✅ Tool Use API（不要手写 ReAct）
- ✅ 复杂任务用 Extended Thinking 或 o-series

### Tier 2（项目中后期）
- ✅ Constitutional / Self-critique 在 high-stakes 输出（法律、医疗）
- ✅ Pre-fill assistant message 强制格式
- ✅ Prompt caching 大 system prompt（[Anthropic prompt caching](https://docs.anthropic.com/)）

### 不要做
- ❌ 在 examples 里写错答案（成 anchor）
- ❌ 100 行散文式 system prompt（用结构化 XML）
- ❌ Few-shot N>10（边际负收益）
- ❌ 给 GPT-4 / Claude 写"Let's think step by step"（已内置）

---

## 📚 延伸

- [Agent 设计：context engineering](../theory/03-engineering/context-engineering-field-guide.md)
- [Agent 评测](./evaluation.md) · 不同 prompt 模式怎么 eval
- [失效模式 T2 reasoning gap](./failure-modes.md)
- 📎 [Anthropic Prompt Engineering Guide](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/overview)

---

[← Back to Cheat Sheet](./README.md)
