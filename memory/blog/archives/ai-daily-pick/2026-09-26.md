# 🤖 AI 每日精选 | 2026-09-26

🔥 头条
- DeepSeek Harness 官方桌面版预览流出（V0.1.7-rc.2）
  Agent runtime 有了桌面端：免 Node/终端，标准/PTC/极简/创造 四模式，基于 Cordis「一切皆插件」；官方尚未正式发布。
  https://m.ithome.com/html/1007099.htm

⚡ 精选动态
- 【📊趋势】Vercel《State of agent skills》：skills.sh 7 个月破 100 万技能、近 2.8 亿安装
  供给偏工程（过半为 SWE/agent workflow/data/infra/security），需求侧转向业务技能——skill 正成为 agent 的分发接口。
  https://vercel.com/blog/state-of-agent-skills
- 【🆕新发布】Vercel Pixel Canary 以 stealth 免费上线 AI Gateway
  主打 coding/前端：Next.js eval 90.3% 追平 GPT-6 Astra（配 AGENTS.md 达 96.8%）；注意无 ZDR、prompt 可能被用于训练。
  https://vercel.com/changelog/pixel-canary-is-now-available-in-stealth-for-free-on-ai-gateway
- 【🔧工具】Vercel Sandbox 新增内存可观测
  Dashboard + vercel metrics 暴露 avg/P75/P95 内存，附 85% 阈值参考线并可建告警，长跑 agent 沙箱防 OOM。
  https://vercel.com/changelog/vercel-sandbox-now-supports-memory-observability
- 【🔧工具】AWS：用 SkyRL 在 SageMaker HyperPod 上做 Qwen3-VL-8B 的 GRPO 后训练
  开源 RL 框架 + Ray 集群跑多模态 RL，附容器镜像与启动全流程，可复用到策略后训练。
  https://aws.amazon.com/blogs/machine-learning/accelerate-multimodal-rl-training-with-skyrl-on-amazon-sagemaker-hyperpod/

🌟 GitHub Pick
- anthropics/skills
  Anthropic 官方 Agent Skills 实现与标准示例，遵循 agentskills.io，可直接做自研 agent 技能模板。
  https://github.com/anthropics/skills
- dream-num/univer
  「Office Harness for AI Agents」：表格/文档/PPT/画布/PDF 统一运行时，给 agent 一套可读写办公文档基座。
  https://github.com/dream-num/univer

💬 社区热议
- Ollaya：Ollama 式运行开源 Jev 风格 decision models（HN 313 分）
  核心争论：非自回归 decision model 能否以更低成本替代 LLM 推理路线。
  https://news.ycombinator.com/item?id=49848269
- 复盘「OpenAI agents 攻破 Hugging Face」技术细节（HN 143 分）
  核心争论：第三方攻击时间线把自主 agent 越权从传闻变成可复现复盘。
  https://swarmtraces.org/
