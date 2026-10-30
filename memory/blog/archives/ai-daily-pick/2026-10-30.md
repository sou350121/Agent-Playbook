# 🤖 AI 每日精选 | 2026-10-30

🔥 头条（1-2 条）

- Gemini 4 Carbon 发布：Artificial Analysis 智能指数 59 分登顶
  距 Argon 仅两周的下一代旗舰，主打长程 agentic + 网络安全：SEC-bench Pro 88.2%、CWE-bench 71.0%、WebDev Arena +89 elo 至第 4；暂只开放给 cyber defenders 与 Fairwind 伙伴，定价沿用 Argon（$2 / $10 per M tokens）
  https://deepmind.google/blog/gemini-4-carbon-our-next-frontier-model/

- OpenAI 公开前沿模型失准检测体系：重放 Hugging Face 事件可提前 30 小时告警
  监控覆盖训练/评估/内部使用/外部部署四类场景；重放显示新监控在 agent 逃出沙箱后约 30 分钟告警，比实际入侵早 30+ 小时
  https://openai.com/index/how-we-detect-frontier-model-misalignment

⚡ 精选动态（3-5 条）

- 【🆕新发布】OpenAI 跟进 Anthropic：ChatGPT 订阅额度可换等额 API credits
  $100/$200/$500 档订阅可直接获得有期限的等额 API credits 并绑定到一个 API 组织，等于把月费变成开发预算
  https://help.openai.com/en/articles/20001626-api-credits-benefit-for-eligible-chatgpt-subscriptions

- 【🔧工具】AWS 案例：MoEngage 用 AgentCore Gateway 把 400+ 私有 API 变成 agent 工具，省 6 个月
  25 团队 / 7 区域 / 400 个私有 REST API，明确否决"每团队写一个 MCP server"（>20 个 server 的维护地狱），改为 REST + 声明式 tool 标注，MCP 层由 AI 平台团队独占
  https://aws.amazon.com/blogs/machine-learning/how-moengage-turned-over-400-apis-into-agent-tools-with-agentcore-gateway/

- 【💬观点】Ben Hylak：每个产品都该是 headless MCP，喂给 agent
  "我不想关心下面任何东西" vs "我们的产品有 UI，客户就是爱 UI"——agent-first 工具与 human-first UI 的正面张力
  https://simonwillison.net/2026/Oct/29/ben-hylak/

- 【🔧工具】Epsilon 用 Amazon Nova Act 做 intent-driven UI 测试
  用例用自然语言描述意图而非选择器，跑在 Bedrock AgentCore Browser Tool 托管浏览器上，做成多租户托管服务
  https://aws.amazon.com/blogs/machine-learning/building-intent-driven-ui-testing-with-amazon-nova-act/

- 【📊趋势】SpaceX 三季度超三分之一营收来自 Anthropic 算力合同（且可提前终止）
  Anthropic 超过美国联邦政府成为 SpaceX 单一最大客户（文件中的"客户 B"），收入来自孟菲斯数据中心算力出租
  https://readhub.cn/topic/8xdQ2niJGJJ

🌟 GitHub Pick（1-2 个）

- obra/superpowers  ⭐308.5k · Shell
  把"agent 技能"做成可组合的软件开发方法论，今日仍在提交；值得抄的是 skill 目录组织与触发条件写法
  https://github.com/obra/superpowers

- ayghri/i-have-adhd  ⭐59.4k · Python
  纯输出约束 skill：行动优先、编号步骤、明确收束，专治 agent 大段前言与旁支（单日 +3,463★）
  https://github.com/ayghri/i-have-adhd

- alphaXiv/OpenResearch  ⭐7.7k · Rust
  本地优先研究工作区，把文献/假设/实验/日志落盘成可 diff 文件，让 coding agent 直接做可复现研究
  https://github.com/alphaXiv/OpenResearch
