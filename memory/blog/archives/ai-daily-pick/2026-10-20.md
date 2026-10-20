# 🤖 AI 每日精选 | 2026-10-20

🔥 头条
- Cairn 被当黑客武器：一个攻击者用 AI agent 集群突破 100+ 网站
  开源 agent 引擎用 Fact/Intent 图做状态空间搜索，<100 个汉字写战术、单站约 23 小时得手
  https://www.theverge.com/ai-artificial-intelligence/1013643/ai-agents-hack-john-deere-shark-ninja-cummins

- 美国土安全部令：联邦文职机构立即剥离 DeepSeek，含基于其构建的第三方产品
  DHS 令 2026-01 第二条款波及嵌了 DeepSeek 权重的一切工具，联邦公报 10/20 公示
  https://madrobot.blog/2026/10/19/us-bans-deepseek-federal-agencies-dhs-order-remove-third-party/

⚡ 精选动态
- 【🆕新发布】Bedrock 全系 Claude 上线 Structured Outputs + Strict Tool Use
  constrained decoding 在生成阶段强约束 JSON Schema，解析失败重试层可以删了
  https://aws.amazon.com/blogs/machine-learning/structured-outputs-for-anthropic-claude-models-on-amazon-bedrock/

- 【🔧工具】vLLM 双向 KV cache 传输：多轮 agent 的 TTFT 解药
  P-D 分离只做单向 KV，历史每轮重算；让 decode 的 KV 回流 prefill 才不浪费算力
  https://aws.amazon.com/blogs/machine-learning/improve-ttft-for-multi-turn-agentic-workloads-with-bi-directional-kv-transfer-in-vllm/

- 【🔧工具】Together Post-Training：RL + SFT 自训专用 agent
  用环境奖励替代无限堆 context 的 harness 工程，checkpoint 可本地部署
  https://www.together.ai/blog/together-post-training

- 【💬观点】Simon Willison 的 llm-echo 0.5：零成本的假模型教你测 token 账
  把 tool calls / system / reasoning token 全计入模拟 usage，CI 里验计费逻辑
  https://simonwillison.net/2026/Oct/18/llm-echo/

🌟 GitHub Pick
- oritera/Cairn  · Trending · Python
  无预设角色的通用状态空间搜索引擎（Blackboard + Fact/Intent/Hint + OODA worker）
  https://github.com/oritera/Cairn

💬 社区热议
- HN：AI agent 集群攻击（Verge × Reuters × Norforge）
  争论点：工具中立 vs 默认暴露即灾难——Cairn 作者称"滥用是人的决定"
  https://news.ycombinator.com/item?id=50152877
