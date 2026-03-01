# 工具链 (Tool Stack)

> **核心使命：** 介绍如何选择、配置并榨干 AI 驱动开发工具的潜力。这里不只是软件列表，更是关于如何构建属于你自己的“超级工厂”的实战指南。

---

## 🧭 推荐阅读顺序

1. **[AI 协作 DNA 工作流：从结论到 PR 的闭环](./agent-dna-workflow.mdx)**
   - 定义每一行代码的交付标准，让 Agent 像资深工程师一样工作。
2. **[Kiro 進階指南：從「會寫」到「交付」](./kiro-mastery-guide.mdx)**
   - 掌握 Spec-Driven 開發，利用 Powers 與 Hooks 構建自動化交付流水線。
3. **[Cursor 深度方法论：从入门到 10x 提效](./cursor-methodology.mdx)**
   - 核心 IDE 生产力工具的深度实战经验。
4. **[Docker 专家级指南：给 Agent 的标准容器](./docker-mastery-for-agents.mdx)**
   - 为什么 Docker 是 Agent 运行环境的唯一真理。
5. **[Tmux：Agent 的任务会话堡垒](./tmux-guide.mdx)**
   - 如何在多任务并发下保持优雅的会话管理。
6. **[手机远程遥控 Agent：把 Claude Code 装进口袋](./mobile-remote-agent.mdx)**
   - SSH + tmux + Tailscale：随时接管家里的终端与会话，移动端 1:1 还原体验。
7. **[DCP：凸性检测规则速查（CVX/CVXPY 的“为什么不让写？”）](./dcp-convexity-checking-rules.mdx)**
   - DCP 是充分非必要；给“报错→重构”的工程套路清单。
8. **[Text-to-SQL 的真实解法：从“写 SQL”到“可审计的取数系统”](./text-to-sql-reliable-architecture.mdx)**
   - 语义层 + schema linking + guardrails + 可追溯：把大模型关进取数系统的轨道。
9. **[多 Agent 协作流：从单兵作战到小队编排](./multi-agent-coding-workflow.mdx)**
   - 探索让不同的模型（Claude/GPT）在同一个项目中各司其职。
10. **[用纯 NumPy 吃透 30 篇论文复现：从 forward 到 backward](./sutskever-30-implementations-numpy.mdx)**
   - 拒绝调包，手写梯度与注意力；把“会用框架”升级为“会推导 + 会实现”。

---

## ⭐ 精选 Top Picks

- **[2025 AI 工作站全家桶：Builder 的武器库](./ai-workbench-stack-2025.mdx)**
  - 从 IDE 到推理引擎，从沙箱到监控，一站式选型建议。
- **[Kiro mastery：Spec、Powers 與 Hooks 的藝術](./kiro-mastery-guide.mdx)**
  - 揭秘如何將 Agent 開發轉化為工業級的生產流水線。
- **[NotebookLM-py：研究 Agent 的最強能力組件](./notebooklm-py.mdx)**
  - 揭秘如何將 Google 的最強 RAG 搬進命令行，實現知識的自動化流轉。
- **[阿里雲 Vibe Coding 实战指南](./aliyun-vibe-coding-practical-guide.mdx)**
  - 将你的 Agent 部署到云端，实现真正的“意图 -> 基础设施”自动化。

---

## 🧠 核心洞见

1️⃣ **工具是“超级工厂”而非“手持器械”**
- **逻辑思考**：IDE（如 Cursor）不只是一个编辑器，它是你与 Agent 的协同协议（Protocol）。Docker 与 Tmux 不只是运行环境，它们是 Agent 的“生存沙盒”与“记忆堡垒”。
- **启发**：不要问“这个工具怎么用”，要问“这个工具如何降低了 Agent 的环境熵值”。

2️⃣ **交付大於編寫：Spec 的力量**
- **邏輯思考**：在 Agent 時代，代碼的生成是廉價的。真正的風險在於「生成的東西不是我想要的」。通過 Spec (Specification)，我們為 Agent 建立了確定的物理導軌，將開發轉向驗證驅動。
- **啟發**：先寫驗證，再寫任務，最後才讓 Agent 寫代碼。

3️⃣ **工具的「解耦」與「注入」**
- **邏輯思考**：像 `notebooklm-py` 這樣的工具，其價值在於將強大的 SaaS 產品功能（如 Google 的 RAG）與繁瑣的 UI 解耦。一旦工具變成了 CLI/API，它就能被「注入」到 Agent 的系統中。
- **啟發**：在選擇工具時，優先考慮那些具備「Skill 屬性」或「可編程入口」的工具。

4️⃣ **DNA 级交付标准：对抗随机性**
- **逻辑思考**：AI 的输出是概率性的。通过定义 `结论 -> 分析 -> 方案 -> 里程碑 -> PR` 的强链条工作流，我们将“概率性输出”转化为“确定性交付”。
- **启发**：最好的工具就是那套能把 AI 的随机性关进笼子里的规约。

---

## 🔗 关联章节
- **[能力边界](../frameworks/README.md)**：了解这些工具背后的模型能力（如语义路由）。
- **[小白通关手册](../../action/onboarding/README.md)**：查看工具的基础安装与上手路径。
- **[案例复盘](../../use-cases/case-studies/README.md)**：看这些工具组合在真实项目中如何发挥威力。
