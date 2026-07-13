# 🤖 AI 每日精选 | 2026-07-13

🔥 头条（1-2 条）
- geohot: I love LLMs, I hate hype 💬观点
  HN 289分/171评。George Hotz 长文：肯定 coding agent 进步（OpenCode+GLM-5.2 on Linux），痛批 FOMO 炒作和末日叙事，认为前沿实验室无法捕获 AI 创造的绝大部分价值
  https://geohot.github.io/blog/jekyll/update/2026/07/12/i-love-llms.html

⚡ 精选动态（3-5 条）
- 【🆕新发布】Anthropic 再次延长 Fable 可用期至 7月19日
  Claude 官方宣布 Fable 再延长一周。GPT-5.6 Sol 被归为 Fable/Mythos 级别后，Anthropic 持续调整 Fable 的 Max 计划可用性
  https://twitter.com/claudeai/status/2076351399999557669

- 【🔧工具】Claude Code vs OpenCode Token 开销实测：33k vs 7k 基线
  首次量化对比两大 coding agent harness 的 token 开销：Claude Code 基线 33k tokens，OpenCode 仅 7k；cache 效率差 54x
  https://systima.ai/blog/claude-code-vs-opencode-token-overhead

- 【📊趋势】Ploy 生产 Agent 迁移 GPT-5.6 Sol：快 2.2x、便宜 27%
  首个公开的生产级 Agent 迁移 GPT-5.6 实战报告。1/3 的 eval 失败源于 harness 对 incumbent 模型的隐性适配
  https://ploy.ai/blog/migrating-a-production-ai-agent-to-gpt-5-6

- 【🆕新发布】NVIDIA 发布 Open Data for Agents：合成数据驱动 Agent 训练
  NVIDIA 阐述为何 Agent 需要开放数据而非仅开放权重，Nemotron 系列合成数据集在 ICML 获 145 篇论文引用
  https://huggingface.co/blog/nvidia/open-data-for-agents

- 【🔧工具】sqlite-utils 4.1.1 发布
  Simon Willison 的 sqlite-utils 小版本更新：table.transform() 在外键约束下开启事务时现在会抛出 TransactionError，修复潜在数据损坏
  https://github.com/simonw/sqlite-utils

---

*归档于 Agent-Playbook · 2026-07-13*
