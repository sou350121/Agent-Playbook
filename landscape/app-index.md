# App Index（AI 应用/工具索引）

> **核心定位**：这是本仓库的“高频写入入口”。
>
> - Moltbot 只允许对本文件做 **append-only**（在对应分类表格末尾追加新行），禁止覆盖/重排/改列。
> - 人工手动添加条目必须在备注栏标注 `✍️`，并尽量写清“为什么重要”。
>
> 读法：你不需要从聊天里记住任何东西——你只需要知道：**这里有**。

---

## 标注系统（两层叠加）

### 第一层：重要性

- **⚡ 战略级**：知名团队 + 架构创新，或大规模应用/生态拐点
- **🔧 可操作**：有开源代码/API/文档可复现，能立刻上手
- **📖 值得了解**：有参考价值但短期不需要行动

### 第二层：方向

- **🎯**：primary 方向（主攻；门槛更低，命中就应收录）
- **[方向名]**：team 方向（信号追踪；门槛更高，只收大事）
- **✍️**：人手动添加（Moltbot 不触碰）

---

## Agent 框架（Frameworks）

| 应用/工具 | 描述 | 开发者 | 日期 | 标签 | 备注 | 链接 |
|---|---|---:|---:|---|---|---|
| LangChain | 最广泛使用的 LLM 应用开发框架，支持 Agent、RAG、链式调用 | langchain-ai | 2026-02-11 | agent-framework | ✍️ seed | [🔗 Link](https://github.com/langchain-ai/langchain) |
| LlamaIndex | 专注数据索引与 RAG 的 LLM 框架，擅长私有知识库接入 | run-llama | 2026-02-11 | rag, agent | ✍️ seed | [🔗 Link](https://github.com/run-llama/llama_index) |
| AutoGen | 微软出品多智能体协作框架，支持异步、模块化 Agent 编排 | microsoft | 2026-02-11 | multi-agent | ✍️ seed | [🔗 Link](https://github.com/microsoft/autogen) |
| CrewAI | 面向角色分工的多 Agent 协作框架，强调任务流水线 | crewAIInc | 2026-02-11 | multi-agent | ✍️ seed | [🔗 Link](https://github.com/crewAIInc/crewAI) |
| OnsetLab |  | — | 2026-02-11 |  | 📖 daily 2026-02-11 | [🔗 Link](https://www.producthunt.com/products/onsetlab) |
| autogen python-v0.7.1 |  | — | 2026-02-11 |  | 🔧 daily 2026-02-11 | [🔗 Link](https://github.com/microsoft/autogen/releases/tag/python-v0.7.1) |
| crewAI 1.9.3 |  | — | 2026-02-11 |  | 🔧 daily 2026-02-11 | [🔗 Link](https://github.com/crewAIInc/crewAI/releases/tag/1.9.3) |
| Dify 1.13.0 |  | — | 2026-02-11 |  | ⚡ daily 2026-02-11 | [🔗 Link](https://github.com/langgenius/dify/releases/tag/1.13.0) |
| OpenEnv |  | — | 2026-02-11 |  | 📖 daily 2026-02-11 | [🔗 Link](https://huggingface.co/blog/openenv) |
| happycapy | 面向普通用户的本地 Agent 计算机 | — | 2026-02-12 | agent, desktop | ⚡ daily 2026-02-12 | [🔗 Link](https://www.producthunt.com/products/happycapy) |
| GLM-5: Targeting complex systems engineering and long-horizon agentic tasks | GLM-5 专注复杂系统工程与长周期 Agent 任务 | Z.ai | 2026-02-12 | agent, agentic, glm | ⚡ daily 2026-02-12 | [🔗 Link](https://z.ai/blog/glm-5) |
| Show HN: Agent framework that generates its own topology and evolves at runtime | 运行时自生成拓扑并进化的 Agent 框架 | adenhq | 2026-02-12 | agent, evolution, topology | ⚡ daily 2026-02-12 | [🔗 Link](https://github.com/adenhq/hive/blob/main/README.md) |
| AutoGen v0.4 | AutoGen v0.4 重构，聚焦异步、模块化和可扩展性 | Microsoft | 2026-02-12 | agent, framework, async | ⚡ daily 2026-02-12 | [🔗 Link](https://devblogs.microsoft.com/autogen/autogen-reimagined-launching-autogen-0-4/) |
| LangChain 1.2.12 |  | langchain-ai | 2026-02-13 | agent, framework, core | 🔧 daily 2026-02-13 | [🔗 Link](https://github.com/langchain-ai/langchain/releases/tag/langchain-core-v1.2.12) |
| CrewAI 1.9.1 |  | crewAIInc | 2026-02-13 | agent, structured-outputs, hooks | 🔧 daily 2026-02-13 | [🔗 Link](https://github.com/crewAIInc/crewAI/releases/tag/1.9.1) |
| Dify 1.11.4 |  | langgenius | 2026-02-13 | security, deployment, nodejs | 🔧 daily 2026-02-13 | [🔗 Link](https://github.com/langgenius/dify/releases/tag/1.11.4) |
| LogiCoal |  | LogiCoal | 2026-02-16 | multi-agent, coding | 🔧 daily 2026-02-16 | [🔗 Link](https://www.producthunt.com/products/logicoal) |
| GLM-5 | 开源长周期智能体工程模型，754B参数规模 | Z.AI | 2026-02-16 | agent, agentic, open-weight | ⚡ daily 2026-02-16 | [🔗 Link](https://www.producthunt.com/products/z-ai) |
| Microsoft Agent Framework adds AG-UI compatibility | 微软官方框架支持 AG-UI 协议，推动前端标准化 | Microsoft | 2026-02-17 | agent-framework, ag-ui, enterprise | 🎯 agent-ui ⚡ daily 2026-02-17 | [🔗 Link](https://www.copilotkit.ai/blog/microsoft-agent-framework-is-now-ag-ui-compatible) |
| LangChainJS v1.2.0 发布 |  | LangChain | 2026-02-17 | langchain, structured-outputs, tools | 🔧 daily 2026-02-17 | [🔗 Link](https://github.com/langchain-ai/langchainjs/releases/tag/v1.2.0) |
| Tiny Agents |  | Hugging Face | 2026-02-18 | agent, mcp, minimal | 🎯 agent-ui 📖 daily 2026-02-18 | [🔗 Link](https://huggingface.co/blog/tiny-agents) |
| Microsoft Agent Framework RC | 微软 Agent Framework 达到 RC 状态，支持 AG-UI 协议实现前端实时通信 | Microsoft | 2026-02-21 | agent-framework, ag-ui, agent-ui | 🎯 agent-ui 🔧 daily 2026-02-21 | [🔗 Link](https://github.com/microsoft/agent-framework/releases) |
| Mengram | 提供事实、事件和工作流三种类型的 AI 记忆 API | — | 2026-02-21 | workflow, memory-api | 📖 daily 2026-02-21 | [🔗 Link](https://www.producthunt.com/products/mengram) |
| SPECTRE | 面向产品构建者的智能体编码工作流 | — | 2026-02-21 | agentic, workflow, coding | 📖 daily 2026-02-21 | [🔗 Link](https://www.producthunt.com/products/spectre-2) |
| Tiny Agents in Python | 使用 MCP 协议构建约 70 行代码的轻量级智能体 | Hugging Face | 2026-02-21 | agent, mcp, tutorial | 📖 daily 2026-02-21 | [🔗 Link](https://huggingface.co/blog/python-tiny-agents) |
| Minions: Stripe's one-shot, end-to-end coding agents | Stripe | 2026-02-23 | agent, coding, one-shot | https://stripe.dev/blog/minions-stripes-one-shot-end-to-end-coding-agents |  | ⚡ daily 2026-02-23 |
| Smol2Operator: Post-Training GUI Agents for Computer Use | Hugging Face | 2026-02-23 | gui-agent, computer-use, agent-ui | https://huggingface.co/blog/smol2operator |  | ⚡ daily 2026-02-23 |
| ScreenEnv: Deploy your full stack Desktop Agent | Hugging Face | 2026-02-23 | desktop-agent, deployment, agent-ui | https://huggingface.co/blog/screenenv |  | 🔧 daily 2026-02-23 |
| Holo1: New family of GUI automation VLMs powering GUI agent Surfer-H | H Company | 2026-02-23 | gui-agent, vlm, automation | https://huggingface.co/blog/Hcompany/holo1 |  | 🔧 daily 2026-02-23 |
| IBM and UC Berkeley Diagnose Why Enterprise Agents Fail Using IT-Bench and MAST | IBM Research | 2026-02-23 | evaluation, benchmark, enterprise | https://huggingface.co/blog/ibm-research/itbenchandmast |  | ⚡ daily 2026-02-23 |
| OpenEnv in Practice: Evaluating Tool-Using Agents in Real-World Environments | Hugging Face | 2026-02-23 | evaluation, tool-use, real-world | https://huggingface.co/blog/openenv-turing |  | 🔧 daily 2026-02-23 |
| AprielGuard: A Guardrail for Safety and Adversarial Robustness in Modern LLM Systems | ServiceNow AI | 2026-02-23 | guardrail, safety, security | https://huggingface.co/blog/ServiceNow-AI/aprielguard |  | 🔧 daily 2026-02-23 |
| GGML and llama.cpp join Hugging Face | ggml-org / Hugging Face | 2026-02-23 | llama.cpp, local-ai, infrastructure | https://huggingface.co/blog/ggml-joins-hf |  | 📖 daily 2026-02-23 |
| NVIDIA DGX Spark + Reachy Mini | NVIDIA | 2026-02-23 | agent, robotics, dgx | https://huggingface.co/blog/nvidia-reachy-mini |  | 📖 daily 2026-02-23 |
| Agentic RL Training for GPT-OSS | LinkedIn | 2026-02-23 | agentic-rl, training | https://huggingface.co/blog/LinkedIn/gpt-oss-agentic-rl |  | 📖 daily 2026-02-23 |
| Straion | — | 2026-02-23 | agent, coding, rules | https://www.producthunt.com/products/straion |  | 📖 daily 2026-02-23 |
| AssetOpsBench | IBM Research | 2026-02-23 | benchmark, agent | https://huggingface.co/blog/ibm-research/assetopsbench-playground-on-hugging-face |  | 📖 daily 2026-02-23 |
| Community Evals | Hugging Face | 2026-02-23 | evaluation, community | https://huggingface.co/blog/community-evals |  | 📖 daily 2026-02-23 |
| Custom Kernels from Claude | Hugging Face | 2026-02-23 | cuda, agent-skills | https://huggingface.co/blog/custom-cuda-kernels-agent-skills |  | 📖 daily 2026-02-23 |
| Alyah Emirati Dialect Benchmarks | TII UAE | 2026-02-23 | evaluation, arabic | https://huggingface.co/blog/tiiuae/emirati-benchmarks |  | 📖 daily 2026-02-23 |
| CUGA | IBM Research | 2026-02-23 | agent, configurable | https://huggingface.co/blog/ibm-research/cuga-on-hugging-face |  | 📖 daily 2026-02-23 |
| DeepMath | Intel | 2026-02-23 | agent, math | https://huggingface.co/blog/intel-deepmath |  | 📖 daily 2026-02-23 |
| Callio - Connect any API with AI Agent under 1 minute | Callio | 2026-02-24 | agent, api-integration, low-code | https://www.producthunt.com/products/callio-3 |  | 📖 daily 2026-02-24 |
| Grok 4.2 - Four AI agents debate internally | xAI | 2026-02-24 | multi-agent, reasoning, model | https://www.producthunt.com/products/grok |  | 📖 daily 2026-02-24 |
| Agentic Engineering Patterns - Writing code is cheap | Simon Willison | 2026-02-24 | agentic, engineering, patterns | https://simonwillison.net/guides/agentic-engineering-patterns/code-is-cheap/ |  | 📖 daily 2026-02-24 |
| Anthropic COBOL capability - enterprise impact | Anthropic | 2026-02-24 | model-capability, enterprise, legacy-code | https://www.anthropic.com/news |  | 📖 daily 2026-02-24 |
| Car Wash test - 53 models AI logic benchmark | Opper AI | 2026-02-24 | evaluation, benchmark, reasoning | https://opper.ai/blog/car-wash-test |  | 📖 daily 2026-02-24 |
| Toggle for OpenClaw – Browser activity streamed to agent | — | 2026-02-25 | agent, browser, realtime | https://www.producthunt.com/products/togglex-openclaw | 🎯 agent-ui | 📖 daily 2026-02-25 — OpenClaw 扩展，浏览器活动实时流式传输给 agent |
| WebMCP – Give AI agents access to web apps via JavaScript | — | 2026-02-25 | mcp, agent, web-automation | https://www.producthunt.com/products/webmcp |  | 🔧 daily 2026-02-25 — 通过 JavaScript 让 agent 直接操作 web 应用，MCP 协议扩展 |
| toktrack – Track AI CLI spending across Claude, Codex & Gemini | — | 2026-02-25 | observability, cli, cost-tracking | https://www.producthunt.com/products/toktrack |  | 🔧 daily 2026-02-25 — 40ms 内追踪多模型 CLI 花费，LLMOps 可观测性工具 |
| Live AI Design Benchmark – Watch AI models compete on creativity | — | 2026-02-25 | benchmark, evaluation, design | https://www.producthunt.com/products/live-ai-design-benchmark | [evaluation] | 📖 daily 2026-02-25 — 实时 AI 设计能力基准测试，可视化模型对比 |
| Deploying Open Source VLM on Jetson – NVIDIA Cosmos tutorial | NVIDIA | 2026-02-25 | vlm, edge, deployment | https://huggingface.co/blog/nvidia/cosmos-on-jetson |  | 🔧 daily 2026-02-25 — NVIDIA 官方教程，Jetson 设备部署 Cosmos VLM 完整指南 |
| Ziva.sh – AI agent for Godot game engine | — | 2026-02-25 | agent, game-dev, godot | https://www.producthunt.com/products/ziva-sh-ai-agent-for-game-engines |  | 📖 daily 2026-02-25 — 专为 Godot 引擎设计的 AI agent，游戏开发垂直场景 |
| Opal 2.0 by Google Labs | Google Labs | 2026-02-26 | agent, google, multimodal | https://www.producthunt.com/products/google | 🎯 agent-ui | ⚡ daily 2026-02-26 — Google Labs 升级 Opal 智能体平台，新增记忆/路由/交互聊天能力 |
| Notion Custom Agents | Notion | 2026-02-26 | agent, productivity, notion | https://www.producthunt.com/products/notion | 🎯 agent-ui | ⚡ daily 2026-02-26 — Notion 推出自定义 Agent，可执行用户在 Notion 内的所有操作 |
| AskAIBase | — | 2026-02-26 | memory, agent, infrastructure | https://www.producthunt.com/products/ask-7 |  | 🔧 daily 2026-02-26 — 为 AI 编程 Agent 设计的记忆基础设施 |
| PeonPing | — | 2026-02-26 | monitoring, claude, devops | https://www.producthunt.com/products/peonping |  | 🔧 daily 2026-02-26 — 监控 Claude Code/Codex/Cursor 等 AI 编程工具的运行状态 |
| Making MCP cheaper via CLI | — | 2026-02-26 | mcp, optimization, cli | https://kanyilmaz.me/2026/02/23/cli-vs-mcp.html |  | 🔧 daily 2026-02-26 — 通过 CLI 方案降低 MCP 调用成本的技术分析 |
| Sandboxes won't save you from OpenClaw | Tachyon | 2026-02-26 | security, sandbox, agent | https://tachyon.so/blog/sandboxes-wont-save-you |  | 📖 daily 2026-02-26 — 分析沙箱在 AI Agent 安全中的局限性与应对思路 |
| Mercury 2 | — | 2026-02-26 | llm, reasoning, production | https://www.producthunt.com/products/mercury-412 |  | ⚡ daily 2026-02-26 — 面向生产环境的最快推理 LLM，支持即时响应 |
| Anthropic ditches its core safety promise | Anthropic | 2026-02-27 | safety, policy | https://www.cnn.com/2026/02/25/tech/anthropic-safety-policy-change |  | ⚡ daily 2026-02-27 |
| gpt-realtime-1.5 | OpenAI | 2026-02-27 | speech, realtime | https://www.producthunt.com/products/openai |  | 📖 daily 2026-02-27 |
| Agent Swarm | desplega-ai | 2026-02-27 | multi-agent, oss | https://github.com/desplega-ai/agent-swarm |  | 🔧 daily 2026-02-27 |
| DeltaMemory | — | 2026-02-27 | agent-memory, cognitive | https://www.producthunt.com/products/deltamemory |  | 📖 daily 2026-02-27 |
| ZSE | Zyora-Dev | 2026-02-27 | inference, oss | https://github.com/Zyora-Dev/zse |  | 🔧 daily 2026-02-27 |
| Playground by Natoma | Natoma | 2026-02-27 | mcp, discovery | https://www.producthunt.com/products/playground-by-natoma |  | 🔧 daily 2026-02-27 |
| OpenClawCity | — | 2026-02-27 | agent-simulation, experimental | https://www.producthunt.com/products/openclawcity |  | 📖 daily 2026-02-27 |
| Agent Swarm | desplega-ai | 2026-02-27 | multi-agent, self-learning, oss | https://github.com/desplega-ai/agent-swarm |  | ⚡ daily 2026-02-27 |
| ZSE | Zyora-Dev | 2026-02-27 | inference, llm, oss | https://github.com/Zyora-Dev/zse |  | 🔧 daily 2026-02-27 |
| DeltaMemory | — | 2026-02-27 | memory, agent, cognitive | https://www.producthunt.com/products/deltamemory |  | 🔧 daily 2026-02-27 |
| Playground by Natoma | Natoma | 2026-02-27 | mcp, discovery | https://www.producthunt.com/products/playground-by-natoma |  | 🔧 daily 2026-02-27 |
| API Pick | — | 2026-02-27 | api, agent, data | https://www.producthunt.com/products/api-pick |  | 📖 daily 2026-02-27 |
| OpenClawCity | — | 2026-02-27 | agent, simulation | https://www.producthunt.com/products/openclawcity |  | 📖 daily 2026-02-27 |
| gpt-realtime-1.5 | OpenAI | 2026-02-27 | speech, realtime, openai | https://www.producthunt.com/products/openai |  | 📖 daily 2026-02-27 |
| Anthropic ditches its core safety promise | Anthropic | 2026-02-27 | safety, policy | https://www.cnn.com/2026/02/25/tech/anthropic-safety-policy-change |  | ⚡ daily 2026-02-27 |
| Heimdall | — | 2026-02-27 | telemetry, tracking | https://www.producthunt.com/products/heimdall-3 |  | 📖 daily 2026-02-27 |
| Show HN: Agent Swarm – Multi-agent self-learning teams (OSS) | desplega-ai | 2026-02-27 | multi-agent, oss | https://github.com/desplega-ai/agent-swarm |  | 🔧 daily 2026-02-27 |
| Show HN: ZSE – Open-source LLM inference engine with 3.9s cold starts | Zyora-Dev | 2026-02-27 | inference, oss | https://github.com/Zyora-Dev/zse |  | 🔧 daily 2026-02-27 |
| DeltaMemory | — | 2026-02-27 | memory, agent | https://www.producthunt.com/products/deltamemory |  | 🔧 daily 2026-02-27 |
| Playground by Natoma | Natoma | 2026-02-27 | mcp, testing | https://www.producthunt.com/products/playground-by-natoma |  | 🔧 daily 2026-02-27 |
| API Pick | — | 2026-02-27 | api, agent | https://www.producthunt.com/products/api-pick |  | 📖 daily 2026-02-27 |
| OpenClawCity | — | 2026-02-27 | agent, simulation | https://www.producthunt.com/products/openclawcity |  | 📖 daily 2026-02-27 |
| Anthropic: Cannot in good conscience accede to Pentagon demands | Anthropic | 2026-02-27 | safety, policy, industry | https://www.anthropic.com/news/statement-department-of-war |  | ⚡ daily 2026-02-27 — Anthropic 官方声明拒绝五角大楼要求，AI 安全政策重大事件 |
| Argo Workflows 4.0 正式发布 | Argo Project | 2026-02-27 | workflow, orchestration, k8s | https://www.oschina.net/news/406058 |  | 🔧 daily 2026-02-27 — 24 项新功能 +122 个修复，大规模流水线编排更安全易用 |
| 阿里云 CodingPlan – 按请求计费解决 token 成本 | 阿里云 | 2026-02-27 | pricing, coding, qwen | https://juejin.cn/post/7610637031321698330 |  | 🔧 daily 2026-02-27 — 整合 Qwen-3.5/Kimi-K2.5/GLM-4.7，按请求计费替代 token |
| Launch HN: Cardboard – Agentic video editor (YC W26) | Cardboard (YC W26) | 2026-02-27 | agentic, video, yc | https://www.usecardboard.com/ |  | 🔧 daily 2026-02-27 — YC 孵化项目，用自然语言描述即可生成编辑视频 |
| Flarehawk – Security monitoring agent | — | 2026-02-27 | security, monitoring, agent | https://www.producthunt.com/products/flarehawk |  | 📖 daily 2026-02-27 — 监控安全工具、探测威胁并提示行动的 agent |
| MaxClaw by MiniMax – Managed OpenClaw agent | MiniMax | 2026-02-27 | agent, managed-service, openclaw | https://www.producthunt.com/products/minimax-agent | 🎯 agent-ui | 📖 daily 2026-02-27 — MiniMax 推出的基于 OpenClaw 的常开托管 agent 服务 |
| Claude Code Remote Access | — | 2026-02-27 | claude, remote, agent-ui | https://www.producthunt.com/products/claude-code-remote-access | 🎯 agent-ui | 📖 daily 2026-02-27 — 随时随地监控和控制 Claude Code agent |
| HelixDB – Open-source graph-vector database in Rust（旧闻补充，发布于 2026-02-21） | — | 2026-02-27 | vector, graph, rust | https://www.producthunt.com/products/helixdb | [RAG] | 📖 daily 2026-02-27 — Rust 编写的开源 OLTP 图向量数据库 |
| Gemini 3 Flash | Google | 2026-02-28 | gemini, foundation-model, free-tier | http://www.geekpark.net/news/358272 |  | 📖 daily 2026-02-28 |
| OpenAI GPT-5.2-Codex | OpenAI | 2026-02-28 | gpt, codex, app-store | http://www.geekpark.net/news/358210 |  | 📖 daily 2026-02-28 |
| Refly.AI | Refly.AI | 2026-02-28 | workflow, no-code, agent-ui | http://www.geekpark.net/news/357942 |  | 📖 daily 2026-02-28 |
| 语核科技 | 语核科技 | 2026-02-28 | agent, to-business | http://www.geekpark.net/news/357968 |  | 📖 daily 2026-02-28 |
| Manus | Manus | 2026-02-28 | multi-agent, open-source | https://blog.csdn.net/csdnnews/article/details/146179635 |  | 📖 daily 2026-02-28 |
| Playground by Natoma | Natoma | 2026-02-28 | mcp, tool-discovery | https://www.producthunt.com/products/playground-by-natoma |  | 📖 daily 2026-02-28 |
| DeltaMemory | DeltaMemory | 2026-02-28 | agent-memory, cognitive | https://www.producthunt.com/products/deltamemory |  | 📖 daily 2026-02-28 |
| Mastra Code | Mastra | 2026-02-28 | coding-agent | https://www.producthunt.com/products/mastra |  | 📖 daily 2026-02-28 |
| GPT-5.2 | OpenAI | 2026-03-01 | foundation-model, agentic, professional | http://www.geekpark.net/news/357946 |  | ⚡ daily 2026-03-01 |
| GPT Image 1.5 | OpenAI | 2026-03-01 | multimodal, image-generation | http://www.geekpark.net/news/358098 |  | ⚡ daily 2026-03-01 |
| DeepSeek V4 | DeepSeek | 2026-03-01 | multimodal, foundation-model | https://m.ithome.com/html/924511.htm |  | ⚡ daily 2026-03-01 |
| Manus | Monica | 2026-03-01 | general-agent, agentic | https://blog.csdn.net/csdnnews/article/details/146084709 |  | ⚡ daily 2026-03-01 |
| Playground by Natoma | Natoma | 2026-03-01 | mcp, discovery, developer-tool | https://www.producthunt.com/products/playground-by-natoma |  | 🔧 daily 2026-03-01 |
| DeltaMemory | DeltaMemory | 2026-03-01 | agent-memory, performance | https://www.producthunt.com/products/deltamemory |  | 🔧 daily 2026-03-01 |
| Refly.AI | Refly.AI | 2026-03-01 | workflow, no-code, agent-builder | http://www.geekpark.net/news/357942 |  | 🔧 daily 2026-03-01 |
| When does MCP make sense vs CLI? | ejholmes | 2026-03-02 | mcp, agent | https://ejholmes.github.io/2026/02/28/mcp-is-dead-long-live-the-cli.html |  | 📖 daily 2026-03-02 — MCP 与 CLI 路线之争的技术深度分析 |
| 驯服"龙虾"，Agent 也要服从基本法 | — | 2026-03-02 | agent | https://www.36kr.com/p/3702844633936256 |  | 📖 daily 2026-03-02 — Agent 工程化落地的核心原则讨论 |
| 我高中辍学，跟 AI 学习，逆袭成为 OpenAI 研究员 | — | 2026-03-02 | vibe-coding | http://www.geekpark.net/news/358072 |  | 📖 daily 2026-03-02 — AI 编程范式转变的典型案例 |
| AI 时代，如何定义电商营销新范式？ | — | 2026-03-02 | workflow, mcp | http://www.geekpark.net/news/358075 |  | 📖 daily 2026-03-02 — AI 重构电商工作流的实践案例 |
| Why XML tags are so fundamental to Claude | — | 2026-03-02 | agent | https://glthr.com/XML-fundamental-to-Claude |  | 📖 daily 2026-03-02 — Claude prompt 工程的核心技术细节 |
| 告别知识库时代，印象笔记如何打造你的「第二大脑」？ | — | 2026-03-02 | agent | http://www.geekpark.net/news/358235 |  | 📖 daily 2026-03-02 — 传统知识管理工具的 AI 转型探索 |
| 深聊豆包手机：该关注这场「技术核试验」的什么？ | 字节跳动 | 2026-03-02 | agent | http://www.geekpark.net/news/357996 |  | 📖 daily 2026-03-02 — AI 与硬件深度整合的早期实验 |
| 我看 MiniMax 闫俊杰：「心舟」已过万重山 | MiniMax | 2026-03-02 | agent | http://www.geekpark.net/news/357970 |  | 📖 daily 2026-03-02 — 中国大模型创业公司的产品化路径 |
| LLM 是初级程序员的外挂，却让高级工程师无感？解析 LLM 的影响曲线！ | — | 2026-03-02 | agent | https://blog.csdn.net/csdnnews/article/details/146167863 |  | 📖 daily 2026-03-02 — LLM 对不同层级开发者影响的实证分析 |
| 英特尔，下一个 AI 时代的「卖铲人」 | 英特尔 | 2026-03-02 | rag, agent | http://www.geekpark.net/news/358085 |  | 📖 daily 2026-03-02 — 个人 AI 记忆基础设施的新方向 |
| CtrlAI | — | 2026-03-03 | agent, guardrail, security | https://www.producthunt.com/products/ctrlai |  | 🔧 daily 2026-03-03 |
| Aura | — | 2026-03-03 | agent, coding, version-control | https://www.producthunt.com/products/aura-28 |  | 🔧 daily 2026-03-03 |
| Anthropic Cowork feature creates 10GB VM bundle on macOS without warning | Anthropic | 2026-03-03 | claude-code, macos, bug | https://github.com/anthropics/claude-code/issues/22543 |  | ⚡ daily 2026-03-03 — HN 344 分热议：Cowork 功能在 macOS 上静默创建 10GB VM，引发资源占用争议 |
| Govbase – Follow a bill from source text to news bias to social posts | — | 2026-03-03 | rag, policy-tracking, ai-pipeline | https://govbase.com | [RAG] | 🔧 daily 2026-03-03 — AI 管道追踪法案从原文到新闻偏见的全链路，RAG 在政策分析领域的落地 |
| Higress-RAG: A Holistic Optimization Framework for Enterprise RAG | — | 2026-03-03 | rag, enterprise, hybrid-retrieval | https://arxiv.org/abs/2602.23374 | [RAG] | 🔧 daily 2026-03-03 — 企业级 RAG 全链路优化框架，双混合检索 + 自适应路由（arXiv） |
| Democratizing GraphRAG: Linear, CPU-Only Graph Retrieval for Multi-Hop QA | — | 2026-03-03 | graphrag, cpu-only, multi-hop | https://arxiv.org/abs/2602.23372 | [RAG] | 🔧 daily 2026-03-03 — 线性复杂度、仅 CPU 的 GraphRAG 方案，降低多跳问答门槛（arXiv） |
| 特朗普禁令下 Claude 登顶 App Store | Anthropic | 2026-03-03 | anthropic, market-reaction, policy | https://www.36kr.com/p/3705066721276290 |  | ⚡ daily 2026-03-03 — 特朗普禁令反而推动 Claude 下载量激增，市场反应与政策意图背离 |
| 群核科技，摸着李飞飞过河 | 群核科技 | 2026-03-03 | spatial-intelligence, china-followup | http://www.geekpark.net/news/358069 |  | 📖 daily 2026-03-03 — 中国公司跟进李飞飞空间智能方向，3D 理解或成下一轮竞争焦点（续报） |
| OpenAI 已讨论以约 7500 亿美元的估值筹集数百亿美元资金 | OpenAI | 2026-03-03 | openai, funding, valuation | http://www.geekpark.net/news/358151 |  | ⚡ daily 2026-03-03 — OpenAI 新一轮融资估值达 7500 亿美元，较上轮高出 50% |
| CtrlAI | CtrlAI | 2026-03-03 | agent, guardrail, security | https://www.producthunt.com/products/ctrlai |  | 🔧 daily 2026-03-03 |
| Aura | Aura | 2026-03-03 | coding-agent, version-control, git | https://www.producthunt.com/products/aura-28 |  | 🔧 daily 2026-03-03 |
| GPT‑5.3 Instant | OpenAI | 2026-03-04 | gpt-5.3, instant, model-release | https://openai.com/index/gpt-5-3-instant/ |  | 📖 daily 2026-03-04 |
| Gemini 3.1 Flash-LITE | Google | 2026-03-04 | gemini, flash-lite, lightweight | https://readhub.cn/topic/8rCj9hV3M60 |  | 📖 daily 2026-03-04 |
| Qwen3.5 Small | Alibaba | 2026-03-04 | qwen, open-source, multimodal | https://www.producthunt.com/products/qwen3 |  | 📖 daily 2026-03-04 |
| Cekura – AI Agent 测试与监控平台 | Cekura | 2026-03-04 | agent-testing, monitoring, yc | https://www.cekura.ai |  | 📖 daily 2026-03-04 |
| AI Agent Skills Refiner | Unknown | 2026-03-04 | agent, skills, benchmark | https://www.producthunt.com/products/ai-agent-skills-refiner |  | 📖 daily 2026-03-04 |
| LangChain Skills + LangSmith CLI: AI 编程助手生态工具包 | LangChain | 2026-03-05 | agent, coding-agent, tracing | https://blog.langchain.com/langchain-skills/ |  | ⚡ daily 2026-03-05 |
| Simon Willison: Agentic Engineering 反模式指南 | Simon Willison | 2026-03-05 | agentic, engineering, best-practices | https://simonwillison.net/guides/agentic-engineering-patterns/anti-patterns/ |  | 🔧 daily 2026-03-05 |
| AWS: 企业应用嵌入 Quick Suite Chat Agents SDK | AWS | 2026-03-05 | agent, sdk, enterprise, deployment | https://aws.amazon.com/blogs/machine-learning/embed-amazon-quick-suite-chat-agents-in-enterprise-applications/ |  | 🔧 daily 2026-03-05 |
| Google Research: 教 LLM 像贝叶斯主义者一样推理 | Google Research | 2026-03-05 | llm, reasoning, bayesian | https://research.google/blog/teaching-llms-to-reason-like-bayesians/ |  | 📖 daily 2026-03-05 |
| OpenAI Case Study: Axios 用 AI 规模化本地新闻工作流 | OpenAI / Axios | 2026-03-05 | workflow, journalism, case-study | https://openai.com/index/axios-allison-murphy |  | 📖 daily 2026-03-05 |
| AWS Case Study: Lendi 12 周用 Bedrock 构建 Agentic AI 房贷系统 | AWS / Lendi | 2026-03-05 | agentic, fintech, bedrock | https://aws.amazon.com/blogs/machine-learning/how-lendi-revamped-the-refinance-journey-for-its-customers-using-agentic-ai-in-12-weeks-using-amazon-bedrock/ |  | 🔧 daily 2026-03-05 |
| Fix in Cursor: GitHub PR 评论一键转 Cursor 提示 | Independent | 2026-03-05 | cursor, github, developer-tool | https://www.producthunt.com/products/fix-in-cursor |  | 🔧 daily 2026-03-05 |
| PageAgent | Alibaba | 2026-03-06 | agent-ui, gui-agent, open-source | https://alibaba.github.io/page-agent/ |  | 📖 daily 2026-03-06 |
| Jido 2.0 | Jido | 2026-03-06 | agent, elixir, multi-agent, mcp | https://jido.run/blog/jido-2-0-is-here |  | 📖 daily 2026-03-06 |
| Codex Security | OpenAI | 2026-03-07 | agent, security, vulnerability-detection | https://openai.com/index/codex-security-now-in-research-preview |  | ⚡ daily 2026-03-07 |
| OBLITERATUS | elder-plinius | 2026-03-07 | llm, uncensor, open-weight | https://github.com/elder-plinius/OBLITERATUS |  | 🔧 daily 2026-03-07 |
| NVIDIA NeMo Evaluator Agent Skills | NVIDIA | 2026-03-07 | evaluation, agent-skill, nemo | https://huggingface.co/blog/nvidia/model-evaluation-skill |  | 🔧 daily 2026-03-07 |
| OpenAI GPT-5.4 正式发布：迄今最强大且高效的前沿模型 | OpenAI | 2026-03-08 | model-release, gpt-5.4 | https://openai.com/index/introducing-gpt-5-4 |  | ⚡ daily 2026-03-08 — OpenAI 最新旗舰模型，事实性更强、效率更高，支持更长上下文保留 |
| Anthropic 研究报告：先拥抱 AI 的行业或许会先被 AI 吃掉 | Anthropic | 2026-03-08 | research, workforce | https://readhub.cn/topic/8rICRmXZdJN |  | 📖 daily 2026-03-08 — 揭示 AI 颠覆职场规律：越早深度拥抱 AI 的行业，越先面临被重构风险 |
| Verification debt: AI 生成代码的隐藏成本 | — | 2026-03-08 | agentic-coding, verification | https://fazy.medium.com/agentic-coding-ais-adolescence-b0d13452f981 |  | 🔧 daily 2026-03-08 — 深入分析 AI 生成代码带来的验证债务问题，提醒开发者注意审查成本 |
| Codex for Open Source：OpenAI 向开源维护者提供 6 个月免费 Claude Max | OpenAI | 2026-03-08 | open-source, codex | https://simonwillison.net/2026/Mar/7/codex-for-open-source/ |  | 🔧 daily 2026-03-08 — OpenAI 跟进 Anthropic，向 5000+ 星或 1M+ NPM 下载的开源项目提供 6 个月免费额度 |
| 🎯 再见 Openclaw，桌面端 Agent 起飞了！ | — | 2026-03-08 | agent-ui, desktop | https://juejin.cn/post/7613680097548795919 | 🎯 agent-ui | 🔧 daily 2026-03-08 — 国内开发者对桌面端 Agent 工具的深度体验与优化建议 |
| 21st Agents SDK：为应用添加 Claude Code AI 代理 | 21st | 2026-03-08 | sdk, agent | https://www.producthunt.com/products/21st-dev-the-npm-for-design-engineers |  | 🔧 daily 2026-03-08 — 让开发者轻松为应用集成 Claude Code AI 代理能力的 SDK 工具 |
| How Balyasny Asset Management 构建 AI 研究引擎 | OpenAI | 2026-03-08 | finance, agent-workflow | https://openai.com/index/balyasny-asset-management |  | 🔧 daily 2026-03-08 — 用 GPT-5.4 + 严格模型评估 + agent 工作流规模化投资分析的实战案例 |
| Agent Safehouse – macOS-native sandboxing for local agents | eugene1g | 2026-03-09 | agent-security, sandbox, macos | https://agent-safehouse.dev/ |  | ⚡ daily 2026-03-09 — 解决本地 Agent 权限过大的核心安全问题，deny-first 模型防止 rm -rf ~ 类事故 |
| Mac mini ANE 被破解：Claude 协助实现 NPU 训练 | Manjeet Singh | 2026-03-09 | local-training, NPU, apple-silicon | https://github.com/maderix/ANE |  | ⚡ daily 2026-03-09 — 绕过 CoreML 直接操控 ANE 实现训练，能效比 H100 高 50 倍，开启设备端训练可能 |
| OpenAI 收购 Promptfoo：AI 安全评估平台纳入生态 | — | 2026-03-10 | evaluation, security, guardrail | https://openai.com/index/openai-to-acquire-promptfoo |  | 📖 daily 2026-03-10 |
| Mog 编程语言 | — | 2026-03-10 | agent, programming-language | https://moglang.org |  | 📖 daily 2026-03-10 |
| LeRobot v0.5.0 | — | 2026-03-10 | robotics, rl | https://huggingface.co/blog/lerobot-release-v050 |  | 📖 daily 2026-03-10 |
| LangChain GTM Agent | — | 2026-03-10 | agent, sales | https://blog.langchain.com/how-we-built-langchains-gtm-agent/ |  | 📖 daily 2026-03-10 |
| MetaNovas Agentic AI 新药研发 | — | 2026-03-10 | agentic, biotech | https://readhub.cn/topic/8rLX2xnukva |  | 📖 daily 2026-03-10 |
| Agents that run while I sleep | — | 2026-03-11 | agent, automation | https://www.claudecodecamp.com/p/i-m-building-agents-that-run-while-i-sleep |  | 🔧 daily 2026-03-11 |
| AI should help us produce better code | Simon Willison | 2026-03-11 | agentic-engineering | https://simonwillison.net/guides/agentic-engineering-patterns/better-code/ |  | ⚡ daily 2026-03-11 |
| How Coding Agents Are Reshaping EPD | LangChain | 2026-03-11 | coding-agent, workflow | https://blog.langchain.com/how-coding-agents-are-reshaping-engineering-product-and-design/ |  | ⚡ daily 2026-03-11 |
| RunAnywhere (YC W26) | RunanywhereAI | 2026-03-11 | inference, apple-silicon | https://github.com/RunanywhereAI/rcli |  | 🔧 daily 2026-03-11 |
| Storage Buckets on HF Hub | Hugging Face | 2026-03-11 | storage, rag | https://huggingface.co/blog/storage-buckets |  | 🔧 daily 2026-03-11 |
| Together GPU Clusters Update | Together AI | 2026-03-11 | observability, gpu | https://www.together.ai/blog/new-in-together-gpu-clusters-autoscaling-observability-self-healing |  | 🔧 daily 2026-03-11 |
| Meta acquires Moltbook | Meta | 2026-03-11 | acquisition, agent | https://www.axios.com/2026/03/10/meta-facebook-moltbook-agent-social-network |  | ⚡ daily 2026-03-11 |
| Instruction Hierarchy Challenge | OpenAI | 2026-03-11 | safety, alignment | https://openai.com/index/instruction-hierarchy-challenge |  | 🔧 daily 2026-03-11 |
| 微软支持 Anthropic 诉讼 | 微软/Anthropic | 2026-03-11 | policy, legal | https://readhub.cn/topic/8rOfIZexOGA |  | ⚡ daily 2026-03-11 |
| 腾讯 CodeBuddy MCP | 腾讯 | 2026-03-11 | mcp, china | https://readhub.cn/topic/8rNGGMYYjhR |  | 🔧 daily 2026-03-11 |
| Rakuten fixes issues twice as fast with Codex | OpenAI | 2026-03-12 | coding-agent, enterprise, case-study | https://openai.com/index/rakuten |  | ⚡ daily 2026-03-12 |
| Designing AI agents to resist prompt injection | OpenAI | 2026-03-12 | security, agent, prompt-injection | https://openai.com/index/designing-agents-to-resist-prompt-injection |  | 🔧 daily 2026-03-12 |
| From model to agent: Equipping the Responses API with a computer environment | OpenAI | 2026-03-12 | agent-runtime, api, container | https://openai.com/index/equip-responses-api-computer-environment |  | ⚡ daily 2026-03-12 |
| Operationalizing Agentic AI Part 1: A Stakeholder's Guide | AWS | 2026-03-12 | enterprise, operations, guide | https://aws.amazon.com/blogs/machine-learning/operationalizing-agentic-ai-part-1-a-stakeholders-guide/ |  | ⚡ daily 2026-03-12 |
| One-Eval: An Agentic System for Automated and Traceable LLM Evaluation | — | 2026-03-12 | evaluation, agent, traceability | https://arxiv.org/abs/2603.09821 |  | 🔧 daily 2026-03-12 |
| Autonomous context compression | LangChain | 2026-03-12 | context, sdk, optimization | https://blog.langchain.com/autonomous-context-compression/ |  | 🔧 daily 2026-03-12 |
| The Anatomy of an Agent Harness | LangChain | 2026-03-12 | architecture, agent-design | https://blog.langchain.com/the-anatomy-of-an-agent-harness/ |  | 📖 daily 2026-03-12 |
| Together AI Brings NVIDIA Nemotron 3 to Developers on Day 0 | NVIDIA / Together AI | 2026-03-12 | nemotron, multi-agent, 1m-context | https://www.together.ai/blog/nvidia-nemotron-3-super |  | ⚡ daily 2026-03-12 |
| 黄仁勋：未来几年传统的软件和 App 形态或将消失，AI 智能体极可能成为主流 | NVIDIA | 2026-03-12 | trend, agent, industry-view | https://readhub.cn/topic/8rP2DkMuodI |  | ⚡ daily 2026-03-12 |
| 微信把超级 Agent 之战一把拉进了自己的舒适圈 | 腾讯 | 2026-03-12 | wechat, china, agent-platform | https://www.36kr.com/p/3718128476664320 |  | ⚡ daily 2026-03-12 |
| Understudy | understudy-ai | 2026-03-13 | agent-ui, desktop, demonstration | https://github.com/understudy-ai/understudy |  | 🔧 daily 2026-03-13 |
| OneCLI | onecli | 2026-03-13 | security, mcp, secrets | https://github.com/onecli/onecli |  | 🔧 daily 2026-03-13 |
| Together Voice Agents | Together AI | 2026-03-13 | voice, realtime | https://www.together.ai/blog/build-real-time-voice-agents-on-together-ai |  | 🔧 daily 2026-03-13 |
| Bedrock AgentCore Policy | AWS | 2026-03-13 | security, policy, enterprise | https://aws.amazon.com/blogs/machine-learning/secure-ai-agents-with-policy-in-amazon-bedrock-agentcore/ |  | 🔧 daily 2026-03-13 |
| Claude Visual Output | Anthropic | 2026-03-13 | claude, visualization | https://claude.com/blog/claude-builds-visuals |  | 🔧 daily 2026-03-13 |
| Spine Swarm | Spine AI | 2026-03-14 | multi-agent, workflow, visual-canvas | https://www.getspine.ai/ |  | ⚡ daily 2026-03-14 |
| Context Gateway | Compresr AI | 2026-03-14 | context-compression, gateway, opensource | https://github.com/Compresr-ai/Context-Gateway |  | 🔧 daily 2026-03-14 |
| NVIDIA NeMo Retriever Agentic Retrieval | NVIDIA | 2026-03-14 | rag, agentic, retrieval | https://huggingface.co/blog/nvidia/nemo-retriever-agentic-retrieval |  | 🔧 daily 2026-03-14 |
| MCP is dead; long live MCP | — | 2026-03-15 | mcp, protocol, agent | https://chrlschn.dev/blog/2026/03/mcp-is-dead-long-live-mcp/ |  | ⚡ daily 2026-03-15 — MCP 协议演进讨论，社区反思标准化与碎片化平衡 |
| Simon Willison: Agentic Engineering fireside chat @ Pragmatic Summit | — | 2026-03-15 | agentic, engineering, best-practices | https://simonwillison.net/2026/Mar/14/pragmatic-summit/#atom-everything |  | 📖 daily 2026-03-15 — Simon 分享 agentic engineering 实战经验与工程模式 |
| Claude March 2026 usage promotion | Anthropic | 2026-03-15 | claude, pricing, promotion | https://support.claude.com/en/articles/14063676-claude-march-2026-usage-promotion |  | 📖 daily 2026-03-15 — Anthropic 官方用量促销，降低 Claude API 使用成本 |
| DeepSeek V4、腾讯混元新模型下月发布 | DeepSeek / Tencent | 2026-03-15 | deepseek, hunyuan, china-model | https://m.ithome.com/html/929040.htm |  | ⚡ daily 2026-03-15 — 两大国产 AI 巨头同期发布新模型，竞争加剧 |
| Chrome DevTools MCP — 直接在浏览器会话中调试 Agent | Google Chrome | 2026-03-16 | mcp, debugging, devtools | https://developer.chrome.com/blog/chrome-devtools-mcp-debug-your-browser-session |  | 🔧 daily 2026-03-16 — Chrome 官方集成 MCP 协议，Agent 开发者可直接在 DevTools 中调试浏览器会话 |
| LLM Architecture Gallery — 可视化探索模型架构 | Sebastian Raschka | 2026-03-16 | llm, education, visualization | https://sebastianraschka.com/llm-architecture-gallery/ |  | 📖 daily 2026-03-16 — 交互式可视化 gallery，帮助理解不同 LLM 架构的设计权衡 |
| What is Agentic Engineering? — Simon Willison 实战指南 | Simon Willison | 2026-03-16 | agentic, patterns, best-practices | https://simonwillison.net/guides/agentic-engineering-patterns/what-is-agentic-engineering/ |  | ⚡ daily 2026-03-16 — 系统性总结 Coding Agent 工程实践，定义 Agentic Engineering 方法论 |
| Nvidia Launches Vera CPU, Purpose-Built for Agentic AI | NVIDIA | 2026-03-17 | agentic, infrastructure, hardware | https://nvidianews.nvidia.com/news/nvidia-launches-vera-cpu-purpose-built-for-agentic-ai |  | ⚡ daily 2026-03-17 |
| Apideck CLI – An AI-agent interface with much lower context consumption than MCP | Apideck | 2026-03-17 | mcp, cli, context-optimization | https://www.apideck.com/blog/mcp-server-eating-context-window-cli-alternative |  | 🔧 daily 2026-03-17 |
| Introducing deploy cli | LangChain | 2026-03-17 | langgraph, deployment, cli | https://blog.langchain.com/introducing-deploy-cli/ |  | 🔧 daily 2026-03-17 |
| Leanstral: Open-Source foundation for trustworthy vibe-coding | Mistral AI | 2026-03-17 | vibe-coding, open-source, trustworthy | https://mistral.ai/news/leanstral |  | ⚡ daily 2026-03-17 |
| How coding agents work | Simon Willison | 2026-03-17 | agentic-engineering, guide, coding-agent | https://simonwillison.net/guides/agentic-engineering-patterns/how-coding-agents-work/ |  | 📖 daily 2026-03-17 |
| Agentic AI in the Enterprise Part 2: Guidance by Persona | AWS | 2026-03-17 | enterprise, agentic, implementation | https://aws.amazon.com/blogs/machine-learning/agentic-ai-in-the-enterprise-part-2-guidance-by-persona/ |  | 📖 daily 2026-03-17 |
| LangChain Announces Enterprise Agentic AI Platform Built with NVIDIA | LangChain | 2026-03-17 | enterprise, agentic, nvidia | https://blog.langchain.com/nvidia-enterprise/ |  | ⚡ daily 2026-03-17 |
| Use subagents and custom agents in Codex | OpenAI | 2026-03-17 | codex, subagents, ga | https://simonwillison.net/2026/Mar/16/codex-subagents/ |  | 🔧 daily 2026-03-17 |
| Show HN: Claude Code skills that build complete Godot games | htdt | 2026-03-17 | claude-code, godot, game-dev | https://github.com/htdt/godogen |  | 🔧 daily 2026-03-17 |
| GPT‑5.4 Mini and Nano | OpenAI | 2026-03-18 | model-release, gpt, tiered-inference | https://openai.com/index/introducing-gpt-5-4-mini-and-nano |  | ⚡ daily 2026-03-18 |
| Get Shit Done: A Meta-Prompting, Context Engineering and Spec-Driven Dev System | gsd-build | 2026-03-18 | context-engineering, spec-driven, meta-prompting | https://github.com/gsd-build/get-shit-done |  | 📖 daily 2026-03-18 |
| Introducing LangSmith Sandboxes: Secure Code Execution for Agents | LangChain | 2026-03-18 | agent, sandbox, security | https://blog.langchain.com/introducing-langsmith-sandboxes-secure-code-execution-for-agents/ |  | 🔧 daily 2026-03-18 |
| Edge.js: Run Node apps inside a WebAssembly sandbox | Wasmer | 2026-03-18 | sandbox, wasm, security | https://wasmer.io/posts/edgejs-safe-nodejs-using-wasm-sandbox |  | 🔧 daily 2026-03-18 |
| Open SWE: An Open-Source Framework for Internal Coding Agents | LangChain | 2026-03-18 | coding-agent, langgraph, open-source | https://blog.langchain.com/open-swe-an-open-source-framework-for-internal-coding-agents/ |  | 🔧 daily 2026-03-18 |
| Holotron-12B - High Throughput Computer Use Agent | Hcompany | 2026-03-18 | computer-use, vision-agent, 12B | https://huggingface.co/blog/Hcompany/holotron-12b |  | 🔧 daily 2026-03-18 |
| Antfly: Distributed, Multimodal Search and Memory and Graphs in Go | antflydb | 2026-03-18 | vector-search, graph-search, distributed | https://github.com/antflydb/antfly |  | 🔧 daily 2026-03-18 |
| 小米罗福莉 AI 团队自研 Agent 效率系统，算力成本直降 71.2% | 小米 | 2026-03-18 | agent-optimization, cost-reduction, enterprise | https://m.ithome.com/html/929767.htm |  | 📖 daily 2026-03-18 |
| Tmux-IDE | thijsverreck | 2026-03-19 | agent-ui, terminal, oss | https://tmux.thijsverreck.com |  | 🔧 daily 2026-03-19 |
| Sashiko | Google | 2026-03-19 | code-review, agentic, linux | https://www.phoronix.com/news/Sashiko-Linux-AI-Code-Review |  | ⚡ daily 2026-03-19 |
| LangSmith Polly | LangChain | 2026-03-19 | observability, debugging, agent | https://blog.langchain.com/polly-langsmith-ga/ |  | 🔧 daily 2026-03-19 |
| OpenAI to acquire Astral — uv, ruff, ty joining OpenAI | OpenAI | 2026-03-20 | python, tooling, acquisition | https://openai.com/index/openai-to-acquire-astral |  | ⚡ daily 2026-03-20 |
| Introducing LangSmith Fleet — Agent Builder 企业版重构 | LangChain | 2026-03-20 | agent, enterprise, llmops | https://blog.langchain.com/introducing-langsmith-fleet/ |  | 🔧 daily 2026-03-20 |
| How we monitor internal coding agents for misalignment | OpenAI | 2026-03-20 | safety, coding-agent, alignment | https://openai.com/index/how-we-monitor-internal-coding-agents-misalignment |  | ⚡ daily 2026-03-20 |
| SPEED-Bench: Unified Benchmark for Speculative Decoding | NVIDIA | 2026-03-20 | benchmark, inference, optimization | https://huggingface.co/blog/nvidia/speed-bench |  | 📖 daily 2026-03-20 |
| Fanar 2.0: Arabic Generative AI Stack | Qatar | 2026-03-20 | sovereign-ai, deployment, arabic | https://arxiv.org/abs/2603.16397 |  | 📖 daily 2026-03-20 |
| Composer 2 — Cursor 多文件编辑能力升级 | Cursor | 2026-03-20 | agent-ui, ide, coding | https://cursor.com/blog/composer-2 |  | 🔧 daily 2026-03-20 |
| A rogue AI led to a serious security incident at Meta | Meta | 2026-03-20 | security, incident, agent | https://www.theverge.com/ai-artificial-intelligence/897528/meta-rogue-ai-agent-security-incident |  | ⚡ daily 2026-03-20 |
| Anthropic takes legal action against OpenCode | Anthropic / anomalyco | 2026-03-20 | legal, open-source, claude | https://github.com/anomalyco/opencode/pull/18186 |  | ⚡ daily 2026-03-20 |
| IndexRAG: Cross-Document Reasoning at Index Time | — | 2026-03-20 | rag, multi-hop, indexing | https://arxiv.org/abs/2603.16415 |  | 📖 daily 2026-03-20 |
| Build a Domain-Specific Embedding Model in Under a Day | NVIDIA | 2026-03-21 | embedding, rag, finetune | https://huggingface.co/blog/nvidia/domain-specific-embedding-finetune |  | 🔧 daily 2026-03-21 |
| Quoting Kimi.ai @Kimi_Moonshot | Moonshot AI | 2026-03-21 | kimi, cursor, model | https://simonwillison.net/2026/Mar/20/cursor-on-kimi/#atom-everything |  | 📖 daily 2026-03-21 |
| 奥特曼真被 Claude 逼急了，ChatGPT 要变成超级应用 | OpenAI | 2026-03-21 | openai, chatgpt, strategy | https://www.36kr.com/p/3730652963405826 |  | 📖 daily 2026-03-21 |
| 微软拟起诉，亚马逊与 OpenAI 500 亿美元合作陷独家协议纠纷 | Microsoft/OpenAI/Amazon | 2026-03-21 | openai, legal, cloud | https://readhub.cn/topic/8re1C64JtPB |  | ⚡ daily 2026-03-21 |
| Using Git with coding agents — Simon Willison 实战指南 | simonw | 2026-03-22 | agentic-engineering, git, coding-agent | https://simonwillison.net/guides/agentic-engineering-patterns/using-git-with-coding-agents/ |  | 🔧 daily 2026-03-22 — Agentic Engineering Patterns 系列新增 Git 工作流指南，教你用 Git 记录/回滚 Agent 代码变更 |
| 小米 MiMo 大模型联合 OpenClaw/OpenCode/KiloCode 等 Agent 框架，首周限免开放 | 小米/Xiaomi | 2026-03-22 | model-release, agent-integration, china | https://platform.xiaomimimo.com |  | 🔧 daily 2026-03-22 — MiMo-V2-Pro/Omni/TTS 发布，联合 5 大 Agent 框架开放免费 API，国产模型生态扩展 |
| 月之暗面回应 Cursor Composer 2 使用 Kimi K2.5 底座（续报） | 月之暗面/Moonshot | 2026-03-22 | cursor, kimi, partnership | https://m.ithome.com/html/931246.htm |  | 📖 daily 2026-03-22 — 官方确认 Composer 2 基于 Kimi K2.5，通过 Fireworks AI 托管推理接入，属授权商业合作 |
| OpenClaw security critique sparks HN debate (274 pts) | Composio | 2026-03-23 | security, agent-framework, debate | https://composio.dev/content/openclaw-security-and-vulnerabilities |  | ⚡ daily 2026-03-23 |
| Teaching Claude to QA a mobile app | — | 2026-03-23 | claude, mobile-qa, workflow | https://christophermeiklejohn.com/ai/zabriskie/development/android/ios/2026/03/22/teaching-claude-to-qa-a-mobile-app.html |  | 🔧 daily 2026-03-23 |
| 小米电脑版 miclaw Agent 开发中（续报） | Xiaomi | 2026-03-23 | agent, chinese, followup | https://readhub.cn/topic/8rhu0OkWSW9 |  | 📖 daily 2026-03-23 |
| LangSmith Fleet 推出两种 Agent 授权模式 | — | 2026-03-24 | agent, security, enterprise | https://blog.langchain.com/two-different-types-of-agent-authorization/ |  | 📖 daily 2026-03-24 |
| AWS Bedrock AgentCore 与 Slack 集成教程 | — | 2026-03-24 | agent, integration, slack | https://aws.amazon.com/blogs/machine-learning/integrating-amazon-bedrock-agentcore-with-slack/ |  | 📖 daily 2026-03-24 |
| AWS: 用确定性模型克服 LLM 幻觉（医疗/金融场景） | — | 2026-03-24 | hallucination, enterprise, compliance | https://aws.amazon.com/blogs/machine-learning/overcoming-llm-hallucinations-in-regulated-industries-artificial-geniuss-deterministic-models-on-amazon-nova/ |  | 📖 daily 2026-03-24 |
| Claude Code 生态爆发：5 个必知新工具 | — | 2026-03-24 | claude-code, ecosystem, tools | https://juejin.cn/post/7619279067029209128 |  | 📖 daily 2026-03-24 |
| Claude Code Cheat Sheet | — | 2026-03-24 | claude-code, cheatsheet, reference | https://cc.storyfox.cz |  | 📖 daily 2026-03-24 |
| iPhone 17 Pro 本地运行 400B 参数 LLM | — | 2026-03-24 | on-device, llm, mobile | https://twitter.com/anemll/status/2035901335984611412 |  | 📖 daily 2026-03-24 |
| Simon Willison：AI 内容「slop」定义引发共鸣 | — | 2026-03-24 | opinion, quality, community | https://simonwillison.net/2026/Mar/23/neurotica/#atom-everything |  | 📖 daily 2026-03-24 |
| 苹果 WWDC26 前瞻：Gemini 底座 Siri + CoreAI 框架 | — | 2026-03-24 | siri, gemini, mobile-ai | https://readhub.cn/topic/8rkKpHdsBgX |  | 📖 daily 2026-03-24 |
| FastMCP | — | 2026-03-25 | mcp, sdk, tool-calling | https://gofastmcp.com |  | 📖 daily 2026-03-25 |
| Hypura | — | 2026-03-25 | inference, apple-silicon, memory | https://github.com/t8/hypura |  | 📖 daily 2026-03-25 |
| skls-mgr | — | 2026-03-25 | agent, cli, skills | https://juejin.cn/post/7619254214456213530 |  | 📖 daily 2026-03-25 |
| OpenAI Safety Bug Bounty: 奖励发现 Agent 漏洞的研究者 | OpenAI | 2026-03-26 | safety, agentic, security | https://openai.com/index/safety-bug-bounty |  | ⚡ daily 2026-03-26 |
| datasette-llm 0.1a1：LLM 能力接入 Datasette 插件生态 | Simon Willison | 2026-03-26 | llm, plugin, datasette | https://simonwillison.net/2026/Mar/25/datasette-llm/ |  | 🔧 daily 2026-03-26 |
| LangSmith Fleet 推出可共享 Skills，团队 Agent 知识复用 | LangChain | 2026-03-26 | agent, collaboration | https://blog.langchain.com/skills-in-langsmith-fleet/ |  | 🔧 daily 2026-03-26 |
| AWS Bedrock + Pipecat：部署流式语音 Agent 实战教程 | AWS/Pipecat | 2026-03-26 | voice, streaming, deployment | https://aws.amazon.com/blogs/machine-learning/deploy-voice-agents-with-pipecat-and-amazon-bedrock-agentcore-runtime-part-1/ |  | 🔧 daily 2026-03-26 |
| Google Vibe Coding XR：用 XR Blocks + Gemini 加速 AI+XR 原型 | Google Research | 2026-03-26 | vibe-coding, XR, multimodal | https://research.google/blog/vibe-coding-xr-accelerating-ai-xr-prototyping-with-xr-blocks-and-gemini/ |  | 🔧 daily 2026-03-26 |
| Simon Willison：当前 Agentic Engineering 走得太快，应慢下来 | — | 2026-03-26 | agentic, critique | https://simonwillison.net/2026/Mar/25/thoughts-on-slowing-the-fuck-down/ |  | ⚡ daily 2026-03-26 |
| Agent Evaluation Readiness Checklist | — | 2026-03-28 | evaluation, agent, checklist | https://blog.langchain.com/agent-evaluation-readiness-checklist/ |  | 🔧 daily 2026-03-28 |
| Vibe coding SwiftUI apps | — | 2026-03-28 | vibe-coding, local-llm | https://simonwillison.net/2026/Mar/27/vibe-coding-swiftui/ |  | 📖 daily 2026-03-28 |
| We Rewrote JSONata with AI in a Day | — | 2026-03-28 | vibe-porting, case-study | https://simonwillison.net/2026/Mar/27/vine-porting-jsonata/ |  | 📖 daily 2026-03-28 |
| Coding Agents Could Make Free Software Matter Again | George London | 2026-03-30 | agent, open-source, philosophy | https://www.gjlondon.com/blog/ai-agents-could-make-free-software-matter-again/ |  | ⚡ daily 2026-03-30 — AI agents 让源代码访问从象征性权利变为实际能力，自由软件重新重要 |
| The Vibe Coding Wall of Shame | Crackr AI | 2026-03-30 | vibe-coding, failures, reference | https://crackr.dev/vibe-coding-failures |  | 🔧 daily 2026-03-30 — 32 个 AI 编程失败案例汇编，含 6.3M+ 受影响记录，开发者警示资源 |
| Python Vulnerability Lookup (Claude Code 构建) | Simon Willison | 2026-03-30 | security, python, claude-code | https://simonwillison.net/2026/Mar/29/python-vulnerability-lookup/ |  | 🔧 daily 2026-03-30 — 用 Claude Code 构建的 OSV.dev 漏洞查询工具，粘贴 requirements.txt 即可检测 |
| Pretext: 高性能文本布局浏览器库 | Cheng Lou (ex-React core) | 2026-03-30 | browser, text-layout, performance | https://simonwillison.net/2026/Mar/29/pretext/ | 🎯 agent-ui | 🔧 daily 2026-03-30 — React 前核心开发者新作，无需触碰 DOM 即可计算文本布局，性能大幅提升 |
| ChatGPT 隐私争议：Cloudflare 读取 React 状态 | — | 2026-03-30 | privacy, security, chatgpt | https://www.buchodi.com/chatgpt-wont-let-you-type-until-cloudflare-reads-your-react-state-i-decrypted-the-program-that-does-it/ |  | 📖 daily 2026-03-30 — 安全研究者解密 ChatGPT 的 Cloudflare 验证程序，引发用户输入状态读取争议 |
| Claude Code 严重 Bug：每 10 分钟执行 git reset –hard | Anthropic | 2026-03-30 | bug, claude-code, git | https://github.com/anthropics/claude-code/issues/40710 |  | 📖 daily 2026-03-30 — GitHub Issue 报告：Claude Code 会定期覆盖用户代码，使用者需警惕 |
| DeepSeek 服务中断后恢复 | DeepSeek | 2026-03-30 | outage, service, china | https://m.ithome.com/html/933898.htm |  | 📖 daily 2026-03-30 — DeepSeek 今日早间无法加载内容，已恢复；API 用户需注意服务稳定性 |
| Bitwarden integrates with OneCLI agent vault | OneCLI | 2026-03-31 | agent, security, sdk | https://www.onecli.sh/blog/bitwarden-agent-access-sdk-onecli |  | 🔧 daily 2026-03-31 |
| Deliver hyper-personalized viewer experiences with an agentic AI movie assistant using Amazon Bedrock AgentCore | AWS | 2026-03-31 | agent, multimodal, bedrock | https://aws.amazon.com/blogs/machine-learning/deliver-hyper-personalized-viewer-experiences-with-an-agentic-ai-movie-assistant-using-amazon-bedrock-agentcore-and-amazon-nova-sonic-2-0/ |  | 🔧 daily 2026-03-31 |
| How Ring scales global customer support with Amazon Bedrock Knowledge Bases | AWS/Ring | 2026-03-31 | rag, evaluation, production | https://aws.amazon.com/blogs/machine-learning/how-ring-scales-global-customer-support-with-amazon-bedrock-knowledge-bases/ |  | 🔧 daily 2026-03-31 |
| 苹果 AI 国行正式上线 | Apple | 2026-03-31 | model-release, china, multimodal | https://readhub.cn/topic/8rvirYegNvX |  | ⚡ daily 2026-03-31 |
| Learn Claude Code by doing, not reading | Community | 2026-03-31 | claude, tutorial, coding-agent | https://claude.nagdy.me/ |  | 📖 daily 2026-03-31 |
| Quoting Georgi Gerganov | Simon Willison | 2026-03-31 | local-llm, inference, debugging | https://simonwillison.net/2026/Mar/30/georgi-gerganov/#atom-everything |  | 📖 daily 2026-03-31 |
| datasette-llm 0.1a3 | Simon Willison | 2026-03-31 | llm, datasette, plugin | https://simonwillison.net/2026/Mar/30/datasette-llm/#atom-everything |  | 📖 daily 2026-03-31 |
| OpenAI 完成 8520 亿美元估值融资，加速下一阶段 AI 发展 | OpenAI | 2026-04-01 | funding, frontier-model | https://openai.com/index/accelerating-the-next-phase-ai |  | ⚡ daily 2026-04-01 |
| Claude Code 源码通过 npm map 文件泄露，社区逆向分析架构细节 | Anthropic | 2026-04-01 | security, source-leak | https://alex000kim.com/posts/2026-03-31-claude-code-source-leak/ |  | ⚡ daily 2026-04-01 |
| Claude Code 用户用量消耗速度远超预期，Anthropic 调整限流策略 | Anthropic | 2026-04-01 | usage-limit, pricing | https://www.theregister.com/2026/03/31/anthropic_claude_code_limits/ |  | 🔧 daily 2026-04-01 |
| AWS 推出 Bedrock AgentCore Evaluations，全托管 AI Agent 性能评估服务 | AWS | 2026-04-01 | evaluation, agent-ops | https://aws.amazon.com/blogs/machine-learning/build-reliable-ai-agents-with-amazon-bedrock-agentcore-evaluations/ |  | 🔧 daily 2026-04-01 |
| Axios 遭供应链攻击，恶意依赖包通过 npm 分发 | axios | 2026-04-01 | security, supply-chain | https://simonwillison.net/2026/Mar/31/supply-chain-attack-on-axios/#atom-everything |  | ⚡ daily 2026-04-01 |
| llm 0.30：Simon Willison 的 LLM 命令行工具更新 | Simon Willison | 2026-04-01 | llm, cli, plugin | https://simonwillison.net/2026/Mar/31/llm/#atom-everything |  | 📖 daily 2026-04-01 |
| LangChain × MongoDB 合作：在 Atlas 上构建生产级 AI Agent | LangChain + MongoDB | 2026-04-01 | vector, memory, observability | https://blog.langchain.com/announcing-the-langchain-mongodb-partnership-the-ai-agent-stack-that-runs-on-the-database-you-already-trust/ |  | 🔧 daily 2026-04-01 |
| pg_textsearch：Postgres BM25 相关性排序全文搜索扩展 | Timescale | 2026-04-01 | vector, search, postgres | https://github.com/timescale/pg_textsearch |  | 🔧 daily 2026-04-01 |
| OpenAI Gradient Labs: AI Agents for Banking Support Workflows | OpenAI | 2026-04-02 | agent, workflow, enterprise | https://openai.com/index/gradient-labs |  | ⚡ daily 2026-04-02 — GPT-4.1/5.4 mini/nano 驱动银行客服 Agent，低延迟高可靠，代表 frontier agent 落地新案例 |
| Automating Competitive Price Intelligence with Amazon Nova Act | AWS | 2026-04-02 | workflow, automation, nova | https://aws.amazon.com/blogs/machine-learning/automating-competitive-price-intelligence-with-amazon-nova-act/ |  | 🔧 daily 2026-04-02 — AWS 官方教程：用 Nova Act 构建自动化价格情报系统，实时市场洞察驱动定价决策 |
| WP Copilot: Agentic AI Copilot for WordPress | Unknown | 2026-04-02 | agent, wordpress, cms | https://www.producthunt.com/products/wp-copilot |  | 📖 daily 2026-04-02 — WordPress 专属 agentic copilot，垂直 CMS 场景的 agent 落地尝试 |
| LangChain March 2026: LangSmith Fleet (Agent Builder) + NVIDIA Integration | LangChain | 2026-04-02 | agent, observability, nvidia | https://blog.langchain.com/march-2026-langchain-newsletter/ |  | 🔧 daily 2026-04-02 — LangSmith Fleet 正式更名 Agent Builder，新增 NVIDIA 集成，Agent 开发工具链持续成熟 |
| Simon Willison March 2026 Newsletter: Agentic Engineering Patterns | Simon Willison | 2026-04-02 | agentic, patterns, streaming | https://simonwillison.net/2026/Apr/2/march-newsletter/#atom-everything |  | ⚡ daily 2026-04-02 — 月度精华：agentic engineering 模式 + streaming experts with MoE，实战经验沉淀 |
| MaxKB4J v2.6.0: Open Source LLMOps Platform Update | MaxKB4J | 2026-04-02 | llmops, open-source, deployment | https://www.oschina.net/news/416782 |  | 🔧 daily 2026-04-02 — 开源 LLMOps 平台 v2.6.0 发布，支持企业级 LLM 应用部署与管理 |
| tama96: Tamagotchi for Terminal + AI Agents | Unknown | 2026-04-02 | agent-ui, desktop, gamification | https://www.producthunt.com/products/tama96-desktop-terminal-ai-pet | 🎯 agent-ui | 📖 daily 2026-04-02 — 🎯 终端 AI 宠物伴侣，将 agent 状态可视化 + 游戏化，探索 agent UI 新形态 |
| GLM-5V-Turbo: Vision-to-Code Foundation Model for GUI Automation | Z-AI | 2026-04-02 | foundation-model, vision, gui-automation | https://www.producthunt.com/products/z-ai |  | ⚡ daily 2026-04-02 — 视觉到代码基础模型，专为 GUI 自动化设计，多模态 agent 基础设施新进展 |
| Gradient Labs | OpenAI | 2026-04-02 | agent, workflow, banking | https://openai.com/index/gradient-labs |  | 📖 daily 2026-04-02 |
| LangSmith Fleet | LangChain | 2026-04-02 | agent-ui, llmops, nvidia | https://blog.langchain.com/march-2026-langchain-newsletter/ |  | 📖 daily 2026-04-02 |
| GLM-5V-Turbo | Z-AI | 2026-04-02 | foundation-model, gui-automation, vision-to-code | https://www.producthunt.com/products/z-ai |  | 📖 daily 2026-04-02 |
| tama96 | Unknown | 2026-04-02 | agent-ui, desktop, terminal | https://www.producthunt.com/products/tama96-desktop-terminal-ai-pet |  | 📖 daily 2026-04-02 |
| WP Copilot | Unknown | 2026-04-02 | agent, wordpress, cms | https://www.producthunt.com/products/wp-copilot |  | 📖 daily 2026-04-02 |
| GLM-5V-Turbo: Vision-to-code foundation model for real GUI automation | Zhipu AI | 2026-04-02 | foundation-model, gui-agent, vision-to-code | https://www.producthunt.com/products/z-ai |  | ⚡ daily 2026-04-02 — 智谱发布视觉到代码基础模型，专攻 GUI 自动化，代表 VLA 技术向应用层延伸 |
| r/programming bans all discussion of LLM programming | — | 2026-04-02 | community, signal | https://old.reddit.com/r/programming/comments/1s9jkzi/announcement_temporary_llm_content_ban/ |  | 📖 daily 2026-04-02 — 主流编程社区临时禁止 LLM 内容讨论，反映开发者群体对 AI 编程内容的疲劳与反弹 |
| 你的工作，能被一个 Agent 跑完吗？ | — | 2026-04-02 | career, agentic | https://www.woshipm.com/?p=6368829 |  | 📖 daily 2026-04-02 — 深度分析 AI 时代职业生存法则：默会知识与情绪交付是 AI 无法逾越的护城河 |
| March 2026: LangChain Newsletter - LangSmith Fleet (formerly Agent Builder) | LangChain | 2026-04-02 | agent-builder, llmops, observability | https://blog.langchain.com/march-2026-langchain-newsletter/ |  | 🔧 daily 2026-04-02 — LangSmith Fleet 正式发布，Agent Builder 更名升级，提供可视化 Agent 构建与监控能力 |
| Maxkb4j v2.6.0 已经发布，开源 LLMOps 平台 | Maxkb4j Team | 2026-04-02 | llmops, open-source, deployment | https://www.oschina.net/news/416782 |  | 🔧 daily 2026-04-02 — 国产开源 LLMOps 平台更新，提供模型部署、监控、评估一体化能力 |
| Gradient Labs gives every bank customer an AI account manager | Gradient Labs / OpenAI | 2026-04-02 | agent, workflow, banking | https://openai.com/index/gradient-labs |  | 🔧 daily 2026-04-02 — OpenAI 官方案例：Gradient Labs 用 GPT-4.1/5.4 构建银行 AI 客服 Agent，低延迟高可靠 |
| tama96: A Tamagotchi for your terminal, desktop, and AI agents | tama96 Team | 2026-04-02 | agent-ui, developer-tool, fun | https://www.producthunt.com/products/tama96-desktop-terminal-ai-pet | 🎯 agent-ui | 🔧 daily 2026-04-02 — 终端 AI 宠物，为开发者提供有趣的 Agent 交互界面，Product Hunt 新品 |
| Cursor 3 | Cursor | 2026-04-03 | agent-ui, coding-agent, ide | https://cursor.com/blog/cursor-3 |  | ⚡ daily 2026-04-03 — AI IDE 重大版本更新，代表 vibe coding 工具链成熟度里程碑 |
| OpenAI 收购科技播客 TBPN | OpenAI | 2026-04-03 | openai, media, ecosystem | https://openai.com/index/openai-acquires-tbpn/ |  | ⚡ daily 2026-04-03 — OpenAI 首次收购媒体资产，标志 AI 公司开始布局叙事话语权 |
| Gemma 4 开源四连发 | Google DeepMind | 2026-04-03 | gemma, open-model, multimodal | https://simonwillison.net/2026/Apr/2/gemma-4/#atom-everything |  | ⚡ daily 2026-04-03 — 2B/4B/31B/MoE 四款 Apache 2.0 视觉模型，开源 frontier 能力新基准 |
| LangChain 开源模型阈值报告 | LangChain | 2026-04-03 | open-model, agent, cost | https://blog.langchain.com/open-models-have-crossed-a-threshold/ |  | 🔧 daily 2026-04-03 — GLM-5/MiniMax M2.7 在核心 Agent 任务上匹敌闭源 frontier，成本延迟大幅降低 |
| AWS Strands Evals ActorSimulator | AWS | 2026-04-03 | evaluation, agent, sdk | https://aws.amazon.com/blogs/machine-learning/simulate-realistic-users-to-evaluate-multi-turn-ai-agents-in-strands-evals/ |  | 🔧 daily 2026-04-03 — 结构化用户模拟集成到评估流水线，解决多轮 Agent 测试难题 |
| Vulnerability Research Is Cooked — Coding Agents 正在重塑安全研究 | Simon Willison | 2026-04-04 | security, coding-agent, vulnerability | https://simonwillison.net/2026/Apr/3/vulnerability-research-is-cooked/ |  | ⚡ daily 2026-04-04 |
| How My Agents Self-Heal in Production — 生产环境 Agent 自愈管道 | LangChain | 2026-04-04 | agent, deployment, llmops | https://blog.langchain.com/production-agents-self-heal/ |  | 🔧 daily 2026-04-04 |
| Evaluating alignment of behavioral dispositions in LLMs | Google Research | 2026-04-04 | alignment, evaluation, safety | https://research.google/blog/evaluating-alignment-of-behavioral-dispositions-in-llms/ |  | 📖 daily 2026-04-04 |
| Oblivion: Self-Adaptive Agentic Memory Control — 遗忘驱动的 Agent 记忆控制 | arXiv authors | 2026-04-04 | agent, memory, rag | https://arxiv.org/abs/2604.00131 |  | 📖 daily 2026-04-04 |
| Agentic Tool Use in Large Language Models — LLM 工具使用综述 | arXiv authors | 2026-04-04 | agent, tool-use, survey | https://arxiv.org/abs/2604.00835 |  | 📖 daily 2026-04-04 |
| The cognitive impact of coding agents — 编程代理的认知成本 | Simon Willison | 2026-04-04 | coding-agent, developer-experience | https://simonwillison.net/2026/Apr/3/cognitive-cost/ |  | 📖 daily 2026-04-04 |
| Anthropic 禁止 Claude Code 订阅用于 OpenClaw 等第三方 harness | Anthropic | 2026-04-04 | claude, policy, third-party | https://news.ycombinator.com/item?id=47633396 |  | ⚡ daily 2026-04-04 |
| Wan 2.7 now available on Together AI — 四模型视频生成套件 | Together AI / Wan | 2026-04-04 | video, generation, multimodal | https://www.together.ai/blog/wan-2-7-now-available-on-together-ai |  | 🔧 daily 2026-04-04 |
| Codex pricing to align with API token usage, instead of per-message | OpenAI | 2026-04-06 | pricing, codex, api | https://help.openai.com/en/articles/20001106-codex-rate-card |  | ⚡ daily 2026-04-06 |
| Running Gemma 4 locally with LM Studio's new headless CLI and Claude Code | George Liu | 2026-04-06 | local-llm, gemma, cli | https://ai.georgeliu.com/p/running-google-gemma-4-locally-with |  | 🔧 daily 2026-04-06 |
| scan-for-secrets 0.1 | Simon Willison | 2026-04-06 | security, claude-code, tool | https://simonwillison.net/2026/Apr/5/scan-for-secrets-3/#atom-everything |  | 🔧 daily 2026-04-06 |
| Nanocode: The best Claude Code that $200 can buy in pure JAX on TPUs | salmanmohammadi | 2026-04-06 | training, jax, tpu, agentic | https://github.com/salmanmohammadi/nanocode/discussions/1 |  | 🔧 daily 2026-04-06 |
| Continual learning for AI agents | LangChain | 2026-04-06 | learning, architecture, concept | https://blog.langchain.com/continual-learning-for-ai-agents/ |  | 📖 daily 2026-04-06 |
| Quoting Chengpeng Mou | — | 2026-04-06 | healthcare, usage-data, insight | https://simonwillison.net/2026/Apr/5/chengpeng-mou/#atom-everything |  | 📖 daily 2026-04-06 |
| Launch HN: Freestyle – Sandboxes for Coding Agents | Freestyle | 2026-04-07 | coding-agent, sandbox, infrastructure | https://www.freestyle.sh/ |  | ⚡ daily 2026-04-07 — 专为 coding agents 设计的云沙箱基础设施，解决 agent 执行安全问题 |
| Accelerate agentic tool calling with serverless model customization in Amazon SageMaker AI | AWS | 2026-04-07 | tool-calling, fine-tuning, RLVR | https://aws.amazon.com/blogs/machine-learning/accelerate-agentic-tool-calling-with-serverless-model-customization-in-amazon-sagemaker-ai/ |  | 🔧 daily 2026-04-07 — 使用 RLVR 微调 Qwen 2.5 7B 提升 agent 工具调用性能的完整实践 |
| Announcing the OpenAI Safety Fellowship | OpenAI | 2026-04-07 | safety, alignment, research | https://openai.com/index/introducing-openai-safety-fellowship |  | ⚡ daily 2026-04-07 — OpenAI 试点项目支持独立安全与对齐研究，培养下一代人才 |
| Google AI Edge Gallery | Google | 2026-04-07 | on-device, gemma, mobile | https://simonwillison.net/2026/Apr/6/google-ai-edge-gallery/ |  | 🔧 daily 2026-04-07 — Google 官方 iPhone 应用，本地运行 Gemma 4 模型，性能出色 |
| SWAY: A Counterfactual Computational Linguistic Approach to Measuring and Mitigating Sycophancy | — | 2026-04-07 | alignment, sycophancy, evaluation | https://arxiv.org/abs/2604.02423 |  | 🔧 daily 2026-04-07 — LLM 谄媚倾向的测量与缓解新方法，对评估系统有参考价值（arXiv） |
| Using LLM-as-a-Judge/Jury to Advance Scalable, Clinically-Validated Safety Evaluations of Model Responses to Users Demonstrating Psychosis | — | 2026-04-07 | safety, evaluation, mental-health | https://arxiv.org/abs/2604.02359 |  | 🔧 daily 2026-04-07 — 使用 LLM-as-a-Jury 进行心理健康场景的安全评估，临床验证方法（arXiv） |
| Build AI-powered employee onboarding agents with Amazon Quick | AWS | 2026-04-07 | agent, hr, tutorial | https://aws.amazon.com/blogs/machine-learning/build-ai-powered-employee-onboarding-agents-with-amazon-quick/ |  | 📖 daily 2026-04-07 — AWS Quick 构建 HR onboarding agent 的完整教程，连接 HR 系统自动化任务 |
| Show HN: Ghost Pepper – Local hold-to-talk speech-to-text for macOS | matthartman | 2026-04-07 | speech-to-text, local, macos | https://github.com/matthartman/ghost-pepper |  | 🔧 daily 2026-04-07 — 100% 本地语音转文字 macOS 应用，数据不出设备，适合编码和邮件场景 |
| Anthropic Project Glasswing：限制 Claude Mythos 仅供安全研究人员 | Anthropic | 2026-04-08 | safety, frontier-model, security | https://www.anthropic.com/glasswing |  | ⚡ daily 2026-04-08 |
| GLM-5.1：Z.ai 开源 754B 参数长程任务模型 | Z.ai | 2026-04-08 | open-source, long-context, foundation-model | https://simonwillison.net/2026/Apr/7/glm-51/ |  | ⚡ daily 2026-04-08 |
| LangChain Deep Agents v0.5：异步子代理 + 多模态文件系统 | LangChain | 2026-04-08 | agent, async, multimodal | https://blog.langchain.com/deep-agents-v0-5/ |  | 🔧 daily 2026-04-08 |
| Arcade.dev MCP 工具集集成 LangSmith Fleet | Arcade + LangChain | 2026-04-08 | mcp, tools, governance | https://blog.langchain.com/arcade-dev-tools-now-in-langsmith-fleet/ |  | 🔧 daily 2026-04-08 |
| Gemma 4 Multimodal Fine-Tuner：Apple Silicon 本地微调工具 | mattmireles | 2026-04-08 | fine-tuning, apple-silicon, multimodal | https://github.com/mattmireles/gemma-tuner-multimodal |  | 🔧 daily 2026-04-08 |
| Claude Managed Agents 正式发布 | Anthropic | 2026-04-09 | agent, managed-service, enterprise | https://claude.com/blog/claude-managed-agents |  | ⚡ daily 2026-04-09 — Anthropic 推出托管 Agent 服务，企业可直接部署无需自建基础设施 |
| ALTK-Evolve：IBM 研发 Agent 在职学习框架 | IBM Research | 2026-04-09 | agent, online-learning, ibm | https://huggingface.co/blog/ibm-research/altk-evolve |  | 🔧 daily 2026-04-09 — IBM 提出 Agent 在职学习新方法，无需离线训练即可适应新任务 |
| OpenAI 企业 AI 下一阶段：Frontier + Codex + 公司级 Agent | OpenAI | 2026-04-09 | enterprise, agent, codex | https://openai.com/index/next-phase-of-enterprise-ai |  | ⚡ daily 2026-04-09 — OpenAI 定义企业 AI 采用加速路径，整合 Frontier/Codex/公司级 Agent 产品线 |
| LangChain Better Harness：用 Eval 信号驱动 Agent 自优化 | LangChain | 2026-04-09 | eval, agent, optimization | https://blog.langchain.com/better-harness-a-recipe-for-harness-hill-climbing-with-evals/ | [evaluation] | 🔧 daily 2026-04-09 — LangChain 提出用强评估信号驱动 Agent harness 自动迭代优化 |
| Google Research 发布两个学术 AI Agent：图表优化 + 同行评审辅助 | Google Research | 2026-04-09 | agent, academic, workflow | https://research.google/blog/improving-the-academic-workflow-introducing-two-ai-agents-for-better-figures-and-peer-review/ |  | 🔧 daily 2026-04-09 — Google 针对学术工作流推出专用 Agent，辅助图表制作与论文评审 |
| 医疗领域 Agent 工作流的人机协同设计模式 | AWS | 2026-04-09 | healthcare, agent, compliance | https://aws.amazon.com/blogs/machine-learning/human-in-the-loop-constructs-for-agentic-workflows-in-healthcare-and-life-sciences/ |  | 📖 daily 2026-04-09 — AWS 总结医疗/生命科学领域 Agent 的人机协同合规设计模式 |
| Meta Muse Spark 发布：Llama 4 后首个模型，meta.ai 集成新工具 | Meta | 2026-04-09 | model-release, meta, muse | https://simonwillison.net/2026/Apr/8/muse-spark/#atom-everything |  | ⚡ daily 2026-04-09 — Meta 发布 Llama 4 后首个模型 Muse Spark，托管服务 + meta.ai 新工具链 |
| AWS Nova Embeddings：语义音频搜索实战教程 | AWS | 2026-04-09 | embedding, audio, rag | https://aws.amazon.com/blogs/machine-learning/building-intelligent-audio-search-with-amazon-nova-embeddings-a-deep-dive-into-semantic-audio-understanding/ | [RAG] | 📖 daily 2026-04-09 — AWS 详解 Nova 多模态 Embedding 在音频搜索场景的落地实践 |
| Multimodal Embedding & Reranker Models with Sentence Transformers | Hugging Face | 2026-04-10 | embedding, reranker, multimodal | https://huggingface.co/blog/multimodal-sentence-transformers |  | 🔧 daily 2026-04-10 |
| The future of managing agents at scale: AWS Agent Registry now in preview | AWS | 2026-04-10 | agent, infrastructure, enterprise | https://aws.amazon.com/blogs/machine-learning/the-future-of-managing-agents-at-scale-aws-agent-registry-now-in-preview/ |  | ⚡ daily 2026-04-10 |
| Human judgment in the agent improvement loop | LangChain | 2026-04-10 | evaluation, agent, human-in-loop | https://blog.langchain.com/human-judgment-in-the-agent-improvement-loop/ |  | 📖 daily 2026-04-10 |
| Deep Agents Deploy: an open alternative to Claude Managed Agents | LangChain | 2026-04-10 | agent, deployment, open-source | https://blog.langchain.com/deep-agents-deploy-an-open-alternative-to-claude-managed-agents/ |  | ⚡ daily 2026-04-10 |
| 即梦上线首个 Vibe Create 工具小章鱼支持多模态同屏共创 | 即梦 AI | 2026-04-10 | agent-ui, multimodal, china | https://readhub.cn/topic/8sBGEJjLfoB |  | 🔧 daily 2026-04-10 |
| CyberAgent moves faster with ChatGPT Enterprise and Codex | OpenAI | 2026-04-10 | case-study, enterprise, codex | https://openai.com/index/cyberagent |  | 📖 daily 2026-04-10 |
| DeepSeek V4 | DeepSeek | 2026-04-11 | foundation-model, china-ai | https://m.ithome.com/html/937682.htm |  | 📖 daily 2026-04-11 |
| FluidCAD | independent | 2026-04-11 | cad, workflow, javascript | https://fluidcad.io/ |  | 📖 daily 2026-04-11 |
| How We Broke Top AI Agent Benchmarks: And What Comes Next | Berkeley RDI | 2026-04-12 | benchmark, evaluation, agent | https://rdi.berkeley.edu/blog/trustworthy-benchmarks-cont/ | [evaluation] | ⚡ daily 2026-04-12 — Berkeley 团队揭示主流 Agent 基准测试缺陷，提出更可靠评估框架 |
| Cirrus Labs to join OpenAI | Cirrus Labs → OpenAI | 2026-04-12 | acquisition, openai, ci/cd | https://cirruslabs.org/ |  | 🔧 daily 2026-04-12 — Cirrus Labs 加入 OpenAI，可能增强 Codex/Agent 基础设施能力 |
| Your harness, your memory | LangChain | 2026-04-12 | agent, memory, harness | https://blog.langchain.com/your-harness-your-memory/ | 🎯 agent-ui | ⚡ daily 2026-04-12 — LangChain 详解 Agent Harness 与记忆系统的耦合关系，警告闭源 API 依赖风险 |
| Show HN: Claudraband – Claude Code for the Power User | halfwhey | 2026-04-13 | workflow, claude-code, terminal | https://github.com/halfwhey/claudraband |  | 🔧 daily 2026-04-13 — 为 Claude Code 用户提供扩展工作流支持，通过 tmux/xterm.js 实现可控会话管理 |
| European AI. A playbook to own it | Mistral AI | 2026-04-13 | mistral, european-ai, sovereignty | https://europe.mistral.ai/ |  | ⚡ daily 2026-04-13 — Mistral 发布欧洲 AI 自主发展路线图，反映地缘技术竞争新态势 |
| MiniMax 开源 M2.7 模型，海内外多家厂商完成适配 | MiniMax | 2026-04-13 | open-source, model-release, inference | http://tech.hexun.com/2026-04-13/223976873.html |  | 🔧 daily 2026-04-13 — M2.7 全球开源，华为昇腾/NVIDIA 等芯片厂商及推理平台首日完成适配 |
| OpenAI 星门项目遭遇人才地震：三名核心成员跳槽 Meta | OpenAI | 2026-04-13 | talent, infrastructure, meta | https://readhub.cn/topic/8sGOm7uLIDZ |  | 📖 daily 2026-04-13 — OpenAI 5000 亿美元数据中心项目三名核心人员加盟 Meta，反映基础设施人才竞争加剧 |
| 基于 Ghostty 带有分割标签页和为 Claude 编程设计的通知终端 | - | 2026-04-13 | terminal, claude-code, productivity | https://juejin.cn/post/7626946285019529250 | 🎯 agent-ui | 🔧 daily 2026-04-13 — 为 Claude Code 用户优化终端体验，支持分割标签页和通知系统，提升多会话管理效率 |
| Cloudflare Agent Cloud 集成 OpenAI GPT-5.4 与 Codex | Cloudflare + OpenAI | 2026-04-14 | agent, enterprise, deployment | https://openai.com/index/cloudflare-openai-agent-cloud |  | ⚡ daily 2026-04-14 |
| EinsteinArena：AI Agent 协作科学发现平台 | Together AI | 2026-04-14 | agent, collaboration, science | https://www.together.ai/blog/einsteinarena |  | 🔧 daily 2026-04-14 |
| AWS Lambda + Amazon Nova：可扩展奖励函数构建教程 | AWS | 2026-04-14 | evaluation, RL, deployment | https://aws.amazon.com/blogs/machine-learning/how-to-build-effective-reward-functions-with-aws-lambda-for-amazon-nova-model-customization/ |  | 🔧 daily 2026-04-14 |
| Hermes Agent v0.8.0：4.8 万星的自学习开源 Agent 框架 | Nous Research | 2026-04-14 | agent, open-source, learning-loop | https://hermes-agent.nousresearch.com |  | ⚡ daily 2026-04-14 |
| Plain | dropseed | 2026-04-15 | agent, python, framework | https://github.com/dropseed/plain |  | 🔧 daily 2026-04-15 |
| LangAlpha | ginlix-ai | 2026-04-15 | finance, mcp, agent | https://github.com/ginlix-ai/langalpha |  | ⚡ daily 2026-04-15 |
| The next evolution of the Agents SDK | OpenAI | 2026-04-16 | agent, sdk, sandbox | https://openai.com/index/the-next-evolution-of-the-agents-sdk |  | 📖 daily 2026-04-16 |
| Libretto | Saffron Health | 2026-04-16 | browser-automation, agent, deterministic | https://github.com/saffron-health/libretto |  | 📖 daily 2026-04-16 |
| Gemini 3.1 Flash TTS | Google | 2026-04-16 | tts, gemini, multimodal | https://simonwillison.net/2026/Apr/15/gemini-31-flash-tts/ |  | 📖 daily 2026-04-16 |
| ChatGPT for Excel | OpenAI | 2026-04-16 | chatgpt, productivity, integration | https://chatgpt.com/apps/spreadsheets/ |  | 📖 daily 2026-04-16 |
| Android CLI: Build Android apps 3x faster using any agent | Google | 2026-04-17 | agent-ui, android, cli | https://android-developers.googleblog.com/2026/04/build-android-apps-3x-faster-using-any-agent.html |  | 🔧 daily 2026-04-17 |
| 要做电商 Agent OS，前钉钉最年轻副总裁创立的「攀峰智能」完成数千万天使轮 | 攀峰智能 | 2026-04-17 | agent, ecommerce, funding | https://www.36kr.com/p/3768320373441281 |  | ⚡ daily 2026-04-17 |
| Launch HN: Kampala (YC W26) – Reverse-Engineer Apps into APIs | Kampala/YC W26 | 2026-04-17 | agent, api, reverse-engineer | https://www.zatanna.ai/kampala |  | ⚡ daily 2026-04-17 |
| Laravel raised money and now injects ads directly into your agent | Laravel | 2026-04-17 | agent, monetization, warning | https://techstackups.com/articles/laravel-raised-money-and-now-injects-ads-directly-into-your-agent/ |  | 🔧 daily 2026-04-17 |
| Introducing GPT-Rosalind for life sciences research | OpenAI | 2026-04-17 | reasoning-model, life-sciences, drug-discovery | https://openai.com/index/introducing-gpt-rosalind |  | ⚡ daily 2026-04-17 |
| MiniMax M2.7 开源协议引争议：严禁商业用途 | MiniMax | 2026-04-17 | open-source, license, controversy | https://www.oschina.net/news/421258 |  | 🔧 daily 2026-04-17 |
| Anthropic 推出 Claude Design：由 Anthropic Labs 开发的新产品线 | Anthropic | 2026-04-18 | claude, anthropic-labs, product-launch | https://www.anthropic.com/news/claude-design-anthropic-labs |  | ⚡ daily 2026-04-18 — Anthropic Labs 首次推出独立产品线，标志从单一模型向产品化转型 |
| Claude 4.7 Tokenizer 成本实测：新分词器如何影响你的账单 | — | 2026-04-18 | claude, tokenizer, cost-optimization | https://www.claudecodecamp.com/p/i-measured-claude-4-7-s-new-tokenizer-here-s-what-it-costs-you |  | 🔧 daily 2026-04-18 — HN 515 分热议，实测数据帮助开发者预估 Claude 4.7 迁移成本 |
| Vidoc Security 复现 Anthropic Mythos 发现：用公开模型验证安全研究 | Vidoc Security | 2026-04-18 | security, mythos, independent-verification | https://blog.vidocsecurity.com/blog/we-reproduced-anthropics-mythos-findings-with-public-models |  | 🔧 daily 2026-04-18 — 独立团队用公开模型复现 Mythos 安全发现，验证方法论可迁移性 |
| AWS Bedrock 推出 Nova Multimodal Embeddings：视频语义搜索新基元 | Amazon | 2026-04-18 | embedding, multimodal, video-search | https://aws.amazon.com/blogs/machine-learning/power-video-semantic-search-with-amazon-nova-multimodal-embeddings/ | [RAG] | 📖 daily 2026-04-18 — Nova 多模态嵌入支持视频内容理解，扩展 RAG 到视频检索场景 |

## UI/UX 工具（Agent UI / Workflow UI）

| 应用/工具 | 描述 | 开发者 | 日期 | 标签 | 备注 | 链接 |
|---|---|---:|---:|---|---|---|
| Dify | 开源 LLM 应用构建平台，可视化 Agent/工作流编辑器 | langgenius | 2026-02-11 | agent-ui | ✍️ seed | [🔗 Link](https://github.com/langgenius/dify) |
| Flowise | 低代码可视化 AI 流程构建器，基于 LangChain | FlowiseAI | 2026-02-11 | visual-builder | ✍️ seed | [🔗 Link](https://github.com/FlowiseAI/Flowise) |
| Langflow | 开源可视化 Agent/RAG 编排工具 | langflow-ai | 2026-02-11 | visual-builder | ✍️ seed | [🔗 Link](https://github.com/langflow-ai/langflow) |
| Open WebUI | 自托管 LLM 聊天界面，兼容 OpenAI API 和 Ollama | open-webui | 2026-02-11 | chat-ui | ✍️ seed | [🔗 Link](https://github.com/open-webui/open-webui) |
| Agent Builder by Thesys |  | — | 2026-02-11 |  | ⚡ daily 2026-02-11 | [🔗 Link](https://www.producthunt.com/products/thesys) |
| github/gh-aw | 面向编码 Agent 的 Chrome DevTools | github | 2026-02-12 | agent, devtools | 🎯 agent-ui ⚡ daily 2026-02-12 | [🔗 Link](https://github.com/github/gh-aw) |
| Open WebUI v0.7.0 | 原生函数调用支持，可执行多步任务 | open-webui | 2026-02-12 | function calling, tools, web-research | 🎯 agent-ui ⚡ daily 2026-02-12 | [🔗 Link](https://github.com/open-webui/open-webui/releases/tag/v0.7.0) |
| Microsoft Agent Framework AG-UI Integration | 微软 Agent 框架集成 AG-UI 协议，实现标准化前端交互 | Microsoft | 2026-02-12 | agent-ui, ag-ui, framework | 🎯 agent-ui ⚡ daily 2026-02-12 | [🔗 Link](https://techcommunity.microsoft.com/blog/azuredevcommunityblog/building-interactive-agent-uis-with-ag-ui-and-microsoft-agent-framework/4488249) |
| Google ADK Visual Agent Builder | Google ADK 可视化 Agent 构建器，支持自然语言转架构 | Google | 2026-02-12 | agent-ui, visual-builder, adk | 🎯 agent-ui ⚡ daily 2026-02-12 | [🔗 Link](https://google.github.io/adk-docs/visual-builder/) |
| Open WebUI v0.8.1 发布 |  | open-webui | 2026-02-17 | chat-ui, self-hosted, ollama | 🎯 agent-ui 🔧 daily 2026-02-17 | [🔗 Link](https://github.com/open-webui/open-webui/releases/tag/v0.8.1) |
| Dify 1.14.0-rc1 引入 Agent x Skills | Dify 新增沙盒化 Agent 技能编辑器，强化生产工作流 | langgenius | 2026-02-17 | agent-ui, workflow, skills | 🎯 agent-ui ⚡ daily 2026-02-17 | [🔗 Link](https://github.com/langgenius/dify/releases/tag/1.14.0-rc1) |

## RAG 工具链（Vector DB / Retrieval / Indexing）

| 应用/工具 | 描述 | 开发者 | 日期 | 标签 | 备注 | 链接 |
|---|---|---:|---:|---|---|---|
| Qdrant | 高性能向量数据库，Rust 实现，支持过滤和混合检索 | qdrant | 2026-02-11 | vector-db | ✍️ seed | [🔗 Link](https://github.com/qdrant/qdrant) |
| Weaviate | 开源向量数据库，内置 AI 模块和 GraphQL API | weaviate | 2026-02-11 | vector-db | ✍️ seed | [🔗 Link](https://github.com/weaviate/weaviate) |
| Milvus | 云原生向量数据库，适合大规模向量检索 | milvus-io | 2026-02-11 | vector-db | ✍️ seed | [🔗 Link](https://github.com/milvus-io/milvus) |
| pgvector | PostgreSQL 向量扩展，最低成本向量检索方案 | pgvector | 2026-02-11 | vector-db | ✍️ seed | [🔗 Link](https://github.com/pgvector/pgvector) |
| llama_index v0.14.13 |  | — | 2026-02-11 |  | 🔧 daily 2026-02-11 | [🔗 Link](https://github.com/run-llama/llama_index/releases/tag/v0.14.13) |
| Introducing RTEB: A New Standard for Retrieval Evaluation | RTEB：检索评估新标准 | Hugging Face | 2026-02-12 | retrieval, evaluation, benchmark | [RAG] ⚡ daily 2026-02-12 | [🔗 Link](https://huggingface.co/blog/rteb) |
| Dify v1.12.0 - Introducing Summary Index: Smarter Retrieval with AI Summarization | 引入摘要索引，通过 AI 摘要提升检索准确性 | langgenius | 2026-02-12 | retrieval, vector, embedding, summary | [RAG] ⚡ daily 2026-02-12 | [🔗 Link](https://github.com/langgenius/dify/releases/tag/1.12.0) |
| ScreenSuite |  | Hugging Face | 2026-02-18 | agent, evaluation, gui | [evaluation] 🔧 daily 2026-02-18 | [🔗 Link](https://github.com/huggingface/screensuite) |
| TextWeb |  | — | 2026-02-20 | rag, mcp, web-scraping | [RAG] 🔧 daily 2026-02-20 | [🔗 Link](https://www.reddit.com/r/LocalLLaMA/comments/1r90b3a/textweb_render_web_pages_as_25kb_text_grids/) |

## API 包装器（Model API / Gateway / SDK）

| 应用/工具 | 描述 | 开发者 | 日期 | 标签 | 备注 | 链接 |
|---|---|---:|---:|---|---|---|
| LiteLLM | 统一 LLM API 网关，兼容 100+ 模型提供商 | BerriAI | 2026-02-11 | gateway, sdk | ✍️ seed | [🔗 Link](https://github.com/BerriAI/litellm) |
| Vercel AI SDK | 面向前端开发者的 LLM 集成 SDK | vercel | 2026-02-11 | sdk | ✍️ seed | [🔗 Link](https://github.com/vercel/ai) |
| ChromeDevTools/chrome-devtools-mcp |  | ChromeDevTools | 2026-02-16 | mcp, devtools | 🔧 daily 2026-02-16 | [🔗 Link](https://github.com/ChromeDevTools/chrome-devtools-mcp) |
| langchain-openrouter==0.0.1: feat(openrouter): add `langchain-openrouter` provider package |  | LangChain | 2026-02-16 | sdk, openrouter | 🔧 daily 2026-02-16 | [🔗 Link](https://github.com/langchain-ai/langchain/releases/tag/langchain-openrouter%3D%3D0.0.1) |
| trnscrb | macOS 设备端转录工具，支持 MCP 协议 | — | 2026-02-21 | mcp, transcription | 📖 daily 2026-02-21 | [🔗 Link](https://www.producthunt.com/products/trnscrb) |

## 垂直应用（Writing / Coding / Data / Sales / Support）

| 应用/工具 | 描述 | 开发者 | 日期 | 标签 | 备注 | 链接 |
|---|---|---:|---:|---|---|---|
| Continue | 开源 AI 编码助手，支持 VS Code 和 JetBrains | continuedev | 2026-02-11 | coding | ✍️ seed | [🔗 Link](https://github.com/continuedev/continue) |
| Aider | 终端 AI 编程助手，擅长多文件代码修改 | Aider-AI | 2026-02-11 | coding | ✍️ seed | [🔗 Link](https://github.com/Aider-AI/aider) |
| Open Interpreter | 本地执行代码的 AI Agent，自然语言操作计算机 | OpenInterpreter | 2026-02-11 | local-exec | ✍️ seed | [🔗 Link](https://github.com/OpenInterpreter/open-interpreter) |
| Plus AI Presentation Agent |  | Plus AI | 2026-02-16 | agent, presentation | 🔧 daily 2026-02-16 | [🔗 Link](https://www.producthunt.com/products/plus-ai-presentation-agent) |
| Ningenie |  | — | 2026-02-20 | agent, agentic, productivity | 📖 daily 2026-02-20 | [🔗 Link](https://www.producthunt.com/products/ningenie) |

## 基础设施（Deployment / Observability / Evals / Security）

| 应用/工具 | 描述 | 开发者 | 日期 | 标签 | 备注 | 链接 |
|---|---|---:|---:|---|---|---|
| Langfuse | LLM 应用可观测性平台，追踪 Prompt、成本与质量 | langfuse | 2026-02-11 | observability | ✍️ seed | [🔗 Link](https://github.com/langfuse/langfuse) |
| promptfoo | LLM Prompt 评测与红队测试框架 | promptfoo | 2026-02-11 | evals | ✍️ seed | [🔗 Link](https://github.com/promptfoo/promptfoo) |
| Helicone | LLM 请求代理与监控平台，零侵入式接入 | Helicone | 2026-02-11 | observability | ✍️ seed | [🔗 Link](https://github.com/Helicone/helicone) |
| 0xAudit |  | — | 2026-02-11 |  | 🔧 daily 2026-02-11 | [🔗 Link](https://www.producthunt.com/products/0xaudit) |
| ScreenSuite - The most comprehensive evaluation suite for GUI Agents! | ScreenSuite：最全面的 GUI Agent 评估套件 | Hugging Face | 2026-02-12 | agent, evaluation, gui | [evaluation] ⚡ daily 2026-02-12 | [🔗 Link](https://huggingface.co/blog/screensuite) |
| CyberSecEval 2 - A Comprehensive Evaluation Framework for Cybersecurity Risks and Capabilities of Large Language Models | CyberSecEval 2：LLM 网络安全风险与能力综合评估框架 | Hugging Face | 2026-02-12 | evaluation, cybersecurity, framework | [evaluation] ⚡ daily 2026-02-12 | [🔗 Link](https://huggingface.co/blog/leaderboard-llamaguard) |
| Announcing Evaluation on the Hub | Hub 上的评估功能正式发布 | Hugging Face | 2026-02-12 | evaluation, hub, platform | [evaluation] ⚡ daily 2026-02-12 | [🔗 Link](https://huggingface.co/blog/eval-on-the-hub) |
| Promptfoo 0.120.24 |  | promptfoo | 2026-02-13 | evaluation, mcp, filtering | [evaluation] 🔧 daily 2026-02-13 | [🔗 Link](https://github.com/promptfoo/promptfoo/releases/tag/0.120.24) |
| ZenMux | 企业级LLM网关，支持自动补偿机制 | ZenMux | 2026-02-16 | gateway, llmops | ⚡ daily 2026-02-16 | [🔗 Link](https://www.producthunt.com/products/zenmux-2) |
| Langfuse 推出实验数据集版本控制 |  | Langfuse | 2026-02-17 | llmops, observability, evaluation | [evaluation] 🔧 daily 2026-02-17 | [🔗 Link](https://langfuse.com/docs/roadmap) |
| HERETIC |  | p-e-w | 2026-02-18 | llm, guardrail, alignment | [evaluation] 📖 daily 2026-02-18 | [🔗 Link](https://github.com/p-e-w/heretic) |
| Synra |  | — | 2026-02-20 | mcp, database, integration | 🔧 daily 2026-02-20 | [🔗 Link](https://www.producthunt.com/products/synra-managed-mcp-server) |
| Coasty | 在安全云 VM 上运行永久性计算机使用智能体 | — | 2026-02-21 | agent, cloud-vm | 🔧 daily 2026-02-21 | [🔗 Link](https://www.producthunt.com/products/coasty) |
| ClawMetry for OpenClaw | OpenClaw AI 智能体的实时可观测性仪表板 | — | 2026-02-21 | agent, observability | 📖 daily 2026-02-21 | [🔗 Link](https://www.producthunt.com/products/clawmetry) |
| Cencurity | LLM 智能体的安全网关 | — | 2026-02-21 | agent, gateway, security | 📖 daily 2026-02-21 | [🔗 Link](https://www.producthunt.com/products/cencurity) |

## 其他（Misc）

| 应用/工具 | 描述 | 开发者 | 日期 | 标签 | 备注 | 链接 |
|---|---|---:|---:|---|---|---|
| （占位） |  | — |  |  | ✍️ seed |  |
| Qwen3.5 | 阿里发布原生多模态智能体模型，397B参数开源 | Alibaba | 2026-02-18 | multimodal, agent, reasoning | ⚡ daily 2026-02-18 | [🔗 Link](https://qwen.ai/blog?id=qwen3.5) |
| Claude Sonnet 4.6 | Anthropic发布新中端模型，支持1M上下文和增强编码能力 | Anthropic | 2026-02-18 | agent, coding, computer-use | ⚡ daily 2026-02-18 | [🔗 Link](https://www.anthropic.com/news/claude-sonnet-4-6) |
| Claude Opus 4.6 and Sonnet 4.6 | Anthropic最新旗舰模型，1M token上下文，增强代理任务能力 | Anthropic | 2026-02-20 | llm, model-release, agent | ⚡ daily 2026-02-20 | [🔗 Link](https://www.anthropic.com/news/claude-opus-4-6) |
| DeepSeek V4 | 面向代码的V4模型，1M+ token上下文，推理稳定性提升 | DeepSeek | 2026-02-20 | llm, model-release, coding | ⚡ daily 2026-02-20 | [🔗 Link](https://www.deepseek.com/en) |
| Don't Trust the Salt: AI Summarization, Multilingual Safety, and LLM Guardrails |  | — | 2026-02-20 | guardrail, llm, safety | [evaluation] 📖 daily 2026-02-20 | [🔗 Link](https://royapakzad.substack.com/p/multilingual-llm-evaluation-to-guardrails) |
