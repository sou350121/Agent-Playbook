# vLLM 语义路由（Semantic Routing）：把“模型选择 + 安全 + 缓存 + 质量”做成一个路由层

> 本文目标：把 vLLM Semantic Routing 的动态信息提纯为**可复用的方法论**。

---

## 1. 语义路由是什么？（不要把它当成简单的负载均衡）

传统路由/负载均衡回答的是：
- “把请求分给哪台机器？”

**语义路由**回答的是：
- “这条请求应该由**哪类模型/哪家提供商/哪条策略**来处理？”
- “在把请求送进 LLM 之前/之后，应该先做哪些**安全与质量门控**？”

它面对的现实是：
- 多模型并存（不同成本/上下文长度/多模态能力/工具调用能力）。
- 多风险并存（脱狱、PII、合规、幻觉）。
- 多优化目标并存（成本、延迟、可靠性、可解释性）。

---

## 2. 在 Agent 架构中的位置

语义路由应当位于：**认知预处理（Preprocessing）** 与 **模型服务层（Serving）** 之间。

```text
[UserRequest]
   |
   v
[SemanticRouter]
   |-- (Safety: jailbreak/PII)
   |-- (Cache: semantic cache)
   |-- (Quality: hallucination gate)
   |
   v
[LLMProviders]
   |-- vLLM_local
   |-- hosted_api
   |-- specialty_model
   v
[Response]
```

与本仓库的术语对应：
- **Intent Routing**：更偏“意图识别/命令模式/上下文投喂”。
- **Semantic Routing**：把**安全、缓存、质量**也纳入“路由决策”。

---

## 3. vLLM Semantic Routing v0.1 解决了什么

> 官方介绍：`https://blog.vllm.ai/2026/01/05/vllm-sr-iris.html`

从“工程能力”角度，它把这些能力统一到一个路由层：

- **模型选型（Model Selection）**：基于请求上下文信号选择不同模型/提供商。
- **安全过滤（Safety Gate）**：对脱狱/PII 等风险进行策略化拦截或降级。
- **语义缓存（Semantic Cache）**：对高频相似请求复用结果，显著降本提速。
- **幻觉检测（Hallucination Check）**：对输出质量做门控（例如触发二次验证或降级策略）。

关键点：
- 它让“策略”从 prompt 里迁移到**可治理的工程层**。
- 它让你可以把路由层当作**独立可演进组件**（像 API 网关一样治理）。

---

## 4. 设计模式：把路由层写成“可审计的策略机”

### 4.1 输入信号（Signals）
建议把 signals 分三类：
- **请求语义**：任务类型（代码/聊天/总结/翻译/检索）、复杂度、是否需要工具。
- **风险语义**：PII 迹象、越权意图、提示注入。
- **资源语义**：SLA（延迟上限）、预算（token cost cap）、可用模型健康度。

### 4.2 策略（Policy）
策略输出通常包括：
- 路由目标（provider/model/variant）
- 前置门控（PII redaction / jailbreak filter）
- 缓存策略（cache key、TTL、命中后是否跳过推理）
- 后置门控（hallucination check、citation requirement）
- 降级策略（fallback model / abstain / ask for clarification）

---

## 5. 与“幂等安全墙”的关系

语义路由不应成为新的“prompt 黑盒”。

建议做法：
- **墙内（幂等）**：信号提取、规则判定、缓存策略、fallback 路由（可测试、可回放）。
- **墙外（非幂等）**：只保留必要的模型判断（例如“这句话是否是 PII”用模型判定，但输出必须进入确定性策略机）。

---

## 6. Checklist：你是否需要语义路由？

- [ ] 你的系统里有 2+ 个模型/提供商并存
- [ ] 你在成本与质量之间频繁权衡
- [ ] 你有明确的安全需求（脱狱/PII/合规）
- [ ] 你需要对输出质量做自动化门控
- [ ] 你希望缓存从“字符串缓存”升级为“语义缓存”

若以上命中 2 条以上，建议引入语义路由层。

---

## 7. 失败模式（必须提前写进设计）

- **误判风险**：安全 gate 误杀导致体验崩溃（需要灰度策略与可解释日志）。
- **缓存污染**：语义缓存命中错误导致“看似正确但其实错”的输出（需要 cache key 设计与版本化）。
- **路由雪崩**：某个 provider 降级导致大量 fallback，触发级联延迟（需要熔断与限流）。

---

## 8. 参考与生态

- vLLM 官网：`https://vllm.ai/`
- vLLM-SR 官方介绍：`https://blog.vllm.ai/2026/01/05/vllm-sr-iris.html`
- 小号 vLLM（学习/轻量部署）：
  - `https://github.com/GeeeekExplorer/nano-vllm`
  - `https://github.com/Wenyueh/MinivLLM`
  - `https://github.com/skyzh/tiny-llm`
