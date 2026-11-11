🤔 *AI 应用双周反思* | 2026-11-11

_读完没立场 = 这两周在消费而不在研究_

━━━ 趋势与判断 ━━━

1️⃣ 本期 *MCP* 被三方当公共地基（AWS 打包接入、Google 37 个开源 skill、NVIDIA 内核沙箱），报告据此断言「协议战争结束，战场移到 skill 生态」。但同期 *DeepSeek Harness* 走的是 Router/Worker 双层自研 harness，压根不接 MCP。那么 skill 层到底是真收敛，还是只是大厂在自己的分发渠道里收敛？你押哪边，给一个三个月内可证伪的判断。

2️⃣ 本期最大未解问题是 *skill* 没有版本语义：Google 37 个开源 skill、AWS toolkit 一次接全、MoEngage 400+ 私有 API 全部挂上去，却没有任何一处提到 lockfile 或回滚。报告预测「一个月内出现版本管理方案」。你自己现在的 agent 依赖几个 skill？如果其中一个昨夜上游改了一行，你怎么知道自己行为变了？

3️⃣ 报告说 *Gemini 4 Carbon*（CursorBench 4.0 / WANDR / AutomationBench 三项第一）和第三方榜单（AA 智能指数 59、SEC-bench Pro 88.2%）是同一件事。可 CursorBench 4.0 是谁出的？AutomationBench 是谁的？当发布方同时是榜单出品方时，你的评测可信度门槛应该设在哪？

4️⃣ 本期 *Claude Fable 5.2*（$8/$40）、Gemini 4 Carbon（$2/$10）、DeepSeek V4.1 Flash（>1000 tok/s、1M 上下文）同时在场，报告却主推「80% 降价是路由与缓存重算」这个叙事。可价格重算恰恰意味着同一份代码换家供应商能差五倍。你上次是按能力选模型，还是按这张价格表已经选好了、再去挑榜单找理由？

5️⃣ 报告称「社群开始为反 slop 付费」（*hallmark*、*mcode-stack*、*impeccable* 62 条确定性规则）。但本期社交样本是 0 条，这个判断的全部依据是 GitHub 星数与周榜。星数在两周内能被人为拉高多少，你心里有数吗——还是说这条结论本身就该整体降权？

━━━ 技术追问 ━━━

🔬 本期 *REMORY* 只做了一件事：基模冻结，在 compaction 摘要后面追加软记忆 token，ASI-Bench 29.33。请说清楚 *compaction* 在长会话里丢掉的到底是什么信息，以及「软记忆 token」为什么能补回来而不用重训。答不上来，你的上下文压缩策略就还是在抄别人的 default。
💡 答不上来建议读：https://github.com/fudan-generative-vision/Remory

🔬 *un-cut* 是 7 MB 单二进制 Go coding-agent harness，卖点「拒绝任何静默上下文截断」；*worktrunk* 用 git worktree 给每个 agent 隔离工作目录。两者解决的是同一个故障的两个面——请说明为什么「并行 agent 写同一工作目录」会让上下文截断从性能问题变成正确性问题。
💡 答不上来建议读：https://github.com/max-sixty/worktrunk

🔬 跨租户 KV cache 泄漏（*GLM-5.3* 155 条响应串上下文）和报告说的「80% 降价来自路由与缓存重算」是同一套系统。请解释跨租户 KV cache 复用的收益模型与隔离边界在哪里失守，以及你打算用什么 key 结构杜绝它。
💡 答不上来建议读：https://github.com/sgl-project/sglang

━━━ 上期回顾 ━━━

6️⃣ 上期预测「一个月内出现 skill 版本管理或依赖锁定的公开方案（至 12-11）」，本期已出现 *anthropics/skills* Office skill 转 Apache-2.0、GitHub 周榜前三全是 Agent Skill，但没有任何一处 lockfile、registry 或回滚语义。判定：⏳ 待观察，且窗口只剩一个月。你的判断是——这是需求不存在，还是需求存在但没人敢先做标准？不许说「两方面都有道理」。

---
_以上问题基于本期 AI 应用监控数据自动生成，旨在强迫你形成判断。_
