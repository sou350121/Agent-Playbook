# 🤖 AI 每日精选 | 2026-07-14

🔥 头条

- Apple SpeechAnalyzer API 实测：击败所有 Whisper 模型，速度快 3x
  首个第三方基准测试：LibriSpeech clean WER 2.12% 击败 Whisper Small 3.74%，速度快 3x，SFSpeechRecognizer 迁移刻不容缓
  https://get-inscribe.com/blog/apple-speech-api-benchmark.html

- GPT-5.6 Sol/Terra/Luna 全量上线 Amazon Bedrock
  三模型系列正式 GA，定价匹配 OpenAI 官方。Sol 在 Coding Agent Index 达 80 分，ExploitBench 73.5%
  https://aws.amazon.com/blogs/machine-learning/openai-gpt-5-6-sol-terra-and-luna-are-now-generally-available-on-amazon-bedrock/

⚡ 精选动态

- 【🏢行业】xAI Grok Build CLI 被曝上传完整 Git 仓库到 Google Cloud Bucket
  安全研究员发现 CLI 将完整仓库（含历史、.env 密钥）上传至 GCS bucket，12GB 仓库上传了 5.1GB。xAI 已悄悄修复但未公开说明
  https://www.internationalcyberdigest.com/xais-grok-build-cli-uploads-entire-git-repositories-to-a-google-cloud-bucket/

- 【🔧工具】Claude Code 插件 Mr. Meeseeks：等待你时播放瑞克和莫蒂音效
  HN 85 分。利用 Notification hook 在 Claude 等待用户输入或需要审批时播放音效，精准区分自主工作和等待状态
  https://github.com/thephw/claude-meseeks

- 【🧪实验】DOOMQL：用 SQLite 做游戏引擎，GPT-5.6 Sol 生成
  所有游戏逻辑（移动、碰撞、渲染）全部用 SQL 实现，包括递归 CTE 光线追踪器。展示 Sol 在非常规问题上的推理深度
  https://simonwillison.net/2026/Jul/13/doomql/

- 【💬观点】Coding Agent 让开源贡献量出现巨大峰值
  Simon Willison 通过 GitHub code-frequency 图表发现 Datasette 项目在顶级 coding agent 发布后代码提交量出现巨大 spike
  https://simonwillison.net/2026/Jul/13/datasette-code-frequency/

- 【🔧工具】Nobie：AI-first 本地 Excel 运行时，支持 Claude/Codex 直接操作
  Mac 本地 Excel 兼容运行时，数据不离开本机。Claude/Codex/Gemini 可直接通过 computer-use agent 操作电子表格
  https://nobie.com
