# 🤖 AI 每日精选 | 2026-10-19

🔥 头条
- 【🔴新发布】Anthropic 宣布把 5% 股份注入「公共利益基金」
  营收近 168 亿美元、IPO 在即，却先划出 5% 股权做公益池——估值每涨 50% 董事会可再追加 2%，资金可定向用于缓冲 AI 对就业的冲击。这是前沿实验室第一次把「外部性」写进股权结构；注意：目前仅见媒体转述（Investing.com/Anadolu 及国内 readhub），anthropic.com/news 尚无公告页，一手口径待补。
  https://ca.investing.com/news/stock-market-news/anthropic-commits-5-of-shares-to-new-public-benefit-fund-4887017
- 【💬观点】Anthropic 抛「奇点已至」论：AI 或把美国 GDP 推到 44 万亿美元
  和上一条是同一场合的两面：一边喊加速，一边用股权基金做对冲。读它的正确姿势是看「谁在为什么买单」，而不是看数字。
  https://www.36kr.com/p/4030919698731654

⚡ 精选动态
- 【🔧工具】DeepSeek Search/Fetch API 转收费：11/1 起每 1000 次成功请求 5 元
  昨天已报 10/17 上线（首发），今天的新信息是计费细则：Harness / Claude Code / Codex 里的 Server 端工具调用此前免费，11/1 00:00 起计费。对高频 RAG / agent 检索是实打实的成本项。
  https://m.ithome.com/html/1014587.htm
- 【🏢行业】DeepSeek 侧写：Harness v0.2.1-rc1 + V4.1-Flash-1017 快照短暂出现
  一手线索只有 API 文档里「deepseek-flash 现由 V4.1-Flash-1017 提供」这一句，模型卡与公告未发布，「快照流出」部分属媒体转述——当成在跑的小版本，别当成大版本。
  https://api-docs.deepseek.com/
- 【💬观点】给 DeepSeek Harness 写一个按峰谷价计费的花费插件
  中文社区里少见的硬核实现：按官方人民币峰谷价逐次计价，做 Host 侧投影 + 节假日日历。比「每天查一次账单」细一个量级。
  https://juejin.cn/post/7697150457639108662
- 【📊趋势】GPT-Rosalind 学术计划：OpenAI 把科研模型向实验室开放
  Rosalind 走的是「科研专用前沿模型 + 学术配额」路线，和通用 API 是两条产品线；如果你们组要跑文献/实验规划类长任务，这是最便宜的入口。
  https://openai.com/index/introducing-the-rosalind-academic-plan
- 【⚙️工具】Vercel AI Gateway 日志新增 session affinity 可见性
  多副本推理下排查「同一会话落到不同后端导致缓存/上下文错乱」，终于不用自己打点了。小改动，但 agents 上线后第一个被问的就是它。
  https://vercel.com/changelog/ai-gateway-logs-now-show-session-affinity

🌟 GitHub Pick
- stablyai/orca ⭐96,625 / TypeScript
  用你自己的订阅去跑「一队」coding agent（Grok Bot / Claude Code），桌面端 + 移动端 + 远程 runtime，仓库 10/19 仍在活跃推送。
  https://github.com/stablyai/orca
- android/skills ⭐8,764 / Kotlin
  Google 官方（android org）的 agent skills 仓库，Kotlin 生态的 skill 组织方式可以直接抄结构。
  https://github.com/android/skills

💬 社区热议
- Simon Willison：web-edit 0.1a2（10/17）
  一个「让模型改网页」的编辑层工具连续迭代 a0→a2，争点是 agent 到底该操作 DOM 还是操作源码——对做 generative UI 的人有直接参考价值。
  https://simonwillison.net/2026/Oct/17/web-edit/
