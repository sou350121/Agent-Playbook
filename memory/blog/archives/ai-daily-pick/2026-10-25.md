# 🤖 AI 每日精选 | 2026-10-25

🔥 头条
- Kimi K3.1 Pro 上线：AA 智能指数 55 分，距前沿只差 3 分，创开源模型新高
  Terminal-Bench 4.0 拿 67%（K3 仅 13%）冲到所有模型第一，GDPval-AA 1,846 Elo 第三；2.8T 总参 / 104B 激活 / 1M 上下文，$2/$10 每百万 token（比 K3 全线降 33%），全量权重承诺 11/4 前放开
  https://www.kimi.ai/blog/kimi-k3-1-pro

- Claude Code 核心作者 Thariq Shihipar 离职 Anthropic，抛「大模型智力已过剩」论
  他在告别信中称强模型可砍掉 80% 系统提示词、算力不再是第一瓶颈，并直言 Opus 5.5「变蠢了」；同期 Anthony Morris 也宣布离开，时间点在其 IPO 前夕
  https://officechai.com/ai/thariq-shihipar-anthony-morris-announce-theyre-leaving-anthropic-weeks-before-its-ipo/

⚡ 精选动态
- 【🧪实验｜安全】NVIDIA Open Agent Safety Platform + OpenShell：把 agent 关进内核级沙箱
  OpenShell 开源 runtime 让每个 agent 跑在独立沙箱，文件/网络/工具/凭据白名单由操作方定义并实时校验；Sentry 跑在 BlueField-4 DPU 上，越界毫秒级隔离。Anthropic、Microsoft、SAP、JPMorgan 等 100+ 机构已在用
  https://github.com/NVIDIA/OpenShell

- 【💬观点】Moonshot 主动「切除」网络攻击相关训练数据后再开放权重
  K3.1 Pro 在真实漏洞利用测试上解 81%（未删减版 90.5%），仍远高于 K3 的 33%，但低于 DeepSeek V4.1-Flash 的 85.7%；开源权重不可回收，这是首个发布方在开放前做能力削减的案例
  https://thenextweb.com/news/moonshot-kimi-k3-1-pro-open-weight-cyber

- 【🔧工具】AWS Agent Toolkit：官方 MCP servers + skills + plugins 一次接全
  把 AWS 服务的 MCP 接入、可复用 skills 与 CLI/IDE 插件打包成一个包，省掉逐服务写 MCP server 的成本
  https://github.com/aws/agent-toolkit-for-aws

- 【🔧工具】Nutlope/hallmark：给 Claude Code / Cursor / Codex 的「反 AI slop」设计 skill
  Hassan 出品的 UI 设计约束 skill，专门约束生成式前端产物不要满是紫蓝渐变和毛玻璃
  https://github.com/Nutlope/hallmark

- 【📊趋势】TRAE 公布 1024 开发者最爱的 10 个 MCP Server（基于近一月真实使用数据）
  比任何榜单更接近中国开发者实际在调用的 MCP 组合，适合作为工具选型参考
  https://juejin.cn/post/7699244622958084122

- 【🏢行业】OpenAI 再次表态前沿模型短期不开源，理由是会冲击网络安全体系
  与 NVIDIA 推开源 agent 安全平台、Moonshot 删减能力后开放权重形成两种完全不同的开放叙事
  https://openai.com/index/broad-access-through-consistent-standards

💬 社区热议
- Show HN：通过 CVE-2022-22706 拿到 TCL Android TV 的 root
  Mali pagecache 漏洞链路通用性讨论，顺带讨论 IoT 设备多年不修的老内核（50 分 / 17 评论）
  https://news.ycombinator.com/item?id=50220042
