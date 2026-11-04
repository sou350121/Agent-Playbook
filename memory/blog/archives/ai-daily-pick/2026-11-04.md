🤖 AI 每日精选 | 2026-11-04

🔥 头条

- Karpathy 用 Claude Code 两小时造出 HackerTube（6,454 部 HN 推荐视频）
  从 HN 全量评论里筛出 40 万→4 万条推荐，丢给 agent 建站、买域名、上 VPS 并加固，人工只做了 3 件事；站点压缩包 17.8 MB 含 DATA.md，给 agent 就能改出你自己的版本
  https://technews.tw/2026/11/02/andrej-karpathy-launches-hackertube-featuring-6454-youtube-videos/
  一手入口：https://hackertube.org/

- Google：K-12 学校若关闭 Gemini AI 功能，将连 Search 一起停用
  官方教育博客确认：管理员需显式开启才能用 Gemini/Gemini Notebook/Search，不能只关 AI 留搜索；Sanders 称其"勒索"
  https://blog.google/products-and-platforms/products/education/ai-learning-era-updates-2026/

⚡ 精选动态

- 【🔧工具】NVIDIA 开源 Auto Ontology：给 agent 一层可校验的语义上下文层
  从企业元数据生成本体、跨系统对齐指标定义，text-to-SQL 结果带 lineage 与 provenance，通过 MCP / CLI / API 接入任意 harness
  https://github.com/NVIDIA/auto-ontology

- 【💬观点】Karpathy：推荐算法的目标是停留时长，不是让你明年还在想那场演讲
  HackerTube 无账号体系，点赞/历史只存本地，视频走 YouTube 隐私增强嵌入——一个"反推荐算法"的 agent 建站样本
  https://hackertube.org/

- 【📊趋势】Anthropic 13 万亿美元参数"泄露模型"被证伪
  Hugging Face 上 7.7 TB 的 Mythos 5.5 权重是 name-seeded 随机数，社区取证几小时拆穿——权重文件也要验
  https://explainx.ai/blog/alleged-anthropic-mythos-checkpoint-numbat-hugging-face-fake-random-weights-2026

- 【🏢行业】欧洲法院顾问：Gemini 复用新闻表达形式可能侵权，但用受版权内容训练 LLM 在 TDM 例外内合法
  训练侧暂安全、输出侧收紧；法务意见不具约束力但通常被采纳
  https://readhub.cn/topic/8xlEBmzX0Jy

- 【🔧工具】AWS 博文：ServiceNow 用 Bedrock AgentCore Gateway 做 on-behalf-of token 交换
  agent 代表用户访问下游系统时的令牌委派做法，可直接对照自己的 agent 鉴权设计
  https://aws.amazon.com/blogs/machine-learning/servicenow-on-behalf-of-token-exchange-with-bedrock-agentcore-gateway/

🌟 GitHub Pick

- deepseek-ai/dsh-superagent-prototype  ⭐16.7k total · TypeScript · 2 天前建库
  面向单个仓库的"主动型"coding agent：监听 GitHub/Feishu，按团队规则开工作项、独立 session 干活、回 PR；明确标注 research code
  https://github.com/deepseek-ai/dsh-superagent-prototype

- ephraimduncan/hackertube.tv  ⭐66 total · Kotlin
  Karpathy HackerTube 想法的 Android TV 版；同期还有 Jnaina/hackertube-tvos（Swift）与 caikaidev/hackertube-cn（V2EX 版）
  https://github.com/ephraimduncan/hackertube.tv

---
