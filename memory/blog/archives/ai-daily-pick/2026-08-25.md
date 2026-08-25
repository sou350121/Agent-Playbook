# 🤖 AI 每日精选 | 2026-08-25

🔥 头条
- LLM 可通过推理引擎漏洞控制宿主机
  安全深度分析：vLLM CVE-2025-9141 真实案例证明 LLM 可通过 token 序列触发推理引擎任意代码执行
  https://boydkane.com/essays/llms-could-control-their-host-machines-by-exploiting-inference-engines

⚡ 精选动态
- 【📊趋势】Hugging Face 量化 ASR 基准优化：多个开源模型「背答案」
  HF 首次量化语音识别领域的 benchmaxxing 现象，11 个开源 ASR 模型中有多个复现了基准转录而非真实转录
  https://huggingface.co/blog/asr-benchmark-optimization

- 【🆕新发布】Apache Maka (Incubating)：本地优先 AI Agent 工作区
  Apache 孵化器新项目，将 Agent 会话记录为 append-only log，支持沙盒工具调用和本地/云模型混合
  https://github.com/apache/maka

- 【🔧工具】Nous Research Hermes Agent：自带学习回路的自改进 Agent
  唯一内置学习回路的 Agent——从经验创建 skill、跨会话搜索、用户建模，支持多平台
  https://github.com/NousResearch/hermes-agent

- 【🆕新发布】Vercel v0 接入 Slack/Google 等 100+ 服务
  v0 生成的应用现在可直接连接 100+ 外部服务，Agent 应用的前后端集成链路进一步缩短
  https://vercel.com/changelog/connect-v0-apps-to-slack-google-and-100-other-services

- 【🔧工具】PicoMQ：基于对象存储的持久化消息流
  Rust 实现的轻量消息队列，每个流独立可寻址、无限容量，构建在 S3 兼容存储上
  https://picomq.com/
