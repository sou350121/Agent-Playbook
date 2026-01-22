# Agent 管理学 (Agent Management)

> **使命**：把“会用 Agent”升级为“能管理 Agent”。从单点提示词，走向可复用的 **编队、SOP、门禁与复盘**。

---

## 🧭 推荐阅读顺序

1. **[01 组织模型与角色分工](./01-operating-model-and-roles.mdx)**
   - 把 Agent 当“团队”管理：角色、职责边界、交接契约。
2. **[02 Playbook：从 Spec 到 PR](./02-playbook-spec-to-pr.mdx)**
   - 最核心的交付链路：信号 → 需求 → 设计 → 实现 → 验证 → PR → 复盘。
3. **[03 Playbook：多 Agent 编队协作](./03-playbook-multi-agent-squad.mdx)**
   - 怎么切任务、怎么合并、怎么减少冲突、怎么让 review 成为质量阀门。
4. **[04 Playbook：风险治理与回滚](./04-playbook-risk-and-rollback.mdx)**
   - 把“出事概率”变成“可控流程”：权限、沙箱、审计、发布与回滚。
5. **[05 Playbook：Ralph Loop 迭代范式与 AFK 指挥](./05-ralph-loop-iteration-paradigm.mdx)**
   - 解决 Agent 的“半途而废”：Stop Hook、完成承诺与持续迭代生产线。

---

## ⭐ Top Picks（少而精）

- **[Spec → PR 交付 Playbook](./02-playbook-spec-to-pr.mdx)**：一切从“可验证”开始。
- **[Ralph Loop 迭代 Playbook](./05-ralph-loop-iteration-paradigm.mdx)**：让 Agent 持续工作直到真正完成。
- **[多 Agent 编队 Playbook](./03-playbook-multi-agent-squad.mdx)**：把并行变成吞吐，而不是混乱。
- **[风险与回滚 Playbook](./04-playbook-risk-and-rollback.mdx)**：面向真实世界的“安全刹车”。

---

## 🧠 核心洞见

1️⃣ **智能體型組織（Agentic Organization）的五大支柱**
- **商業模式**：邊際成本趨近算力成本；專屬數據成為核心壁壘。
- **運營模式**：從職能部門轉向去中心化的智能體團隊網絡。
- **治理體系**：嵌入式治理（以智能體制衡智能體）；實時化、數據驅動。
- **人才與文化**：人類轉向端到端業務成果的所有者；M 型監督者與 T 型專家。
- **技術與數據**：智能體網格 (Agent AI Mesh)；智能體間通訊協議。

2️⃣ **管理學的本質：把隨機性變成制度**
- **逻辑思考**：Agent 的能力不是线性的，它的风险也不是线性的。你不能靠“更聪明的模型”对冲工程事故，只能靠 **流程门禁 + 可审计** 的治理体系。
- **启发**：从“提示词写得好”转向“系统设计得稳”——角色、SOP、验收与回滚，才是长期复利。

2️⃣ **从“写代码”到“指挥生产线”**
- **逻辑思考**：Agent 更像工厂，不像手工。管理者要设计 **输入（Spec）→ 过程（执行链路）→ 输出（可验证交付）** 的控制面。
- **启发**：当你能复制一个 playbook，你就能复制产能。

3️⃣ **“Review”不是礼貌，是质量阀门**
- **逻辑思考**：多 Agent 并行的最大敌人不是速度，而是冲突与返工。Review 的职责是把“不可逆错误”拦在合并之前。
- **启发**：把 review 变成制度化关卡，而不是临时的“看一眼”。

4️⃣ **AFK：管理的终极杠杆是自动闭环**
- **逻辑思考**：Ralph Loop 证明了，只要完成条件足够客观（測試、代碼狀態），我們就可以通過外部循環強制 Agent 持久工作，而不需要人類持續監督。
- **启发**：將「信任」建立在可驗證的自動化檢測之上。

---

## 🔗 关联章节

- **[架构治理](../architecture-governance/README.mdx)**：物理导轨与逻辑契约（项目级治理）。
- **[计划与范式](../planning/README.md)**：心法与协作范式（认知级治理）。
- **[安全与防御](../security/README.md)**：环境隔离与攻击面管理（风险级治理）。

