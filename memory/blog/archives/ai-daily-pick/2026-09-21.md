# 🤖 AI 每日精选 | 2026-09-21

🔥 头条
- AX：Google 工程师开源的声明式 agentic 编排器（HN 热榜）
  把 agent 任务的 sandbox、workspace、网络围栏声明成 K8s 风格 task.yaml，一条 ax apply 批量运行；背靠 Agent Substrate 做到亚秒级挂起/恢复与密集多路复用
  https://agentexecutor.io

⚡ 精选动态
- 【🔧工具】llm-keys-ui 0.1：手机远程管理 coding agent 密钥
  Simon Willison 新发布的小工具，从手机端配置/轮换 agent 的 API key，把密钥从本地明文配置里剥离
  https://simonwillison.net/2026/Sep/20/llm-keys-ui/

- 【🏢行业】Amazon SageMaker HyperPod Inference Gateway 上线
  AWS 官方：GPU 感知路由，首 token 延迟最高降 82%，面向多模型 agent 的低延迟推理
  https://aws.amazon.com/blogs/machine-learning/introducing-amazon-sagemaker-hyperpod-inference-gateway/

- 【💬观点】voxium：大公司里「万物皆由 Claude Code 生成」的一线现场
  一线工程师吐槽：specs/code/PRD/报告全由 Claude Code 产出，L1 到 L7 只负责按 enter、无人 review
  https://simonwillison.net/2026/Sep/20/voxium/

🌟 GitHub Pick
- affaan-m/ECC  ⭐263,723 / Trending · JavaScript
  Agent harness 性能优化层：skills/instincts/memory/security/research-first，覆盖 Claude Code、Codex、Cursor
  https://github.com/affaan-m/ECC

- vercel-labs/json-render  ⭐17,296 / Trending · TypeScript
  Vercel 的生成式 UI 框架（JSON → UI），直接对应 Agent UI 方向
  https://github.com/vercel-labs/json-render
