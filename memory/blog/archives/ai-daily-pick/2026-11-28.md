# 🤖 AI 每日精选 | 2026-11-28

🔥 头条

- OpenAI 起诉苹果窃取商业秘密，硬件合作彻底撕破脸
  称苹果扣留供应商、阻挠其对接硬件伙伴；两年前还把 ChatGPT 塞进 iPhone，如今对簿公堂
  https://readhub.cn/topic/8yPKHvylsvk

- Vercel Workflow SDK 5.8：新执行引擎，agent 循环开销砍到 0.9s
  step 间 p75 开销 85ms→7ms，256 路并行 fan-out 函数耗时省 14x；可重试 step 走投机执行
  https://vercel.com/changelog/workflows-speculative-execution

⚡ 精选动态

- 【🆕新发布】Together 开源 Hurdle：给「你的 API/文档/skills」跑 agent 评测
  npm 库，跑 Claude Code / Codex 真实任务，支持 code check + 越权 guard + LLM judge，并可比 MCP 开关前后差异
  https://github.com/togethercomputer/hurdle

- 【🔧工具】iFood 把 15,000 个仓库的编码 agent 做成 Remote Agents Platform
  入口是 REST API，远端沙箱执行、结果回传 merge request；安全平台修复漏洞数翻倍
  https://openai.com/business/customer-stories/ifood

- 【🔧工具】Pax by Pydantic 上线 Product Hunt
  把 Pydantic 类型约束带进 agent 输出校验，Schema 即接口契约；适合替代手写 JSON 修补逻辑
  https://www.producthunt.com/products/pydantic

- 【📊趋势】llama.cpp 推出 AMD Ryzen / Radeon 官方 benchmark dashboard
  PP512 / TG128 / 上下文扩展三条曲线可跨 build、量化对比；本地推理调参终于有公开基线
  https://huggingface.co/blog/ggml-org/llamacpp-amd-bench

- 【💬观点】Claude Code 核心人物反思 Vibe Coding 的未来
  从「让模型连续改到对」转向可控、可审计的协作方式；与近期 harness/评测工具潮呼应
  https://www.36kr.com/p/4087449994181000

- 【🧪实验】HF 系列博文《Swarms, Flocks, Gangs》：训练 agent 群如何沟通
  两卡 H200 跑 5 小时约 $50 复现；核心结论是「拼上下文不等于增益」，沟通能力必须训练出来
  https://huggingface.co/blog/training-swarms

- 【📊趋势】Together 把 Kimi-K3.1-Pro 蒸馏进 Qwen3.8-27B 教新语言
  小模型继承大模型的目标语言能力，是低成本多语 agent 落地的一条现实路径
  https://www.together.ai/blog/distilling-kimi-into-qwen

💬 社区热议

- DeepSeek 灰度「消耗额度」可视化：对话成本直接摆到台面上
  额度可见 = agent 长链推理的预算门控终于有产品化形态
  https://m.ithome.com/html/1033157.htm

---
*2026-11-28 · 48h 窗口 · 仅一手来源*
