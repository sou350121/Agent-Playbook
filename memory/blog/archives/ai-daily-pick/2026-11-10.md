# 🤖 AI 每日精选 | 2026-11-10

🔥 头条

- Anthropic 发布 Fable 5.2 / Mythos 5.2：速度提升、Fable 全线降价 20%
  Fable 5.2 主攻长周期软件工程与硬件/机器人任务，官方称可协调 1000+ 并发 agent，输入 $8 / 输出 $40 每百万 token；Mythos 5.2 走验证计划定向开放。
  https://platform.claude.com/docs/zh-CN/release-notes/overview

- Pathways 在 Google Cloud 正式 GA：单控制器训练从「谷歌自用」变成「客户可用」
  Gemini 训练用的分布式运行时开放给云客户，SPMD 之外的单控制器图执行 + 容错恢复可直接用于 RL 循环（sampler/reward/trainer 异构程序重叠）。
  https://developers.googleblog.com/en/what-is-pathways-single-controller-training-for-large-models/

⚡ 精选动态

- 【🆕新发布】NVIDIA Nemotron 3.5 Super VL（120B）上架 SageMaker JumpStart
  文本/图像/视频统一推理，NVFP4 量化可直接部署，常驻 agent 的视觉底座多了一个非 API 方案。
  https://aws.amazon.com/blogs/machine-learning/nvidia-nemotron-3-5-super-vl-is-now-available-in-amazon-sagemaker-jumpstart/

- 【💬观点】OpenAI Control Room：跨研究基础设施追踪并「一键熔断」模型负载
  把运行时安全从 prompt 层上移到基础设施层——停的是 workload 而不是某次调用，给 agent 编排的平台侧熔断提供了参考架构。
  https://openai.com/index/control-room/

- 【📊趋势】CodeRabbit 用 Codex 把交付量拉 20 倍，同一支工程团队
  agentic 评审 + 生成进入生产流水线后的真实倍数数据，比 benchmark 更能说明 coding agent 的收益边界。
  https://openai.com/index/coderabbit-codex-daybreak/

- 【🔧工具】anthropics/skills 的 Office 系列 skill 改为 Apache-2.0
  Word/Excel/PPT 处理 skill 可被第三方产品直接复用改造，文件处理类 agent 不必从零写。
  https://github.com/anthropics/skills

- 【🏢行业】OpenAI 无预警大范围封号，DeepSeek Search/Fetch 转收费后成本结构继续变化
  账号风控与第三方 API 收紧同步发生，依赖单一 provider 的 agent 产品需要预案。
  https://www.36kr.com/p/4059618356089985

🌟 GitHub Pick

- max-sixty/worktrunk  ⭐12,273 / 本周 +2,313 · Rust
  基于 Git worktree 给每个 agent 一份独立工作目录，专治多 agent 改同一份文件；README 首句就写「为并行 AI agent 工作流设计」。
  https://github.com/max-sixty/worktrunk

- vercel-labs/agent-browser  ⭐48,453 · Rust · Apache-2.0
  给 agent 用的浏览器自动化 CLI（含 MCP server 与 Vercel Sandbox 集成），v0.41 起工具名统一到 MCP catalog。
  https://github.com/vercel-labs/agent-browser

---
规则：今天的大事集中在「模型发布 + 训练基础设施开放」，工具侧最热的是多 agent 的调度与隔离层。
