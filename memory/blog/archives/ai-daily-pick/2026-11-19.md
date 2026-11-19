# 🤖 AI 每日精选 | 2026-11-19

🔥 头条
- Google 发布 Gemini 4 Neon：前沿档中间层，$3/$15 + 100 万上下文
  AA 智能指数 61 分排第 3，新 Agent Arena 上「可操控性」第 2——为长跑 agent / orchestrator 定位，支持任务中途纠偏
  https://blog.google/innovation-and-ai/models-and-research/gemini-models/introducing-gemini-4-neon/

- Google Labs 推出 Stitch Loop：常驻产品 agent，改完自动开 PR
  接 GitHub + 线上指标（180+ 集成 / 自定义 MCP），内置安全、延迟、无障碍三类常驻 loop，永远人工 review 才 merge
  https://blog.google/innovation-and-ai/models-and-research/google-labs/stitch-loop/

⚡ 精选动态
- 【🔧工具】Prime Radiant 开源三种「外部沙箱」：agent 在 Mac 上，代码在 v86/WASM、Apple Containers、Quicksand 里跑
  npx 两条命令即可让 Claude Code / Codex / Pi 在 Alpine 里执行命令；默认禁网，代理做凭据替换——密钥不进沙箱
  https://blog.primeradiant.com/external-sandboxes-for-coding-agents/

- 【💬观点】Daniel Stenberg：Rust 重写 agent 刷了 18.5 万行 C→34 万行 Rust，curl 同期合了 300+ commit、200 个 bugfix
  同一时间窗口里，人写的修复比 agent 克隆更快；"这些克隆追得上吗"——对「全自动重写」叙事的直接反证
  https://simonwillison.net/2026/Nov/18/daniel-stenberg/

- 【📊趋势】OpenAI：coding agent 加速科研是「锯齿前沿」，表现极不均匀
  官方度量 agent 对 AI 研究的提速与盲区，直接关联「递归自我改进」讨论——做科研 agent 的必读标尺
  https://openai.com/index/research-acceleration-jagged-frontier/

- 【🏢行业】Anthropic 即将敲钟：5300 人、人均约 3 亿，IPO 后亚马逊+谷歌合计持股约 28%
  同日 OpenAI 抢发 GPT-6.2 狙击，前沿实验室竞争从模型榜转向资本市场叙事
  https://www.36kr.com/p/4074882886751112

- 【🆕新发布】Gemini 4 Neon 同步进 Antigravity / Gemini app / 企业版
  cached input 打 95%（$0.15/M），长上下文 agent 重放成本显著下降，适合多轮 tool-call 场景
  https://deepmind.google/blog/introducing-gemini-4-neon/

🌟 GitHub Pick
- prime-radiant-inc/external-sandbox-pi  · 新开源 · TypeScript
  把 Pi coding agent 的执行动作转发到外部沙箱的扩展，协议可复用给 Claude Code / Codex
  https://github.com/prime-radiant-inc/external-sandbox-pi

💬 社区热议
- Agent 重写 curl（HN / 博客圈）
  18.5 万行 C 生成的 Rust 克隆 vs 同期 200 个人类 bugfix：代码量不等于工程质量
  https://daniel.haxx.se/blog/2026/11/17/actual-curl-rewrites-in-rust/
