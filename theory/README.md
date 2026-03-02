# Agentic Engineering 知识库

[![CC BY 4.0](https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by/4.0/)
[![文章数量](https://img.shields.io/badge/文章-93篇-blue.svg)]()
[![自动更新](https://img.shields.io/badge/Pulsar-自动更新-brightgreen.svg)]()

**系统化学习 Agentic Engineering 的中文知识库——从底层原理到生产部署，从个人技能到组织转型。**

---

## 为什么需要这个库

你是否遇到过这些困境：

- **刷 Twitter/X**：信息碎片化，今天看到一个新框架，明天又换一个，没有体系
- **读英文论文**：门槛高、时间成本大，读完还不知道怎么落地
- **买付费课程**：价格高、更新慢，课程跟不上技术迭代速度

这个知识库的定位是：**把碎片化的 Agentic Engineering 前沿知识，整理成可学习、可实践的结构化中文内容**。

每篇文章都经过 Pulsar 系统从全网信号中提炼，经过 Devil's Advocate（恶魔代言人）质疑环节过滤，确保内容有深度、有争议性、有工程价值——而不只是新闻摘要。

---

## 这个库的不同之处

| 来源 | 碎片化 | 工程实战深度 | 中文 | 免费 | 持续更新 |
|------|--------|-------------|------|------|----------|
| Twitter/X | ❌ 极高 | ❌ 浅层 | ⚠️ 部分 | ✅ | ✅ |
| YouTube 课程 | ⚠️ 中等 | ⚠️ 偏入门 | ⚠️ 部分 | ⚠️ 部分 | ❌ 慢 |
| 英文论文 | ✅ 结构完整 | ✅ 深度强 | ❌ | ✅ | ✅ |
| **Agent-Playbook theory** | ✅ **系统分类** | ✅ **生产级深度** | ✅ **全中文** | ✅ | ✅ **每日自动** |

> 本库不替代论文，而是帮你**先建立工程直觉**，再有选择地深入阅读原始资料。

---

## 六大学习模块

| 模块 | 名称 | 文章数 | 核心焦点 | 推荐读者 |
|------|------|--------|----------|----------|
| `01-principles/` | 底层原理 | 11篇 | LLM 推理机制、不确定性建模、智能的本质 | 所有人必读基础 |
| `02-agent-design/` | Agent 设计 | 17篇 | 记忆系统、编排架构、工具与框架选型 | 需要设计 Agent 系统的工程师 |
| `03-engineering/` ⭐ | 工程实战 | 34篇 | 护栏设计、Context 工程、评估迭代、流程治理 | **核心模块，人人必读** |
| `04-paradigm/` | 范式转变 | 11篇 | Vibe Coding、Software 3.0、意图驱动开发 | 想理解行业走向的工程师和产品人 |
| `05-strategy/` | 战略生存 | 13篇 | 职业转型、组织设计、分发变现 | 团队负责人、独立开发者、产品经理 |
| `06-frontier/` | 前沿研究 | 7篇 | 具身 AI、世界模型、跨领域融合 | 有志于研究方向的工程师 |

> ⭐ `03-engineering/` 是最大模块（34篇），也是本库最核心的价值所在。

---

## 推荐学习路径

### Path A：工程师入门路径（Engineer Starting Out）

> 目标：从零建立 Agentic 工程体系，能独立设计和部署 Agent 系统

```
① 01-principles/agent-mental-model.md          ← 建立 Agent 心智模型
② 03-engineering/00-glossary-for-beginners.md  ← 打通核心术语
③ 03-engineering/context-engineering-field-guide.md  ← 掌握 Context 工程
④ 03-engineering/agent-failure-taxonomy.md     ← 理解 T1-T6 故障分类
⑤ 02-agent-design/ (按需挑选)                  ← 深入设计模式
```

预计时长：2–3 周，每天 1 篇 + 配合实际项目实践

---

### Path B：架构师路径（Architect）

> 目标：设计多 Agent 系统，制定技术标准，规避生产陷阱

```
① 03-engineering/agentic-control-plane-design.md     ← 控制平面蓝图
② 03-engineering/trust-tier-design.md                ← 权限分层设计
③ 03-engineering/delegation-not-automation-engineering-principles.md  ← 委托原则
④ 02-agent-design/agentic-orchestration-meta-system.md  ← 元编排架构
⑤ 05-strategy/agent-native-org-roles.md              ← 组织角色重构
```

预计时长：1 周精读 + 架构评审实践

---

### Path C：产品 / 战略路径（Product & Strategy）

> 目标：理解 Agentic 时代的竞争格局，做出更好的产品和商业决策

```
① 04-paradigm/ (全部 11 篇)                          ← 理解范式转变
② 05-strategy/ (全部 13 篇)                          ← 战略与生存
③ 03-engineering/eval-loop-as-production-practice.md ← 理解工程质量体系
```

预计时长：1–2 周，侧重宏观判断能力

---

## 核心精选文章

以下 12 篇是本库中经过多轮验证、工程价值最高的文章，建议优先阅读：

| # | 文章 | 一句话描述 |
|---|------|-----------|
| 1 | [`03-engineering/context-engineering-field-guide.md`](https://github.com/sou350121/Agent-Playbook/blob/main/theory/03-engineering/context-engineering-field-guide.md) | Context 工程完整方法论，从压缩策略到结构化注入的系统性指南 |
| 2 | [`03-engineering/agent-failure-taxonomy.md`](https://github.com/sou350121/Agent-Playbook/blob/main/theory/03-engineering/agent-failure-taxonomy.md) | T1–T6 六层故障分类法，Agent 生产部署必读 |
| 3 | [`03-engineering/eval-loop-as-production-practice.md`](https://github.com/sou350121/Agent-Playbook/blob/main/theory/03-engineering/eval-loop-as-production-practice.md) | 把评估环路当成生产实践而非测试阶段的工程范式 |
| 4 | [`03-engineering/agentic-control-plane-design.md`](https://github.com/sou350121/Agent-Playbook/blob/main/theory/03-engineering/agentic-control-plane-design.md) | 多 Agent 控制平面设计蓝图，含路由、状态与降级策略 |
| 5 | [`03-engineering/trust-tier-design.md`](https://github.com/sou350121/Agent-Playbook/blob/main/theory/03-engineering/trust-tier-design.md) | 权限分层设计体系，系统性防止 Agent 越权与滥用 |
| 6 | [`03-engineering/delegation-not-automation-engineering-principles.md`](https://github.com/sou350121/Agent-Playbook/blob/main/theory/03-engineering/delegation-not-automation-engineering-principles.md) | 委托而非自动化的核心工程原则，重构人机协作边界 |
| 7 | [`02-agent-design/agent-memory-system-short-to-long.md`](https://github.com/sou350121/Agent-Playbook/blob/main/theory/02-agent-design/agent-memory-system-short-to-long.md) | 短期到长期记忆系统完整架构，含存储选型与检索策略 |
| 8 | [`02-agent-design/agentic-orchestration-meta-system.md`](https://github.com/sou350121/Agent-Playbook/blob/main/theory/02-agent-design/agentic-orchestration-meta-system.md) | 元编排系统设计：如何让 Agent 协调其他 Agent |
| 9 | [`01-principles/agent-mental-model.md`](https://github.com/sou350121/Agent-Playbook/blob/main/theory/01-principles/agent-mental-model.md) | Agent 心智模型基础，理解 LLM 作为推理引擎的本质 |
| 10 | [`03-engineering/00-glossary-for-beginners.md`](https://github.com/sou350121/Agent-Playbook/blob/main/theory/03-engineering/00-glossary-for-beginners.md) | 新手必读词汇表，统一 Agentic 工程核心术语 |
| 11 | [`05-strategy/agent-native-org-roles.md`](https://github.com/sou350121/Agent-Playbook/blob/main/theory/05-strategy/agent-native-org-roles.md) | Agent 原生组织角色重构，Prompt Engineer 到 Agent Architect 的职能演变 |
| 12 | [`03-engineering/03-process-governance.md`](https://github.com/sou350121/Agent-Playbook/blob/main/theory/03-engineering/03-process-governance.md) | Agentic 流程治理：如何在自动化流水线中保持可控性 |

---

## 内容地图（完整文章列表）

<details>
<summary>📐 01-principles — 底层原理（11篇）</summary>

底层原理模块聚焦于理解 LLM 推理的本质、不确定性建模，以及构建智能系统的基础认知框架。

| 文章 | 主题 |
|------|------|
| [agent-mental-model.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/01-principles/agent-mental-model.md) | Agent 心智模型：如何正确理解 LLM 作为推理引擎 |
| [alphaopt-self-improving-library.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/01-principles/alphaopt-self-improving-library.md) | 自优化库设计：AlphaOpt 方法论与自改进机制 |
| [bayesian-estimation-and-uncertainty.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/01-principles/bayesian-estimation-and-uncertainty.md) | 贝叶斯估计与不确定性：Agent 决策中的概率思维 |
| [hypernetworks-explained.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/01-principles/hypernetworks-explained.md) | 超网络解析：动态权重生成与元学习基础 |
| [independent-reasoning-and-proof-logic.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/01-principles/independent-reasoning-and-proof-logic.md) | 独立推理与证明逻辑：LLM 的逻辑能力边界 |
| [jagged-intelligence-rlvr.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/01-principles/jagged-intelligence-rlvr.md) | 参差智能与 RLVR：强化学习视觉推理的本质 |
| [latent-space-reasoning.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/01-principles/latent-space-reasoning.md) | 潜空间推理：Token 之外的隐式计算机制 |
| [lofa-vs-rag-comparison.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/01-principles/lofa-vs-rag-comparison.md) | LoFA vs RAG：两种知识注入范式的深度对比 |
| [manifold-hyper-connections-mhc.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/01-principles/manifold-hyper-connections-mhc.md) | 流形超连接（MHC）：高维表示学习新方向 |
| [post-scaling-research-age-playbook.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/01-principles/post-scaling-research-age-playbook.md) | 后 Scaling 研究时代手册：当算力红利消退后怎么做 |
| [waveformer-wave-equation-vision.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/01-principles/waveformer-wave-equation-vision.md) | Waveformer：波方程视觉建模的新范式 |

</details>

<details>
<summary>🤖 02-agent-design — Agent 设计（17篇）</summary>

Agent 设计模块覆盖构建 Agent 系统所需的核心设计模式，包括记忆系统、编排架构、工具选型与框架评估。

| 文章 | 主题 |
|------|------|
| [01-operating-model-and-roles.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/02-agent-design/01-operating-model-and-roles.md) | Agent 运营模型与角色定义：人机协作的组织结构 |
| [03-playbook-multi-agent-squad.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/02-agent-design/03-playbook-multi-agent-squad.md) | 多 Agent 小队 Playbook：分工协作模式与实战模板 |
| [agent-execution-environment-cloud-vs-local.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/02-agent-design/agent-execution-environment-cloud-vs-local.md) | Agent 执行环境选型：云端 vs 本地的权衡分析 |
| [agent-interaction-roles.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/02-agent-design/agent-interaction-roles.md) | Agent 交互角色体系：规划者、执行者、校验者的分工 |
| [agent-memory-system-short-to-long.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/02-agent-design/agent-memory-system-short-to-long.md) | 记忆系统完整架构：从短期上下文到长期持久化存储 |
| [agent-ui-api-design-patterns.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/02-agent-design/agent-ui-api-design-patterns.md) | Agent UI/API 设计模式：流式响应与交互协议设计 |
| [agentic-orchestration-meta-system.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/02-agent-design/agentic-orchestration-meta-system.md) | 元编排系统：管理 Agent 的 Agent 架构设计 |
| [ai-coding-agent-architecture.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/02-agent-design/ai-coding-agent-architecture.md) | AI 编码 Agent 架构：从文件操作到代码审查的完整管道 |
| [autogen_autogen_v04_deep_dive.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/02-agent-design/autogen_autogen_v04_deep_dive.md) | AutoGen v0.4 深度解析：新架构设计与迁移指南 |
| [database-comparison-for-agents.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/02-agent-design/database-comparison-for-agents.md) | Agent 数据库选型指南：向量库、图数据库与关系库对比 |
| [knowledge-distillation-workflow.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/02-agent-design/knowledge-distillation-workflow.md) | 知识蒸馏工作流：从大模型到小模型的高效迁移 |
| [lighthouse-vs-torch-framework.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/02-agent-design/lighthouse-vs-torch-framework.md) | Lighthouse vs Torch：Agent 框架选型的决策框架 |
| [llamaindex_team_opensearch_v100_nmslib_faiss_deep_dive.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/02-agent-design/llamaindex_team_opensearch_v100_nmslib_faiss_deep_dive.md) | LlamaIndex + OpenSearch 向量检索深度解析 |
| [rag-agent-memory.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/02-agent-design/rag-agent-memory.md) | RAG 与 Agent 记忆的融合：动态检索增强的设计模式 |
| [skill-vs-mcp-architecture.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/02-agent-design/skill-vs-mcp-architecture.md) | Skill vs MCP 架构对比：工具调用标准化的路径选择 |
| [social-simulation-and-multi-agent-systems.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/02-agent-design/social-simulation-and-multi-agent-systems.md) | 社会仿真与多 Agent 系统：涌现行为与群体智能 |
| [vllm-semantic-routing-deep-dive.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/02-agent-design/vllm-semantic-routing-deep-dive.md) | vLLM 语义路由深度解析：高吞吐推理的工程实现 |

</details>

<details>
<summary>⚙️ 03-engineering — 工程实战（34篇）⭐ 核心模块</summary>

工程实战模块是本库最大模块，覆盖护栏设计、Context 工程、评估迭代、流程治理等生产级内容，是 Agentic Engineering 的工程实践精华。

**三大支柱：A 护栏设计 | B Context 工程 | C 评估迭代**

| 文章 | 主题 |
|------|------|
| [00-glossary-for-beginners.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/03-engineering/00-glossary-for-beginners.md) | 新手词汇表：Agentic 工程 50+ 核心术语统一定义 |
| [01-physical-rails.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/03-engineering/01-physical-rails.md) | 物理护栏：沙盒、资源限制与执行隔离设计 |
| [02-logical-contracts.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/03-engineering/02-logical-contracts.md) | 逻辑契约：Agent 行为约束的声明式规范设计 |
| [02-playbook-spec-to-pr.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/03-engineering/02-playbook-spec-to-pr.md) | Spec to PR Playbook：从需求规格到代码提交的 Agentic 流程 |
| [03-process-governance.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/03-engineering/03-process-governance.md) | Agentic 流程治理：自动化管道中的可控性保障 |
| [04-automated-enforcement.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/03-engineering/04-automated-enforcement.md) | 自动化执行：策略即代码与 CI/CD 集成的护栏落地 |
| [04-playbook-risk-and-rollback.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/03-engineering/04-playbook-risk-and-rollback.md) | 风险与回滚 Playbook：Agent 操作的安全撤销机制 |
| [05-adr-mind-palace.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/03-engineering/05-adr-mind-palace.md) | ADR 心智宫殿：架构决策记录在 Agentic 系统中的应用 |
| [05-ralph-loop-iteration-paradigm.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/03-engineering/05-ralph-loop-iteration-paradigm.md) | RALPH 循环迭代范式：反思-行动-学习-规划-假设的闭环 |
| [06-agent-evals-playbook.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/03-engineering/06-agent-evals-playbook.md) | Agent 评估 Playbook：从单次测试到持续评估体系 |
| [10x-tactical-integrated-workflow.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/03-engineering/10x-tactical-integrated-workflow.md) | 10× 战术集成工作流：高效工程师的 Agentic 工具链 |
| [agent-failure-taxonomy.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/03-engineering/agent-failure-taxonomy.md) | T1–T6 故障分类法：Agent 生产故障的系统性分析框架 |
| [agentic-coding-doc-engineering.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/03-engineering/agentic-coding-doc-engineering.md) | Agentic 编码文档工程：让 AI 读懂并维护你的代码文档 |
| [agentic-control-plane-design.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/03-engineering/agentic-control-plane-design.md) | 多 Agent 控制平面设计蓝图：路由、状态管理与降级 |
| [agentic-org-chart-design.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/03-engineering/agentic-org-chart-design.md) | Agentic 组织图设计：Agent 团队的职责划分与汇报结构 |
| [ai-assisted-coding-adoption-metrics-and-governance.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/03-engineering/ai-assisted-coding-adoption-metrics-and-governance.md) | AI 辅助编码采用度量与治理：团队级推广的量化指标 |
| [ai-native-debugging-vs-manual-profiling.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/03-engineering/ai-native-debugging-vs-manual-profiling.md) | AI 原生调试 vs 手工 Profiling：新旧调试范式对比 |
| [ai_app_handbook_design.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/03-engineering/ai_app_handbook_design.md) | AI App 手册设计：从用户故事到工程规范的完整路径 |
| [anthropic_claude_deep_dive.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/03-engineering/anthropic_claude_deep_dive.md) | Anthropic Claude 深度解析：模型能力边界与工程使用指南 |
| [architectural-rails-for-ai-coding.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/03-engineering/architectural-rails-for-ai-coding.md) | AI 编码的架构护栏：如何在 AI 生成代码中保持架构一致性 |
| [bcachefs_llm_deep_dive.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/03-engineering/bcachefs_llm_deep_dive.md) | BCacheFS + LLM 深度解析：存储系统与 AI 工作负载的协同 |
| [context-engineering-field-guide.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/03-engineering/context-engineering-field-guide.md) | Context 工程实战手册：压缩、结构化注入与上下文管理 |
| [delegation-not-automation-engineering-principles.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/03-engineering/delegation-not-automation-engineering-principles.md) | 委托而非自动化：重构人机协作的核心工程原则 |
| [eval-loop-as-production-practice.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/03-engineering/eval-loop-as-production-practice.md) | 评估环路即生产实践：把 Eval 嵌入 CI/CD 的工程体系 |
| [how_i_use_claude_code_separation_of_planning_and_execution_deep_dive.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/03-engineering/how_i_use_claude_code_separation_of_planning_and_execution_deep_dive.md) | 规划与执行分离：Claude Code 实战中的认知分工策略 |
| [hybrid-docops-agentops-best-practices.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/03-engineering/hybrid-docops-agentops-best-practices.md) | 混合 DocOps + AgentOps 最佳实践：文档驱动的 Agent 运维 |
| [microsoft_agent_framework_100_preview2602121_ag_ui_agent_ui_deep_dive.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/03-engineering/microsoft_agent_framework_100_preview2602121_ag_ui_agent_ui_deep_dive.md) | Microsoft Agent Framework 1.0 + AG-UI 深度解析 |
| [microsoft_agent_framework_rc_deep_dive.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/03-engineering/microsoft_agent_framework_rc_deep_dive.md) | Microsoft Agent Framework RC 深度解析：生产就绪特性 |
| [microsoft_agent_framework_team_microsoft_agent_framework_ag_deep_dive.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/03-engineering/microsoft_agent_framework_team_microsoft_agent_framework_ag_deep_dive.md) | Microsoft Agent Framework 团队版深度解析 |
| [microsoft_agent_frameworkag_ui_deep_dive.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/03-engineering/microsoft_agent_frameworkag_ui_deep_dive.md) | Microsoft Agent Framework AG-UI 深度解析：协议规范 |
| [open_webui_team_v083_deep_dive.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/03-engineering/open_webui_team_v083_deep_dive.md) | Open WebUI v0.8.3 深度解析：插件生态与 Agent 集成 |
| [open_webui_v081_deep_dive.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/03-engineering/open_webui_v081_deep_dive.md) | Open WebUI v0.8.1 深度解析：Pipeline 架构演进 |
| [prd-for-engineers-and-agents.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/03-engineering/prd-for-engineers-and-agents.md) | 面向工程师与 Agent 的 PRD 写法：机器可读的需求规格 |
| [trust-tier-design.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/03-engineering/trust-tier-design.md) | 信任层级设计：多层权限体系防止 Agent 越权 |

</details>

<details>
<summary>🔄 04-paradigm — 范式转变（11篇）</summary>

范式转变模块追踪 Agentic 时代最重要的思维转变，包括 Vibe Coding 浪潮、Software 3.0 定义、意图驱动开发等。

| 文章 | 主题 |
|------|------|
| [a-year-of-vibes-prompt-vcs-and-agency.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/04-paradigm/a-year-of-vibes-prompt-vcs-and-agency.md) | Vibes 元年：Prompt 版本控制与 Agency 的一年回顾 |
| [agdp-for-humans.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/04-paradigm/agdp-for-humans.md) | AGDP（Agentic-Guided Development Process）人类指南 |
| [anthropic-agentic-coding-trends-2026.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/04-paradigm/anthropic-agentic-coding-trends-2026.md) | Agentic 编码趋势 2026：Anthropic 视角的行业判断 |
| [authenticity-vs-generated-noise.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/04-paradigm/authenticity-vs-generated-noise.md) | 真实性 vs 生成噪声：AI 内容泛滥时代的信号稀缺问题 |
| [intelligence-as-a-resource.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/04-paradigm/intelligence-as-a-resource.md) | 智能即资源：像分配算力一样分配认知资源的新范式 |
| [knowledge-equality-and-flat-cost.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/04-paradigm/knowledge-equality-and-flat-cost.md) | 知识平权与扁平成本：AI 压缩专业门槛的经济学分析 |
| [not-designing-for-humans-paradigm.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/04-paradigm/not-designing-for-humans-paradigm.md) | 不再为人类设计：当 UI 的主要用户变成 Agent |
| [one-person-ceo-paradigm.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/04-paradigm/one-person-ceo-paradigm.md) | 单人 CEO 范式：Agent 驱动的独立创业路径 |
| [reflyai_vibe_workflow_deep_dive.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/04-paradigm/reflyai_vibe_workflow_deep_dive.md) | ReflyAI Vibe Workflow 深度解析：工作流 Vibe 化的实现 |
| [state-of-llms-2025.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/04-paradigm/state-of-llms-2025.md) | LLMs 现状 2025：能力边界、局限与未来预判 |
| [vibe-coding-paradigm.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/04-paradigm/vibe-coding-paradigm.md) | Vibe Coding 范式：意图驱动开发的本质与边界 |

</details>

<details>
<summary>🎯 05-strategy — 战略生存（13篇）</summary>

战略生存模块面向需要在 Agentic 时代做出职业与商业决策的读者，覆盖个人转型、组织设计与变现路径。

| 文章 | 主题 |
|------|------|
| [agent-native-org-roles.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/05-strategy/agent-native-org-roles.md) | Agent 原生组织角色：从工程师到 Agent Architect 的职能演变 |
| [ai-education-revolution.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/05-strategy/ai-education-revolution.md) | AI 教育革命：技能半衰期压缩时代的学习策略 |
| [backend-engineer-roadmap-evolution.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/05-strategy/backend-engineer-roadmap-evolution.md) | 后端工程师路线图演进：Agentic 时代的技能升级路径 |
| [global-ai-startup-structuring-and-exit-checklist.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/05-strategy/global-ai-startup-structuring-and-exit-checklist.md) | 全球 AI 创业架构与退出清单：从注册到并购的完整指南 |
| [gradient-descent-life-strategy.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/05-strategy/gradient-descent-life-strategy.md) | 梯度下降人生策略：用优化思维做职业决策 |
| [human-centric-agent-design.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/05-strategy/human-centric-agent-design.md) | 以人为中心的 Agent 设计：避免自动化剥夺人的能动性 |
| [intelligence-arbitrage-strategy.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/05-strategy/intelligence-arbitrage-strategy.md) | 智能套利策略：如何利用 AI 能力不均衡创造优势 |
| [monetization-strategy-for-solo-developers.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/05-strategy/monetization-strategy-for-solo-developers.md) | 独立开发者变现策略：Agentic 时代的商业模式设计 |
| [reconstructing-engineering-mindset.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/05-strategy/reconstructing-engineering-mindset.md) | 重构工程师心智：从执行者到设计者的认知升级 |
| [research-taste-as-value-function.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/05-strategy/research-taste-as-value-function.md) | 研究品味即价值函数：如何培养高质量问题选择能力 |
| [the-three-understandings-of-ai-coding.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/05-strategy/the-three-understandings-of-ai-coding.md) | AI 编码的三重理解：工具、协作者与系统的认知层次 |
| [vibe-coding-deployment-friction.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/05-strategy/vibe-coding-deployment-friction.md) | Vibe Coding 部署摩擦：从原型到生产的最后一公里问题 |
| [x-distribution-and-monetization-playbook.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/05-strategy/x-distribution-and-monetization-playbook.md) | X 平台分发与变现 Playbook：技术内容创作者的增长策略 |

</details>

<details>
<summary>🔭 06-frontier — 前沿研究（7篇）</summary>

前沿研究模块追踪 Agentic Engineering 的技术边界，包括具身 AI、世界模型与跨领域融合方向。

| 文章 | 主题 |
|------|------|
| [1x-world-model-paradigm.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/06-frontier/1x-world-model-paradigm.md) | 1X 世界模型范式：机器人大脑的全局感知与规划框架 |
| [bottleneck-data-selection-paradigm.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/06-frontier/bottleneck-data-selection-paradigm.md) | 瓶颈数据选择范式：数据效率优于数据规模的新方向 |
| [embodied-ai-economic-agents.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/06-frontier/embodied-ai-economic-agents.md) | 具身 AI 经济体：物理世界中的 Agent 经济学 |
| [emu3-next-token-multimodal-world-model-route.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/06-frontier/emu3-next-token-multimodal-world-model-route.md) | Emu3：下一 Token 多模态世界模型路线解析 |
| [intellifold2-open-source-biomolecular-foundation-model.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/06-frontier/intellifold2-open-source-biomolecular-foundation-model.md) | IntelliFold2：开源生物分子基础模型的工程路线 |
| [robotics-bootstrap-theory.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/06-frontier/robotics-bootstrap-theory.md) | 机器人 Bootstrap 理论：自举学习与涌现能力的来源 |
| [spatial-intelligence.md](https://github.com/sou350121/Agent-Playbook/blob/main/theory/06-frontier/spatial-intelligence.md) | 空间智能：3D 理解与空间推理的前沿进展 |

</details>

---

## 如何高效使用这个知识库

### 1. 从词汇表开始

如果你是第一次接触 Agentic Engineering，强烈建议先读：

```
theory/03-engineering/00-glossary-for-beginners.md
```

这篇文章统一了本库所有文章中使用的核心术语，避免因概念混淆造成理解障碍。

### 2. 遇到不懂的概念查 01-principles

`01-principles/` 模块覆盖了 LLM 推理、不确定性、潜空间等底层机制。如果在阅读工程类文章时遇到概念性问题，回来这里找答案。

### 3. 每篇文章配合实际项目实践

理论 + 实践 = 真正掌握。建议每读完一篇关键文章，找一个具体的工程问题实践一次，效果翻倍。

### 4. 使用知识图谱可视化文章关联

Pulsar 可视化界面（`/graph`）展示所有文章的语义关联，帮助你发现相关文章和知识路径，避免孤立地阅读单篇文章。

### 5. 关注 deep_dive 标记的文章

文件名中包含 `deep_dive` 的文章经过了更深入的论证和 Devil's Advocate 质疑，代表当前知识体系中置信度最高的观点。

---

## 自动更新说明

本目录由 **Pulsar** 知识系统自动维护：

- **每日信号采集**：从 28 个来源收集 Agentic Engineering 相关信号
- **关键词过滤**：两级过滤（A/B 关键词体系）确保内容相关性
- **LLM 深度提炼**：每篇文章经过 8 段提示的结构化生成
- **Devil's Advocate 质疑**：发布前进行反驳性审查，过滤低质量内容
- **模块分类归档**：`_classify_module()` 自动将文章归入最匹配的模块
- **语义去重**：三道去重机制防止重复内容

> 每篇 `*_deep_dive.md` 文章都经过额外的 Devil's Advocate 环节，确保观点有深度、有争议性、有工程价值。

---

## 贡献与反馈

本知识库由 Pulsar 系统自动生成与维护。如发现内容错误或希望补充特定主题，欢迎提交 Issue。

---

## 许可证

本知识库内容采用 [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) 许可证。

你可以自由地：
- **分享** — 以任何媒介或格式复制和发行本作品
- **改编** — 对本作品进行混合、变换或以本作品为基础进行创作，即使用于商业目的

惟须遵守以下条件：
- **署名** — 你必须给出适当的署名，并指明是否（对原始作品）作了修改

---

*由 Pulsar 知识系统自动生成 · 最后更新：2026-03-02*
