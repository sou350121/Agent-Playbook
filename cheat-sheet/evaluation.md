# Agent 评测体系（Evaluation）

> 6 大主流 eval 工具 × 评测策略 × 关键指标
> **核心论点**：📎 评测是生产实践，不是测试阶段的事 —— eval loop 嵌入生产流程而非事后

---

## 📊 6 大评测工具速查

| 工具 | 出品方 | 重心 | 集成 | 价格 |
|------|-------|------|------|------|
| **[LangSmith](https://smith.langchain.com/)** | LangChain | trace + dataset + eval（一体） | LangChain/Graph 原生 | Free 5K traces · $39 起 |
| **[Braintrust](https://www.braintrust.dev/)** | Braintrust | 通用 eval-as-code · 强 dataset | 任何框架 | Free 1K events · $$ |
| **[Phoenix (Arize)](https://phoenix.arize.com/)** | Arize | OpenTelemetry-based · 自托管 | OTel 标准 | Open source · 自托管免费 |
| **[Inspect AI](https://inspect.aisi.org.uk/)** | UK AI Safety Institute | 严肃 benchmark eval | Python | Open source · 免费 |
| **[Promptfoo](https://promptfoo.dev/)** | Promptfoo | YAML config · CI 友好 | 任何 | Open source · Cloud $$ |
| **[DeepEval](https://github.com/confident-ai/deepeval)** | Confident AI | pytest-style · Python 原生 | Python | Open source · Cloud $$ |

### 选型决策

```
你的需求？
│
├─ 用 LangChain/LangGraph
│   └─ LangSmith（最顺滑）
│
├─ Production scale + 团队协作
│   └─ Braintrust（最成熟） · LangSmith
│
├─ 自托管 / 数据合规要求
│   └─ Phoenix（OTel · 自托管）
│
├─ 严肃学术 / 安全性 benchmark
│   └─ Inspect AI（UK AISI 出品 · 引用学术多）
│
├─ CI / Pull Request 集成
│   └─ Promptfoo（YAML · GitHub Action 友好）
│
└─ 已有 Python 测试栈
    └─ DeepEval（pytest 风格无缝接入）
```

---

## 🎯 评测的 3 个关键问题（先想清楚再选工具）

### Q1：你 eval 的是什么？

| 评测层 | 例子 | 工具关注点 |
|------|------|----------|
| **单 LLM call** | 翻译质量、摘要质量 | Promptfoo · DeepEval |
| **Tool use 正确性** | 调对工具？参数对？ | LangSmith · Braintrust |
| **Agent 完成任务** | 端到端 task success | Inspect AI · LangSmith |
| **Multi-agent 流程** | 协作正确？记忆对？ | LangSmith · Phoenix |
| **生产 trace** | 实际用户怎么用 | All（trace 监控） |

### Q2：用什么作 ground truth？

| 来源 | 优 | 劣 |
|------|----|----|
| **人工标注** | 准确 | 慢 · 贵 |
| **LLM-as-a-Judge** | 快 · 可扩展 | bias · 需 calibration |
| **Programmatic** | 客观 · 可重复 | 仅适合可形式化任务 |
| **Production trace + 用户反馈** | 真实分布 | sparse · noisy |

🧠 **作者推荐**：Programmatic（能用就用）+ LLM-Judge（弱信号）+ Spot human review（calibrate Judge）

### Q3：什么时候 eval？

```
开发期：dev set · 大量 examples · 自动化 grader · 快速迭代
       │
预上线：staging set · 人工 spot check · 多模型对比
       │
生产中：trace 100% · 抽样人工 · 实时回归告警 ← 持续 eval
       │
迭代：根据 failure cluster 加新 test case 回到 dev set
```

📎 这是 [eval-loop-as-production-practice](../theory/03-engineering/eval-loop-as-production-practice.md) 论点的展开。

---

## 📐 关键指标速查

### 任务正确性
- **Exact Match (EM)**：纯字符串匹配，最严格
- **F1 / BLEU / ROUGE**：经典 NLP 指标，对生成式任务粗糙
- **LLM-Judge Score**：1-5 / 1-10 评分（需要 rubric + calibration）

### Agent 行为
- **Tool Call Accuracy**：调对工具？参数对？
- **Trajectory Success**：完成任务的步数路径是否合理
- **Recovery Rate**：失败后能否自纠错（参见 [failure-modes T6](./failure-modes.md)）

### Production-only
- **Latency P50/P95/P99**：响应时延分位
- **Token cost / request**：成本控制
- **Hallucination rate**：尤其 RAG 场景关键
- **User Thumbs Up/Down**：最直接的 quality 信号

---

## 🛠️ Eval 工程模式

### Pattern 1: Eval-as-Code（推荐主流）

📎 Braintrust / DeepEval / Inspect AI 的核心范式：

```python
def grade(output, expected) -> float:
    # 自定义评分逻辑
    if exact_match(output, expected):
        return 1.0
    return llm_judge(output, expected, rubric="...")

eval_run = run_eval(
    dataset=load_dataset(),
    model=my_agent,
    grader=grade,
)
```

✅ 优点：版本化 · CI 集成 · 可重现
⚠️ 学习曲线 · 写 grader 需经验

### Pattern 2: YAML Config（CI 友好）

📎 Promptfoo 的核心范式：

```yaml
prompts:
  - "summarize: {{text}}"
providers:
  - openai:gpt-4o
  - anthropic:claude-opus-4-7
tests:
  - vars:
      text: "..."
    assert:
      - type: contains
        value: "key term"
      - type: llm-rubric
        value: "Output is < 100 words and accurate"
```

✅ 优点：版本化 · GitHub Action 一键集成
⚠️ 复杂逻辑表达力弱

### Pattern 3: LLM-as-a-Judge

```
你是评估员。评估以下 AI 回答的质量（1-10 分）：

<question>{question}</question>
<gold_answer>{gold}</gold_answer>
<ai_answer>{ai}</ai_answer>

考虑：准确性、完整性、清晰度。
返回 JSON: {"score": <1-10>, "reasoning": "..."}
```

⚠️ **校准技巧**（避免 LLM-Judge 偏差）：
- 📎 用同等强度的模型当评委（Claude eval Claude 输出）
- 📎 提供具体 rubric（不仅"评分"）
- 📎 用 reasoning 字段防 anchor 效应
- 📎 抽样人工对照 calibrate

---

## 🚩 Eval 常见陷阱

| 陷阱 | 症状 | 解法 |
|------|------|------|
| **dev set 过拟合** | dev 95%, prod 60% | hold-out test set + 持续从 prod 抽 |
| **LLM-Judge 偏向自家模型** | Claude 评 Claude 总高分 | 用更强或 cross-vendor judge |
| **只看平均分** | 隐藏 long-tail failure | 分布 + cluster failures + percentile |
| **eval 只跑一次** | 难以发现 regression | CI 自动跑 · alert P95 退化 |
| **没有 ground truth** | 无法量化 | 至少 100 条人工 label · synthetic 补充 |
| **Test set 太小** | 噪声 > 信号 | 至少 ~500 条；Inspect AI 学术 benchmark 多在 1K+ |

---

## 📖 最佳实践 6 条

1. **小步快跑** · dev set 100 条 → 加到 500 → 加到 2000
2. **Failure-driven test set** · 每发现一个 production bug，加进 test set
3. **Multi-grader ensemble** · LLM-Judge + Programmatic + 抽样人工
4. **Eval CI 集成** · 每次 PR / model 换都跑（Promptfoo + GitHub Action 是好起点）
5. **A/B in production** · 双模型并跑 · 抽样比对
6. **Trace 100% production** · OTel + Phoenix 自托管 / LangSmith hosted

---

## 📚 延伸

- 📎 [Eval Loop as Production Practice](../theory/03-engineering/eval-loop-as-production-practice.md)
- 📎 [Trust Tier Design](../theory/03-engineering/trust-tier-design.md) · 不同信任层级用不同 eval 强度
- [失效模式 T1-T6](./failure-modes.md) · 哪些失效需要哪种 eval 抓
- [Frameworks 对比](./frameworks.md) · 框架自带 eval vs 独立 eval 工具

---

[← Back to Cheat Sheet](./README.md)
