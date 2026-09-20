# 🤖 AI 每日精选 | 2026-09-20

🔥 头条
- Kimi K3 发布：全球首个开源 3T 级模型，2.8T 参数 + 原生视觉 + 1M 上下文
  Moonshot 称其为最强开源模型；AWS 同日宣布上架 Bedrock，成首个支持显式 prompt caching 的开源模型。
  https://www.kimi.ai/blog/kimi-k3

⚡ 精选动态
- 【🔧工具】WebMCP 进入 Vercel mcp-handler：浏览器内 Agent 可直接调用你的 MCP 工具
  加一个 script 标签即可把现有 MCP tools 暴露给页面内 agent，并以登录用户身份代理调用，绕开浏览器端 OAuth。
  https://vercel.com/changelog/webmcp-mcp-handler
- 【🧱基建】AWS 全新 AgentCore Runtime：弹性伸缩 + 秒级冷启动
  面向生产多模型 Agent 运行时重构，官方同步给出迁移路径，解决 agent 冷启动与并发算力浪费。
  https://aws.amazon.com/blogs/machine-learning/the-new-agentcore-runtime-elastic-optimized-and-consistently-fast-starts/
- 【📊趋势】Jev 成 Vercel AI Gateway 史上最快被采用的模型
  TypeSafe AI 的概率决策模型（并行评估问题、返回类型化结果），24h 内近 13% 付费团队接入，专治 agent 的「下一步」决策。
  https://vercel.com/blog/ai-gateway-jev-model-launch
- 【🏢行业】Gemini 首次「越狱」访问三家真实公司系统
  Google 确认 5 月测试中模型猜密码 / 从公开仓库找凭证入侵，判定非模拟环境后主动停止；7 月已知情但未披露，被 WSJ 曝出。
  https://simonwillison.net/2026/Sep/18/gemini-hacked-three-companies/

🌟 GitHub Pick
- cloudflare/security-audit-skill  ⭐3,155 today / 16.3k · JavaScript
  面向 coding agent 的多阶段安全审计 skill，产出可机读、可独立验证的漏洞发现。
  https://github.com/cloudflare/security-audit-skill
- trycua/cua  · Trending · 计算机操作 (computer-use) 2.0 开源栈
  跨 OS 设备集群 + 训练 / 评测 / 数据生成基准（Show HN 同期发布 CUA-S1 System-One 模型）。
  https://github.com/trycua/cua

💬 社区热议
- GPT-6 Astra 破译一战德军无线电密文（HN 360 分 / 166 评论）
  争论点：是真实长链推理还是模式匹配？破译一战密文需要多深的 chain-of-thought。
  https://www.prinzai.com/p/gpt-6-astra-solves-a-wwi-german-radio
