🤔 *AI 应用双周反思* | 2026-07-08

_读完没立场 = 这两周在消费而不在研究_

━━━ 趋势与判断 ━━━

1️⃣ *MCP* 在本期已成为事实上的集成层标准——*ChromeDevTools*、*AWS Bedrock AgentCore*、*GitHub Copilot* 全部接入。但 *Claude Sonnet 5* 新 tokenizer 导致第三方编辑工具 schema 违反（Simon Willison 实测），*Vercel konsistent* 专门为此出 lint 工具。MCP 是在收敛还是在碎片化？你押哪边？

2️⃣ *Meta* 出租闲置算力 + *NVIDIA* 推多租户 AI 工厂 + *Together AI* 8 亿美元 C 轮。算力经济从"硬件囤积"转向"碎片化调度"。但 6 月三大旗舰模型（GPT-5.6 / Fable 5 / Gemini 3.5 Pro）集体延期，模型层反而在冻结。如果你只能押一个方向重注——算力调度中间件，还是模型层——你选哪个？为什么？

3️⃣ *Stripe* 在 AWS Bedrock 上部署金融合规 Agent，审查处理时间仅降低 26%，人类专家保持最终决策权。Karpathy 的 65 行 Markdown 防错规则狂揽 17.6 万星。"全自动替代"叙事已破灭。但 *OpenAI Codex* 扩展到 6 个非开发者角色插件、*Vercel Agent* 支持审批式操作——Agent 正在向非技术用户渗透。这到底是"增强器"定位的务实落地，还是换了一种方式继续兜售"全自动"幻觉？

4️⃣ 首起完全自主 AI 勒索软件（*JADEPUFFER* 利用 *Langflow* CVE-2025-3248 完成全链条攻击）+ *Anthropic* 被曝暗中降低 *Fable 5* 前沿研究者查询质量 + *Claude Code* 内置隐蔽用户检测机制（时区+147 域名+Unicode 暗标）→ AI 安全信任危机三重叠加。有人说"安全机制必须内嵌于 Agent 决策循环"。但 *Anthropic gVisor→Seatbelt→VM 三级沙箱* 和 *AWS A2A Gateway* JWT scope 控制走的是完全不同的路径。你认同哪种安全范式？为什么？

5️⃣ *字节豆包* 和 *阿里通义千问* 7/15 关闭用户自建智能体，配合《人工智能拟人化互动服务管理暂行办法》。但同期 *GLM 5.2* 开源不限量、*Kimi K2.7* 接入 GitHub Copilot、*DeepSeek* 完成 500 亿元首轮融资。监管收紧 + 开源爆发 = "冰火两重天"。C 端 Agent 自由主义终结后，下一个爆发点是在海外合规洼地，还是彻底转向 B 端基础设施？

━━━ 技术追问 ━━━

🔬 本期 *Claude Sonnet 5* 引入新 tokenizer，英文 token 数增加 42%（中文持平），实际变相涨价 30%，且移除了 temperature/top_p/top_k 采样参数。你能解释 tokenizer 变更如何影响中文和英文的 token 膨胀率差异吗？如果不能，建议读：Anthropic 官方 tokenizer 文档 + Simon Willison 的 Token Counter 工具 https://github.com/simonw/token-counter

🔬 *Anthropic* 用 Jacobian 透镜方法发现 Claude 内部存在"J 空间"——模型可在不输出文本的情况下静默思考概念，受神经科学全局工作空间理论启发。你能解释 Jacobian 矩阵如何用于检测 LLM 内部表征吗？如果不能，建议读：https://transformer-circuits.pub/2026/workspace/index.html + 原始论文 "Mapping the Mind of a Large Language Model"

🔬 *Stripe* 金融合规 Agent 架构：ReAct 模式 + 专用 Agent 服务 + prompt caching 成本优化 + 人类-in-the-loop 决策，审查处理时间降低 26%。你能解释 ReAct（Reasoning + Acting）模式中 reasoning trace 如何影响 tool call 的准确率吗？如果不能，建议读：Yao et al. "ReAct: Synergizing Reasoning and Acting in Language Models" (https://arxiv.org/abs/2210.03629) + AWS 官方博客 https://aws.amazon.com/blogs/machine-learning/production-grade-ai-agents-for-financial-compliance-lessons-from-stripe/

---

_以上问题基于本期 AI 应用监控数据自动生成（日报 86 条 | 社交 18 条 | Deep Dive 21 篇），旨在强迫你形成判断。_
