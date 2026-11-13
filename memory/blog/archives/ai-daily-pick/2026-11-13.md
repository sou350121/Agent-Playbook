# 🤖 AI 每日精选 | 2026-11-13

🔥 头条（2 条）

- Gemini 4 Hydrogen 上线，Antigravity 同步推出 Orchestrator 动态双模型编排
  Google 同日发布低成本 Hydrogen 并在 Antigravity 加 Orchestrator：Carbon 规划/排障、Hydrogen 改代码跑测试，卡住自动交回 Carbon 修计划；Terminal-Bench 4.1 上近 Carbon 成功率、省 24% 配额、快 19%
  https://antigravity.google/blog/gemini-4-hydrogen-in-google-antigravity/

- Google 发布 Gemini Decision 1 + Decisions API：不生成 token，一次前向给候选打分
  专做封闭选项决策（是/否、2-255 多选、有序 rubric 打分），单请求最多 1000 问、150-250ms 端到端、$0.10/M 输入且输出免费；Google 内部已用于 agent 路由与工具选择
  https://blog.google/technology/ai/gemini-decision-1/

⚡ 精选动态（4 条）

- 【📊趋势】Antigravity 静态 model router 的两个失效点被官方点明
  Google 直接批评"按首个 prompt 猜难度、整条任务路由到最便宜模型"的做法：长任务不同阶段需要的复杂度不同，且是任务演进中才暴露的——动态双向切换才是解法
  https://antigravity.google/blog/gemini-4-hydrogen-in-google-antigravity/

- 【🆕新发布】Anthropic 将 Opus 5.5 设为 Pro / Max / Ultra / Team 默认模型
  Claude 侧默认档位整体上移，Claude Code 在 $20 Pro 与 Team Standard 上默认从 Sonnet 变 Opus；做成本模型时旧 Sonnet 单价假设需要重算
  https://www.cls.cn/detail/2533262

- 【🔧工具】AWS 给出 "cost per task" 方法论：Bedrock agent ROI 不看 token 单价
  拆四个隐性成本项（缓存、路由、输出压缩等），主张按任务计价核算——per-token 比价会系统性高估便宜模型的实际成本
  https://aws.amazon.com/blogs/machine-learning/optimizing-cost-per-task-and-proving-agent-roi-on-amazon-bedrock/

- 【🏢行业】Anthropic IPO 获数倍超额认购；黄仁勋回英伟达就近期风波向员工致歉
  一边是 Anthropic 上市认购火爆（叠加 Opus 5.5 上默认、Claude 攻势），一边是英伟达高层风波，供给侧叙事正在重排
  https://www.36kr.com/p/4066019497464960

🌟 GitHub Pick（2 个）

- vercel-labs/ui  ⭐1,423 / Trending · TypeScript
  Vercel 官方实验仓：给 agent 用的 UI 行为库（不是组件库），面向"agent 主导生成界面"这一类
  https://github.com/vercel-labs/ui

- agentes-chat/agentes-chat  ⭐1,164 · TypeScript
  自托管 Slack 替代品，人与 AI agent 在频道里平等协作；上线 4 天冲上千星
  https://github.com/agentes-chat/agentes-chat

💬 社区热议（1 条）

- Claude 攻势太猛，OpenAI "有点怂了"（虎嗅）
  当 Claude 在 Coding / Agent 侧默认档位全面上移，OpenAI 的企业叙事被迫转向客户案例而非能力对比
  https://www.huxiu.com/article/4904580.html
