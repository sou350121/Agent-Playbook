# 🤖 AI 每日精选 | 2026-11-23

🔥 头条（1 条）
- Anthropic 上市后急跌：2 万亿 → 1.28 万亿，首日溢价一周蒸发
  发行价 83 美元、首日冲上 97 美元，随后 AI 交易回撤，市场重新给「前沿模型公司」定价
  https://www.36kr.com/p/4079379879252868

⚡ 精选动态（4 条）
- 【🆕新发布】OpenAI Agents SDK 发布 v1.0.0-alpha.1：Codex 成为可插拔 model provider
  通过 PyO3 内嵌未改动的 Codex Core rust-v0.166.0，Runner 里按 run 切换 provider，不用再起 codex app-server / JSON-RPC
  https://github.com/openai/openai-agents-python/releases/tag/v1.0.0-alpha.1
- 【🔧工具】OpenAI 公开 Codex 沙箱内部设计：agent 有独立文件系统与网络边界
  官方首篇讲清 sandbox 的进程/网络/挂载边界，是自建 coding agent 沙箱最直接的参照
  https://openai.com/index/inside-the-codex-sandbox
- 【💬观点】OpenAI：对抗性蒸馏是新的防御战场
  官方承认境外团队靠大规模蒸馏复制前沿能力，正在上多层行为与水印检测——自建微调管线的人需要重新评估数据来源
  https://openai.com/index/combatting-adversarial-distillation
- 【🔧工具】Vercel AI Gateway：Parallel Web Search 免费到 1 月 31 日
  gateway 内置 web search 直接进 agent 工具链，检索层可以彻底不自己接
  https://vercel.com/changelog/parallel-web-search-is-free-on-ai-gateway-and-eve-through-january-31

🌟 GitHub Pick（2 个）
- vercel/eve  ⭐6.0k · TypeScript · 开源 agent 框架
  eve@1.3.0（11-20）后两天连推补丁，invocation 语义收敛；agent 框架里更新最勤的一个
  https://github.com/vercel/eve
- openai/openai-agents-python  ⭐30.8k · Python · 官方 agent SDK
  v1.0.0 alpha 与 mcp 2.x、sandbox provider 同期推进，是 2026 年最值得跟的 agent 运行时
  https://github.com/openai/openai-agents-python

---
（今日稳定源中可过「48 小时 + 一手来源」双校验的条目偏少，其余候选或超期、或仅二手转述，未凑数收录。）