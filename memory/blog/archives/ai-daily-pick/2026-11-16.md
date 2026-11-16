# 🤖 AI 每日精选 | 2026-11-16

🔥 头条（2 条）
- 李沐出任硅谷 Aimotion 联合创始人兼 CTO：世界模型搬进商业博弈空间
  与 Boson AI 交叉任职，把世界模型从「物理空间」迁到汽车等长决策周期销售漏斗；明确指向可自主执行销售流程的商业 Agent，而非问答插件。Aimotion 已完成 BAI Capital 领投数千万美元 A 轮。
  https://www.pingwest.com/a/319556

- llama.cpp v1.0.0（ggml v1.0.0 同日）：本地推理第一次有了 semver 契约
  3.5 年后正式发 1.0，公开 C API 位于 include/，重大版本号 = 破坏性变更；下游从此能按 MAJOR/MINOR/PATCH 判断何时会炸。
  https://huggingface.co/blog/ggml-org/llama-cpp-v1

⚡ 精选动态（5 条）
- 【🆕新发布】Vercel Workflow SDK 5：agent 事件日志端到端加密
  event log 里的 step 参数、hook payload、stream 数据全用 AES-256-GCM 加密，每次 run 一把独立密钥，托管后端只见到密文；已在 40 亿 step / 7 亿 run 后定型。
  https://vercel.com/blog/workflow-sdk-5

- 【🔧工具】Vercel AI Gateway 免费开放 Parallel Decisions
  Gemini 侧边加了个 Decisions API（一次前向给候选打分，不生成 token），Vercel 把它做到网关层：路由、护栏、候选排序不用再烧一轮生成。
  https://vercel.com/changelog/parallel-decisions-now-available-on-ai-gateway-for-free

- 【🔧工具】Vercel Sandbox 首尔区域启动 3.5s → 1.05s
  agent 工具调用的冷启动才是真实延迟瓶颈，4x 提速直接改写「每步一个沙箱」的可行性门槛。
  https://vercel.com/changelog/vercel-sandbox-starts-up-to-four-times-faster

- 【💬观点】Your Agent Will Pick the Hackable One：可替换固件成为购买判据
  M-VAVE FM-1 合成器用户用 AI 工具几周写出数十版自研固件，厂商干脆 GPLv3 开源官方固件 + 开发套件；推论：未来设备由 agent 比价采购，开放固件会自动胜出。
  https://geoffstearns.com/blog/your-agent-will-pick-the-hackable-one/

- 【🏢行业】OpenAI 开出「科学博客」：Navier–Stokes 证明、拟黎曼假设之后
  官方把 AI 辅助科研的方法与翻车点公开成文，配套已有 Navier–Stokes、拟黎曼假设等结果；等于给 agent 做科研打了个「可复核」的样板间。
  https://openai.com/index/our-new-blog-for-science

🌟 GitHub Pick（2 个）
- anthropics/skills  ⭐ +5,860（近 7 天）/ 195k total · Markdown/TS
  Agent Skills 生态仍是本周最大涨幅；skills 已捐给 Linux Foundation 的 AAIF，装之前建议先用 NVIDIA/SkillSpector 扫一遍。
  https://github.com/anthropics/skills

- OpenJarvis  ⭐ +12.4%（13.9k → 15.6k）· 个人 agent runtime
  本周增速冠军，定位是可自托管的个人 agent 运行时；适合当 Claude Code / Codex 之外的第三种底盘来跑。
  https://ryanalberts.github.io/best-of-Agent-Harnesses/h/openjarvis/

💬 社区热议（1 条）
- M-VAVE FM-1 固件潮（HN）
  设备该不该开放固件？争论点其实是：agent 替人买东西后，「可改造性」会不会变成唯一差异化的硬件卖点。
  https://geoffstearns.com/blog/your-agent-will-pick-the-hackable-one/
