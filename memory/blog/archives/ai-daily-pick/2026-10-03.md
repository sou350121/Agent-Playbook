# 🤖 AI 每日精选 | 2026-10-03

🔥 头条
- OpenAI《用 GPT-6 构建应用实践指南》 🆕
  官方首次系统给出 GPT-6 家族（Astra / Sol / Luna / 6.1 Sol）的能力与定价定位，是给开发者的选型与成本基线。
  https://openai.com/index/practical-guide-building-gpt-6

- Vercel AI Gateway 上架 Laya「决策模型」（System One） 🆕
  Jev 的 decision model 可经 Vercel 单 key 调用，10/31 前免费，主打「直接产出可执行决策」的异构形态。
  https://vercel.com/changelog/laya-decision-model-now-available-on-ai-gateway-free-through-october-31

⚡ 精选动态
- 【🔧工具】AWS：用 Bedrock AgentCore Gateway 给 Claude Desktop 加安全 Web Search
  给桌面 Agent 接联网的完整链路，重点是用 JWT 作用域把搜索工具鉴权收口。
  https://aws.amazon.com/blogs/machine-learning/add-secure-web-search-to-claude-desktop-with-amazon-bedrock-agentcore/

- 【🔧工具】AWS：在 SageMaker AI 用多轮 RL 微调搜索 Agent
  用回合级奖励（答案正确 + 命中引文）替代纯 SFT，改善多跳检索 Agent。
  https://aws.amazon.com/blogs/machine-learning/fine-tune-a-search-agent-with-multi-turn-rl-on-amazon-sagemaker-ai/

- 【🔧工具】HF/ServiceNow：AutoSynthData — 为企业 Agent 合成训练数据
  用真实企业流程自动生成 tool-calling / instruction 样本，解决垂直 Agent 冷启动无标注。
  https://huggingface.co/blog/ServiceNow-AI/autosynthdata

- 【🔧工具】Weaviate 发布高危安全补丁（Google 模块凭据泄露）
  生产若用 Weaviate 的 Google 模块需立即升级并轮换凭据。
  https://weaviate.io/blog/weaviate-security-release-googlemodules-2026

🌟 GitHub Pick
- pbakaus/impeccable  ⭐722 today · JavaScript
  把设计规范变成 agent 可读的「设计语言」，让 AI harness 产出的 UI 不再土味。
  https://github.com/pbakaus/impeccable

- Panniantong/Agent-Reach  ⭐696 today · Python
  一个 CLI 让 Agent 读取/搜索 Twitter、Reddit、YouTube、GitHub、B站、小红书，零 API 费。
  https://github.com/Panniantong/Agent-Reach

💬 社区热议
- HN：AI 首次在隐藏信息博弈 Stratego 击败史上最强人类玩家（163↑）
  争论点：低成本 + 不完全信息推理能否泛化到真实世界的对抗决策。
  https://arstechnica.com/science/2026/10/ai-finally-beat-the-best-stratego-player-in-history-and-did-it-on-a-budget/

- HN：Redis 作者 antirez 发布本地 LLM 运行器 ds4（129↑）
  争论点：一行命令跑本地模型，是否足以替代 llama.cpp 做私有 RAG。
  https://dwarfstar.sh/
