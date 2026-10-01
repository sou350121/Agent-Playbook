# 🤖 AI 每日精选 | 2026-10-01

🔥 头条
- 【🆕新发布】OpenAI 发布 dots：24/7 常驻的 always-on agent
  基于 GPT-6 Astra，自带云端电脑、可连接 4000+ 应用插件，常驻 ChatGPT/Slack/Teams 并随时间学习你的偏好；面向 Pro/Business Premium/Enterprise 分批开放。
  https://openai.com/index/introducing-dots

- 【🆕新发布】OpenAI GPT-6.1 Sol 上线：接近 Astra 的智能，价格 1/5
  官方称在 agentic coding / computer use / 专业文档上逼近 GPT-6 Astra，标准输入输出价仅 1/5；缓存输入 $0.10/M（比标准价低 95%），明显利好长上下文复用型 agent。
  https://openai.com/index/introducing-gpt-6-1-sol

⚡ 精选动态
- 【🆕新发布】DeepSeek 开源昇腾版基础设施组件，与 NVIDIA 侧一一对应
  开源 TileLang 昇腾版及 DeepGEMM-Ascend / DeepEP-Ascend / FlashMLA / DeepSelect 等，训练算子已可在昇腾 950 128 卡超节点上接近硬件上限。
  https://github.com/deepseek-ai/DeepGEMM-Ascend

- 【💬观点】HF 博客：MCP Agent 的「来源感知」验证
  主张 agent 不只校验事实对不对，还要校验事实「从哪来」——为 MCP 工具调用设计可溯源证据链，降低工具被投毒/误引风险。
  https://huggingface.co/blog/MultiverseComputingCAI/getting-the-source-right-not-just-the-fact-source

- 【🔧工具】Vercel Sandbox 支持 Secure Compute
  Sandbox 现可在私有网络内跑代码执行，agent 产出的不可信代码不必再直接暴露到公网环境。
  https://vercel.com/changelog/vercel-sandbox-now-supports-secure-compute

- 【🏢行业】OpenAI 重启 $200 Pro 套餐、额度减半引开发者不满
  官方以「未来 API 降价/能效提升」解释当下额度缩水，开发者逐条反驳并要求对标 Claude Opus 5.5 的每美元价值。
  https://readhub.cn/topic/8wqERkdxaWY

🌟 GitHub Pick
- NVIDIA/OpenShell  ⭐12,648 · Rust
  面向自主 AI agent 的安全、私有运行时（沙箱 + 权限边界），适合给 agent 执行层加护栏。
  https://github.com/NVIDIA/OpenShell

- mksglu/context-mode  ⭐24,486 · TypeScript
  Coding agent 的上下文窗口优化：沙箱化工具输出（宣称减少 98%）、持久 session 记忆，并通过 MCP + hooks 路由 17 个平台。
  https://github.com/mksglu/context-mode
