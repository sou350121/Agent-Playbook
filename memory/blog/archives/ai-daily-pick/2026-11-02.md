🤖 AI 每日精选 | 2026-11-02

🔥 头条

- OpenAI／Google／Microsoft／Anthropic 集体采纳统一的"AI 训练退出"信令
  一个 policy-token 写进 robots.txt 就对四家同时生效，抓取/训练边界从逐家声明变成一门公共协议——RAG 语料合规要跟着改。
  https://www.theverge.com/tech/1023763/openai-google-microsoft-ai-scraping-standard-opt-out

- MiniMax Code 团队开源自己每天在用的 16 个 Agent Skills（mcode-stack）
  不是提示词合集，是判断"该不该派子 agent、长命令等多久、长会话怎么不失焦"的真在跑的 SKILL.md，可一条命令装进 Claude Code / Codex / MiniMax Code。
  https://github.com/MiniMax-AI/mcode-stack

⚡ 精选动态

- 【🔧工具】morluto/rea 冲上 GitHub 单日榜首量级（⭐418k 总量，今日仍在更新）
  基于 MCP 把 Ghidra / Hopper 桥接给 agent，让模型自己驱动反编译做二进制、Electron、.NET 分析，agent 的"手"伸进了逆向工程。
  https://github.com/morluto/rea

- 【📊趋势】Agent harness 一周 star 榜：DeepSeek Harness +6.9k、claude-mem +5.9k、Orkas +230%
  memory / state 层成了新战场，Orkas 这类多 agent 编排仓库一周从 2.2k 涨到 7.2k，说明大家在补的是"编排+记忆"而不是"再做一个 chat 框"。
  https://github.com/RyanAlberts/best-of-Agent-Harnesses/releases/tag/digest-2026-11-01

- 【🔧工具】pbakaus/impeccable：给 coding agent 的设计语言 + 62 条确定性规则
  24 个命令（critique/audit/polish）不靠 LLM 打分，规则化检查 AI 界面通病，前端 agent 的验收环节第一次有了可重复闸门。
  https://github.com/pbakaus/impeccable

- 【💬观点】Simon Willison 转述 Kyle Kingsbury 对 agent 责任边界的看法
  讨论聚焦在"agent 替你做决定时，日志与回滚到底归谁"，这是今年 agent 落地最容易被跳过、出事最贵的一环。
  https://simonwillison.net/2026/Nov/1/quoting-kyle-kingsbury/

- 【🏢行业】DeepSeek 完成超千亿元 A+ 轮融资（媒体周报口径，尚未见官方公告）
  国产开源权重阵营拿到手机厂/存储厂/代工龙头同一份股东名单，模型选型与推理硬件路线可能随之重排；本条仅有二手来源，建议自行核验。
  https://www.36kr.com/p/4050669181342601

🌟 GitHub Pick

- MiniMax-AI/mcode-stack  · ⭐493 / Trending  · Markdown
  MiniMax Code 团队自用的 SKILL.md 栈，含 ronny/jiachen 两套可安装 plugin。
  https://github.com/MiniMax-AI/mcode-stack
- pingdotgg/t3code  · 今日 +1,148 / ⭐35.6k / Trending  · TypeScript
  手机+Web+桌面统一控制本机 Codex/Claude/OpenCode 会话；作者自述 very early，慎上生产。
  https://github.com/pingdotgg/t3code

💬 社区热议

- 统一 AI 抓取退出标准（The Verge / IETF 草案讨论）
  支持者说终于一门协议，反对者担心 robots.txt 仍靠公司自觉、没有执行力的"退出"只是礼貌。
  https://datatracker.ietf.org/doc/draft-kelley-aipref-training-preference-signal/
