# 🤖 AI 每日精选 | 2026-11-11

🔥 头条

- Gemini 4 Carbon 正式开放：前沿模型 + /swarm 群体 agent
  CursorBench 4.0 / Perplexity WANDR / Zapier AutomationBench 三项第一，每任务成本低于次优外部模型 2 倍以上；Google Antigravity 预览 /swarm，一句提示扩成可实时追踪的 agent 团队（更深推理模型做架构/协调/审计 + 轻模型并行做对抗验证）。
  https://blog.google/innovation-and-ai/models-and-research/gemini-models/gemini-4-carbon-now-available/

- Meta 发布 Muse Ember：agent 全天重复工作的专用小模型
  @ $0.10/$0.50 per M（≤200k prompt），专门面向 tool call、编码子任务、路由、抽取、长文档解析；Artificial Analysis 的 Intelligence vs Cost-per-Task 图上直接落在 Pareto 前沿——不比它贵就无法更强。
  https://research.meta.ai/blog/muse-ember

⚡ 精选动态

- 【🆕新发布】Claude Fable 5.2 同日发布，价格是 Ember 的 80 倍
  $8/$40 per M，定位长程重推理任务；同日三款模型同时卡在同一条价格-能力前沿，选型从「哪家最强」变成「哪一档够用」。
  https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5-2

- 【💬观点】Anthropic 文档：一句「这份代码是你的」能让模型主动重构
  Claude Fable 5.2 在小规模编码任务里，prompt 未声明代码归属时倾向照抄既有结构；加上「This codebase is yours…」后合并重复代码的成功率从不到 10% 升到约 50%——归属声明是一等 prompt 参数。
  https://simonwillison.net/2026/Nov/10/prompting-claude-fable-52/

- 【🔧工具】REMORY：1.9B 记忆模块补在 compaction 摘要后，冻结基模
  Qwen3.8-27B + REMORY-1.9B 在 ASI-Bench 拿 29.33，超过 Kimi-K2.7(27.34)/DeepSeek-V4-Pro(24.98) 的公开分数；记忆 checkpoint 走 SGLang/Transformers 部署，配套 /remory train 可在 r-codex 里在线训练。
  https://github.com/fudan-generative-vision/Remory

- 【🆕新发布】OpenAI 上线 Businesses in ChatGPT
  ChatGPT 里可直接管理企业信息、查看企业展示数据并把兴趣转成动作——商业入口开放给 agent 生态，商家侧数据将成为工具调用新原子。
  https://openai.com/index/introducing-businesses-chatgpt

- 【📊趋势】OpenAI Q3 营收跳到 100 亿美元
  单季营收规模已接近全年 IPO 叙事所需水位；同期 Anthropic 早期支持者正以 3%-5% 费用转售 IPO 提前配额——两家都在为公开市场做最后铺垫。
  https://readhub.cn/topic/8xxIMLaSLyw

- 【🔧工具】AWS：用 LangGraph + Bedrock AgentCore Web Search 做依赖巡检 agent
  AgentCore 的新 Web Search API 直接用 AWS 凭证签名返回带引用的实时结果，官方给出「每日依赖 watcher」完整参考图——不需要自己接搜索 provider 就能拿到可审计引用。
  https://aws.amazon.com/blogs/machine-learning/build-a-daily-dependency-watcher-with-langgraph-and-amazon-bedrock-agentcore-web-search/

🌟 GitHub Pick

- meta/astryx  ⭐3,108 today / 22,777 total · TypeScript
  开源设计系统，完全可定制且「agent ready」——Vercel 设计团队（vjeux）参与，单日 3k star 冲榜。
  https://github.com/meta/astryx

- homeassistant-ai/ha-mcp  ⭐ trending / 6,645 total · Python
  用 Claude / ChatGPT 等助手配置并自动化 Home Assistant 的 MCP server——MCP 落地到家用 IoT 控制面的典型样本。
  https://github.com/homeassistant-ai/ha-mcp

💬 社区热议

- 同日三款小模型撞价（Ember / GPT-6 Luna / Haiku 5.5 全部 $0.10 输入）
  争论点：per-token 定价已经失真，该看 per-task cost 还是 Intelligence Index？长 prompt 阈值（200k/272k/100k）才是真实成本分水岭。
  https://simonwillison.net/2026/Nov/10/muse-ember/
