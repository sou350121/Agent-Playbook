# 🤖 AI 每日精选 | 2026-08-20

🔥 头条

- Claude 自主设计蛋白质：15 靶标命中 14 个，成功率超人类专家 2-3 倍
  Anthropic 官方公布 Claude (Mythos Preview + Opus 4.8) 湿实验结果：22-35% 设计成功率 vs 行业 10-15%，部分设计结合力超越已发表最优
  https://www.anthropic.com/research/Claude-accelerates-protein-design

- Replit 上线 Free Mode：GPT-5.6 Luna 驱动，30 倍产出
  日常任务不再消耗 credits，Core 用户月费 $20 可创建 30 倍内容，全新 UI 整合聊天/构建/发布
  https://replit.com/blog/replit-introduces-free-mode

⚡ 精选动态

- 【💬观点】Jeremy Morrell：LLM 时代的可扩展软件（Extensible Software）
  LLM 大幅降低扩展编写成本 + 沙箱原语降低部署成本 → Web 软件应走向「用户用 LLM 自己扩展」模式
  https://jeremymorrell.dev/blog/extensible-software-in-the-age-of-llms/

- 【🔧工具】AWS Bedrock AgentCore 异步调用模式：解决 Agent 等待的算力浪费
  三种 serverless 异步模式（task-token callback / direct service integration / durable function），释放等待期间的 compute 成本
  https://aws.amazon.com/blogs/machine-learning/asynchronous-patterns-for-calling-amazon-bedrock-agentcore-agents-in-serverless-pipelines/

- 【🏢行业】Fanatics 用多 Agent 系统重构体育赛事客服
  应对州级法规差异、实时负责任游戏检测、超级碗流量峰值，从决策树 chatbot 升级到 Agent 架构
  https://aws.amazon.com/blogs/machine-learning/how-fanatics-betting-and-gaming-built-a-multi-agent-customer-support-system/

🌟 GitHub Pick

- volcengine/OpenViking ⭐Trending · Go
  面向 AI Agent 的自进化上下文数据库，统一 Memory/RAG/Skills 为 viking:// 虚拟文件系统，三级分层加载减少 token 消耗
  https://github.com/volcengine/OpenViking

- chaitanyagiri/munder-difflin ⭐Trending · TypeScript/Electron
  本地多 Agent 编排 harness，将 Claude Code/Codex/Grok 等 CLI 包装为本地克隆 Agent，BYOK + 可视化协作
  https://github.com/chaitanyagiri/munder-difflin
