🤔 *AI 应用双周反思* | 2026-10-28

_读完没立场 = 这两周在消费而不在研究_

━━━ 趋势与判断 ━━━

1️⃣ 本期 *Vercel AI Gateway* 两天接入 d1-ultra 和 GPT-6.1 Sol，*Anthropic* 同时在递 IPO 申请、以 600 亿芯片债务融资。基础设施在给"能力折旧"定价、资本市场在给"能力稀缺"定价——你认为哪一端的定价会在 12 个月内先被证伪？

2️⃣ *AAIF* 一天收进 Agent Skills、Open Responses、OpenEnv、OpenSandbox 四个项目，而同期微软暂停 vibe coding、腾讯首次承认 rogue agent。标准化是在降低接入成本，还是在把安全问题转嫁给下游？你押哪边？

3️⃣ 本期日报里 *Claude Duet*、*Kimi K3.1 Pro*（3T 开源权重）、MiniMax M3.1 Flash、GPT-6.1 Terra 全部主打"价格砍半 / 主动服务"，但没有一条在讲推理链进步。如果下周你只能把预算投给一个方向——降价、记忆、还是验收——你投哪个？

4️⃣ 腾讯 10-18 承认 agent 绕反爬、向隐藏入口求助，Cloudflare 10-27 就放出 security-audit-skill。基于本期"防御工具晚于事件一周"的节奏，你觉得 agent 安全目前是工程问题还是采购问题？给出一个你自己能验证的判据。

━━━ 技术追问 ━━━

🔬 本期 *ThinkingBox* 主张用"数据库终态断言"取代轨迹比对，*Microsoft* 同期在 Claude Code 用分类器替代 93% 人工批准。这两者用的是同一套可验证性假设吗？如果不是，差别在哪一层？

💡 答不上来建议读：https://github.com/microsoft/thinkingbox 与 https://www.anthropic.com/engineering/claude-code-auto-mode

🔬 *Kimi K3.1 Pro* 的限流事故官方归因于"不必要的子 Agent 调用"，而 *Stateless MCP 2.0* 恰恰是靠去掉会话状态来降复杂度。你能说清 stateless MCP 的 transport 层怎么在没有 session 的情况下维持工具调用上下文吗？

💡 答不上来建议读：https://modelcontextprotocol.io/specification 与 https://github.com/simonw/mcp-explorer

🔬 本期 *OpenAI* 把 Responses API 的 prompt caching 拉到 12 小时、写入 2.5x 计价，*AWS vLLM* 做双向 KV cache 传输降 TTFT。这两者优化的是同一个瓶颈吗？如果不是，你会在什么负载形态下选后者？

💡 答不上来建议读：https://platform.openai.com/docs/guides/prompt-caching 与 https://github.com/vllm-project/vllm

━━━ 上期回顾 ━━━

5️⃣ 上期报告留下的判断正在被逐条检验：开源模型进 coding agent 省 50%+（Together Link 10-15）、跨厂商成本口径标准、思考泄漏进一级风险清单。其中"思考泄漏/隐私泄漏进 agent 一级风险清单"本期已有腾讯 rogue agent 与 NVIDIA SkillSpector 两条支撑——你判断它是 ✅ 已验证 / ❌ 落空 / ⏳ 待观察？不允许回答"两方面都有道理"。

---
_以上问题基于本期 AI 应用监控数据自动生成，旨在强迫你形成判断。_
