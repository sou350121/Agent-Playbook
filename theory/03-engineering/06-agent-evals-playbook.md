# Playbook：Agent 评估体系（Evals）从 0 到 1

> **目标**：把“Agent 看起来变差了/变好了”变成可度量、可回归、可追责的工程事实。
>
> 参考：Anthropic《Demystifying evals for AI agents》  
> [`https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents`](https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents)

---

## 1. 你评估的不是模型，而是“模型 + harness”

在工程上，“Agent”通常包含两部分：

- **模型**：生成决策与语言
- **Agent harness / scaffold**：工具编排、状态管理、错误处理、重试、记忆、约束等

所以 eval 的对象应该是“整体系统”，否则你会把 harness 的问题错怪给模型（或相反）。

---

## 2. 核心概念（务必统一语言）

- **task**：一个测试用例（输入 + 成功标准）
- **trial**：一次运行（同一 task 要跑多次）
- **transcript**：完整轨迹（对话、工具调用、中间结果）
- **outcome**：最终结果态（环境里真实发生了什么）
- **grader**：评分器（对 transcript 或 outcome 的检查）
- **eval harness**：跑任务、隔离环境、记录轨迹、执行 grader、汇总指标的框架

---

## 3. 三类 grader（组合拳）

### 3.1 Code-based（确定性/可复现）

- 测试套件、端到端脚本、静态分析
- 结果态验证（DB/文件/配置/产物）
- transcript 指标（turn、toolcalls、token、耗时）

### 3.2 Model-based（处理主观与开放式）

- rubric 打分（多维度）
- 自然语言断言
- pairwise 对比、多评审一致性

> **注意**：model-based grader 要定期用人类抽检校准，否则会“自嗨”。

### 3.3 Human（校准与高风险兜底）

- 专家抽检、A/B、人工复核

---

## 4. 两类评估：capability vs regression

- **capability eval**：测“能做到什么”，从低分开始，留出优化空间
- **regression eval**：测“还能稳定做到吗”，分数应接近 100%

capability eval 一旦饱和，就应该升级题库，或将其“毕业”为 regression。

---

## 5. 四类 Agent 的通用评估模板

### 5.1 编码 Agent（最适合确定性评分）

组合建议：

- outcome：单元测试 / 集成测试 / 端到端任务
- transcript：代码质量 heuristics + LLM rubric（必要时）
- static analysis：lint/type/security

参考：

- SWE-bench Verified：[`https://www.swebench.com/SWE-bench/`](https://www.swebench.com/SWE-bench/)
- Terminal-Bench：[`https://www.tbench.ai/`](https://www.tbench.ai/)

### 5.2 对话 Agent（最终状态 + 交互质量）

组合建议：

- outcome：ticket/refund/订单等状态验证
- transcript：同理心、解释清晰度、是否遵循 policy、是否 grounded
- user simulation：通常需要第二个 LLM 扮演用户

参考：

- \(τ\)-Bench：[`https://arxiv.org/abs/2406.12045`](https://arxiv.org/abs/2406.12045)
- \(τ^2\)-Bench：[`https://arxiv.org/abs/2506.07982`](https://arxiv.org/abs/2506.07982)

### 5.3 研究/搜索 Agent（groundedness + coverage + source quality）

组合建议：

- groundedness：关键断言是否有来源支持
- coverage：关键信息点是否覆盖
- source quality：来源是否权威

参考：BrowseComp：[`https://arxiv.org/abs/2504.12516`](https://arxiv.org/abs/2504.12516)

### 5.4 计算机使用 Agent（UI 不够，必须验证后端状态）

组合建议：

- UI 层：URL、页面状态、元素属性
- 后端层：订单/文件/配置/数据库的真实结果态
- 行为层：是否选择了合适的交互方式（DOM vs screenshot）

---

## 6. 面对随机性：pass@k 与 pass^k 怎么用？

- **pass@k**：k 次尝试里至少成功一次（偏“潜力/可用性”）
- **pass^k**：k 次尝试次次成功（偏“一致性/可靠性”）

产品选型建议：

- 工具型：更看 pass@k（尤其 pass@1）
- 代理型：更看 pass^k（用户期待每次靠谱）

---

## 7. 从 0 到 1 的工程路线图（Checklist）

1. **从真实失败开始**：先做 20–50 个高价值 task
2. **任务可判定**：两位领域专家能独立给同样 verdict
3. **reference solution**：证明 task 可解、grader 没写错
4. **问题集平衡**：测“该做”也测“不该做”（避免单边优化）
5. **环境隔离**：每次 trial 从干净环境开始，避免共享状态污染
6. **grader 不要过度约束路径**：优先评 outcome，避免死盯工具调用顺序
7. **读 transcript**：确认低分来自 agent，而不是 eval 设计问题
8. **持续维护**：题库、rubric、环境都需要 owner 与定期体检

---

## 8. 参考配置（YAML 形态，示意）

> 说明：以下是“结构示意”，你应按实际产品的工具/状态改写。

```yaml
task:
  id: refund_frustrated_user_1
  desc: 处理用户退款请求，并在 10 轮内完成

  graders:
    - type: state_check
      expect:
        tickets: {status: resolved}
        refunds: {status: processed}

    - type: llm_rubric
      rubric: prompts/support_quality.md
      assertions:
        - Agent表现出同理心
        - 解释清晰，包含到账时间预期
        - 回复基于policy/工具返回结果

    - type: tool_calls
      required:
        - {tool: verify_identity}
        - {tool: process_refund, params: {amount: "<=100"}}
        - {tool: send_confirmation}

    - type: transcript
      max_turns: 10

  tracked_metrics:
    - type: transcript
      metrics: [n_turns, n_toolcalls, n_total_tokens]
    - type: latency
      metrics: [time_to_first_token, time_to_last_token]
```

