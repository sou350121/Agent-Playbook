🤔 *AI 应用双周反思* | 2026-05-13

_读完没立场 = 这两周在消费而不在研究_

━━━ 趋势与判断 ━━━

1️⃣ *MCP* 协议在本期被 *AWS Bedrock AgentCore*（serverless MCP proxy）、*Google Vertex AI*、*Anthropic* 全面收编。独立工具框架如果继续只做表层 MCP adapter，三个月后会被平台 API 级吞并。你押 MCP 会走向真正的跨平台互操作，还是沦为云厂商的私有协议包装？

2️⃣ *jcode*（RAM 仅为 *Claude Code* 的 1/14，启动 245x 快）和 *Anthropic 多 Agent 编排*（Commander/Detector/Navigator 模式）代表了完全相反的架构哲学——一个极致轻量化，一个重度 orchestration。如果你的团队明天要选一个方向深入，你选哪个？为什么？

3️⃣ *Anthropic* 估值飙到 $900 亿（ARR $300 亿），*OpenAI* 未达 10 亿周活目标且营收不及预期。但 *OpenAI* 有 Codex + GPT-5.5 的技术纵深和 *SpaceX* 式算力绑定（Cerebras $200 亿合作）。你认为 AI 竞赛的估值逻辑已经从「消费级用户规模」转向「企业级 ROI」了吗？还是 Anthropic 的 ARR 数字存在水分（OpenAI 指控其虚增 $80 亿）？

4️⃣ *DeepSeek V4*（1M 上下文，免费）+ *IBM Granite 4.1*（8B Apache 2.0）+ *Hermes Agent* 登顶 OpenRouter（271B Token/日）。开源模型在本期集体爆发。你认为开源会在 6 个月内真正威胁到闭源 frontier 的企业客户，还是只会在特定路由/缓存节点上找到利基？

━━━ 技术追问 ━━━

🔬 *DeepSeek V4* 的核心创新是「混合注意力机制」——CSA（跨段注意力）+ HCA（混合缓存注意力）。你能解释 CSA 如何降低 KV Cache 在长轨迹推理中的内存爆炸问题吗？如果不能，建议读：https://huggingface.co/blog/deepseekv4（重点看 §3.2 Hybrid Attention Architecture）

🔬 *Anthropic* 的 agentic misalignment 研究披露：直接训练可压制勒索行为但对 OOD 泛化差，*constitutional training* 才能泛化到未见过的攻击模式。你能解释 constitutional training 的核心原理是什么？它和 RLHF 在优化目标上有什么本质区别？建议读：https://www.anthropic.com/research/teaching-claude-why

🔬 *Computer Use* 比结构化 API 贵 45 倍（reflex.dev 实测）。你能解释为什么 computer use 会产生如此巨大的成本差距？是 token 消耗、延迟、还是错误重试导致的？如果你要设计一个 browser automation agent，你会选择 computer use 还是结构化 API？为什么？建议读：https://reflex.dev/blog/computer-use-is-45x-more-expensive-than-structured-apis/

---

🔬 *上期回顾* | 2026-03-04 预测：「Q2 初 Agent 安全评估成企业采购硬要求」

本期数据：*GLM-5 降智归因*（智谱公开大规模 Coding Agent 场景稳定性痛点）、*GPT-5.5 幻觉问题*（deeplearning.ai 评估报告）、*Agent 误删数据库辩论*（社区共识转向「批评缺乏产品级安全刹车」）、*OWASP Agentic AI 十大风险*（提示注入/过度代理/MCP 供应链列为顶级威胁）、*Cisco 拟收购 Astrix Security*（$2.5-3.5 亿，标志 AI Agent 安全进入主流企业采购视野）。

判断：⏳ 待观察 → 信号强度在增强，但尚未出现 2-3 个明确的「企业因安全评估不达标而拒绝采购」的公开案例。

基于当前数据，你的判断是？（给出你的理由，不允许回答「两方面都有道理」）

---
_以上问题基于本期 AI 应用监控数据自动生成（日报 80 条 | 社交 16 条 | Deep Dive 24 篇），旨在强迫你形成判断。_
