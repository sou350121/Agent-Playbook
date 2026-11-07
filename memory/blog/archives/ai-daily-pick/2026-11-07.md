# 🤖 AI 每日精选 | 2026-11-07

🔥 头条（1-2 条）
- OpenAI GPT‑6 Cyber 发布：对齐型安全 agent 首次超过「越界」诱惑
  ExploitGym 48.5%（前代 32.1%，+51%）；实测挖出 Linux 948 个提权漏洞、Firefox 81 个未知高危漏洞（Mozilla 已发补丁），越界服务规避率 99.93%→100%
  https://openai.com/index/introducing-gpt-6-cyber

- Google 发布 Gemini Omni 1.2 Flash：文生视频 15 秒 + 原生音频，价格再降约 30%
  文生视频/图生视频两项榜单第一，Omni 系列包揽前三；已全量上线，可用 videoId 回溯编辑
  https://blog.google/innovation-and-ai/technology/developers-tools/introducing-gemini-omni-1-2-flash/

⚡ 精选动态（3-5 条）
- 【🆕新发布】Claude Code 核心产品负责人跳槽 OpenAI（前一天刚宣布离开 Anthropic）
  两篇 36Kr 报道指同一人；属二手来源，仅作人事风向信号，团队后续排期以官方为准
  https://www.36kr.com/p/4056162615350407

- 【🔧工具】AWS：Okta Cross App Access × Bedrock AgentCore，给 agent 做细粒度授权
  Part 1/2 两篇，把「agent 代表用户访问第三方 SaaS」的 token 交换与作用域收窄写成可落地方案
  https://aws.amazon.com/blogs/machine-learning/govern-ai-agent-access-with-okta-cross-app-access-and-amazon-bedrock-agentcore-part-1/

- 【🔧工具】AWS：Serverless MCP server（ECS Fargate）打通 agent 的数据湖访问
  把 MCP 服务做成无状态容器，agent 侧只拿到受控查询能力，避免直连数仓
  https://aws.amazon.com/blogs/machine-learning/serverless-mcp-server-for-ai-agent-data-lake-access-on-amazon-ecs-fargate/

- 【📊趋势】Together：Compiler + Polymorphic Inference，按负载动态编译推理图
  宣称让开放模型在不变硬件上按流量自调优，聚焦连续编译与形态切换，而非一次性静态图
  https://www.together.ai/blog/polymorphic-inference

- 【🏢行业】紫光展锐：Agent 进生产的「4+1」标准（安全优先 + 稳定/可观测/可度量 + 人机协同）
  三类已落地（Camera 内存调查、销售供应链预测、项目风险追踪），配内部 UniMaaS 平台
  https://readhub.cn/topic/8xqpSXMrULr

🌟 GitHub Pick（1-2 个）
- thedotmack/claude-mem  ⭐~114k / TypeScript · Trending
  跨 session 的 agent 持久记忆：捕获过程→AI 压缩→按需注入，兼容 Claude Code、Codex、Gemini 等
  https://github.com/thedotmack/claude-mem

- max-sixty/worktrunk  ⭐~11.8k / Rust · Trending
  给并行 agent 用的 git worktree CLI，一命令一工作树，解决多 agent 抢同一目录
  https://github.com/max-sixty/worktrunk

💬 社区热议（0-2 条）
- Anthropic 收紧中转/代理调用，AI 中转站商业模式受冲击（36Kr）
  争论点：限流与计费口径，是否会把第三方工具链逼回官方 SDK
  https://www.36kr.com/p/4056019887510401

---
规则：如果今天没什么大事，也要精选五小事（3-5 条）；只有在极端情况下才发“今日无重大动态”。
