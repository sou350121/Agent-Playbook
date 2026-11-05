# 🤖 AI 每日精选 | 2026-11-05

🔥 头条

- OpenAI 将收购 Pierre Computer（Code Storage 团队，Trees/Diffs 库作者）
  Codex 正面冲进 GitHub 地盘；同周 OpenAI 公开自研 Git 后端 Pando，push 中位延迟降近 5x
  https://openai.com/index/openai-to-acquire-pierre

- OpenAI 自动化漏洞链路：2308 个内核候选 → 1724 个已复现 → 948 个本地提权 exploit
  五阶段管线，单轮约 121 万美元 API 成本换回 1890–6630 万美元漏洞价值
  https://openai.com/index/a-thousand-fewer-paths-to-root

⚡ 精选动态

- 【📊趋势】GitHub 周榜前三全是 Agent Skill，「去 AI 味」设计插件与安全审计 Skill 领跑
  11-02 周榜 16 个项目里 13 个是给 Claude Code / Codex / Cursor 装的 skill
  https://news.qiniu.com/archives/1793586030871

- 【🆕新发布】Weight-Space Programming：模型直接读写权重，Simon Willison 在笔记本上复现
  GPT-6 Astra 只改 0.016% 权重把 Qwen3.5-0.8B 的 MATH-500 从 7.9% 拉到 48.1%
  https://simonwillison.net/2026/Nov/3/qwen-can-interpret-model-weights/

- 【🔧工具】datasette-agent 0.5a0 + datasette-apps 0.3a0 + llm 0.37.1 同期发布
  「SQLite 查询 → agent 可调用 → 部署成 app」的最小栈，适合当工具调用层对照组
  https://simonwillison.net/2026/Nov/4/datasette-agent/

🌟 GitHub Pick

- cloudflare/security-audit-skill  +10,069 ⭐本周 / 56,442 ⭐总计  · Python
  Cloudflare 内部漏洞挖掘系统的起点，六阶段独立 agent 审计 + JSON Schema 校验
  https://github.com/cloudflare/security-audit-skill

- pbakaus/impeccable  +12,017 ⭐本周 / 99,417 ⭐总计  · JS
  62 条确定性规则做「AI 味」检测，不调模型、不需要 Key
  https://github.com/pbakaus/impeccable

💬 社区热议

- 28 种 Agent 组合横评，最高任务解决率仅 14%（Readhub 热榜）
  组合堆叠不等于能力叠加，多 agent 编排的收益被系统性高估
  https://readhub.cn/topic/8xmijSUyKMM
