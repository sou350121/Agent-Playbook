🤔 *AI 应用双周反思* | 2026-09-30

_读完没立场 = 这两周在消费而不在研究_

━━━ 趋势与判断 ━━━

1️⃣ 上期预测「3–4 周内 ≥3 家云/平台推托管 Agent 运行时」本期已落地：*AWS AgentCore Runtime*(9/20)、*Google ax*(9/24)、*Vercel Sandbox Drives 公测*(9/23)，提前兑现 → ✅ 已验证。那么独立 Agent 框架在应用层的份额是真受压，还是靠 harness 层（*ECC* / *Strands Harness* / *harness-sdk*）重新长出空间？给出你的判断，不许回答「两方面都有道理」。

2️⃣ *Bedrock AgentCore* 两周四度登场、*Google ax* 与 *Strands Harness* 同周开源，另一头 GitHub 上 ECC、ai-memory、litelm、Pion 仍碎成一片。你押哪边：runtime 收敛成 AWS/Google 两三家，还是 harness 层会长出一批独立玩家？点名一个你愿意下注的项目。

3️⃣ 社区同时存在 “MCP was always a bad idea?” 的批评，与 *AgentCore Gateway + MCP*、*WebMCP*、mcp-handler 的官方推法。基于本期数据，「MCP 已从开放协议沦为云厂 runtime 上的一个 App 形态」这个判断成立吗？拿哪几条证据支撑。

4️⃣ 本期至少四个编码 Agent 记忆方案涌现：*ai-memory*、*hindsight*（会学习的 Memory）、*ReasoningBank*、AgentCore Memory。如果只能读一个的源码，你选哪个？说清你淘汰另外三个的理由。

━━━ 技术追问 ━━━

🔬 *IBM Research* 9/20《Your Agent Aced the Task. Will It Do It Again?》把评测从单次成功率推向可复现率。你能讲清楚怎么量化一个 Agent 的同任务复现性（pass^k、跨 run 方差，还是别的），以及它为什么比 pass@1 更难做吗？
💡 答不上来建议读：https://huggingface.co/blog/ibm-research/altk-evolve-consistency

🔬 *Strands Harness* 9/28 声称同模型下 token 成本降 28%。这个降幅到底来自 context 压缩、工具结果截断，还是 prompt cache 命中——你能拆开说吗？
💡 答不上来建议读：https://strandsagents.com/blog/introducing-strands-harness/

🔬 *Claude Sonnet 5.5* 在 *Terminal-Bench 4.0* 打到 70.6%。你清楚这个 benchmark 测的究竟是 shell 操作、工具调用，还是长任务端到端成功率吗？它和 SWE-bench 的差异在哪？
💡 答不上来建议读：https://www.anthropic.com/claude-sonnet-5-5

---
_以上问题基于本期 AI 应用监控数据自动生成，旨在强迫你形成判断。_
