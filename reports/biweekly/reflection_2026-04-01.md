🤔 *AI 应用双周反思* | 2026-04-01

_读完没立场 = 这两周在消费而不在研究_

━━━ 趋势与判断 ━━━

1️⃣ 本期 *OpenAI* 完成$122B 融资（估值$852B）但同期关闭 *Sora* 视频 app 终止 Disney $1B 合作，*Manus AI* 用户积分耗尽、*Windsurf* 静默扣费被抗议——资本在赌「基建完善后可靠性会自然解决」，用户用脚投票转投竞品。这个「剪刀差」会在 6 个月内迫使行业重新评估经济模式，还是继续恶化？你押哪边？

2️⃣ 36 篇 Deep Dive 中「*MCP is dead; long live MCP*」标题本身就是信号——*FastMCP*、*Universal CLI (Composio)* 并行出现无一方主导叙事，但 *LangChain* 靠 *LangSmith Fleet* 两种 Agent 授权模式 + *Sandboxes* 安全代码执行赢在治理层。当协议层碎片化时，治理层成为新瓶颈。你认为 2027 年独立 Agent 框架团队会面临「无人复用」困境吗？为什么？

3️⃣ 72 小时内 3 起重大安全事故集中爆发：*LiteLLM* 供应链攻击（3/24）窃取 SSH/云凭证、*Meta* 内部 agent 致敏感数据暴露 2 小时（3/23）、*OpenClaw* 更新致微信/飞书/钉钉集成瘫痪（3/24）——这不是巧合，是「快速迭代无回归测试」的必然结果。有人说「Agent 安全评估 Q2 成采购硬要求」，基于本期 88% 组织经历 AI agent 安全事件的数据，这个判断成立吗？给出你的理由，不允许回答「两方面都有道理」。

4️⃣ *Simon Willison Blog* 占 Daily Picks 19%（15/81）——单一意见领袖占比过高，这是领域缺乏共识的危险信号。对比 VLA 域同期有假设持续追踪，AI 应用域 Active Assumptions 为空——这是系统性盲点。如果只能深入学一个本期出现的框架/工具，你选哪个？为什么？（禁止回答「看场景」）

━━━ 技术追问 ━━━

🔬 本期 *LangSmith Sandboxes* 推出安全代码执行、*LangSmith Fleet* 两种 Agent 授权模式——这是 agent 安全基础设施的必经之路。你能解释 *LangSmith* 的沙盒隔离机制与 *Docker* 容器、*gVisor* 的核心区别吗？它解决了哪些传统沙盒无法解决的 agent 特有问题？
💡 答不上来建议读：https://blog.langchain.com/introducing-langsmith-sandboxes-secure-code-execution-for-agents/ + https://docs.langchain.com/enterprise/sandboxes

🔬 *LiteLLM* 供应链攻击（3/24）恶意 PyPI 版本可窃取 SSH 密钥/数据库密码/云凭证，*Karpathy* 转发警告——依赖「pip install 信任」的时代结束。你能解释 Python 包签名验证（PEP 458/480）的核心原理吗？为什么至今未强制启用？
💡 答不上来建议读：https://peps.python.org/pep-0458/ + https://simonwillison.net/2026/Mar/25/litellm-hack/

🔬 36 篇 Deep Dive 中 27 篇是「significant_update」（75%）仅 9 篇纯理论（25%）——工程团队在分享实战经验而非追逐 hype，「*Vibe Coding*」被证伪，*Agentic Engineering* 成主流。你能解释 *Agentic Engineering* 与 *Vibe Coding* 在工程流程上的 3 个核心区别吗？
💡 答不上来建议读：https://simonwillison.net/guides/agentic-engineering-patterns/what-is-agentic-engineering/ + https://simonwillison.net/2026/Mar/25/thoughts-on-slowing-the-fuck-down/

---
_以上问题基于本期 AI 应用监控数据自动生成，旨在强迫你形成判断。_
