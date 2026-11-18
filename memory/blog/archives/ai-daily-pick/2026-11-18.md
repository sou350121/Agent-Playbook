# 🤖 AI 每日精选 | 2026-11-18

🔥 头条（2 条）

- GPT‑6.2 Astra / Sol 正式发布：Astra 降价 20%、缓存输入降 60%
  Agents' Last Exam 比 GPT-6 Astra 高 5.2 分而成本不到三分之一，比 Claude Fable 5.2 高 5.5 分只用 5% 成本；Astra 输入 $8/输出 $40（缓存 $0.40）每百万 token，Sol 维持 $2/$10
  https://openai.com/index/introducing-gpt-6-2-astra-sol/

- Anthropic IPO 文件：Claude Mythos 三天完成 Claude 模型到 AMD MI355X 的移植
  近 100% 底层 kernel 由模型自主编写、几乎无人工介入，原本需数十名工程师做 6–12 个月；移植后性能与 CUDA 方案差 8–12% —— CUDA 护城河第一次有可量化的裂缝
  https://www.tomshardware.com/tech-industry/artificial-intelligence/anthropic-says-claude-mythos-slashed-software-work-to-onboard-amd-gpus-from-up-to-12-months-to-around-three-days-writing-almost-100-percent-of-kernels-autonomously-chips-away-at-nvidias-cuda-moat

⚡ 精选动态（4 条）

- 【🆕新发布】微软 Ignite 发布 MAI Realtime 1：首个语音对语音模型，$0.01/分钟
  限邀预览，接口对齐 OpenAI Realtime API；难点回合转交独立推理引擎按 token 计费（"Copilot Voice Mode 将用它"是转述，微软官方材料未写）
  https://microsoft.ai/news/introducing-mai-realtime-1/

- 【🔧工具】Simon Willison 实测 GPT‑6.2 并同步发出 LLM 0.38
  给出 Astra/Sol 的同 prompt 对照与价格拆解：6.2 Astra 的缓存价打到 $0.40/M，长跑 agentic 会话的账要重算；同场指出两模型在 3D/mech demo 上仍不如 Fable 5.2 与 Gemini 4 Carbon
  https://simonwillison.net/2026/Nov/17/gpt62-astra-and-sol/

- 【💬观点】Simon Willison：Datasette Lite 用 service worker + Pyodide 完整重写
  现在几乎可以在浏览器里跑完整的服务端 Datasette Python 应用；对"把 agent 的查询/审阅界面塞进静态页面"是一条新路子
  https://simonwillison.net/2026/Nov/17/datasette-lite/

- 【🏢行业】OpenAI 宣布与 NATO 及盟国网络机构合作强化网络防御
  以官方合作形式让 AI 承担漏洞发现、修复验证与关键系统防护；agent 进入国家级防御工作流，采购侧的审计与权限要求会随之抬高
  https://openai.com/index/strengthening-nato-allied-cyber-defences-ai

🌟 GitHub Pick

- 今日稳定源未产出可核验的 trending 条目（仅有核心 RSS 与博客源），本栏留空，不用未验证仓库凑数。

💬 社区热议

- 今日无通过 48 小时与一手来源双重校验的社区高热话题（HN/Reddit 本次未采集）。
