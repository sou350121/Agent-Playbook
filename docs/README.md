# 📖 Docs Master Map (文档总目录)

> **如何使用本库：**
> - **Blog** 是信号入口（捕捉 X/Twitter 碎片化动态）。
> - **Docs** 是知识提纯（将动态沉淀为可执行的方法论、工具包与范式）。

---

## 🚀 推荐学习路径 (Learning Tracks)

根据你的目标，选择最适合的阅读路径：

### 1. ⚡ 45 分钟极速上手 (Fast Start)
*适合想快速理解 Agent 协作本质并立刻动手的读者。*
- [启程：认识 Agent 并装好你的“神笔”](./beginner-guide/00-intro-and-setup.md) (10 min)
- [心法：从“写代码”到“指挥 AI”](./beginner-guide/01-mindset-shift.md) (10 min)
- [Hybrid DocOps + AgentOps 最佳实践](./planning/hybrid-docops-agentops-best-practices.mdx) (15 min)
- [开发全生命周期速查表](./prompt-library/dev-lifecycle-cheat-sheet.mdx) (10 min)

### 2. 🏗️ 2 小时 Builder 进阶 (The Builder Track)
*适合准备用 Agent 开发真实产品或复杂逻辑的工程师。*
- [小白通关手册全集](./beginner-guide/README.md)
- [AI 协作 DNA 工作流：交付标准定义](./tools/agent-dna-workflow.mdx)
- [vLLM 语义路由：多模型管理艺术](./capabilities/vllm-semantic-routing-deep-dive.mdx)
- [6 步 PRD 产出法：从意图到需求闭环](../blog/2026-01-08-ai-driven-pm-workflow.md)
- [NotebookLM-py：自動化研究管道實踐](./tools/notebooklm-py.mdx)

### 3. 🏛️ 架构与管理专项 (Governance & Management)
*适合负责中大型项目，担心代码“越写越乱”或 Agent 编队难以管理的架构师。*
- [架构治理总览](./architecture-governance/README.mdx)
- [Agent 管理学：从单点到编队协作](./agent-management/README.md)
- [物理导轨：项目组织边界](./architecture-governance/01-physical-rails.mdx)
- [逻辑契约：编码规范治理](./architecture-governance/02-logical-contracts.mdx)
- [04 Playbook：风险治理与回滚](./agent-management/04-playbook-risk-and-rollback.mdx)

---

## 🧭 目录导航 (Directory Map)

| 模块 | 核心目的 | 快速入口 |
| :--- | :--- | :--- |
| **[新手指南](./beginner-guide/)** | 从零开始的 AI 驱动开发路径 | [README](./beginner-guide/README.md) |
| **[计划与范式](./planning/)** | 思考模型、协作范式与心法 | [README](./planning/README.md) |
| **[架构治理](./architecture-governance/)** | 大型项目的物理导轨与契约 | [README](./architecture-governance/README.mdx) |
| **[Agent 管理](./agent-management/)** | 编队、SOP、门禁、Ralph 迭代 | [README](./agent-management/README.md) |
| **[工具链](./tools/)** | Cursor/Docker/vLLM 等深度指南 | [README](./tools/README.md) |
| **[能力边界](./capabilities/)** | 穿透黑话，理解模型的能力与风险 | [README](./capabilities/README.md) |
| **[Prompt 库](./prompt-library/)** | 沉淀高质量、原子级的 Prompt 模板 | [README](./prompt-library/README.md) |
| **[案例复盘](./case-studies/)** | 真实的胜利与昂贵的失败记录 | [README](./case-studies/README.md) |
| **[安全与防御](./security/)** | 环境安全、隔离范式与资产保护 | [README](./security/README.md) |
| **[模型对比](./model-comparisons/)** | 硬核工程场景下的模型实测 | [README](./model-comparisons/README.md) |
| **[资源名录](./resources/)** | AI 情报源与影响力图谱 | [README](./resources/README.md) |

---

## ⭐ 按需检索 Top Picks

- **想提炼方法论？** 查看 [写作模板](./_templates/README.md)。
- **怕项目崩盘？** 阅读 [架构导轨：AI 时代的生存之道](./planning/architectural-rails-for-ai-coding.mdx)。
- **想要模擬未來？** 查看 [MiroFish：平行世界預測引擎](./capabilities/social-simulation-and-multi-agent-systems.mdx)。
- **構建開源團隊？** 查看 [Eigent：多智能體協同桌面應用](./tools/eigent-open-source-cowork.mdx)。
- **理解架構穩定性？** 查看 [mHC 範式：信號守恆定律](./capabilities/manifold-hyper-connections-mhc.mdx)。
- **解決 AI 退出早？** 查看 [Ralph Loop：持續迭代範式](./agent-management/05-ralph-loop-iteration-paradigm.mdx)。
- **理解機器人未來？** 查看 [機器人引導程序理論](./capabilities/robotics-bootstrap-theory.mdx)。
- **尋找商業靈感？** 閱讀 [智力套利策略](./planning/intelligence-arbitrage-strategy.mdx)。
- **拒绝 AI 廢話？** 學習 [真實性 vs 生成噪音](./capabilities/authenticity-vs-generated-noise.mdx)。
- **理解組織變革？** 閱讀 [麥肯錫：智能體型組織五大支柱](../blog/2026-01-22-mckinsey-agentic-organizations.md)。

---

## 🧠 智慧全景：Agent 时代的生存逻辑 (The Meta-Wisdom)

> **“如果你还像过去那样写代码，AI 就是你的替代者；如果你学会了编排智能，AI 就是你的杠杆。”**

1. **意圖的主權**：代碼只是實現意圖的消耗品，真正昂貴的是你對問題的定義（Spec）和對好壞的判斷（Taste）。
2. **信任的對衝**：接受 Agent 的隨機性，用「物理導軌」和「邏輯契約」構建確定性。
3. **閉環的複利**：不要做信息的搬運工，要做知識的提純者。Blog 記錄動態，Docs 沉澱方法，PR 交付價值。
4. **管理槓桿的躍遷**：從 1:1 的結對編程，走向 1:20 的智能體編隊指揮。

---

*最後更新：2026.01.22*
