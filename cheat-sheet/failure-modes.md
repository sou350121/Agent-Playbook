# Agent 失效模式 T1-T6（Failure Taxonomy）

> 🧠 基于 [theory/03-engineering/agent-failure-taxonomy](../theory/03-engineering/agent-failure-taxonomy.md) 的速查版
> Debug Agent 时的第一步：用 T1-T6 定位失效类别

---

## 🚨 一张速查表（贴墙上）

| 类别 | 名字 | 症状 | 根因 | 首选检测 |
|------|------|------|------|---------|
| **T1** | Scope Leak | Agent 做了你没让它做的事 | Task packet 不完整 / 隐式假设 | Trace 检视 + intent 标注 |
| **T2** | Reasoning Gap | Agent 走错路径但确信 | Prompt 信息不足 / 缺工具 | Step-level grader · CoT 审查 |
| **T3** | Tool Misuse | 调对工具但参数错 | Schema 模糊 / 缺 example | Tool call accuracy eval |
| **T4** | Memory Drift | 上下文丢失 / 记错事实 | Context window 失序 / RAG 召回差 | Memory test set + Hallucination check |
| **T5** | Recovery Failure | 失败后卡死 / 不会重试 | 没设计 fallback / retry 策略 | Inject 故障 · 看是否 graceful |
| **T6** | Trust Collapse | 该 escalate 时没找人 | 信任层级模糊 | Trust tier audit · escalation log |

---

## 🔴 T1 · Scope Leak（范围越界）

### 症状
- Agent **做了你没让它做的事**：例如要它整理收件箱，它顺便回复了几封邮件
- 看 trace 像"模型 helpfulness 太高"
- 在生产环境 = 安全 / 合规风险

### 根因
1. **Task packet 缺少明确边界**："整理邮件" vs "整理但不发送/回复任何内容"
2. **Agent 的 disposition** 偏 helpful（Anthropic Claude 训练目标之一）
3. **隐式假设**：开发者觉得"显然不会做 X"，Agent 不这么想

### 检测
- ✅ **Trace 检视**：看 Agent 实际动作序列，对比预期边界
- ✅ **Intent 标注**：每个工具调用前要 Agent 输出 intent，再 vs scope 比对
- ✅ **Permissions audit**：限制工具能力（write 工具只能写特定路径）

### 修复
- 📎 **Task Packet 明确写**："不允许 X / 只能在 Y 范围 / 遇到 Z 必须 stop"
- 📎 **使用 Trust Tier**：T0 工具完全自动 / T1 需要 review / T2 需要人确认
- 📎 **Subagent 隔离**：用 Claude Subagents 把高风险动作放进受限子 agent

---

## 🔴 T2 · Reasoning Gap（推理鸿沟）

### 症状
- Agent **走了错的逻辑路径但很确信**
- CoT 看起来合理，结论荒谬
- "对的方向" + "错的细节" 同时出现

### 根因
1. **Prompt 信息不足**：模型必须靠先验填补
2. **缺工具**：模型只能 hallucinate 而不能查实
3. **Context 顺序**：关键信息埋在中间被忽略（middle is forgotten）

### 检测
- ✅ **Step-level grader**：每步推理打分，不只看最终答案
- ✅ **Counterfactual prompt**：去掉一个 context 元素，看推理是否变化
- ✅ **CoT thought 审查**：用 LLM-Judge 评 reasoning chain 质量

### 修复
- 📎 **Few-shot 示范正确推理路径**（4-shot sweet spot）
- 📎 **加 Tool Use** 让模型查实而非假设
- 📎 **关键信息放最后**（Anthropic 长 context 实证）
- 📎 **Extended Thinking** / o-series 内置 reasoning

---

## 🔴 T3 · Tool Misuse（工具错用）

### 症状
- Agent **挑对了工具，但参数填错** / 顺序错 / 调用过多
- 例：search 工具被反复调用同样的 query
- Tool error 反复相同 → 不学习

### 根因
1. **Schema 描述模糊**："query: string" 没说要 keyword 还是 NL question
2. **缺 example**：tool description 没有"correct usage" 范例
3. **没看 tool error**：error message 没设计成可教学

### 检测
- ✅ **Tool Call Accuracy** eval：参数 vs ground truth
- ✅ **Repetition detector**：相同参数调用 N 次报警
- ✅ **Error response analysis**：模型读到 error 后下一步动作是否合理

### 修复
- 📎 **Schema 写详细**：包括 example values + 何时用 / 何时不用
- 📎 **Tool description 加 anti-pattern 警告**："Don't use this for X"
- 📎 **结构化 error response**：`{"error": "...", "suggestion": "..."}` 引导下一步

---

## 🔴 T4 · Memory Drift（记忆漂移）

### 症状
- Agent **忘了 5 步前的事** / 重复同样的工作 / 对事实记错
- RAG 系统中 hallucination 率高
- 长会话越走越偏

### 根因
1. **Context window 内容失序**：早期信息被 truncate / overshadow
2. **RAG 召回差**：检索器没拿到关键文档
3. **状态没显式维护**：依赖 LLM 自己"记得"

### 检测
- ✅ **Memory test set**：在 N 步后问"刚才发生了什么"
- ✅ **Hallucination check**：用 fact-checker LLM 对照 source
- ✅ **Recall@K** for RAG：retriever 评估独立做

### 修复
- 📎 **显式 state**（不依赖 context window）：LangGraph checkpointer / Mastra Workflow state
- 📎 **Summarize-then-forget**：长 trace 摘要后清掉细节
- 📎 **Hybrid search**（稠密 + 稀疏）改善 RAG 召回
- 📎 **Cite sources**：要求每个事实陈述带 citation，可机器验证

---

## 🔴 T5 · Recovery Failure（失败恢复失败）

### 症状
- 出错后 Agent **卡死** / 重复同样错误 / 直接放弃
- 没有"fallback path"概念
- 用户必须手动重启

### 根因
1. **没有 retry / fallback 策略**：tool 报错就 propagate 上层
2. **No graceful degradation**：MCP server down → Agent 整体崩
3. **训练分布不含失败案例**：模型没见过"如何从错误恢复"

### 检测
- ✅ **Fault injection**：故意让 tool 返回 error，看 Agent 怎么处理
- ✅ **Recovery rate** 指标：故障后任务仍完成的比例
- ✅ **Trace cycle detection**：检测无限循环 / 重复模式

### 修复
- 📎 **Retry policy**：tool wrapper 内置 backoff retry
- 📎 **Fallback chain**：tool A fail → 试 tool B → 升级 human
- 📎 **Circuit breaker**：N 次连续失败 → escalate
- 📎 **训练时纳入 recovery demo**：用 RoboMIND 2.0 类思路（VLA 域类比）

---

## 🔴 T6 · Trust Collapse（信任坍塌）

### 症状
- Agent **该 escalate 时不 escalate**：处理了 high-stakes 决策没找人
- 反过来：**该自动时频繁打扰人**：信任分层失效
- 用户对 Agent 既不敢放手又被打扰

### 根因
1. **信任层级模糊**：什么时候自动 / 什么时候人介入没明确
2. **No escalation hooks**：架构上没有 escalation API
3. **测试不到位**：开发只测 happy path，没测"不确定时"

### 检测
- ✅ **Trust tier audit**：把任务按风险/可逆性分级，看 Agent 是否对应分层
- ✅ **Escalation log analysis**：人介入频次 / 必要性 vs 实际
- ✅ **Confidence calibration**：让 Agent 输出置信度，对照实际正确率

### 修复
- 📎 **明确 Trust Tier**（参考 [trust-tier-design](../theory/03-engineering/trust-tier-design.md)）：
  - **T0**：完全自动（reversible · low-stakes）
  - **T1**：do-and-tell（auto + 通知）
  - **T2**：propose-then-act（要 approval）
  - **T3**：human-only（high-stakes / irreversible）
- 📎 **Escalation primitives**：提供 `request_human_review()` API
- 📎 **Confidence threshold**：< 0.8 自动升级

---

## 🎯 Debug 决策树（真机/生产 Agent 出问题时）

```
Agent 行为异常
│
├─ Trace 看 Agent 动作 vs 任务说明
│   ├─ 做了不该做的 → T1 Scope Leak
│   └─ 该做的没做 ↓
│
├─ 看 reasoning chain
│   ├─ 推理跳错 → T2 Reasoning Gap
│   └─ 推理 OK 但 tool 调错 → T3 Tool Misuse
│
├─ 检查 long-context / memory
│   ├─ 早期信息被忘 → T4 Memory Drift
│   └─ Memory OK ↓
│
├─ 看错误处理
│   ├─ 故障后卡死 → T5 Recovery Failure
│   └─ 故障 OK 但决策不该自己做 → T6 Trust Collapse
│
└─ 都不像 → 检查 prompt / model selection / data
```

---

## 📐 失效频次分布（🧠 作者经验）

| 类别 | 占比 | Top 修复 ROI |
|------|:---:|------------|
| T2 Reasoning Gap | ~35% | 加 Few-shot + Extended Thinking |
| T3 Tool Misuse | ~25% | Schema 写详细 + tool example |
| T4 Memory Drift | ~15% | Explicit state + RAG 改善 |
| T1 Scope Leak | ~10% | Task packet 明确 + Trust Tier |
| T5 Recovery Failure | ~10% | Retry / Fallback policy |
| T6 Trust Collapse | ~5% | Trust Tier + escalation |

---

## 📚 延伸阅读

- 📎 [agent-failure-taxonomy](../theory/03-engineering/agent-failure-taxonomy.md) · 完整理论
- 📎 [trust-tier-design](../theory/03-engineering/trust-tier-design.md) · T6 治理
- 📎 [delegation-not-automation](../theory/03-engineering/delegation-not-automation-engineering-principles.md) · T1 哲学
- [Eval](./evaluation.md) · 怎么 eval 这些失效
- [Frameworks](./frameworks.md) · 哪些框架原生支持 retry / fallback / escalation

---

[← Back to Cheat Sheet](./README.md)
