# 🤖 AI 每日精选 | 2026-10-23

🔥 头条（2 条）
- Anthropic 把 Agent Skills 捐给 AAIF（Linux Foundation）
  1M 个 skills 已发布 / 2.8 亿次安装、70+ 平台接入；标准名、Logo、GitHub org、agentskills.io 全部移交，Anthropic/Google/OpenAI 工程师以个人身份共同维护
  https://www.anthropic.com/news/donating-agent-skills-to-the-agentic-ai-foundation

- AAIF 一天收进四个项目：Agent Skills / Open Responses / OpenEnv / OpenSandbox
  Anthropic、OpenAI、Hugging Face、Alibaba 各捐一个，正好覆盖 agent 能力、模型互通、训练环境、安全执行四层；AAIF 一年从 3 个项目到 10 个
  https://www.linuxfoundation.org/press/agentic-ai-foundation-announces-four-new-projects-agent-skills-open-responses-openenv-and-opensandbox

⚡ 精选动态
- 【🆕新发布】Claude Duet 研究预览：会主动找你汇报的个人 agent（Opus 5.5）
  跨 iOS/Android/Web + Pro/Max，任务完成后再回来汇报；内置敏感信息分类器，禁止转账/证券交易，刻意比 OpenAI Dots、Meta Muse 更保守
  https://www.techtarget.com/ai/news/366652530/Anthropic-rolls-out-Claude-Duet-but-enterprises-arent-ready

- 【🔧工具】Claude API v2026-10-21 + SDK 全面大版本（Python 2.0 / TS 1.0 / Go 2.0）
  SDK 与 ant CLI 许可证从 MIT 换成 Apache 2.0，且有与 API 版本无关的 breaking changes —— 升级前先看 migration 页
  https://platform.claude.com/docs/en/release-notes/overview

- 【🔧工具】Claude API 上线 Google Cloud（Anthropic 自营，IAM 鉴权 + Marketplace 计费）
  同时开放 Opus 5.5 的 Fast mode；多云合规部署终于不用再绕 Bedrock/Vertex 的分叉路径
  https://platform.claude.com/docs/en/build-with-claude/claude-models-on-google-cloud/anthropic-managed

- 【🧪实验】Microsoft HF 博客：把数据库判分变成 RL 奖励，用 ThinkingBox 后训练 agent
  用可验证的 SQL/DB 执行结果当 reward，而不是 LLM-as-judge —— 这是 agent 后训练里最省钱的正确方向
  https://huggingface.co/blog/microsoft/thinkingbox-training

- 【📊趋势】Armin Ronacher：过去 30 年写的烂软件，正在被 AI 安全研究惩罚
  Simon Willison 摘录的一句话，戳中 agent 时代的真实痛点：agent 放大的是历史技术债
  https://simonwillison.net/2026/Oct/22/armin-ronacher/

🌟 GitHub Pick
- Graphify-Labs/graphify  ⭐132.9k / Python · Trending
  把代码库+文档+SQL schema+PDF 转成可查询知识图谱，本地确定性 AST 解析、每条边可解释、不用向量库
  https://github.com/Graphify-Labs/graphify

- cloudflare/security-audit-skill  ⭐39.6k / JavaScript · Trending
  Cloudflare 官方 coding-agent skill：多阶段安全审计，产出机器可读且独立验证的发现
  https://github.com/cloudflare/security-audit-skill

💬 社区热议
- Anthropic 同时被两件事缠上：音乐版权诉讼 + 「借安全之名抢超级智能」论战（Dario 发长文回应并称雪藏 Mythos 级模型 4 个月）
  争点是：主动延迟发布到底是真安全，还是抢先占位的叙事包装
  https://readhub.cn/topic/8xQCifJvqb8
