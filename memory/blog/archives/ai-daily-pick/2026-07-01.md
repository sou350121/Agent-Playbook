# 🤖 AI 每日精选 | 2026-07-01

🔥 头条（1-2 条）
- Claude Sonnet 5 发布：性能接近 Opus 4.8，新 tokenizer 有效涨价 30%
  Anthropic 新一代 Sonnet，1M context / 128K output；temperature/top_p/top_k 采样参数已移除；新 tokenizer 使英文 token 数增加 42%（中文仅 1%），实际是变相涨价
  https://www.anthropic.com/news/claude-sonnet-5

⚡ 精选动态（3-5 条）
- 【🆕新发布】Google 发布 Gemini 3.1 Flash Lite Image（Nano Banana 2 Lite）——最快最便宜的 Gemini 图像模型
  Google 推出定位「速度和规模」的轻量级图像生成模型，AI Studio 和 API 均可用；拼写精度仍有瑕疵
  https://deepmind.google/models/gemini-image/flash-lite/

- 【🔧工具】Google TabFM：零样本表格数据基础模型，sklearn 兼容
  将 TimesFM 零样本思路扩展到表格数据——无需训练/调参/特征工程，直接把训练数据当 context 喂入即可做分类回归；PyTorch/JAX 双后端
  https://github.com/google-research/tabfm

- 【🔧工具】AWS 推出 AG-UI 协议支持：Agent 生成式 UI 的开放标准
  AG-UI 是 Agent↔User 交互的开放协议，与 MCP 和 A2A 并列三大 agentic 协议；支持 LangGraph/CrewAI/Strands 后端 + React/Vue/Angular 前端解耦
  https://docs.ag-ui.com/introduction

- 【🔧工具】Vercel Agent 扩展至 Public Beta：支持生产问题调查 + 审批式操作
  从 PR 代码审查扩展到完整平台 Agent：Dashboard 聊天、生产故障调查、审批式 remediation（开 PR/回滚/改配置），默认只读 + sandbox 验证
  https://vercel.com/changelog/an-expanded-vercel-agent-chat-investigations-and-approved-actions-now-in-public-beta

- 【💬观点】OpenAI 核心转储流行病学：用大规模 core dump 分析修复 18 年老 bug
  OpenAI 工程师用大规模 core dump 分析定位罕见基础设施崩溃，发现硬件故障 + 18 年软件 bug——展示 LLM 公司底层工程的硬核一面
  https://openai.com/index/core-dump-epidemiology-data-infrastructure-bug

🌟 GitHub Pick（1-2 个）
- google-research/tabfm ⭐ 新兴项目 · Python/JAX
  零样本表格数据基础模型——无需训练调参，直接把数据当 context 喂入即可做分类回归
  https://github.com/google-research/tabfm

💬 社区热议（0-2 条）
- Claude Sonnet 5 登上 Hacker News 热榜
  核心争论点：新 tokenizer 有效涨价 30% 是否值得——性能提升能否抵消成本增加
  https://news.ycombinator.com/item?id=48736605
