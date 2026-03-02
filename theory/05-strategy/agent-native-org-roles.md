# Agent-Native 組織新角色 (Agent-Native Organization Roles)

> 📌 05-strategy — 战略生存

> **來源**: Karpathy "下2步" 框架 + 工程組織演化觀察 + 2026 行業調查 (2025–2026)
> **日期**: 2026-03-02
> **定位**: 當 Agent 成為一等公民操作主體，公司組織必須演化出對應的新職能——不是舊職稱換名字，而是全新的責任邊界

**X-Ray 開場**

「把 AI 工具導入工程團隊」是下0的思路。下2步的思路是：當 Agent 作為一等公民持續執行工程工作，人類的組織結構必須相應演化。Karpathy 描述的轉變——工程師從「寫代碼」到「設計讓 Agent 安全工作的系統」——在組織層面意味著一批全新角色的出現。這不是遠期猜測：這些職能在今天的前沿工程團隊中已有雛形，只是還沒有統一的名字。

**關鍵數據（2026）**：
- Gartner：40% 的企業應用將集成 task-specific AI Agent（2026 年底，較 2025 年 <5% 大幅提升）
- McKinsey：62% 的組織已在試驗 AI Agent，23% 在至少一個部門完成規模化部署
- 職位市場：AI Agent 相關崗位 2023 年以來增長 986%；AI Engineer 職位 YoY +340%
- Dario Amodei（Anthropic CEO）：70-80% 信心，2026 年將出現首個「單人十億美元公司」

> **注意**：`03-engineering/agentic-org-chart-design.md` 描述的是如何組織你的 Agent（Agent 拓撲設計）。
> 本文描述的是如何組織你的**人**（圍繞 Agent 的人員職能設計）。

---

## 原有四角色（核心框架）

### 角色 1：Agent Architect（智能體架構師）

**核心職責**：設計整個 Agentic 系統的拓撲結構——哪些任務委派給哪些 Agent、Agent 間如何協調、控制平面如何設計。

**不同於傳統 Software Architect**：

| 維度 | Software Architect | Agent Architect |
|------|-------------------|----------------|
| 設計對象 | 代碼模塊、服務邊界 | Agent 拓撲、委派邊界、信任層級 |
| 主要產出 | 架構圖、ADR | Agent 拓撲圖、Task Packet schema、信任層級矩陣 |
| 關鍵判斷 | 哪些服務需要分離 | 哪些任務適合委派 vs 自動化 |
| 失敗責任 | 系統不可用 | Agent 產生有害輸出或超出授權範圍 |

**核心技能**：
- 理解 Agent 失效模式（T1-T6，見 `agent-failure-taxonomy`）
- 設計控制平面的六個維度（見 `agentic-control-plane-design`）
- 能設計信任層級框架並定義 Agent 晉升路徑

**過渡路徑**：從 Senior Software Architect 轉型，需補充 Agentic 系統設計和失效模式知識。

---

### 角色 2：AI QA / Eval Engineer（AI 品質與評估工程師）

**核心職責**：設計、維護並持續運行 Eval 基礎設施。是 Agentic 系統進入生產的最後守門人。

**不同於傳統 QA Engineer**：

| 維度 | QA Engineer | AI QA / Eval Engineer |
|------|-------------|----------------------|
| 測試對象 | 確定性代碼行為 | 概率性 Agent 輸出 |
| 測試方法 | Unit / Integration / E2E | Code-based + Model-based + Human eval |
| 核心挑戰 | 覆蓋所有代碼路徑 | 覆蓋語義意圖，而非代碼路徑 |
| 主要工具 | pytest, Selenium | Eval harness, rubrics, golden datasets |
| 失敗判斷 | 測試通過/失敗（二元）| Pass rate 趨勢 + 語義回歸（連續）|

**核心技能**：
- 設計 Model-based eval rubrics（如何用 LLM 評估 LLM 輸出）
- 維護 golden test dataset（選擇、更新、版本控制）
- 把 Eval 集成進 CI/CD pipeline（見 `eval-loop-as-production-practice`）
- 失效分類與 Root Cause Analysis（見 `agent-failure-taxonomy`）

**過渡路徑**：從 Senior QA Engineer 或 ML Engineer 轉型。前者帶來測試設計能力，後者帶來對模型行為的理解。

---

### 角色 3：Context Engineer（上下文工程師）

**核心職責**：設計並維護 Agent 的知識基礎設施——repo map、AGENT_CONSTITUTION、context injection 策略、長期記憶結構。

**這是 Karpathy 框架中最新的職能**，在現有工程師職稱中沒有直接對應。

**工作內容**：
- 維護 `AGENT_CONSTITUTION.md` 和 repo-level context 文件
- 設計 Task Packet 標準格式（見 `context-engineering-field-guide`）
- 管理 retrieval 策略（什麼靜態注入，什麼動態檢索）
- 監控 Context 衰減問題並設計緩解方案

**Context Engineer 的核心判斷**：

```
問題：Agent 在執行任務時表現不佳。
Context Engineer 的問題清單：
  1. Agent 知道代碼庫的結構嗎？（Repo Map 是否存在且更新）
  2. Agent 知道它的邊界嗎？（AGENT_CONSTITUTION 是否清晰）
  3. Agent 在會話中途「忘記」了什麼？（Context 衰減監控）
  4. Task Packet 的範圍描述是否明確？（scope.in / scope.out）
  5. 相關 ADR 是否在 Agent 的上下文中？（context_refs）
```

**核心技能**：
- 理解上下文窗口的物理限制和信息優先級
- 設計 retrieval 系統（向量搜索、BM25、混合）
- 用數據驅動優化 context 配置（通過 eval 結果反饋）

**過渡路徑**：從 Technical Writer、DevOps Engineer 或 ML Engineer 轉型。關鍵是對「信息如何影響模型行為」有深入理解。

---

### 角色 4：Automation PM（自動化產品經理）

**核心職責**：定義人機分工的邊界——哪些流程適合「委派給 Agent 自動化執行」，哪些必須「保留人工介入」，並持續調整這個邊界。

**不同於傳統 Product Manager**：

| 維度 | Product Manager | Automation PM |
|------|-----------------|---------------|
| 設計對象 | 用戶與產品的交互 | 人類與 Agent 的協作邊界 |
| 主要問題 | 「用戶要什麼功能？」| 「哪些決策可以委派，哪些必須人工做？」|
| 核心工具 | PRD, Roadmap | 委派邊界矩陣、Autonomy Slider 設計 |
| 成功指標 | 用戶留存、NPS | Agent pass rate、人工介入率、審查效率 |

**Autonomy Slider 設計**：

每個工程流程的自主度應明確定義，並可以隨時間調整：

```
Level 0 — 全人工：Agent 提供建議，人類決策並執行
Level 1 — 人工批准：Agent 提案，人類批准後執行
Level 2 — 人工審查：Agent 執行，人類事後審查 diff
Level 3 — 例外升級：Agent 自動執行，僅在特定條件下升級
Level 4 — 完全自動：Agent 自動執行，僅記錄日誌
```

一個新流程應從 Level 0-1 開始，隨著 Eval 數據積累逐步提升自主度。

**核心技能**：
- 理解 Agent 信任層級框架（`trust-tier-design`）
- 能將業務風險轉化為 Agent 設計約束
- 用 Eval 數據驅動 Autonomy Slider 的調整決策

**過渡路徑**：從 Product Manager + 對 AI 系統有深入理解。關鍵是能在「效率提升」和「風險控制」之間做有依據的決策。

---

## 新兴角色完整图谱（2026 擴展）

> 2026 年行業調查顯示，除上述四個核心角色外，前沿企業正快速催生六個新職能。這些角色填補了 Agent 系統在信任、治理、交互設計層面的空白。

### 新興角色組織圖

```
                    ┌─────────────────────────────────┐
                    │    Agent-Native 組織結構（2026）  │
                    └─────────────────────────────────┘
                                    │
          ┌─────────────────────────┼──────────────────────────┐
          │                         │                          │
   ┌──────▼──────┐          ┌───────▼───────┐        ┌────────▼────────┐
   │ 架構与工程层 │          │  产品与设计层  │        │   治理与监管层   │
   └──────┬──────┘          └───────┬───────┘        └────────┬────────┘
          │                         │                          │
  ┌───────┼────────┐       ┌────────┼──────┐         ┌────────┼────────┐
  ▼       ▼        ▼       ▼        ▼      ▼         ▼        ▼        ▼
Agent  Context  Eval    Agent    Auto-  HAID     AI Gov  Agent   Trust
Arch.  Engr.   Engr.   PM(new)  PM     Designer Officer  Ops    Engr.
(原)   (原)    (原)   (扩展)   (原)   (新)     (新)    (新)    (新)
```

---

### 新角色 A：Agent 产品经理（Agent PM / Task Packet Designer）

**核心职责**：把用户意图翻译成 Agent 可执行的 Task Packet——这不是写 PRD，而是构建 Agent 能理解的机器可读任务描述。

**与 Automation PM 的区别**：Automation PM 定义「哪些事可以自动化」；Agent PM 定义「每个任务的 Agent 执行规格」。

**核心产出**：
```json
{
  "task_id": "feature-search-v2",
  "intent": "用户想要语义搜索替换关键词搜索",
  "scope": {
    "in": ["src/search/", "tests/search/"],
    "out": ["数据库 schema 变更", "前端 UI"]
  },
  "success_criteria": ["所有现有测试通过", "新增语义搜索测试覆盖率 >80%"],
  "autonomy_level": 2,
  "escalation_triggers": ["需要修改 DB schema", "影响超过 3 个模块"]
}
```

**过渡路径**：从 Senior PM 转型，需补充 Agent 系统设计和任务分解能力。时间线：6-12 个月。

---

### 新角色 B：AI 治理官（AI Governance Officer）

**核心职责**：监管 Agent 行为合规性、建立审计体系、定义跨组织的 Agent 使用边界。

**2026 背景**：Gartner 指出 40% 以上的 Agent 项目将因治理缺失在 2027 年前失败；McKinsey 调查显示 63% 的企业尚未建立 AI-ready 的数据和决策治理实践。

**职能范围**：

| 域 | 具体职责 |
|----|---------|
| 合规审计 | Agent 决策日志审查；监管要求映射（GDPR/AI Act） |
| 风险分级 | 按业务影响对 Agent 动作分级（低/中/高风险） |
| 边界政策 | 哪些业务领域禁止 Agent 自主操作（红线清单） |
| 事故响应 | Agent 越权/错误时的处置流程和善后机制 |

**核心技能**：法律合规 + AI 系统理解 + 风险管理。

**过渡路径**：从 Legal/Compliance、CISO、或高级 PM 转型。时间线：12-18 个月（需补充 AI 系统深度认知）。

---

### 新角色 C：人机协作设计师（Human-Agent Interaction Designer，HAID）

**核心职责**：设计 Human-in-the-Loop (HITL) 流程的用户体验——当 Agent 需要人类输入时，交互应该是什么形态。

**关键设计问题**：
- 何时打断人类？打断的触发条件和呈现形式
- Agent 的不确定性如何向人类可视化？
- 委托边界（Delegation Boundary）如何通过 UI 表达和调整？
- 人类审批的最小认知负担设计

**与传统 UX Designer 的区别**：

| 维度 | UX Designer | HAID |
|------|-------------|------|
| 设计对象 | 人与界面的交互 | 人与 Agent 的委托关系 |
| 核心产出 | 界面原型、流程图 | HITL 流程规格、委托协议 UI |
| 核心问题 | 「用户体验是否流畅？」| 「人类何时需要介入？介入成本是否合理？」|

**过渡路径**：从 Senior UX Designer + AI 系统理解转型。时间线：6-9 个月。

---

### 新角色 D：Agent Ops（智能体运维工程师）

**核心职责**：管理 Agent Fleet 的运行健康——不是管服务器，而是管「Agent 群落」的监控、调度、版本更新和事故响应。

**与传统 SRE/DevOps 的区别**：

| 维度 | DevOps / SRE | Agent Ops |
|------|-------------|-----------|
| 管理对象 | 服务、容器、基础设施 | Agent 实例、任务队列、委托链 |
| 监控指标 | CPU/内存/延迟/错误率 | Task completion rate、Escalation rate、Agent drift |
| 故障处理 | 重启服务、扩容、回滚 | 终止失控 Agent、降级自主度、触发人工接管 |
| 核心工具 | Kubernetes、Prometheus | Agent observability platform、Control plane dashboard |

**过渡路径**：从 DevOps/SRE 转型，补充 Agent 系统监控和控制平面知识。时间线：3-6 个月。

---

### 新角色 E：Trust Engineer（信任工程师）

**核心职责**：把「可信赖性」工程化——设计 Agent 的可信度证明机制、信任层级晋升标准、以及跨系统的信任传递协议。

**核心工作**：
- 定义每个 Agent 的信任 Baseline（初始能力边界）
- 设计 Agent 晋升路径（基于 Eval 数据的 Autonomy Level 提升标准）
- 构建跨 Agent 信任传递协议（A Agent 批准的动作，B Agent 是否需要重新审核？）
- 建立 Trust Decay 机制（长时间未 eval 的 Agent 自动降级）

**为什么需要独立角色**：随着 Agent 数量增加，信任管理的复杂度呈指数级增长。Agent Architect 负责拓扑设计，Trust Engineer 负责拓扑中每条边的信任属性。

**过渡路径**：从 Security Engineer 或 Agent Architect 分化。时间线：与 Agent Architect 同步发展。

---

### 新角色 F：Prompt / LLM Registry 工程师

**核心职责**：维护组织的 Prompt 版本库——所有生产环境使用的 Prompt 的版本控制、性能追踪、A/B 测试和变更管理。

**背景**：当一个组织有 30+ 个 Agent、每个 Agent 有多个核心 Prompt 时，Prompt 的无序变更会导致系统级退化。

**核心产出**：
- Prompt Registry（32+ 任务的 Prompt 版本 + SHA256 hash）
- Prompt 性能 dashboard（A/B test 结果、eval pass rate 趋势）
- Prompt 变更 review 流程（PR 级别的 Prompt 审查）

**过渡路径**：从 ML Engineer 或 Eval Engineer 分化，偏重 Prompt 优化和版本管理。

---

## 消失 / 转变的角色

Agent-Native 组织不只是新增角色，更会加速某些传统角色的转型或淘汰。

| 传统角色 | 转变方向 | 核心变化 | 转型时间线 |
|---------|---------|---------|-----------|
| 传统 QA Engineer | → Eval 工程师 | 从「测试通过/失败」到「持续评估概率输出」；从写测试用例到设计 eval rubrics | 12-18 个月 |
| 传统 Business Analyst (BA) | → Agent PM / Task Packet Designer | 从「写需求文档」到「定义 Agent 可执行的 Task Packet」；从自然语言需求到机器可读规格 | 9-15 个月 |
| 传统系统管理员 (Sysadmin) | → Agent Ops | 从「管服务器」到「管 Agent Fleet」；从基础设施监控到 Agent 行为监控 | 6-12 个月 |
| 传统 Prompt Engineer | → Context Engineer / LLM Registry Eng. | Prompt 工程从独立技能变成 Context Engineering 的子集；工程化程度大幅提升 | 6-9 个月 |
| 传统 Software Architect | → Agent Architect（部分） | 架构设计从「模块边界」扩展到「信任边界和委托边界」；原有职能仍存在但需扩充 | 9-12 个月 |

> 关键洞察：没有哪个角色是「被取代」的——而是「职责边界被重新定义」。传统 QA 不会消失，但纯粹做「确定性测试」的 QA 会大幅减少；Eval 工程师是 QA 能力在 Agent 世界的进化形态。

---

## 2026 企业调查数据

### 宏观采用数据

| 指标 | 数据 | 来源 |
|------|------|------|
| 企业级 Agent 生产部署率 | 62% 试验 / 23% 规模化 | McKinsey 2025 |
| 企业应用集成 Agent 比例（2026 年底预测） | 40% | Gartner 2025 |
| AI 相关投资增加计划 | 88% 企业计划增加 AI 预算 | PwC 2025 |
| Agent 项目失败率预测（2027 前） | >40% | Gartner |
| 具备 AI-ready 数据治理的企业 | 仅 37% | Gartner |

### 角色需求数据

| 角色类型 | 增长数据 |
|---------|---------|
| AI Engineer 职位 | YoY +340% |
| Agent 相关职位（自 2023） | 累计增长 986% |
| AI Agent Orchestration Specialist | 被 Eightfold AI 列为「2026 最重要职位」 |
| Context Engineer | ODSC 列为「2026 新兴高需求角色」之首 |

### 主要障碍

```
Q: 组织 Agent 规模化的首要障碍是什么？
─────────────────────────────────────────
1. 数据质量与治理              32%  ████████████
2. 技能缺口（新角色人才）       28%  ███████████
3. 安全与合规不确定性           21%  ████████
4. 集成复杂度                  14%  █████
5. 投资回报不清晰               5%  ██
─────────────────────────────────────────
```

> 注：数据质量（32%）和技能缺口（28%）合计占障碍的 60%——这正是 Context Engineer 和新兴治理角色的直接价值所在。

---

## One-Person Company 模型

> Dario Amodei（Anthropic）：「我有 70-80% 的信心，2026 年将出现第一个单人十亿美元公司。」

### 单人公司的 Agent 组织架构

在传统公司中，角色由不同的人担任。在 One-Person Company 模型中，**一个人担任所有角色，Agent Fleet 执行所有实际工作**。

```
Solo Founder（单人）
    │
    ├── 担任 Agent Architect：设计整体 Agent 拓扑
    ├── 担任 Automation PM：决定何时委托、何时人工介入
    ├── 担任 Context Engineer：维护各 Agent 的 AGENT_CONSTITUTION
    └── 担任 Eval Engineer：设定 Agent 的质量门禁
          │
          ▼
    Agent Fleet（执行层）
    ├── Coding Agent：功能开发、代码审查、文档生成
    ├── Customer Support Agent：85% 工单自动解决
    ├── Marketing Agent：内容生成、SEO、社交媒体
    ├── Analytics Agent：监控指标、生成报告、识别信号
    └── Operations Agent：账单、合规文件、供应商沟通
```

### Solo 开发者的实际 Agent 栈（2026 案例）

一个 Solo 开发者使用 Agent Fleet 实现的典型规模：

| 传统团队职能 | Agent 替代方案 | 效果 |
|------------|--------------|------|
| 5 人工程团队 | Coding Agent × 3 (前端/后端/测试) | 产品迭代速度 5x |
| 客服团队 | Customer Support Agent | 85% 工单自动化 |
| 增长/营销 | Content + Analytics Agent | 95% 低于传统运营成本 |
| 财务/法务 | Operations Agent | 处理标准化文书工作 |

> 关键原则：**Headcount 已被 Leverage 取代**。Solo 创始人的竞争优势不是「有多少人」，而是「Agent Fleet 的设计质量」——这直接回到了 Agent Architect 和 Context Engineer 的价值。

### 个人 Agent 组织的演进路径

```
阶段 1：工具使用期
  一个人 + 若干 AI 工具（Cursor, Claude, etc.）
  → 效率提升 2-3x，但仍是人主导执行

阶段 2：委托期（当前前沿）
  一个人 + 小型 Agent Fleet（3-5 个专用 Agent）
  → 效率提升 5-10x；人负责方向和质量门控

阶段 3：Fleet 管理期（2026-2027 前沿）
  一个人 + Agent Fleet（10-20 个协作 Agent）
  → Solo 创始人达到传统 20-30 人团队的输出规模
  → 核心竞争力：Agent 拓扑设计 + 质量管控体系
```

---

## 角色转型路径表

### 工程师路径

| 当前角色 | 目标新角色 | 需要新增的技能 | 建议转型时间线 | 优先行动 |
|---------|----------|--------------|-------------|---------|
| Senior Software Engineer | Agent Architect | Agentic 系统设计、失效模式分类、控制平面设计 | 9-12 个月 | 读 `agentic-control-plane-design` + `agent-failure-taxonomy` |
| QA / SDET | Eval Engineer | Model-based eval 设计、LLM 评估方法、eval-CI 集成 | 12-18 个月 | 读 `eval-loop-as-production-practice`；实践设计 eval rubrics |
| DevOps / SRE | Agent Ops | Agent observability、控制平面操作、Fleet 管理 | 6-12 个月 | 了解 Agent 监控工具；参与 Agent 生产事故 review |
| ML Engineer | Context / Eval Engineer | 根据偏向：Context（retrieval、注入策略）或 Eval（rubric 设计） | 6-9 个月 | 选择方向后深耕；两者都需要 |
| Technical Writer | Context Engineer | RAG 系统、向量检索、context 注入架构 | 9-15 个月 | 从「为人类写文档」转向「为 Agent 设计知识库」 |

### PM / 产品路径

| 当前角色 | 目标新角色 | 需要新增的技能 | 建议转型时间线 | 优先行动 |
|---------|----------|--------------|-------------|---------|
| Senior PM | Automation PM | Agent 信任层级理解、风险量化、Autonomy Slider 设计 | 6-9 个月 | 读 `trust-tier-design` + `delegation-not-automation` |
| Business Analyst | Agent PM | Task Packet 设计、Agent 能力边界理解、机器可读规格写作 | 9-15 个月 | 实践将一个现有需求翻译成 Task Packet |
| UX Designer | HAID | HITL 流程设计、委托 UX 原则、Agent 不确定性可视化 | 6-9 个月 | 研究现有 HITL 产品（Copilot、Cursor）的交互模式 |

### 管理者路径

| 当前角色 | 目标新角色 | 需要新增的技能 | 建议转型时间线 | 优先行动 |
|---------|----------|--------------|-------------|---------|
| Legal / Compliance | AI 治理官 | AI 系统工作原理、Agent 审计方法、AI 法规（EU AI Act 等） | 12-18 个月 | 学习 AI 系统基础；主导一个 Agent 合规审查项目 |
| CISO / Security | AI 治理官 / Trust Engineer | Agent 攻击面（prompt injection 等）、信任层级协议 | 9-12 个月 | 从安全视角审查现有 Agent 部署 |
| Engineering Manager | Agent Architect / 转型为 Fleet Manager | Agentic 系统全局视角；从管理人 → 管理人+Agent 的混合团队 | 6-12 个月 | 立即开始：在团队中设定 Context Owner 和 Eval Owner |

---

## 四个原有角色的协作模式

```
新功能 / 流程改进
    │
    ├─→ Automation PM：定义委派边界，设计 Autonomy Slider
    │       ↓
    ├─→ Agent Architect：设计 Agent 拓扑，确定信任层级
    │       ↓
    ├─→ Context Engineer：设计 AGENT_CONSTITUTION + Task Packet
    │       ↓
    └─→ AI QA / Eval Engineer：设计 Eval rubrics，集成 CI Gate
            ↓
        生产部署 → 持续监控 → 反馈改进
```

### 十角色全景协作图

```
战略层
  AI 治理官 ←──────────────────────────────── 设定边界
    │
    ▼
产品层
  Automation PM ──→ Agent PM（Task Packet）
    │                    │
    ▼                    ▼
工程层
  Agent Architect ←─── Trust Engineer
    │                    │
    ├─→ Context Engineer │
    │                    │
    └─→ Eval Engineer ───┘

运维层
  Agent Ops ←────── 生产监控回路 ──────→ Eval Engineer

体验层
  HAID（Human-Agent Interaction Designer）← 所有 HITL 触点
```

---

## 与现有角色的关系

这些角色不是要取代现有工程师，而是**现有工程师职能的分化**：

| 现有角色 | 分化出的新职能 |
|---------|-------------|
| Senior Software Architect | Agent Architect（+ Agentic 系统设计）|
| Senior QA / SDET | AI QA / Eval Engineer（+ 语义评估能力）|
| Technical Writer / DevOps | Context Engineer（全新职能，无直接前身）|
| Senior PM | Automation PM（+ AI 系统风险判断能力）|
| Legal / CISO | AI 治理官（+ AI 系统深度理解）|
| DevOps / SRE | Agent Ops（+ Agent Fleet 管理）|
| UX Designer | HAID（+ 委托 UX 和 HITL 设计）|
| Security Engineer | Trust Engineer（+ 信任协议设计）|

**在小团队中**：一个人可以兼任多个角色。但随着 Agentic 系统规模增长，这些职能的分化是不可避免的。**Solo 创始人** 则是极端情况——一人兼任所有角色，Agent Fleet 执行所有实际工作。

---

## 今天就可以做的事

在正式设立这些角色之前，你可以立即做的：

1. **指定 Context Owner**：谁负责维护 AGENT_CONSTITUTION 和 repo map？
2. **指定 Eval Owner**：谁负责 eval suite 的健康和 CI gate 的阈值？
3. **明确委派边界**：用 Autonomy Slider 评估现有的每个 Agent 工作流
4. **做一次 Failure Review**：收集上个月的 Agent 失效，用 T1-T6 分类，找出谁应该拥有每类失效的预防责任
5. **角色盘点**：对照转型路径表，为每位团队成员识别最近的目标新角色
6. **治理先行**：即使没有 AI 治理官，也要在生产部署前定义 Agent 的「红线动作」清单

---

## 相关文章

- `03-engineering/agentic-control-plane-design.md` — Agent Architect 的主要设计工具
- `03-engineering/context-engineering-field-guide.md` — Context Engineer 的操作手册
- `03-engineering/eval-loop-as-production-practice.md` — AI QA Engineer 的核心实践
- `03-engineering/agent-failure-taxonomy.md` — 四个角色共同使用的失效框架
- `03-engineering/trust-tier-design.md` — Trust Engineer 和 AI 治理官的理论基础
- `03-engineering/delegation-not-automation-engineering-principles.md` — Automation PM 的委托哲学
- `05-strategy/reconstructing-engineering-mindset.md` — 个人如何从执行者转型为决策者（本文的个人层面版本）
