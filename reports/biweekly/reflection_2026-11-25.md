🤔 *AI 应用双周反思* | 2026-11-25

_读完没立场 = 这两周在消费而不在研究_

━━━ 趋势与判断 ━━━

1️⃣ 本期把结论写成「MCP 统一接入、harness 分散调度」，但 *Claude Code Projects*（11-17）已经把自己升级成多 agent 协调者、*Kimi* 直接托管 harness、*DeepSeek* 开插件市场。三者是在同一层竞争，还是各自切了一块不同的层？你押哪边？

2️⃣ 11-21 *Anthropic* 上市首日市值破 2 万亿，11-23 就跌回 1.28 万亿，同期 11-24 出现「AI 编程成本危机」和 *Airbnb* 换成 cost per task 指标。这轮涨跌是估值修正，还是市场对 agent 经济性的第一次定价？你押哪个？

3️⃣ 11-18 IPO 文件说 *Claude Mythos* 三天完成模型到 AMD MI355X 迁移、自主写近 100% kernel；11-12 *METR* 给出约 2 倍加速且多数来自 AI 参与研发。两条同时出现在同一家身上，这是巧合，还是 38 篇 deep dive 里唯一该被转成命题的信号？为什么系统没转？

4️⃣ 如果只能深入读本期一篇，你选 *METR 的 2 倍加速评估* 还是 *Airbnb 的 cost per task 方法论*？前者改你的技术假设，后者改你的账单结构——选一个，说理由。

━━━ 技术追问 ━━━

🔬 11-13 *Claude Code 2.1.319* 的 *denyInsteadOfPrompting* 把权限决策从「人点确认」改成「策略预先裁定」。请解释：在一个异步后台化的 agent 里，这条策略引擎必须在什么粒度上知道工具调用的后果，才能不误杀合法操作？说不清就是对本期核心机制没摸到。
💡 答不上来建议读：https://github.com/sou350121/Agent-Playbook/blob/main/theory/02-agent-design/claude_code_21319mcp_denyinsteadofpromptingclaude_api_latenc_deep_dive.md

🔬 11-12 *Vercel Decisions API* 与 11-13 *Gemini Decision 1* 都声称「不生成 token 的决策」。单次前向打分和「小模型生成是/否」在工程上到底差在哪，为什么 *Antigravity* 敢说静态 model router 已失效？
💡 答不上来建议读：https://github.com/sou350121/Agent-Playbook/blob/main/theory/03-engineering/vercel_parallel_decisions_apiai_gateway_deep_dive.md

🔬 11-19 *Bedrock AgentCore* 用快照预热把冷启动压到 2 秒，11-17 又有「每次工具返回后重算预算再落新窗口」的上下文压缩。快照恢复的会话状态与压缩后的上下文窗口，谁拥有记忆的真相？
💡 答不上来建议读：https://github.com/sou350121/Agent-Playbook/blob/main/theory/03-engineering/bedrock_agentcore_runtime_2_deep_dive.md

━━━ 上期回顾 ━━━

5️⃣ 九个月前（2026-03-04）你预测「Q2 初 Agent 安全评估成企业采购硬要求」。本期证据分裂：*LangSmith Tool Gateway* 做了工具凭证与审批治理（11-23）、*OpenAI×Cisco* 的 Shirudo 挡漏洞利用（11-24），但它是厂商自建护栏，不是采购标准或认证体系。你的判断：✅ 验证 / ❌ 落空 / ⏳ 待观察？给出理由，不允许「两方面都有道理」。

---
_以上问题基于本期 AI 应用监控数据自动生成，旨在强迫你形成判断。_
