# Agentic Engineering 知识库

[![CC BY 4.0](https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by/4.0/)
[![文章数量](https://img.shields.io/badge/文章-93篇-blue.svg)]()
[![自动更新](https://img.shields.io/badge/Pulsar-每日自动更新-brightgreen.svg)]()

> **一句话定位**：不是入门教程，不是学术综述——是帮你在混乱的 Agentic 工程领域找到坐标，建立工程直觉的中文知识库。

---

## 这个库解决什么问题

你是否遇到过这些困境：

- **刷 Twitter/X**：信息碎片化，今天一个新框架，明天又换一个，没有体系
- **读英文论文**：门槛高、时间成本大，读完还不知道怎么落地
- **买付费课程**：价格高、更新慢，跟不上技术迭代速度

这个知识库的定位是：**把碎片化的 Agentic Engineering 前沿知识，整理成可学习、可实践的结构化中文内容**。每篇文章由 Pulsar 系统从全网信号提炼，经过 Devil's Advocate 质疑过滤，确保有深度、有工程价值——而不只是新闻摘要。

| 来源 | 碎片化 | 工程实战深度 | 中文 | 免费 | 持续更新 |
|------|--------|-------------|------|------|----------|
| Twitter/X | 极高 | 浅层 | 部分 | ✓ | ✓ |
| YouTube 课程 | 中等 | 偏入门 | 部分 | 部分 | 慢 |
| 英文论文 | 结构完整 | 深度强 | ✗ | ✓ | ✓ |
| **Agent-Playbook theory/** | **系统分类** | **生产级深度** | **✓ 全中文** | **✓** | **✓ 每日** |

---

## 三个核心张力

理解这三个张力，你就理解了为什么 `03-engineering/` 是本库最核心的模块。

| 张力 | 核心命题 | 工程含义 | 关键文章 |
|------|---------|---------|---------|
| **委托 vs. 自动化** | 没有 scope 定义的 Agent = 责任真空 | Task Packet 是委托的最小合同 | [`delegation-not-automation`](./03-engineering/delegation-not-automation-engineering-principles.md) |
| **能力 vs. 可控性** | 越强大的 Agent 越需要分层信任 | 信任分层矩阵决定谁能做什么 | [`trust-tier-design`](./03-engineering/trust-tier-design.md) |
| **速度 vs. 可靠性** | 评估是生产实践，不是测试阶段 | eval loop 嵌入生产而非事后 | [`eval-loop-as-production-practice`](./03-engineering/eval-loop-as-production-practice.md) |

---

## 六大模块知识地图

```
[01-principles]  ────────▶  [02-agent-design]  ────────▶  [03-engineering ★]
  底层理论                      系统设计                      工程实战（核心）
  为什么 LLM 能做这些           如何组合成系统                 如何做得可靠
       ↑                            ↑                              ↓
[06-frontier]              [04-paradigm]                  [05-strategy]
  前沿扩展                    范式背景                        战略应用
  预判下一个范式转移            理解时代为何转变                 在组织/职业中落地
```

| 模块 | 名称 | 篇数 | 核心焦点 | 适合谁 |
|------|------|------|---------|-------|
| `01-principles/` | 底层原理 | 11篇 | LLM 推理机制、不确定性、智能的本质 | 所有人的基础 |
| `02-agent-design/` | Agent 设计 | 17篇 | 记忆系统、编排架构、工具与框架选型 | 设计 Agent 系统的工程师 |
| `03-engineering/` ★ | 工程实战 | 34篇 | 护栏、Context 工程、评估迭代、流程治理 | **核心模块，人人必读** |
| `04-paradigm/` | 范式转变 | 11篇 | Vibe Coding、Software 3.0、意图驱动 | 想理解行业走向的工程师和产品人 |
| `05-strategy/` | 战略生存 | 13篇 | 职业转型、组织设计、分发变现 | 团队负责人、独立开发者、产品经理 |
| `06-frontier/` | 前沿研究 | 7篇 | 具身 AI、世界模型、跨领域融合 | 有志研究方向的工程师 |

> `03-engineering/` 是最大模块（34篇），也是本库最核心的价值所在。

---

## 不知道从哪里开始？选一条路径

### ⚙ 路径 A：工程师入门
*从零建立完整的 Agentic 工程认知*

1. [`00-glossary-for-beginners`](./03-engineering/00-glossary-for-beginners.md) — 先建立词汇体系
2. [`agent-mental-model`](./01-principles/agent-mental-model.md) — 理解 Agent 的思维模型
3. [`context-engineering-field-guide`](./03-engineering/context-engineering-field-guide.md) — Context 是基础设施
4. [`agent-failure-taxonomy`](./03-engineering/agent-failure-taxonomy.md) — 认识 T1-T6 失败模式
5. [`agent-memory-system-short-to-long`](./02-agent-design/agent-memory-system-short-to-long.md) — 记忆系统完整架构

### ⬡ 路径 B：系统架构师
*设计可靠的多 Agent 控制平面与治理框架*

1. [`trust-tier-design`](./03-engineering/trust-tier-design.md) — 信任分层是架构第一步
2. [`agentic-control-plane-design`](./03-engineering/agentic-control-plane-design.md) — 控制平面设计蓝图
3. [`delegation-not-automation-engineering-principles`](./03-engineering/delegation-not-automation-engineering-principles.md) — 委托的工程含义
4. [`agentic-orchestration-meta-system`](./02-agent-design/agentic-orchestration-meta-system.md) — 元编排系统设计
5. [`agent-native-org-roles`](./05-strategy/agent-native-org-roles.md) — 组织层面的角色重构

### ◎ 路径 C：产品 / 战略
*把握范式转变，制定 AI 时代竞争策略*

1. [`vibe-coding-paradigm`](./04-paradigm/vibe-coding-paradigm.md) — 理解范式从哪里来
2. [`intelligence-as-a-resource`](./04-paradigm/intelligence-as-a-resource.md) — 智能作为生产资料
3. [`agent-native-org-roles`](./05-strategy/agent-native-org-roles.md) — 组织如何重构
4. [`eval-loop-as-production-practice`](./03-engineering/eval-loop-as-production-practice.md) — 产品层面的评估实践

---

## 精选必读

建立 Agentic 工程直觉的核心文章，按顺序或按需阅读：

| # | 文章 | 模块 | 一句话说明 |
|---|------|------|-----------|
| 01 | [`00-glossary-for-beginners`](./03-engineering/00-glossary-for-beginners.md) | 工程实战 | 掌握核心术语，新手第一篇必读 |
| 02 | [`agent-mental-model`](./01-principles/agent-mental-model.md) | 底层原理 | Agent = LLM（大脑）+ 工具（四肢），开发者是管理者 |
| 03 | [`context-engineering-field-guide`](./03-engineering/context-engineering-field-guide.md) | 工程实战 | Context 是基础设施，不是 Prompt Engineering 的别名 |
| 04 | [`agent-failure-taxonomy`](./03-engineering/agent-failure-taxonomy.md) | 工程实战 | T1-T6 故障分类法，生产部署前必读 |
| 05 | [`trust-tier-design`](./03-engineering/trust-tier-design.md) | 工程实战 | 防止 Agent 越权的多层级权限架构 |
| 06 | [`eval-loop-as-production-practice`](./03-engineering/eval-loop-as-production-practice.md) | 工程实战 | 把评估从测试阶段提升为持续生产实践 |
| 07 | [`delegation-not-automation-engineering-principles`](./03-engineering/delegation-not-automation-engineering-principles.md) | 工程实战 | 委托 ≠ 自动化，工程含义完全不同 |
| 08 | [`agentic-control-plane-design`](./03-engineering/agentic-control-plane-design.md) | 工程实战 | 多 Agent 控制平面设计蓝图 |
| 09 | [`agent-memory-system-short-to-long`](./02-agent-design/agent-memory-system-short-to-long.md) | Agent 设计 | 短期到长期记忆系统完整架构 |
| 10 | [`agent-native-org-roles`](./05-strategy/agent-native-org-roles.md) | 战略生存 | Agent 时代的职能重构与角色设计 |
| 11 | [`agentic-orchestration-meta-system`](./02-agent-design/agentic-orchestration-meta-system.md) | Agent 设计 | 元编排系统设计 |
| 12 | [`03-process-governance`](./03-engineering/03-process-governance.md) | 工程实战 | Agentic 流程治理框架 |

---

## 六个核心框架

本库围绕这六个框架构建工程体系：

### 1. T1–T6 故障分类法
> *一旦失败模式可描述，就能被工程化流程吸收*

| 类型 | 名称 | 严重度 | 预防方式 |
|------|------|--------|---------|
| T1 | 范围泄漏（Scope Leak） | 高 | 物理护栏 + `scope.out` 定义 |
| T2 | 上下文漂移（Context Drift） | 高 | AGENT_CONSTITUTION 定期重注入 |
| T3 | API 契约误读 | 中 | 测试可捕获 |
| T4 | 边界条件缺失 | 中 | 测试可捕获 |
| T5 | 语义回归 | 高 | 最难检测，需黄金数据集评估 |
| T6 | 多 Agent 链式失效 | 极高 | 整链回滚，委托契约必须定义 |

→ 完整分析：[`agent-failure-taxonomy`](./03-engineering/agent-failure-taxonomy.md)

### 2. Context 工程三要素
> *你给 Agent 看什么，决定它能做什么*

- **Repo Map**：给 Agent 空间感知（`AGENT_CONSTITUTION.md` + `ARCHITECTURE.md` + `.agent/repo-map.json`）
- **Task Packet**：委托的最小合同（`scope.in` / `scope.out` / `constraints` / `deliverable`）
- **Context Decay 处理**：长会话中早期约束被工具调用结果挤出，需定期重注入

→ 完整方法论：[`context-engineering-field-guide`](./03-engineering/context-engineering-field-guide.md)

### 3. 委托设计契约
> *如果 Agent 做了意料之外的事，你能说"那不在我委托范围内"吗？*

```json
{
  "scope": {
    "in":  ["src/auth/", "src/api/middleware/"],
    "out": ["database/migrations/", "tests/e2e/"]
  },
  "constraints": ["不修改 public API 签名", "不引入新依赖"],
  "deliverable": "通过 pnpm test 的 PR diff"
}
```

→ 工程原则：[`delegation-not-automation`](./03-engineering/delegation-not-automation-engineering-principles.md)

### 4. 信任分层矩阵
> *按"操作后果不可逆程度"分配权限，而不是按能力*

| 层级 | 可执行操作 | 需要审批 |
|------|-----------|---------|
| T0（只读） | 读文件、搜索、分析 | 无 |
| T1（可逆写） | 写文件、运行测试 | 无 |
| T2（低风险执行） | 调用 API、写数据库（可回滚） | 日志记录 |
| T3（不可逆） | 生产部署、删除数据、外部通信 | 人工审批 |

→ 完整设计：[`trust-tier-design`](./03-engineering/trust-tier-design.md)

### 5. 评估环路
> *测试（Testing）是验证代码正确性；评估（Eval）是持续衡量 Agent 行为质量*

| 维度 | Testing | Eval |
|------|---------|------|
| 触发时机 | 代码变更时 | 持续运行 |
| 判断标准 | Pass/Fail（确定性） | 分布/趋势（概率性） |
| 失败响应 | 修 bug | 调整提示/数据/模型 |
| 覆盖范围 | 边界条件 | 代表性场景分布 |

→ 完整实践：[`eval-loop-as-production-practice`](./03-engineering/eval-loop-as-production-practice.md)

### 6. Agent 心智模型
> *从"编程思维"切换到"管理思维"是 Agentic Engineering 的认知门槛*

- 编程思维：我告诉计算机每一步怎么做
- 管理思维：我定义范围、目标和验收标准，Agent 决定怎么做
- 工具 = 授权给 Agent 的技能清单
- System Prompt = 工作手册，不是指令序列

→ 认知框架：[`agent-mental-model`](./01-principles/agent-mental-model.md)

---

## 按问题类型查文章

| 我正在遇到... | 推荐入口 | 模块 |
|-------------|---------|------|
| Agent 修改了不该动的文件 | [`trust-tier-design`](./03-engineering/trust-tier-design.md) + [`01-physical-rails`](./03-engineering/01-physical-rails.md) | 工程实战 |
| 长会话后 Agent 忘记了早期约束 | [`context-engineering-field-guide`](./03-engineering/context-engineering-field-guide.md) §Context Decay | 工程实战 |
| 不知道如何衡量 Agent 的表现好坏 | [`eval-loop-as-production-practice`](./03-engineering/eval-loop-as-production-practice.md) | 工程实战 |
| 多个 Agent 协作时错误层叠传播 | [`agent-failure-taxonomy`](./03-engineering/agent-failure-taxonomy.md) §T6 | 工程实战 |
| 团队不知道谁对 Agent 行为负责 | [`delegation-not-automation`](./03-engineering/delegation-not-automation-engineering-principles.md) | 工程实战 |
| 需要选择 Agent 框架/工具 | [`skill-vs-mcp-architecture`](./02-agent-design/skill-vs-mcp-architecture.md) + [`database-comparison-for-agents`](./02-agent-design/database-comparison-for-agents.md) | Agent 设计 |
| 需要设计 Agent 的记忆系统 | [`agent-memory-system-short-to-long`](./02-agent-design/agent-memory-system-short-to-long.md) + [`rag-agent-memory`](./02-agent-design/rag-agent-memory.md) | Agent 设计 |
| 管理层问 AI 转型如何推进 | [`agent-native-org-roles`](./05-strategy/agent-native-org-roles.md) + [`reconstructing-engineering-mindset`](./05-strategy/reconstructing-engineering-mindset.md) | 战略生存 |
| 想理解 Vibe Coding 之后是什么 | [`vibe-coding-paradigm`](./04-paradigm/vibe-coding-paradigm.md) + [`anthropic-agentic-coding-trends-2026`](./04-paradigm/anthropic-agentic-coding-trends-2026.md) | 范式转变 |
| 想评估具身 AI / 世界模型进展 | [`1x-world-model-paradigm`](./06-frontier/1x-world-model-paradigm.md) + [`embodied-ai-economic-agents`](./06-frontier/embodied-ai-economic-agents.md) | 前沿研究 |

---

## 2026 年的现状：已解决 vs. 仍待攻克

| 维度 | 状态 | 说明 |
|------|------|------|
| Context 窗口大小 | ✅ 已解决 | 128K–1M token 已成标配 |
| 基础工具调用 | ✅ 已解决 | 函数调用稳定，MCP 标准化 |
| 编排模式 | ✅ 基本解决 | Chain/Star/Mesh 拓扑清晰 |
| 可观测性 | ✅ 基本解决 | 89% 生产系统有基础 trace |
| 物理护栏（沙箱） | ✅ 工具成熟 | 文件系统隔离/容器化 |
| 跨 Agent 上下文对齐 | 🔴 仍待攻克 | 上游错误级联传播，最大失败来源 |
| Context Rot | 🔴 仍待攻克 | 长会话性能衰减，无通用解法 |
| 在线评估（Online Eval） | 🟡 部分解决 | 仅 37-44% 生产系统实施 |
| 分布式状态同步 | 🟡 部分解决 | 多 Agent 共享状态仍易不一致 |
| 语义回归检测（T5） | 🟡 部分解决 | 需黄金数据集，成本高 |

---

## 全部文章（93篇）

<details>
<summary><strong>01-principles · 底层原理（11篇）</strong></summary>

- [Agent Mental Model](./01-principles/agent-mental-model.md)
- [Alphaopt Self Improving Library](./01-principles/alphaopt-self-improving-library.md)
- [Bayesian Estimation and Uncertainty](./01-principles/bayesian-estimation-and-uncertainty.md)
- [Hypernetworks Explained](./01-principles/hypernetworks-explained.md)
- [Independent Reasoning and Proof Logic](./01-principles/independent-reasoning-and-proof-logic.md)
- [Jagged Intelligence RLVR](./01-principles/jagged-intelligence-rlvr.md)
- [Latent Space Reasoning](./01-principles/latent-space-reasoning.md)
- [LOFA vs RAG Comparison](./01-principles/lofa-vs-rag-comparison.md)
- [Manifold Hyper Connections MHC](./01-principles/manifold-hyper-connections-mhc.md)
- [Post Scaling Research Age Playbook](./01-principles/post-scaling-research-age-playbook.md)
- [Waveformer Wave Equation Vision](./01-principles/waveformer-wave-equation-vision.md)

</details>

<details>
<summary><strong>02-agent-design · Agent 设计（17篇）</strong></summary>

- [Operating Model and Roles](./02-agent-design/01-operating-model-and-roles.md)
- [Playbook Multi Agent Squad](./02-agent-design/03-playbook-multi-agent-squad.md)
- [Agent Execution Environment: Cloud vs Local](./02-agent-design/agent-execution-environment-cloud-vs-local.md)
- [Agent Interaction Roles](./02-agent-design/agent-interaction-roles.md)
- [Agent Memory System: Short to Long](./02-agent-design/agent-memory-system-short-to-long.md)
- [Agent UI API Design Patterns](./02-agent-design/agent-ui-api-design-patterns.md)
- [Agentic Orchestration Meta System](./02-agent-design/agentic-orchestration-meta-system.md)
- [AI Coding Agent Architecture](./02-agent-design/ai-coding-agent-architecture.md)
- [AutoGen v0.4 Deep Dive](./02-agent-design/autogen_autogen_v04_deep_dive.md)
- [Database Comparison for Agents](./02-agent-design/database-comparison-for-agents.md)
- [Knowledge Distillation Workflow](./02-agent-design/knowledge-distillation-workflow.md)
- [Lighthouse vs Torch Framework](./02-agent-design/lighthouse-vs-torch-framework.md)
- [LlamaIndex OpenSearch FAISS Deep Dive](./02-agent-design/llamaindex_team_opensearch_v100_nmslib_faiss_deep_dive.md)
- [RAG Agent Memory](./02-agent-design/rag-agent-memory.md)
- [Skill vs MCP Architecture](./02-agent-design/skill-vs-mcp-architecture.md)
- [Social Simulation and Multi-Agent Systems](./02-agent-design/social-simulation-and-multi-agent-systems.md)
- [vLLM Semantic Routing](./02-agent-design/vllm-semantic-routing-deep-dive.md)

</details>

<details>
<summary><strong>03-engineering ★ · 工程实战（34篇）——核心模块</strong></summary>

- [00 Glossary for Beginners ⭐](./03-engineering/00-glossary-for-beginners.md)
- [01 Physical Rails](./03-engineering/01-physical-rails.md)
- [02 Logical Contracts](./03-engineering/02-logical-contracts.md)
- [02 Playbook: Spec to PR](./03-engineering/02-playbook-spec-to-pr.md)
- [03 Process Governance](./03-engineering/03-process-governance.md)
- [04 Automated Enforcement](./03-engineering/04-automated-enforcement.md)
- [04 Playbook: Risk and Rollback](./03-engineering/04-playbook-risk-and-rollback.md)
- [05 ADR Mind Palace](./03-engineering/05-adr-mind-palace.md)
- [05 Ralph Loop Iteration Paradigm](./03-engineering/05-ralph-loop-iteration-paradigm.md)
- [06 Agent Evals Playbook](./03-engineering/06-agent-evals-playbook.md)
- [10x Tactical Integrated Workflow](./03-engineering/10x-tactical-integrated-workflow.md)
- [Agent Failure Taxonomy ⭐](./03-engineering/agent-failure-taxonomy.md)
- [Agentic Coding Doc Engineering](./03-engineering/agentic-coding-doc-engineering.md)
- [Agentic Control Plane Design ⭐](./03-engineering/agentic-control-plane-design.md)
- [Agentic Org Chart Design](./03-engineering/agentic-org-chart-design.md)
- [AI Assisted Coding Adoption Metrics](./03-engineering/ai-assisted-coding-adoption-metrics-and-governance.md)
- [AI Native Debugging vs Manual Profiling](./03-engineering/ai-native-debugging-vs-manual-profiling.md)
- [AI App Handbook Design](./03-engineering/ai_app_handbook_design.md)
- [Anthropic Claude Deep Dive](./03-engineering/anthropic_claude_deep_dive.md)
- [Architectural Rails for AI Coding](./03-engineering/architectural-rails-for-ai-coding.md)
- [Bcachefs LLM Deep Dive](./03-engineering/bcachefs_llm_deep_dive.md)
- [Context Engineering Field Guide ⭐](./03-engineering/context-engineering-field-guide.md)
- [Delegation Not Automation ⭐](./03-engineering/delegation-not-automation-engineering-principles.md)
- [Eval Loop as Production Practice ⭐](./03-engineering/eval-loop-as-production-practice.md)
- [How I Use Claude Code](./03-engineering/how_i_use_claude_code_separation_of_planning_and_execution_deep_dive.md)
- [Hybrid DocOps AgentOps Best Practices](./03-engineering/hybrid-docops-agentops-best-practices.md)
- [Microsoft Agent Framework Preview](./03-engineering/microsoft_agent_framework_100_preview2602121_ag_ui_agent_ui_deep_dive.md)
- [Microsoft Agent Framework RC](./03-engineering/microsoft_agent_framework_rc_deep_dive.md)
- [Microsoft Agent Framework AG](./03-engineering/microsoft_agent_framework_team_microsoft_agent_framework_ag_deep_dive.md)
- [Microsoft Agent Framework AG-UI](./03-engineering/microsoft_agent_frameworkag_ui_deep_dive.md)
- [Open WebUI Team v0.8.3](./03-engineering/open_webui_team_v083_deep_dive.md)
- [Open WebUI v0.8.1](./03-engineering/open_webui_v081_deep_dive.md)
- [PRD for Engineers and Agents](./03-engineering/prd-for-engineers-and-agents.md)
- [Trust Tier Design ⭐](./03-engineering/trust-tier-design.md)

</details>

<details>
<summary><strong>04-paradigm · 范式转变（11篇）</strong></summary>

- [A Year of Vibes: Prompt, VCS, and Agency](./04-paradigm/a-year-of-vibes-prompt-vcs-and-agency.md)
- [AGDP for Humans](./04-paradigm/agdp-for-humans.md)
- [Anthropic Agentic Coding Trends 2026](./04-paradigm/anthropic-agentic-coding-trends-2026.md)
- [Authenticity vs Generated Noise](./04-paradigm/authenticity-vs-generated-noise.md)
- [Intelligence as a Resource](./04-paradigm/intelligence-as-a-resource.md)
- [Knowledge Equality and Flat Cost](./04-paradigm/knowledge-equality-and-flat-cost.md)
- [Not Designing for Humans](./04-paradigm/not-designing-for-humans-paradigm.md)
- [One Person CEO Paradigm](./04-paradigm/one-person-ceo-paradigm.md)
- [Refly AI Vibe Workflow](./04-paradigm/reflyai_vibe_workflow_deep_dive.md)
- [State of LLMs 2025](./04-paradigm/state-of-llms-2025.md)
- [Vibe Coding Paradigm](./04-paradigm/vibe-coding-paradigm.md)

</details>

<details>
<summary><strong>05-strategy · 战略生存（13篇）</strong></summary>

- [Agent Native Org Roles ⭐](./05-strategy/agent-native-org-roles.md)
- [AI Education Revolution](./05-strategy/ai-education-revolution.md)
- [Backend Engineer Roadmap Evolution](./05-strategy/backend-engineer-roadmap-evolution.md)
- [Global AI Startup Structuring and Exit](./05-strategy/global-ai-startup-structuring-and-exit-checklist.md)
- [Gradient Descent Life Strategy](./05-strategy/gradient-descent-life-strategy.md)
- [Human Centric Agent Design](./05-strategy/human-centric-agent-design.md)
- [Intelligence Arbitrage Strategy](./05-strategy/intelligence-arbitrage-strategy.md)
- [Monetization Strategy for Solo Developers](./05-strategy/monetization-strategy-for-solo-developers.md)
- [Reconstructing Engineering Mindset](./05-strategy/reconstructing-engineering-mindset.md)
- [Research Taste as Value Function](./05-strategy/research-taste-as-value-function.md)
- [The Three Understandings of AI Coding](./05-strategy/the-three-understandings-of-ai-coding.md)
- [Vibe Coding Deployment Friction](./05-strategy/vibe-coding-deployment-friction.md)
- [X Distribution and Monetization Playbook](./05-strategy/x-distribution-and-monetization-playbook.md)

</details>

<details>
<summary><strong>06-frontier · 前沿研究（7篇）</strong></summary>

- [1X World Model Paradigm](./06-frontier/1x-world-model-paradigm.md)
- [Bottleneck Data Selection Paradigm](./06-frontier/bottleneck-data-selection-paradigm.md)
- [Embodied AI Economic Agents](./06-frontier/embodied-ai-economic-agents.md)
- [EMU3: Next-Token Multimodal World Model](./06-frontier/emu3-next-token-multimodal-world-model-route.md)
- [IntelliFold2: Open Source Biomolecular Foundation Model](./06-frontier/intellifold2-open-source-biomolecular-foundation-model.md)
- [Robotics Bootstrap Theory](./06-frontier/robotics-bootstrap-theory.md)
- [Spatial Intelligence](./06-frontier/spatial-intelligence.md)

</details>

---

## 如何高效使用

- **从词汇表开始**：[`00-glossary-for-beginners`](./03-engineering/00-glossary-for-beginners.md) 帮你快速建立术语体系
- **遇到不懂的概念**：查 `01-principles/` 找底层原理
- **每篇文章配合实际项目实践**：理解效果翻倍
- **可视化文章关联**：[Pulsar 知识图谱](/graph) 展示 93 篇文章的相似度聚类

---

## 自动更新说明

Pulsar pipeline 每天自动追踪最新论文与工程实践，通过 Devil's Advocate 质疑过滤，生成深度分析文章并归档至对应模块。本目录每日 11:55（上海时间）自动同步至 [Pulsar Web](https://sou350121.github.io/pulsar-web/ai-deepdive/)。

---

*由 Pulsar 知识系统驱动 · [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) · 最后更新：2026-03-02*
