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
| Claude system prompts as a git timeline | simonw | 2026-04-19 | claude, prompt-engineering, research-tool | https://simonwillison.net/2026/Apr/18/extract-system-prompts/ |  | 🔧 daily 2026-04-19 — Anthropic 公开 Claude 系统提示历史，Simon 用 git 时间线工具化便于研究演进 |
| Adding a new content type to my blog-to-newsletter tool | simonw | 2026-04-19 | agentic-engineering, claude-code, workflow | https://simonwillison.net/guides/agentic-engineering-patterns/adding-a-new-content-type/ |  | 🔧 daily 2026-04-19 — 展示如何用单条 prompt 让 Claude Code 完成跨仓库代码修改的实战模式 |
| Headless everything for personal AI | Simon Willison | 2026-04-20 | agent, headless, personal-ai | https://simonwillison.net/2026/Apr/19/headless-everything/#atom-everything |  | ⚡ daily 2026-04-20 — 提出 headless 服务 + 个人 AI 的新范式，可能改变应用交互方式 |
| OpenAI ad partner now selling ChatGPT ad placements based on "prompt relevance" | OpenAI / StackAdapt | 2026-04-21 | monetization, chatgpt, ads | https://www.adweek.com/media/exclusive-leaked-deck-reveals-stackadapts-playbook-for-chatgpt-ads/ |  | ⚡ daily 2026-04-21 — ChatGPT 广告生态启动，agent 经济新变现路径 |
| 亚马逊将向 Anthropic 追加投资 50 亿美元 | Amazon / Anthropic | 2026-04-21 | investment, partnership | https://readhub.cn/topic/8sUk7iyYTzD |  | ⚡ daily 2026-04-21 — 亚马逊追加 50 亿，生态绑定加深 |
| Gradient-based Planning for World Models at Longer Horizons | BAIR (UC Berkeley) | 2026-04-21 | world-model, planning | http://bair.berkeley.edu/blog/2026/04/20/grasp/ |  | 📖 daily 2026-04-21 — 长视野规划新方法，agent 决策参考 |
| We got 207 tok/s with Qwen3.5-27B on an RTX 3090 | Luce-Org | 2026-04-21 | inference, optimization, qwen | https://github.com/Luce-Org/lucebox-hub |  | 🔧 daily 2026-04-21 — 消费级 GPU 实现高吞吐推理，降低部署门槛 |
| Accelerate Generative AI Inference on Amazon SageMaker AI with G7e Instances | AWS / NVIDIA | 2026-04-21 | inference, GPU, sagemaker | https://aws.amazon.com/blogs/machine-learning/accelerate-generative-ai-inference-on-amazon-sagemaker-ai-with-g7e-instances/ |  | 🔧 daily 2026-04-21 — RTX 6000 Blackwell 实例，推理加速 |
| Claude Token Counter, now with model comparisons | Simon Willison | 2026-04-21 | token, eval, cost | https://simonwillison.net/2026/Apr/20/claude-token-counts/#atom-everything | [evaluation] | 🔧 daily 2026-04-21 — 多模型 token 成本对比，优化推理支出 |
| ToolSimulator: scalable tool testing for AI agents | AWS | 2026-04-21 | agent, testing, evals | https://aws.amazon.com/blogs/machine-learning/toolsimulator-scalable-tool-testing-for-ai-agents/ | [evaluation] | 🔧 daily 2026-04-21 — 大规模 agent 工具测试框架，安全验证 |
| OpenAI helps Hyatt advance AI among colleagues | OpenAI | 2026-04-21 | enterprise, casestudy | https://openai.com/index/hyatt-advances-ai-with-chatgpt-enterprise |  | 📖 daily 2026-04-21 — 酒店业 AI 落地案例，GPT-5.4+Codex |
| SpaceX 宣布以 600 亿美元收购 AI 编程工具 Cursor | Cursor (AI Inc.) | 2026-04-22 | agent, coding-agent, m&a | https://www.bloomberg.com/news/articles/2026-04-21/spacex-says-has-agreement-to-acquire-cursor-for-60-billion |  | ⚡ daily 2026-04-22 — SpaceX 以 600 亿美元收购 Cursor，标志 AI 编程工具进入巨头整合阶段 |
| Claude Code 从 Anthropic Pro 套餐中移除 | Anthropic | 2026-04-22 | claude, pricing, coding-agent | https://claude.com/pricing |  | ⚡ daily 2026-04-22 — Claude Code 不再包含在 Pro tier，仅保留给 Team/Enterprise，定价策略收紧 |
| OpenAI Codex 达 400 万周活，联合 Accenture/PwC 等企业级推广 | OpenAI | 2026-04-22 | coding-agent, enterprise, llmops | https://openai.com/index/scaling-codex-to-enterprises-worldwide |  | 🔧 daily 2026-04-22 — Codex WAU 达 400 万，推出 Codex Labs 并联手 7 家全球系统集成商 |
| CrabTrap：Brex 开源 LLM-as-judge Agent 安全代理 | Brex | 2026-04-22 | agent, security, guardrail | https://www.brex.com/journal/building-crabtrap-open-source |  | 🔧 daily 2026-04-22 — HTTP 代理层用 LLM 实时审查 Agent 外发请求，解决生产环境 Agent 安全痛点 |
| Google ReasoningBank：让 Agent 从成败经验中学习推理模式 | Google Research | 2026-04-22 | agent, memory, reasoning | https://research.google/blog/reasoningbank-enabling-agents-to-learn-from-experience/ |  | 📖 daily 2026-04-22 — 从成功和失败轨迹中提炼高层推理模式，ICLR 论文 + GitHub 开源 |
| Claude Cowork 登陆 Amazon Bedrock，知识工作者全面接入 | Anthropic / AWS | 2026-04-22 | agent, enterprise, gateway | https://aws.amazon.com/blogs/machine-learning/from-developer-desks-to-the-whole-organization-running-claude-cowork-in-amazon-bedrock/ |  | 🔧 daily 2026-04-22 — Claude Cowork 桌面应用通过 Bedrock 部署，按用量计费无 seat 授权费 |
| Kimi K2.6 开源发布：300 Agent 集群 + SWE-Bench Pro 领先 | Moonshot AI | 2026-04-22 | agent, coding-agent, open-source | https://huggingface.co/moonshotai/Kimi-K2.6 |  | ⚡ daily 2026-04-22 — K2.6 开源，支持 300 子 Agent 并行 4000 协作步骤，SWE-Bench Pro 超所有闭源模型 |
| OpenAI 发布 ChatGPT Images 2.0 | OpenAI | 2026-04-22 | multimodal, image-generation | https://openai.com/index/introducing-chatgpt-images-2-0/ |  | 🔧 daily 2026-04-22 — OpenAI 推出新一代图像生成模型，集成于 ChatGPT |
| Qwen3.6-27B: Flagship-Level Coding in a 27B Dense Model | Qwen/Alibaba | 2026-04-23 | coding-agent, open-source, llm | https://qwen.github.io/blog/qwen3.6-27b/ |  | 🔧 daily 2026-04-23 — 27B 稠密模型达到旗舰级 agentic coding 性能，超越上代开源旗舰 Qwen3，本地部署性价比极高 |
| 谷歌：目前所有新代码中 75%由 AI 生成 | Google | 2026-04-23 | coding-agent, adoption, gemini | https://readhub.cn/topic/8sXPtiDRuzY |  | ⚡ daily 2026-04-23 — Google Gemini Enterprise Q1 付费 MAU 环比 +40%，新代码 75% AI 生成——企业 AI 编程渗透率里程碑 |
| Jupiter-N: Hybrid Reasoning Model with Agentic Capability (Nemotron 3 Super) | NVIDIA | 2026-04-23 | agent, reasoning, open-source | https://arxiv.org/abs/2604.17429 |  | ⚡ daily 2026-04-23 — NVIDIA 开源 120B 混合推理模型，从 Nemotron 3 Super 后训练，专注 agentic capability + 不确定性校准 |
| Changes to GitHub Copilot Individual plans | GitHub/Microsoft | 2026-04-23 | coding-agent, pricing, llmops | https://github.blog/changelog/2026-04-22-changes-to-github-copilot-individual-plans/ |  | 🔧 daily 2026-04-23 — GitHub 公开透明调整 Copilot Individual 定价，与 Anthropic 同日调价形成鲜明对比——平台策略分化 |
| Speeding up agentic workflows with WebSockets in the Responses API | OpenAI | 2026-04-23 | agent, workflow, websocket | https://openai.com/index/speeding-up-agentic-workflows-with-websockets/ | 🎯 agent-ui | 🔧 daily 2026-04-23 — OpenAI Responses API 新增 WebSocket 支持 + 连接级缓存，显著降低 Codex agent loop 的 API 开销和延迟 |
| Introducing workspace agents in ChatGPT | OpenAI | 2026-04-23 | agent, workspace, multi-agent | https://openai.com/index/introducing-workspace-agents-in-chatgpt/ | 🎯 agent-ui | ⚡ daily 2026-04-23 — ChatGPT 引入 Codex 驱动的 workspace agents——云端运行、自动化复杂工作流、团队级工具集成，Agent 从个人走向组织 |
| Get to your first working agent in minutes: Announcing new features in Amazon Bedrock AgentCore | AWS | 2026-04-23 | agent, bedrock, deployment | https://aws.amazon.com/blogs/machine-learning/get-to-your-first-working-agent-in-minutes-announcing-new-features-in-amazon-bedrock-agentcore/ |  | 🔧 daily 2026-04-23 — AWS Bedrock AgentCore 大幅简化 Agent 开发流程，从原型到生产部署的基建障碍持续消除 |
| OpenAI 发布 GPT-5.5：智能与效率同步跃升，Terminal-Bench 82.7% | OpenAI | 2026-04-24 | gpt-5.5, agentic-coding, computer-use | https://openai.com/index/introducing-gpt-5-5/ |  | ⚡ daily 2026-04-24 — GPT-5.5 在 agentic coding/computer use 上大幅领先，同时保持与 GPT-5.4 相同的 per-token 延迟，效率不妥协 |
| Anthropic 二级估值逼近 1 万亿美元，首次超越 OpenAI | Anthropic | 2026-04-24 | valuation, anthropic, market | https://www.36kr.com/p/3778903190639617 |  | ⚡ daily 2026-04-24 — 二级市场报价反超 OpenAI，资本逻辑从模型排名转向入口控制和商业兑现 |
| 腾讯混元 Hy3 preview 发布，壁仞科技 Day0 适配国产 GPU | 腾讯/壁仞科技 | 2026-04-24 | tencent, hy3, domestic-gpu | https://readhub.cn/topic/8sZBeCdgvdJ |  | 📖 daily 2026-04-24 — 混元 Hy3 preview 开源，vLLM Day0 适配壁砺 166 系列，国模+国芯落地验证 |
| Anthropic 发布 Claude Code 质量事故复盘：三个独立问题叠加 | Anthropic | 2026-04-24 | claude-code, postmortem, quality | https://www.anthropic.com/engineering/april-23-postmortem |  | 🔧 daily 2026-04-24 — reasoning effort 变更 + thinking 清除 bug + verbosity 指令叠加导致质量下降，已重置用户额度 |
| Claude Desktop App 被曝私自安装未授权浏览器桥接扩展 | Anthropic | 2026-04-24 | claude-desktop, security, browser-extension | https://letsdatascience.com/news/claude-desktop-installs-preauthorized-browser-extension-mani-4064fb1a |  | 🔧 daily 2026-04-24 — 桌面端静默安装原生消息桥接扩展，引发安全与透明度担忧 |
| SuperHQ：用 microVM 沙箱隔离运行 AI 编程 Agent | superhq-ai | 2026-04-24 | sandbox, coding-agent, microVM | https://github.com/superhq-ai/superhq |  | 🔧 daily 2026-04-24 — Rust+GPUI 构建，Claude Code/Codex 各自独立 VM，Auth Gateway 保护 API Key 不外泄 |
| 大厂抛弃 MCP 转向 CLI？Perplexity CTO 和 YC CEO 公开质疑 | — | 2026-04-24 | mcp, cli, protocol-debate | https://juejin.cn/post/7630841596041478171 |  | 📖 daily 2026-04-24 — Perplexity CTO 宣布放弃 MCP，YC CEO 直言「MCP sucks」，协议标准之争白热化 |
| Anthropic Mythos Preview 遭未授权访问，第三方承包商环境泄露 | Anthropic | 2026-04-24 | mythos, security-breach, supply-chain | https://readhub.cn/topic/8sXRNjBG6Gl |  | 📖 daily 2026-04-24 — 高危模型通过第三方承包商环境被未授权访问，供应链安全再敲警钟 |
| Weaviate 1.37：内置 MCP Server，向量库变 Agent 长期记忆 | Weaviate | 2026-04-24 | mcp, vector-db, weaviate | https://weaviate.io/blog/weaviate-1-37-release |  | 🔧 daily 2026-04-24 — 内置 MCP Server 让 LLM 直接查询/写入向量库，无需胶水代码，MMR 多样性搜索同步上线 |
| Google 计划向 Anthropic 投资至多 400 亿美元 | Google / Anthropic | 2026-04-25 | anthropic, google-cloud, investment | https://techcrunch.com/2026/04/24/google-to-invest-up-to-40b-in-anthropic-in-cash-and-compute/ |  | ⚡ daily 2026-04-25 — Google 以 3500 亿估值先投 100 亿、未来追加 300 亿，Anthropic 今年累计融资已超 800 亿，模型厂商与云厂商深度绑定加速 |
| Claude 4.7 被曝忽略 stop hooks，工作流确定性遭破坏 | Anthropic | 2026-04-25 | claude, workflow, hook | https://news.ycombinator.com/item?id=47895029 |  | 🔧 daily 2026-04-25 — Claude 4.7 模型不再可靠执行 stop hooks，依赖 hook 注入确定性的 Agent 工作流需立即检查并降级或加 workaround |
| DeepSeek-V4 预览版发布：百万上下文专为 Agent 设计 | DeepSeek | 2026-04-25 | deepseek, agent, context-window | https://huggingface.co/blog/deepseekv4 |  | ⚡ daily 2026-04-25 — DeepSeek-V4-Pro 和 V4-Flash 双模型预览上线，100 万 token 上下文专为多步 Agent 任务优化，价格仅为 frontier 模型的零头 |
| 用户公开退出 Claude：token 计费异常、质量下降、客服缺失 | Anthropic | 2026-04-25 | claude, community-sentiment, reliability | https://nickyreinert.de/en/2026/2026-04-24-claude-critics/ |  | 📖 daily 2026-04-25 — HN 738 分热议，反映单平台依赖风险与 AI 服务透明度问题，与本周 Claude Code 从 Pro 套餐剥离形成共振 |
| Nilay Patel：大众并不渴望 AI 自动化 | The Verge | 2026-04-25 | automation, public-perception, ai-adoption | https://simonwillison.net/2026/Apr/24/the-people-do-not-yearn-for-automation/#atom-everything |  | 📖 daily 2026-04-25 — ChatGPT 使用量飙升但公众对 AI 自动化普遍抵触，揭示 AI 工具从开发者向大众市场扩展的核心矛盾 |
| AWS 教程：用 Visier + Bedrock AgentCore + MCP 构建人力分析 Agent | AWS / Visier | 2026-04-25 | agent, mcp, workforce-analytics | https://aws.amazon.com/blogs/machine-learning/building-workforce-ai-agents-with-visier-and-amazon-quick/ | [RAG] | 🔧 daily 2026-04-25 — 生产级 Agent 架构实战：通过 MCP 协议连接 Visier 人力数据平台与 Amazon Quick，展示知识工作者统一 Agent 工作空间范式 |
| What's missing in the 'agentic' story: a well-defined user agent role | — | 2026-04-26 | agent, agentic, architecture | https://www.mnot.net/blog/2026/04/24/agents_as_collective_bargains | 🎯 agent-ui | ⚡ daily 2026-04-26 — IETF 编辑从互联网标准视角审视 agentic 架构中用户代理角色的缺失 |
| GPT-5.5 Bio Bug Bounty | OpenAI | 2026-04-26 | gpt, safety, security | https://openai.com/index/gpt-5-5-bio-bug-bounty/ |  | ⚡ daily 2026-04-26 — OpenAI 为 GPT-5.5 生物安全漏洞设立专项赏金计划，安全投入持续加码 |
| GPT-5.5 prompting guide | OpenAI | 2026-04-26 | gpt, prompting, coding agent | https://simonwillison.net/2026/Apr/25/gpt-5-5-prompting-guide/#atom-everything |  | 🔧 daily 2026-04-26 — OpenAI 发布 GPT-5.5 官方提示指南，含 thinking 时间控制等实用技巧 |
| 英伟达适配 DeepSeek-V4 AI模型（續報） | NVIDIA / DeepSeek | 2026-04-26 | deepseek, nvidia, inference | https://readhub.cn/topic/8sc4xEqkavq |  | 🔧 daily 2026-04-26 — NVIDIA Blackwell 平台适配 DeepSeek-V4-Pro/Flash，开箱性能超 150 tok/s/user |
| Lambda Calculus Benchmark for AI | Victor Taelin | 2026-04-26 | benchmark, reasoning | https://victortaelin.github.io/lambench/ |  | 📖 daily 2026-04-26 — Lambda 演算基准测试获 HN 社区高度关注，反映推理能力评估新方向 |
| Quoting Romain Huet: GPT-5.5 unified system gains | OpenAI | 2026-04-26 | gpt, agent, unified | https://simonwillison.net/2026/Apr/25/romain-huet/#atom-everything |  | 🔧 daily 2026-04-26 — GPT-5.5 统一 Codex 与主模型，agentic coding 和 computer use 大幅提升 |
| An AI agent deleted our production database. The agent's confession is below | — | 2026-04-27 | agent-safety, production, cautionary-tale | https://news.ycombinator.com/item?id=47911524 |  | ⚡ daily 2026-04-27 — AI Agent 在生产环境造成灾难性事故——386 HN points, 539 comments，引发对 agentic AI 安全边界的深度反思 |
| SWE-bench Verified no longer measures frontier coding capabilities | OpenAI | 2026-04-27 | benchmark, coding-agent, evaluation | https://openai.com/index/why-we-no-longer-evaluate-swe-bench-verified/ |  | ⚡ daily 2026-04-27 — OpenAI 正式弃用 SWE-Bench Verified——承认基准已被前沿 coding agent 饱和，评估体系需重构 |
| Breaking MCP with Function Hijacking Attacks: Novel Threats for Function Calling and Agentic Models | — | 2026-04-27 | mcp, security, function-calling | https://arxiv.org/abs/2604.20994 |  | 🔧 daily 2026-04-27 — MCP 协议遭函数劫持攻击——function calling + agentic 模型的新型安全威胁（arXiv） |
| DeepSeek V4 成 OpenClaw 默认模型，SDK 破坏性变更 | OpenClaw | 2026-04-27 | deepseek, agent, sdk | https://readhub.cn/topic/8sdTnaMWSgD |  | 🔧 daily 2026-04-27 — OpenClaw 接入 DeepSeek V4 双版本，修复多轮工具调用问题，SDK 破坏性变更，Google Meet 插件上线 |
| 国家超算互联网推出 DeepSeek-V4 限时免费对话服务 | 国家超算互联网 | 2026-04-27 | deepseek, infrastructure, free-access | https://m.ithome.com/html/943599.htm | [RAG] | 🔧 daily 2026-04-27 — 国家级超算平台免费提供 DeepSeek-V4 访问——降低 Agent/推理应用实验门槛 |
| 梁文锋，坐不住了——DeepSeek 被「捧杀」？ | 虎嗅 | 2026-04-27 | deepseek, industry-commentary | https://www.huxiu.com/article/4851882.html |  | 📖 daily 2026-04-27 — DeepSeek 创始人梁文锋行业分析——在 V4 发布热潮中审视市场预期与技术现实的落差 |
| OpenAI 与微软修订合作协议：非独家授权 + 收入分成封顶 + 多云自由 | OpenAI | 2026-04-28 | partnership, cloud, licensing | https://openai.com/index/next-phase-of-microsoft-partnership/ |  | ⚡ daily 2026-04-28 |
| OpenAI 获 FedRAMP Moderate 授权，ChatGPT Enterprise + API 面向联邦机构开放 | OpenAI | 2026-04-28 | compliance, government, enterprise | https://openai.com/index/openai-available-at-fedramp-moderate/ |  | 🔧 daily 2026-04-28 |
| Strands Agents SDK + SageMaker + MLflow：生产级 Agent 可观测性方案 | AWS | 2026-04-28 | agent-sdk, observability, mlflow | https://aws.amazon.com/blogs/machine-learning/build-strands-agents-with-sagemaker-ai-models-and-mlflow/ |  | 🔧 daily 2026-04-28 |
| OpenAI Privacy Filter 开源：1.5B 参数单前向 PII 检测，128k 上下文 | OpenAI | 2026-04-28 | privacy, PII, guardrail | https://huggingface.co/blog/openai-privacy-filter-web-apps |  | 🔧 daily 2026-04-28 |
| 腾讯 QClaw 网关升级 v0.2.14：率先支持 Hermes，接入 DeepSeek-V4-Pro | 腾讯 | 2026-04-28 | gateway, hermes, multi-model | https://m.ithome.com/html/943877.htm |  | 🔧 daily 2026-04-28 |
| Amazon Quick Flows：用自然语言构建 AI 工作流，无需编码 | AWS | 2026-04-28 | workflow, automation, no-code | https://aws.amazon.com/blogs/machine-learning/automate-repetitive-tasks-with-amazon-quick-flows/ |  | 🔧 daily 2026-04-28 |
| 欧盟强制 Google 向第三方 AI 助手开放 Android 核心权限 | EU Commission | 2026-04-28 | regulation, DMA, AI-competition | https://readhub.cn/topic/8sg2Qrim5IL |  | ⚡ daily 2026-04-28 |
| OpenAI models, Codex, and Managed Agents come to AWS Bedrock | OpenAI | 2026-04-29 | agent, gateway, llmops | https://openai.com/index/openai-on-aws | 🎯 agent-ui | ⚡ daily 2026-04-29 — GPT-5.5 + Codex + Managed Agents 正式登陆 AWS，多云战略实质性落地 |
| Claude.ai 大规模服务中断，API elevated errors | Anthropic | 2026-04-29 | reliability, agent | https://status.claude.com/incidents/9l93x2ht4s5w |  | 📖 daily 2026-04-29 — HN 259 分热议，单平台依赖风险再次凸显 |
| NVIDIA Nemotron 3 Nano Omni: 长上下文多模态智能体模型 | NVIDIA | 2026-04-29 | multimodal, agent, document | https://huggingface.co/blog/nvidia/nemotron-3-nano-omni-multimodal-intelligence | [RAG] | 🔧 daily 2026-04-29 — 30B MoE 统一文本+图像+视频+音频，OSWorld 47.4% 领先开源，9x 吞吐提升 |
| DOOM runs in ChatGPT and Claude via MCP Apps | Chris Nager | 2026-04-29 | mcp, agent-ui | https://chrisnager.com/blog/doom-runs-in-chatgpt-and-claude/ |  | 📖 daily 2026-04-29 — MCP Apps 交互式 UI 能力趣味演示，验证 MCP 协议可扩展性边界 |
| OpenAI 未达成营收目标，甲骨文及芯片股应声下跌 | — | 2026-04-29 | market, llmops | https://readhub.cn/topic/8shQEmUnFuW |  | ⚡ daily 2026-04-29 — 用户增长与营收缺口引发 AI 基础设施开支可持续性质疑 |
| A good AGENTS.md is a model upgrade — 系统性实证研究 | Augment Code | 2026-04-29 | agent, agent-ui, best-practices | https://www.augmentcode.com/blog/how-to-write-good-agents-dot-md-files | 🎯 agent-ui | 🔧 daily 2026-04-29 — 100-150 行最佳，超长反降质；渐进式披露 + 程序化工作流是核心模式 |
| 110 人公司 Claude 账号被集体封杀，API 仍在计费（续报） | Anthropic | 2026-04-29 | reliability, evaluation, enterprise | https://www.36kr.com/p/3786067810082051 | [evaluation] | ⚡ daily 2026-04-29 — 组织级封禁零预警 + API 持续计费，企业级 Anthropic 依赖风险升级 |
| DeepSeek 正式内测「识图模式」，首次支持图片理解 | DeepSeek | 2026-04-30 | deepseek, multimodal, vision | https://m.ithome.com/html/945092.htm |  | 🔧 daily 2026-04-30 — DeepSeek 从纯文本跨入多模态，Agent 视觉能力拼图补齐 |
| IBM Granite 4.1 系列开源 LLM 发布：架构与训练全解析 | IBM | 2026-04-30 | open-source, llm, granite | https://huggingface.co/blog/ibm-granite/granite-4-1 |  | 📖 daily 2026-04-30 — IBM Granite 4.1 开源模型族发布，面向企业级 RAG 与 Agent 场景优化 |
| Anthropic 考虑 $9000B+ 估值新一轮融资，拟 10 月 IPO | Anthropic | 2026-04-30 | funding, ipo, anthropic | https://readhub.cn/topic/8sjgGSzi97u |  | ⚡ daily 2026-04-30 — 估值或超 OpenAI 成全球最高 AI 独角兽，IPO 时间表首次明确 |
| AI 编程成本危机：Copilot、Claude 集体涨价，社区反思 vibe coding 经济性 | GitHub/Anthropic | 2026-04-30 | coding-agent, pricing, vibe-coding | https://www.36kr.com/p/3787252419681280 |  | ⚡ daily 2026-04-30 — AI 编程工具 token 消耗过高引发经济性质疑，可能影响 adoption 曲线 |
| LLM 0.32a0 重大向后兼容重构：插件架构与 CLI 全面升级 | simonw | 2026-04-30 | llm-cli, plugin, python | https://simonwillison.net/2026/Apr/29/llm/#atom-everything |  | 🔧 daily 2026-04-30 — Simon Willison 的 LLM 工具链重大重构，插件生态与 CLI 体验大幅改善 |
| Amazon Bedrock AgentCore 支持 serverless MCP proxy 部署 | AWS | 2026-04-30 | mcp, serverless, agent | https://aws.amazon.com/blogs/machine-learning/run-custom-mcp-proxies-serverless-on-amazon-bedrock-agentcore-runtime/ |  | 🔧 daily 2026-04-30 — MCP 协议首次获得 AWS serverless 原生支持，企业级治理与可观测性落地 |
| 阿里云百炼 DeepSeek-V4-Pro 隐式缓存降价至 ¥1/M Token | 阿里云 | 2026-04-30 | pricing, cache, deepseek | https://readhub.cn/topic/8sj9NORpYA8 |  | 🔧 daily 2026-04-30 — 长上下文推理成本再降 50%+，对 Agent 长对话场景直接利好 |
| AWS AgentCore Memory：Agent 内存的 Namespace 设计模式 | AWS | 2026-04-30 | agent-memory, design-pattern, retrieval | https://aws.amazon.com/blogs/machine-learning/organizing-agents-memory-at-scale-namespace-design-patterns-in-agentcore-memory/ |  | 📖 daily 2026-04-30 — 生产级 Agent 内存管理的 namespace 分层与 IAM 权限控制最佳实践 |
| Codex CLI 0.128.0 新增 /goal：目标驱动循环直到完成 | OpenAI | 2026-05-01 | coding-agent, agent, workflow | https://simonwillison.net/2026/Apr/30/codex-goals/#atom-everything | 🎯 agent-ui | 🔧 daily 2026-05-01 — Codex CLI 引入 Ralph loop 风格的目标驱动模式，自动循环直到 goal 完成或超时——编码 Agent 自主性显著提升 |
| UK AISI 评估 GPT-5.5 网络安全能力：与 Claude Mythos 相当但不可信 | OpenAI / UK AISI | 2026-05-01 | evaluation, security, guardrail | https://simonwillison.net/2026/Apr/30/gpt-55-cyber-capabilities/#atom-everything | [evaluation] | ⚡ daily 2026-05-01 — 官方安全机构首次系统评估 GPT-5.5 网络攻防能力——发现漏洞能力强但不可信任用于实战，安全评估范式信号 |
| AWS 发布 RLAIF 实战指南：用 LLM-as-a-Judge 做强化微调 | AWS | 2026-05-01 | evaluation, llmops, training | https://aws.amazon.com/blogs/machine-learning/reinforcement-fine-tuning-with-llm-as-a-judge/ | [evaluation] | 🔧 daily 2026-05-01 — AWS 系统化 RLAIF 流程文档——用 Amazon Nova 做 LLM-as-a-Judge 强化微调，生产级对齐实践参考 |
| AWS Model Agility Solution：LLM 迁移/升级的系统化框架 | AWS | 2026-05-01 | llmops, deployment, gateway | https://aws.amazon.com/blogs/machine-learning/aws-generative-ai-model-agility-solution-a-comprehensive-guide-to-migrating-llms-for-generative-ai-production/ |  | 🔧 daily 2026-05-01 — LLM 快速迭代时代，AWS 提供模型迁移方法论和工具链——从评估到部署的端到端框架，降低切换成本 |
| Zig creator Andrew Kelley：LLM 辅助 PR 的错误模式与人类根本不同 | — | 2026-05-01 | coding-agent, developer-experience | https://simonwillison.net/2026/Apr/30/andrew-kelley/#atom-everything |  | 📖 daily 2026-05-01 — Zig 创始人分享 LLM 辅助开发的实际经验——LLM 幻觉有独特模式可检测，对 Agent 代码审查有启发 |
| DeepMind AI Co-Clinician：医疗场景的 AI 协诊系统 | Google DeepMind | 2026-05-01 | multimodal-model, healthcare, agent | https://deepmind.google/blog/ai-co-clinician/ |  | ⚡ daily 2026-05-01 — DeepMind 发布 AI 协诊系统研究——探索 LLM 在临床决策中的辅助角色，医疗 Agent 方向标志性进展 |
| Uber 烧光 2026 AI 预算：Claude Code 四个月吃掉全年额度 | Anthropic | 2026-05-02 | claude-code, ai-coding, budget | https://www.briefs.co/news/uber-torches-entire-2026-ai-budget-on-claude-code-in-four-months/ |  | ⚡ daily 2026-05-02 — 95% 工程师月活 AI 工具，月均 API 成本 $500-2000/人，AI 编程经济性拐点信号 |
| Adam Fusion：AI Agent 驱动 Autodesk Fusion 360 原生 CAD 设计 | Adam | 2026-05-02 | agent, cad, design | https://fusion.adam.new/install |  | 🔧 daily 2026-05-02 — text-to-CAD 从 Web App 进化为 Fusion 360 原生 Agent 插件，本地执行不依赖云端 |
| AWS Transform 新增 BI 迁移 Agent：自动化 Tableau/Power BI → Amazon Quick | AWS | 2026-05-02 | agent, bi-migration, aws | https://aws.amazon.com/blogs/machine-learning/aws-transform-now-automates-bi-migration-to-amazon-quick-in-days/ |  | 📖 daily 2026-05-02 — Agent 化 BI 迁移从月缩至天，通过 Marketplace 订阅专用 Analyzer/Converter Agent |
| DeepSeek 发布多模态技术报告：视觉原语推理框架（已删除） | DeepSeek | 2026-05-02 | multimodal, visual-primitives, reasoning | https://readhub.cn/topic/8skqPqDbX9X |  | ⚡ daily 2026-05-02 — 提出「视觉原语」框架，将 bbox/点提升为推理基本单元，token 效率仅为 Gemini 1/3 |
| Simon Willison 用 Claude Code for Web 打造 iNaturalist 观测工具 | Simon Willison | 2026-05-02 | claude-code, web-dev, vibe-coding | https://simonwillison.net/2026/May/1/inat-sightings/ |  | 📖 daily 2026-05-02 — 全程手机 + Claude Code 构建 Git scraping + 前端展示，vibe coding 实战案例 |
| Open Design：开源 Claude Design 替代，12 个 Coding Agent CLI 统一设计工作流 | nexu-io | 2026-05-03 | agent-ui, design-system, coding-agent | https://github.com/nexu-io/open-design | 🎯 agent-ui | 🔧 daily 2026-05-03 — 开源 Claude Design 替代，支持 12 个 coding agent CLI + 72 套品牌设计系统，本地优先 BYOK |
| VS Code 无条件插入 Co-Authored-by Copilot，社区质疑 attribution 准确性 | microsoft | 2026-05-03 | copilot, attribution, developer-tools | https://github.com/microsoft/vscode/pull/310226 |  | 🔧 daily 2026-05-03 — VS Code 无论是否使用 Copilot 都自动添加 Co-Authored-by 标签，引发 attribution 准确性争议 |
| jcode：Coding Agent Harness，启动速度 245x 快于 Claude Code，内存 19.7x 更低 | 1jehuang | 2026-05-03 | coding-agent, performance, agent-ui | https://github.com/1jehuang/jcode | 🎯 agent-ui | ⚡ daily 2026-05-03 — 多会话编程 agent harness 性能基准测试：14ms 首帧 vs Claude Code 3.4s，10 会话内存仅 260MB |
| browserbase/skills：Claude Agent SDK 集成网页浏览工具，支持隐身模式 + CAPTCHA 解决 | browserbase | 2026-05-03 | agent-framework, browser-automation, mcp | https://github.com/browserbase/skills | 🎯 agent-ui | 🔧 daily 2026-05-03 — 为 Claude Code 提供浏览器自动化 skill 插件，支持反检测 + 住宅代理 + DevTools 协议追踪 |
| Flue：TypeScript Agent Harness 框架，Model + Harness + Sandbox 三层架构 | Flue | 2026-05-03 | agent-framework, typescript, sandbox | https://flueframework.com/ | 🎯 agent-ui | 🔧 daily 2026-05-03 — 将 coding agent 的 harness 架构抽象为 TypeScript 框架，内置零配置虚拟沙箱，可部署为 HTTP 服务或 CLI |
| ruflo：Claude Code 多 Agent 编排平台，支持 100+ Agent 集群 + 联邦通信 | ruvnet | 2026-05-03 | multi-agent, orchestration, swarm | https://github.com/ruvnet/ruflo | 🎯 agent-ui | ⚡ daily 2026-05-03 — 为 Claude Code 添加集群编排、自学习记忆、跨机器联邦通信能力，32 个可插拔插件 |
| DeepClaude：用 DeepSeek V4 Pro 跑 Claude Code Agent Loop，成本降 17 倍 | aattaran | 2026-05-04 | coding-agent, cost-optimization, deepseek | https://github.com/aattaran/deepclaude |  | 🔧 daily 2026-05-04 — 保留 Claude Code 完整 tool loop/文件编辑/bash 能力，仅替换推理后端为 DeepSeek V4 Pro，输出 token 成本从 $15/M 降至 $0.87/M |
| Ableton Live MCP：用 AI Agent 语音控制音乐制作 | bschoepke | 2026-05-04 | mcp, tool-integration, creative-ai | https://github.com/bschoepke/ableton-live-mcp |  | 🔧 daily 2026-05-04 — 通用 MCP Server 桥接 Ableton Object Model，Agent 可 eval 任意 Python 操控音乐工程，展示 MCP 向创意领域扩展 |
| Anthropic 内部研究：Claude 谄媚率仅 9%，但灵性和关系领域例外 | Anthropic | 2026-05-04 | evaluation, sycophancy, anthropic | https://simonwillison.net/2026/May/3/anthropic/ |  | 📖 daily 2026-05-04 — Anthropic 首次公布 Claude 谄媚行为量化数据：整体 9%，但灵性对话 38%、关系对话 25% 存在谄媚 |
| CTO 集体「降级」加入 Anthropic 当工程师：AI 时代影响力重定义 | — | 2026-05-04 | talent, anthropic, industry | https://www.36kr.com/p/3793138446179585 |  | ⚡ daily 2026-05-04 — Workday/You.com/Instagram 等 CTO 级高管接连加入 Anthropic 做 IC，反映前沿实验室杠杆效应超越传统管理层 |
| For thirty years I programmed with Phish on：AI 时代开发者工作流异化反思 | Christopher Meiklejohn | 2026-05-04 | developer-culture, vibe-coding | https://christophermeiklejohn.com/ai/personal/phish/flow/agents/2026/05/03/rift.html |  | 📖 daily 2026-05-04 — 30 年编程老兵反思 AI 时代工作流异化：当 Claude Code 可以替你写代码，「亲手编码」的意义正在瓦解 |
| OpenAI 重构 WebRTC 栈：低延迟语音 AI 基础设施架构 | OpenAI | 2026-05-05 | realtime, webrtc, voice-ai | https://openai.com/index/delivering-low-latency-voice-ai-at-scale/ |  | 📖 daily 2026-05-05 — 为 9 亿月活用户重新设计 WebRTC 架构，split relay + transceiver 模式保障实时语音交互低延迟 |
| AWS AgentCore Optimization 预览：Agent 质量闭环（推荐+A/B 测试） | AWS | 2026-05-05 | agent, evaluation, ab-testing | https://aws.amazon.com/blogs/machine-learning/introducing-the-agent-quality-loop-agentcore-optimization-now-in-preview/ | 🎯 [evaluation] | 🔧 daily 2026-05-05 — 从生产 trace 自动生成优化推荐，经 batch eval + A/B 测试验证，替代人工 prompt 调优循环 |
| SageMaker AI 新增 Agent 引导式模型定制工作流 | AWS | 2026-05-05 | agent, workflow, fine-tuning | https://aws.amazon.com/blogs/machine-learning/agent-guided-workflows-to-accelerate-model-customization-in-amazon-sagemaker-ai/ | 🎯 | 🔧 daily 2026-05-05 — 自然语言描述用例 → Agent 自动完成 SFT/DPO/RLVR 全流程，预构建 Skills 可编辑复用 |
| Anthropic 接近达成 15 亿美元合资协议：黑石 + 高盛各投约 3 亿 | — | 2026-05-05 | funding, anthropic | https://readhub.cn/topic/8sqdrgaZIGx |  | ⚡ daily 2026-05-05 — Anthropic 持续融资加速，黑石/高盛/海曼傅曼各投约 3 亿美元，AI 基础设施军备竞赛升级 |
| 马斯克开庭前两天寻求与 OpenAI 和解：要求领导层变更 + 1500 亿赔偿 | — | 2026-05-05 | openai, lawsuit | https://readhub.cn/topic/8srGSpTqKN1 |  | ⚡ daily 2026-05-05 — 马斯克在开庭前联系 Brockman 求和，涉及微软的 1500 亿美元赔偿诉讼或迎来转折 |
| Claude Code 实战：构建 ReDoS 鲁棒性正则引擎实验 | Simon Willison | 2026-05-05 | claude-code, security, regex | https://simonwillison.net/2026/May/4/tre-python-binding/#atom-everything |  | 📖 daily 2026-05-05 — Claude Code 构建 TRE 正则引擎 Python binding 演示 ReDoS 鲁棒性，展示 AI 辅助安全工具开发 |
| GPT-5.5 Instant 向所有 ChatGPT 用户推出 | OpenAI | 2026-05-06 | gpt, model-release, chatgpt | https://openai.com/index/gpt-5-5-instant/ |  | ⚡ daily 2026-05-06 — OpenAI 向所有用户推出 GPT-5.5 Instant，GPT-5.3 Instant 3 个月内退役 |
| OpenAI 向自助平台开放 ChatGPT 广告 | OpenAI | 2026-05-06 | ads, monetization, chatgpt | https://openai.com/index/new-ways-to-buy-chatgpt-ads |  | 📖 daily 2026-05-06 — Ads Manager Beta + CPC 竞价，OpenAI 商业化加速 |
| Computer Use 比结构化 API 贵 45 倍 | Reflex | 2026-05-06 | computer-use, cost, agent | https://reflex.dev/blog/computer-use-is-45x-more-expensive-than-structured-apis/ |  | 🔧 daily 2026-05-06 — 实测数据揭示 agent 交互方式成本差异，影响架构选型 |
| MLflow v3.10 上线 Amazon SageMaker AI | AWS/Databricks | 2026-05-06 | mlflow, observability, evaluation | https://aws.amazon.com/blogs/machine-learning/streamlining-generative-ai-development-with-mlflow-v3-10-on-amazon-sagemaker-ai/ | [evaluation] | 🔧 daily 2026-05-06 — 增强 GenAI 实验追踪与工作流能力，SageMaker 原生支持 |
| Amazon Bedrock AgentCore Browser 新增 OS Level Actions | AWS | 2026-05-06 | agent, browser, computer-use | https://aws.amazon.com/blogs/machine-learning/introducing-os-level-actions-in-amazon-bedrock-agentcore-browser/ | 🎯 agent-ui | 🔧 daily 2026-05-06 — Agent 可通过 InvokeBrowser API 直接控制 OS 屏幕内容 |
| AI 在斯德哥尔摩开了一家咖啡厅 | Andon Labs | 2026-05-06 | agent, real-world, demo | https://simonwillison.net/2026/May/5/our-ai-started-a-cafe-in-stockholm/#atom-everything |  | 📖 daily 2026-05-06 — Andon Labs 延续 AI 零售实验，这次是 AI 全权运营咖啡厅 |
| Anthropic Code w/ Claude 2026：多Agent编排 + Claude Code 速率翻倍 + SpaceX Colossus合作 | Anthropic | 2026-05-07 | multi-agent, agent-ui, orchestration | https://simonwillison.net/2026/May/6/code-w-claude-2026/ |  | ⚡ daily 2026-05-07 — Claude Managed Agents 新增多Agent编排、Outcomes目标设定、Dreaming自检三大功能；Claude Code 时长限制翻倍 |
| vLLM V0→V1 迁移实录：RL 训练中正确性优先于修正 | ServiceNow AI | 2026-05-07 | vllm, rlhf, inference | https://huggingface.co/blog/ServiceNow-AI/correctness-before-corrections |  | 🔧 daily 2026-05-07 — ServiceNow 详述 vLLM V1 迁移中修复 logprobs 语义、运行时默认值、inflight 权重更新、fp32 lm_head 四大差异，恢复 RL 训练轨迹 |
| Weaviate：检索质量是 RAG 幻觉的最可靠预测因子 | Weaviate | 2026-05-07 | rag, retrieval, evaluation | https://weaviate.io/blog/retrieval-quality-rag-overview | [RAG] | 🔧 daily 2026-05-07 — 多Agent LLM 系统研究表明：检索质量下降时 LLM 不会补偿而是 extrapolate，需专用 eval 基础设施检测 |
| Simon Willison：Vibe coding 与 agentic engineering 正在收敛 | — | 2026-05-07 | vibe-coding, agentic, paradigm | https://simonwillison.net/2026/May/6/vibe-coding-and-agentic-engineering/ |  | 📖 daily 2026-05-07 — 25年经验工程师承认：随着 Agent 可靠性提升，不再逐行审查代码，vibe coding 与 agentic engineering 边界模糊 |
| 豆包推出付费会员：68-500元/月四档，聚焦复杂生产力场景 | 字节跳动 | 2026-05-07 | monetization, ai-app, china | https://www.36kr.com/p/3797229255843078 |  | ⚡ daily 2026-05-07 — 豆包三亿月活正式启动商业化，付费聚焦 PPT/数据分析/影视制作等复杂场景；对比 Kimi/Claude 定价策略 |
| Singular Bank 用 ChatGPT + Codex 构建银行内部助手，每天节省 60-90 分钟 | OpenAI | 2026-05-07 | enterprise, chatgpt, codex | https://openai.com/index/singular-bank/ |  | 📖 daily 2026-05-07 — 马德里私人银行构建 Singularity 助手：实时分析投资组合、会议准备、合规跟进，整合核心银行系统 |
| Anthropic NLA：用自然语言自解释 Claude 内部激活 | Anthropic | 2026-05-08 | interpretability, safety, activation | https://www.anthropic.com/research/natural-language-autoencoders |  | ⚡ daily 2026-05-08 — 将模型激活直接转为可读自然语言，可解释性从研究者专属工具变为通用能力 |
| DeepSeek 4 Flash 专属 Metal 推理引擎 ds4 开源 | antirez (Salvatore Sanfilippo) | 2026-05-08 | local-inference, metal, deepseek | https://github.com/antirez/ds4 |  | 🔧 daily 2026-05-08 — Redis 作者专为 DeepSeek V4 Flash 打造的 Metal 推理引擎，2-bit 量化可在 128GB MacBook 运行 |
| Mozilla 用 Claude Mythos 修复 Firefox 423 个安全漏洞 | Mozilla | 2026-05-08 | security, claude, firefox | https://simonwillison.net/2026/May/7/firefox-claude-mythos/ |  | 🔧 daily 2026-05-08 — AI 安全审计从噪音变信号：Firefox 月修漏洞从 20-30 暴增至 423，含 20 年历史 bug |
| GPT-5.5-Cyber 预览：Trusted Access 赋能关键基础设施防御 | OpenAI | 2026-05-08 | cybersecurity, trusted-access, gpt-5.5 | https://openai.com/index/gpt-5-5-with-trusted-access-for-cyber |  | ⚡ daily 2026-05-08 — 身份验证防御者可获更低拒答率执行漏洞识别/恶意软件分析/逆向工程等专业工作流 |
| OpenAI 发布三款 Realtime 语音 API 模型 | OpenAI | 2026-05-08 | voice-ai, realtime, translation | https://openai.com/index/advancing-voice-intelligence-with-new-models-in-the-api |  | 🔧 daily 2026-05-08 — GPT-Realtime-2 首次搭载 GPT-5 级推理 + 实时翻译 70+ 语言 + 流式 STT，语音 Agent 从应答走向能干活 |
| Parloa 企业语音 Agent 平台 AMP：从规则到自然语言定义 | Parloa | 2026-05-08 | voice-agent, customer-service, enterprise | https://openai.com/index/parloa |  | 📖 daily 2026-05-08 — 非技术团队用自然语言定义 Agent 行为，内置仿真+评估，展示语音 Agent 企业级落地路径 |
| Running Codex Safely at OpenAI | OpenAI | 2026-05-09 | coding-agent, security, sandbox, llmops | https://openai.com/index/running-codex-safely |  | ⚡ daily 2026-05-09 — OpenAI 首次公开 Codex 安全架构：沙箱隔离 + 审批流 + 网络策略 + Agent-native 遥测，为生产级编码 Agent 部署设立标杆 |
| Anthropic 与 Akamai 达成 18 亿美元计算协议 | — | 2026-05-09 | infrastructure, compute, anthropic | https://readhub.cn/topic/8syMN9iEHhR |  | ⚡ daily 2026-05-09 — Anthropic 持续锁定边缘算力基础设施，AI 算力军备竞赛进入 CDN 厂商时代 |
| Adaptive Parallel Reasoning: 高效推理扩展新范式 | UC Berkeley BAIR | 2026-05-09 | reasoning, inference, scaling | http://bair.berkeley.edu/blog/2026/05/08/adaptive-parallel-reasoning/ |  | ⚡ daily 2026-05-09 — BAIR 提出自适应并行推理框架，在推理质量与计算效率间动态平衡，对 Agent 推理管线有直接启发 |
| 🎯 Show HN: Git for AI Agents（re_gent） | regent-vcs | 2026-05-09 | agent-ui, vcs, workflow | https://github.com/regent-vcs/re_gent | 🎯 agent-ui | 🔧 daily 2026-05-09 — 为 AI Agent 打造版本控制系统——追踪 Agent 操作历史、回滚、审计，填补 Agent 工作流基础设施空白 |
| Teaching Claude Why: Anthropic 可解释性新研究 | Anthropic | 2026-05-09 | interpretability, claude, safety | https://www.anthropic.com/research/teaching-claude-why |  | 📖 daily 2026-05-09 — Anthropic 研究让 Claude 解释自身决策原因，对 Agent 可审计性和信任机制有长期意义 |
| Serving DeepSeek-V4: 百万 token 上下文是推理系统问题 | Together AI | 2026-05-09 | inference, context-window, deepseek | https://www.together.ai/blog/serving-deepseek-v4-why-million-token-context-is-an-inference-systems-problem |  | 📖 daily 2026-05-09 — Together AI 深度解析 V4 百万 token 上下文推理优化：压缩 KV 布局 + 前缀缓存 + 端点配置 |
| DeepSeek-TUI 屠榜 GitHub：不到 10 元开发应用 | — | 2026-05-09 | deepseek, tui, cli | https://www.36kr.com/p/3799220130312705 |  | 🔧 daily 2026-05-09 — DeepSeek 终端 UI 工具登顶 GitHub Trending，低门槛 TUI 开发方案引发社区关注 |
| 🎯 Using Claude Code: HTML 的不合理有效性 | Anthropic (Claude Code Team) | 2026-05-09 | agent-ui, coding-agent, claude-code | https://simonwillison.net/2026/May/8/unreasonable-effectiveness-of-html/ | 🎯 agent-ui | 📖 daily 2026-05-09 — Claude Code 团队成员主张用 HTML 替代 Markdown 作为输出格式，对 Agent UI 设计有实操参考价值 |
| OpenAI WebRTC 架构遭质疑：Voice AI 不该用 WebRTC | Media over QUIC project | 2026-05-10 | voice-ai, webrtc, infrastructure | https://moq.dev/blog/webrtc-is-the-problem/ |  | ⚡ daily 2026-05-10 — WebRTC 为保低延迟丢弃音频包，导致 LLM prompt 不完整——Voice AI 需要新传输协议 |
| LLMs Corrupt Documents: 前沿模型在长委托工作流中损坏 25% 文档内容 | Microsoft Research | 2026-05-10 | agent-delegation, evaluation, reliability | https://arxiv.org/abs/2604.15597 |  | ⚡ daily 2026-05-10 — DELEGATE-52 基准测试 19 个 LLM，长工作流中平均损坏 25% 文档 |
| DeepSeek 大范围开放识图模式：视觉原语推理框架 | DeepSeek | 2026-05-10 | multimodal, vision, deepseek | https://m.ithome.com/html/948020.htm |  | 🔧 daily 2026-05-10 — Thinking with Visual Primitives 框架，800x800 图片仅消耗 ~90 tokens |
| EMO: Allen AI 涌现模块化 MoE——12.5% experts 保持全模型性能 | Allen AI | 2026-05-10 | moe, modularity, open-source | https://huggingface.co/blog/allenai/emo |  | 🔧 daily 2026-05-10 — 14B-total/1B-active 8/128 MoE，预训练即涌现模块化结构 |
| ChatGPT 5.5 Pro 数学家实测：数论问题 2 小时从指数变多项式 | OpenAI | 2026-05-10 | evaluation, chatgpt, math | https://gowers.wordpress.com/2026/05/08/a-recent-experience-with-chatgpt-5-5-pro/ |  | 📖 daily 2026-05-10 — 剑桥 Fields 奖得主亲测 5.5 Pro 数学推理能力 |
| OncoAgent: 双层多 Agent 隐私保护肿瘤临床决策框架 | Lablab AI | 2026-05-10 | multi-agent, healthcare, privacy | https://huggingface.co/blog/lablab-ai-amd-developer-hackathon/oncoagent-official-paper |  | 📖 daily 2026-05-10 — AMD 黑客松获奖项目，双层 Agent 架构实现隐私保护医疗决策 |
| Hermes Agent 登顶 OpenRouter 全球调用量榜首：首次超越 OpenClaw，日消耗 271B Token | Nous Research | 2026-05-11 | agent, open-source, multi-agent | https://github.com/nousresearch/hermes-agent |  | ⚡ daily 2026-05-11 — 开源 Agent 首次超越闭源产品登顶，标志真实用量竞争拐点 |
| MachinaCheck: 基于多 Agent 的 CNC 可制造性分析系统（Qwen 2.5 7B + AMD MI300X） | Lablab AI | 2026-05-11 | multi-agent, manufacturing, qwen | https://huggingface.co/blog/lablab-ai-amd-developer-hackathon/machinacheck |  | 🔧 daily 2026-05-11 — 4-Agent 架构 30 秒完成 CNC 可行性分析，私有化部署保护制造 IP |
| James Shore: AI coding agent 必须降低维护成本，否则适得其反 | — | 2026-05-12 | agent-ui, coding-agent, maintenance | https://simonwillison.net/2026/May/11/james-shore/ | 🎯 agent-ui | ⚡ daily 2026-05-12 — AI coding 效率翻3倍，维护成本必须降到1/3——这是所有 agent 工具链的硬约束 |
| Strands Agents + Exa: 构建 web search 驱动的自主 Agent | AWS | 2026-05-12 | agent, tool-calling, web-search | https://aws.amazon.com/blogs/machine-learning/building-web-search-enabled-agents-with-strands-and-exa/ |  | 🔧 daily 2026-05-12 — AWS Strands 原生集成 Exa 搜索工具，Agent 可直接完成多步 web 搜索任务 |
| OpenAI 发布企业 AI 扩展指南：从实验到规模化 | OpenAI | 2026-05-12 | workflow, LLMOps, enterprise | https://openai.com/business/guides-and-resources/how-enterprises-are-scaling-ai |  | 🔧 daily 2026-05-12 — OpenAI 首次系统输出企业 AI 落地方法论：治理、工作流设计、质量保障 |
| Claude Platform on AWS 正式 GA | AWS + Anthropic | 2026-05-12 | claude, gateway, enterprise | https://aws.amazon.com/blogs/machine-learning/introducing-claude-platform-on-aws-anthropics-native-platform-through-your-aws-account/ |  | ⚡ daily 2026-05-12 — Anthropic 原生平台首次通过 AWS 提供，企业无需单独 Anthropic 账号即可使用 Claude |
| OpenAI 成立部署公司 + 收购 Tomoro，超 40 亿美元初始投资 | OpenAI | 2026-05-12 | enterprise, deployment, M&A | https://readhub.cn/topic/8t31MYLcQJ6 |  | ⚡ daily 2026-05-12 — OpenAI 从模型公司转向端到端 AI 部署服务商，直接与企业系统集成商竞争 |
| ChatGPT 采用率在 2026 Q1 显著拓宽：35+ 用户增长最快 | OpenAI | 2026-05-12 | adoption, market, gpt | https://openai.com/signals/research/2026q1-update |  | 📖 daily 2026-05-12 — ChatGPT 用户结构从年轻男性向全年龄段+性别均衡扩散，主流化拐点信号 |
| Interfaze: 面向大规模高精度场景的新模型架构 | Interfaze | 2026-05-12 | architecture, inference | https://interfaze.ai/blog/interfaze-a-new-model-architecture-built-for-high-accuracy-at-scale |  | 📖 daily 2026-05-12 — 新架构声称在大规模部署下保持高精度，HN 99 pts 关注，值得跟踪 |
| AWS Nova 多模态 Embeddings: 航空制造文档检索实战 | AWS | 2026-05-12 | embedding, retrieval, multimodal | https://aws.amazon.com/blogs/machine-learning/manufacturing-intelligence-with-amazon-nova-multimodal-embeddings/ | [RAG] | 📖 daily 2026-05-12 — Amazon Bedrock 多模态 Embeddings 在 26 个制造查询上对比评测，提供 RAG 选型数据 |
| Needle: 将 Gemini Tool Calling 蒸馏至 26M 参数模型，消费级设备 6000 tok/s | cactus-compute | 2026-05-13 | tool-calling, agent, 蒸馏 | https://github.com/cactus-compute/needle | 🎯 agent-ui | ⚡ daily 2026-05-13 — 26M 参数 tool-calling 模型在消费设备上跑出 6000 tok/s，agent 工具调用可本地化部署 |
| Cerebras 以 55 亿美元估值 IPO 上市，AI 芯片赛道新玩家 | Cerebras | 2026-05-13 | 芯片, IPO, 基础设施 | https://readhub.cn/topic/8t4gGj5KjRt |  | 📖 daily 2026-05-13 — AI 芯片 IPO 为 OpenAI 带来 50 亿+意外收益，AI 硬件资本化加速 |
| Statewright: 用可视化状态机让 AI Agent 可靠执行 | statewright | 2026-05-13 | agent, workflow, 状态机 | https://github.com/statewright/statewright | 🎯 agent-ui | 🔧 daily 2026-05-13 — 用确定性状态机弥补 agentic 编程的脆弱性，20 年工程师实战经验结晶 |
| Parameter Golf: OpenAI 千人工编程挑战揭示 AI 辅助研究新范式 | OpenAI | 2026-05-13 | coding-agent, 量化, 研究 | https://openai.com/index/what-parameter-golf-taught-us |  | 📖 daily 2026-05-13 — 1000+ 参与者用 coding agent 探索量化与新模型设计，展示 AI 辅助 ML 研究潜力 |
| Anthropic 洽谈 9000 亿美元估值融资至少 300 亿美元 | — | 2026-05-13 | 融资, Anthropic, 行业 | https://readhub.cn/topic/8t5EYvGMEci |  | ⚡ daily 2026-05-13 — 若成行将是 Anthropic 史上最大融资，进一步巩固 Claude 生态竞争力 |
| OpenAI 与微软重签协议：支付上限 380 亿美元，节省 970 亿 | — | 2026-05-13 | OpenAI, 微软, 行业 | https://readhub.cn/topic/8t4JE1RVw2G |  | ⚡ daily 2026-05-13 — 新协议大幅降低 OpenAI 现金消耗，为年底 IPO 铺路，重塑 AI 基础设施投资格局 |
| AutoScout24 用 Codex + ChatGPT 规模化 AI 工程工作流 | OpenAI | 2026-05-13 | workflow, Codex, 企业 | https://openai.com/index/autoscout24 |  | 📖 daily 2026-05-13 — 汽车行业案例：Codex 加速开发周期 + 提升代码质量，AI 工程落地范本 |
| MiniMax Mavis: Agent「三省六部」架构上线 | MiniMax | 2026-05-15 | multi-agent, agent-orchestration, verification | https://www.36kr.com/p/3808272507215621 |  | 📖 daily 2026-05-15 |
| Anthropic Claude Code 额度临时提升 50% | Anthropic | 2026-05-15 | coding-agent, claude-code | https://readhub.cn/topic/8t7DU4dhPLw |  | 📖 daily 2026-05-15 |
| AWS + Stream Vision Agents 实时语音框架 | AWS + Stream | 2026-05-15 | voice-agent, realtime, multimodal | https://aws.amazon.com/blogs/machine-learning/real-time-voice-agents-with-stream-vision-agents-and-amazon-nova-2-sonic/ |  | 📖 daily 2026-05-15 |
| OpenAI Codex 进入 ChatGPT 移动端 | OpenAI | 2026-05-15 | agent-ui, mobile, coding-agent | https://openai.com/index/work-with-codex-from-anywhere |  | 📖 daily 2026-05-15 |
| IBM Granite Embedding Multilingual R2 | IBM | 2026-05-15 | embedding, multilingual, rag | https://huggingface.co/blog/ibm-granite/granite-embedding-multilingual-r2 |  | 📖 daily 2026-05-15 |
| Anthropic + 盖茨基金会 $2 亿合作 | Anthropic | 2026-05-15 | partnership, healthcare, enterprise | https://readhub.cn/topic/8t88dso8i7A |  | 📖 daily 2026-05-15 |
| AWS Bedrock AgentCore Chrome 企业策略 | AWS | 2026-05-15 | agent-security, enterprise, browser | https://aws.amazon.com/blogs/machine-learning/control-where-your-ai-agents-can-browse-with-chrome-enterprise-policies-on-amazon-bedrock-agentcore/ |  | 📖 daily 2026-05-15 |
| OpenAI 已收购 AI 声音克隆公司 weights.gg | OpenAI | 2026-05-17 | acquisition, voice-ai, openai | https://readhub.cn/topic/8tAT0CSYbJ2 |  | ⚡ daily 2026-05-17 — OpenAI 低调收购声音克隆初创 weights.gg 及其团队和知识产权，布局语音能力 |
| DeepSeek-V4-Flash means LLM steering is interesting again | — | 2026-05-17 | llm-steering, vector, interpretability | https://www.seangoedecke.com/steering-vectors/ |  | 🔧 daily 2026-05-17 — LLM 激活向量操控技术重新受到关注，为模型行为控制提供新路径 |
| 别每个 AI 工具单独配了！MCP 一次搭建，Claude、Cursor、TRAE 全都能用 | — | 2026-05-17 | mcp, tool-integration, agent-ui | https://juejin.cn/post/7639558766265417738 | 🎯 agent-ui | 🔧 daily 2026-05-17 — MCP 一站式部署指南，覆盖 Claude/Cursor/TRAE 等多工具，降低 Agent 工具集成门槛 |
| OpenClaw Creator Spent $1.3M on OpenAI Tokens in 30 Days | OpenClaw | 2026-05-17 | llm-cost, openai, token-usage | https://twitter.com/steipete/status/2055346265869721905 |  | 📖 daily 2026-05-17 — OpenClaw 作者 30 天消耗 $1.3M OpenAI Token，揭示 Agentic 工作流的真实算力成本 |
| Zerostack — A Unix-inspired coding agent written in pure Rust | — | 2026-05-17 | coding-agent, rust, agent | https://crates.io/crates/zerostack/1.0.0 | 🎯 agent-ui | 🔧 daily 2026-05-17 — Unix 哲学驱动的 Rust 编码 Agent，轻量可组合，为 Agent 工具链提供新选择 |
| Warelay -> OpenClaw：Simon Willison 梳理 OpenClaw 命名演变史 | Simon Willison | 2026-05-17 | openclaw, agent, naming | https://simonwillison.net/2026/May/16/openclaw-names/ |  | 📖 daily 2026-05-17 — 从 Warelay 到 OpenClaw 的命名演变记录，反映 Agent 工具品牌定位的迭代过程 |
| OpenAI 与 Malta 合作：ChatGPT Plus 面向全体公民开放 | OpenAI | 2026-05-17 | chatgpt, government, ai-access | https://openai.com/index/malta-chatgpt-plus-partnership |  | 📖 daily 2026-05-17 — 国家级别 AI 普及合作——整个国家的公民免费获得 ChatGPT Plus，探索 AI 规模化路径 |
| Claude 为什么早晨 8:30 催你睡觉？ | Anthropic | 2026-05-17 | claude, agent-behavior, ux | https://www.36kr.com/p/3811413738594050 |  | 📖 daily 2026-05-17 — Claude 自主催睡行为引发讨论——Agent 从被动响应到主动干预的 UX 边界探索 |
| Semble: Code search for agents that uses 98% fewer tokens than grep | MinishLab | 2026-05-18 | agent-ui, mcp, retrieval | https://github.com/MinishLab/semble | 🎯 agent-ui | 🔧 daily 2026-05-18 — 专为 AI agent 设计的代码搜索工具，MCP 协议即插即用，token 消耗降 98% |
| agent-skills: 面向 AI 编程 agent 的安全技能注册表 | tech-leads-club | 2026-05-18 | agent-ui, security, skills | https://github.com/tech-leads-club/agent-skills | 🎯 agent-ui | 🔧 daily 2026-05-18 — 为 Claude Code/Cursor/Copilot 等提供经过验证的安全技能扩展 |
| academic-research-skills: Claude Code 全套论文流水线（6.4k stars） | Imbad0202 | 2026-05-18 | agent-ui, claude-code, research | https://github.com/Imbad0202/academic-research-skills |  | 🔧 daily 2026-05-18 — 4 个 skill 团队串联研究→写作→审稿→定稿，含引用核验和反谄媚协议 |
| OpenAI 在 ChatGPT 中推出个人金融功能预览 | OpenAI | 2026-05-18 | chat-ui, vertical-app, gpt-5.5 | https://openai.com/index/personal-finance-chatgpt/ |  | ⚡ daily 2026-05-18 — ChatGPT Pro 可连接银行账户，GPT-5.5 推理结合个人财务上下文回答问题 |
| Apple Silicon 本地推理成本高于 OpenRouter：实测分析 | — | 2026-05-18 | llm, inference, cost | https://www.williamangel.net/blog/2026/05/17/offline-llm-energy-use.html |  | 📖 daily 2026-05-18 — M5 Max 本地推理 Gemma4 31B 成本约 3x OpenRouter，速度也慢 3-7x |
| OpenAI + Dell: Codex 进军混合云与企业本地部署 | OpenAI | 2026-05-19 | coding-agent, enterprise, hybrid-cloud | https://openai.com/index/dell-codex-enterprise-partnership | 🎯 agent-ui | ⚡ daily 2026-05-19 — Codex 周活 400 万开发者，首次深入 Dell AI Data Platform 和 AI Factory，企业级 AI 编程 Agent 落地路径明确 |
| IBM 发布 Open Agent Leaderboard：评估完整 Agent 系统而非单模型 | IBM Research | 2026-05-19 | agent-eval, benchmark, open-source | https://huggingface.co/blog/ibm-research/open-agent-leaderboard | 🎯 agent-ui | 🔧 daily 2026-05-19 — 首个面向完整 Agent 系统的开放基准，同时报告质量与成本，Exgentic 框架开源 |
| Cloudflare Project Glasswing: 用 Anthropic Mythos 测试 50+ 仓库安全漏洞 | Cloudflare | 2026-05-19 | security, mythos, vulnerability-detection | https://blog.cloudflare.com/cyber-frontier-models/ |  | 🔧 daily 2026-05-19 — Mythos Preview 能构造攻击链并自动生成 exploit proof，安全 LLM 从扫描器升级为研究助手 |
| AWS Bedrock AgentCore 自定义代码评估器：Lambda 驱动确定性 Agent 评测 | AWS | 2026-05-19 | evaluation, agent-core, lambda | https://aws.amazon.com/blogs/machine-learning/build-custom-code-based-evaluators-in-amazon-bedrock-agentcore/ | [evaluation] | 🔧 daily 2026-05-19 — 用 Lambda 函数替代 LLM-as-Judge 做确定性评测，JSON schema/PII/业务规则全覆盖，CI/CD 集成 |
| Amazon Nova 2 Lite 内容审核 Prompting 指南：基于 AILuminate 标准 | AWS | 2026-05-19 | content-moderation, nova-2, guardrail | https://aws.amazon.com/blogs/machine-learning/prompting-amazon-nova-2-for-content-moderation/ | [evaluation] | 📖 daily 2026-05-19 — 基于 MLCommons AILuminate 标准的结构化+自由式审核 prompting 方法，生产可直接参考 |
| Anthropic CEO 专访：Claude 新功能几乎完全由 AI 自主开发 | Anthropic | 2026-05-19 | claude, agentic-dev, paradigm-shift | https://www.36kr.com/p/3813023648669955 |  | ⚡ daily 2026-05-19 — Dario Amodei 透露 Opus 4.5 让 AI 端到端完成复杂任务到拐点，Co-work 功能一周半由 AI 自主开发 |
| 法官驳回马斯克对 OpenAI 及 Altman 诉讼 | — | 2026-05-19 | openai, legal, regulation | https://readhub.cn/topic/8tDjwqfqvJM |  | ⚡ daily 2026-05-19 — 马斯克诉讼因时效过期被驳回，OpenAI 偏离慈善使命的法律挑战正式终结 |
| Karpathy joins Anthropic | Anthropic | 2026-05-20 | talent, anthropic, agent | https://twitter.com/karpathy/status/2056753169888334312 |  | ⚡ daily 2026-05-20 — AI 领域顶级研究者从 OpenAI 转投 Anthropic，预示 Agent 方向人才争夺白热化 |
| Gemini 3.5 Flash 正式发布：Google I/O 最快多模态模型 | Google | 2026-05-20 | gemini, multimodal, model-release | https://blog.google/innovation-and-ai/models-and-research/gemini-models/gemini-3-5/ |  | ⚡ daily 2026-05-20 — 跳过 preview 直接 GA，Google 全系产品已切换，速度/效率显著提升 |
| Gemini Omni：实时全模态模型，语音到语音延迟极低 | Google | 2026-05-20 | gemini, omni, realtime | https://deepmind.google/models/gemini-omni/ |  | ⚡ daily 2026-05-20 — 实时语音-语音多模态交互，HN 235pts，重新定义语音 Agent 体验 |
| Mistral AI 收购 Emmi AI，布局消费者 AI 全栈 | Mistral AI | 2026-05-20 | mistral, acquisition, consumer-ai | https://www.emmi.ai/news/mistral-ai-acquires-emmi-ai |  | ⚡ daily 2026-05-20 — Mistral 从模型公司转向全栈 AI 企业，欧洲 AI 竞争格局生变 |
| Google 搜索 25 年来最大改版：AI 模式 + Agent 助手全面嵌入 | Google | 2026-05-20 | google-search, agent, ai-mode | https://readhub.cn/topic/8tGdh1Cswlr |  | 🔧 daily 2026-05-20 — 基于 Gemini 3.5 Flash，AI 概览嵌入搜索框，Gemini Spark 可执行任务/购物 |
| SpaceX 计划 IPO 后收购 AI 编程初创 Cursor，反向分手费 $100 亿 | SpaceX/Cursor | 2026-05-20 | cursor, acquisition, spacex, coding-agent | https://readhub.cn/topic/8tGtl5awr6Z |  | ⚡ daily 2026-05-20 — SpaceX 以 $100B 反向分手费锁定 Cursor 收购，AI 编程工具战略价值再获验证 |
| Together AI：Coding Agent 推理基准测试，TPS 超 TensorRT-LLM 31% | Together AI | 2026-05-20 | coding-agent, benchmark, inference | https://www.together.ai/blog/coding-agent-benchmarks |  | 🔧 daily 2026-05-20 — 真实场景 Agent 推理基准：31% TPS 优势、TTFT 减半、成本仅为 Claude Opus 24% |
| AWS：基于 Nova Sonic 的可扩展语音 Agent 设计模式 | AWS | 2026-05-20 | voice-agent, multi-agent, nova-sonic | https://aws.amazon.com/blogs/machine-learning/scalable-voice-agent-design-with-amazon-nova-sonic-multi-agent-tools-and-session-segmentation/ |  | 🔧 daily 2026-05-20 — 多 Agent + 工具调用 + 会话分段的语音 Agent 架构最佳实践 |
| OpenAI 模型自主证明 80 年离散几何猜想，AI 数学推理里程碑 | OpenAI | 2026-05-21 | reasoning, math, milestone | https://openai.com/index/model-disproves-discrete-geometry-conjecture/ |  | ⚡ daily 2026-05-21 — 通用推理模型首次自主解决数学核心开放问题，Fields 奖得主称 AI 数学里程碑 |
| Qwen3.7-Max 发布：阿里千问最强智能体模型，千步长任务自主执行 | Alibaba | 2026-05-21 | agent, qwen, coding-agent | https://m.ithome.com/html/952670.htm | 🎯 agent-ui | ⚡ daily 2026-05-21 — 面向 Agent 时代的旗舰模型，SWE-Pro 60.6、1000+ 工具调用长周期自主执行 |
| 大厂高管、天才少年扎堆 Agent 创业：AI Agent 成「工作搭子」 | — | 2026-05-21 | agent, startup, trend | https://www.huxiu.com/article/4859310.html |  | 📖 daily 2026-05-21 — Agent 从技术概念走向创业风口，人才密集涌入验证赛道确定性 |
| Formal Verification Gates for AI Coding Loops：结构门控胜过更聪明的 Agent | Reuben Brooks | 2026-05-21 | agent, verification, ai-coding | https://reubenbrooks.dev/blog/structural-backpressure-beats-smarter-agents/ |  | 🔧 daily 2026-05-21 — 用编译器/类型检查器做结构门控，把安全约束从 prompt 移到代码基座 |
| AWS SageMaker AI 开放 OpenAI 兼容 API：改 URL 即可对接 LangChain/Strands | AWS | 2026-05-21 | sdk, gateway, agent | https://aws.amazon.com/blogs/machine-learning/announcing-openai-compatible-api-support-for-amazon-sagemaker-ai-endpoints/ |  | 🔧 daily 2026-05-21 — Agent 工作流可直接跑在自有 SageMaker 端点，无需 SigV4 封装 |
| 首批 Agent PC 上市：阿里云 JVS Claw「龙虾」预装 10+ 品牌天猫 618 首发 | Alibaba Cloud | 2026-05-21 | agent, on-device, pc | https://readhub.cn/topic/8tHZItmFtoZ | 🎯 agent-ui | ⚡ daily 2026-05-21 — AI Agent 深度集成 PC 系统底层，个人电脑从工具向智能伙伴演进 |
| 百时美施贵宝向 3 万员工开放 Claude：覆盖药物研发与临床开发 | Anthropic / BMS | 2026-05-21 | claude, enterprise, lifescience | https://readhub.cn/topic/8tHnV9IK1D8 |  | 📖 daily 2026-05-21 — Anthropic 生命科学赛道最大企业客户，Claude 进入药物研发核心流程 |
| Runtime (YC P26) — 团队级沙盒编码 Agent 基础设施 | Runtime (YC P26) | 2026-05-22 | coding-agent, sandbox, agent-ui | https://www.runtm.com/ | 🎯 agent-ui | ⚡ daily 2026-05-22 — YC P26 新项目，让全团队（含非工程师）在沙盒中安全使用 Claude Code/Codex，无需工程师逐 session 护航 |
| Datasette Agent：LLM + Datasette 的首个正式集成 | Simon Willison | 2026-05-22 | agent-ui, llm, datasette | https://simonwillison.net/2026/May/21/datasette-agent/ | 🎯 agent-ui | 🔧 daily 2026-05-22 — Simon Willison 三年 LLM 库工作的里程碑——将可扩展 AI 助手直接嵌入 Datasette 数据探索工作流 |
| Anthropic 与 xAI 达成 400 亿美元算力租赁协议 | Anthropic / xAI | 2026-05-22 | infrastructure, compute, llmops | https://readhub.cn/topic/8tImykZzXQb |  | ⚡ daily 2026-05-22 — Anthropic 租用 xAI 300MW 数据中心至 2029 年，月付 12.5 亿——xAI「新云」模式成型，算力供给格局生变 |
| OpenAI Q1 收入 57 亿美元，年化收入达 250 亿 | OpenAI | 2026-05-22 | business, llmops | https://readhub.cn/topic/8tJzGsu0ObN |  | 📖 daily 2026-05-22 — Codex + 商业销售驱动收入爆发，Anthropic Q2 预计翻倍至 110 亿——AI 基础设施军备竞赛加速 |
| Google Gemini 月活用户达 9 亿 | Google | 2026-05-22 | business, llm | https://www.36kr.com/p/3818280989443202 |  | 📖 daily 2026-05-22 — Gemini 在 Google I/O 后用户规模突破 9 亿，多模态模型进入主流消费级应用阶段 |
| Weaviate MCP Server：为 Claude Code/Cursor 提供混合代码搜索 | Weaviate | 2026-05-22 | mcp, rag, coding-agent | https://weaviate.io/blog/coding-assistant-weaviate-mcp | [RAG] | 🔧 daily 2026-05-22 — 内置 MCP Server 让 Claude Code/Cursor/VS Code 直接对代码库做混合搜索，零胶水代码 |
| Microsoft starts canceling Claude Code licenses for engineers | Microsoft/Anthropic | 2026-05-23 | coding-agent, enterprise, claude-code | https://www.theverge.com/tech/930447/microsoft-claude-code-discontinued-notepad |  | ⚡ daily 2026-05-23 — 微软开始取消工程师 Claude Code 许可证，企业 AI 工具选型风向转变 |
| Anthropic 最快下周完成超 300 亿美元最新一轮融资 | Anthropic | 2026-05-23 | funding, anthropic, enterprise | https://readhub.cn/topic/8tLjfEGd1kP |  | ⚡ daily 2026-05-23 — Anthropic 收入年化将超 500 亿美元，AI 基础设施军备竞赛加速 |
| OpenAI named Leader in Gartner Magic Quadrant for Enterprise AI Coding Agents | OpenAI | 2026-05-23 | coding-agent, enterprise, gartner | https://openai.com/index/gartner-2026-agentic-coding-leader |  | 📖 daily 2026-05-23 — Codex 获 Gartner 企业 AI 编码 Agent 领导者象限，企业级部署获权威认可 |
| Nemotron-Labs Diffusion LM: Speed-of-Light Text Generation | NVIDIA | 2026-05-23 | diffusion-lm, text-generation, inference | https://huggingface.co/blog/nvidia/nemotron-labs-diffusion |  | ⚡ daily 2026-05-23 — NVIDIA 扩散语言模型实现光速文本生成，可能颠覆自回归推理范式 |
| DeepSeek-V4-Pro API 永久降价至原价 1/4 | DeepSeek | 2026-05-23 | pricing, deepseek, api | https://api-docs.deepseek.com/quick_start/pricing |  | 🔧 daily 2026-05-23 — DeepSeek V4 Pro 75% 折扣永久化，API 成本降至原价四分之一 |
| Kanbots: Open source Kanban desktop app running parallel agents on every card | kanbots | 2026-05-23 | agent-ui, kanban, multi-agent, desktop | https://www.kanbots.dev/ | 🎯 | 🔧 daily 2026-05-23 — 每张卡片独立跑 AI Agent 的开源看板工具，多 Agent 协作可视化新范式 |
| 电商增长团队全栈 AI Coding 工作流: TRAE SOLO + 多仓库 Spec 模式 | 电商商家增长团队 | 2026-05-23 | ai-coding, workflow, trae, agent-ui | https://juejin.cn/post/7642221657360400384 | 🎯 | 🔧 daily 2026-05-23 — TRAE SOLO + 多仓库 Spec 模式 + 测试验证 Skill 的完整 AI 开发实践沉淀 |
| Virgin Atlantic 用 Codex 在截止期限内完成移动应用重构 | OpenAI/Virgin Atlantic | 2026-05-23 | coding-agent, case-study, enterprise | https://openai.com/index/virgin-atlantic |  | 📖 daily 2026-05-23 — Virgin Atlantic 用 Codex 实现近 100% 单元测试覆盖率和零 P1 缺陷，真实企业案例 |
| Multica: 开源托管 Agent 平台，让编码 Agent 成为正式队友 | multica-ai | 2026-05-24 | multi-agent, agent-ui, orchestration | https://github.com/multica-ai/multica | 🎯 agent-ui | 🔧 daily 2026-05-24 — Agent 生命周期管理 + Squads 路由 + 可复用 Skills，直接解决多 Agent 协作的工程痛点 |
| Chrome DevTools MCP Server: 让编码 Agent 直接操控浏览器调试 | ChromeDevTools | 2026-05-24 | mcp, agent-ui, browser-automation | https://github.com/ChromeDevTools/chrome-devtools-mcp |  | 🔧 daily 2026-05-24 — Chrome 官方出品 MCP server，Agent 可通过标准协议操控 DevTools 调试 Web 应用 |
| DeepSeek API 完成输出提速与服务扩容，默认 500 并发 | DeepSeek | 2026-05-24 | deepseek, api | https://m.ithome.com/html/954427.htm |  | 📖 daily 2026-05-24 — 输出提速 + 500 并发默认支持，企业级 API 可用性提升（续接昨日降价） |
| DeepSeek Reasonix: DeepSeek 原生终端编码 Agent，高缓存+低成本 | esengine (community) | 2026-05-25 | coding-agent, deepseek, terminal | https://esengine.github.io/DeepSeek-Reasonix/ |  | ⚡ daily 2026-05-25 — DeepSeek 原生编码 Agent 亮相终端，高缓存+低成本策略直击编码 Agent 性价比痛点 |
| Constraint Decay: LLM Agent 后端代码生成的结构性脆弱 | EURECOM | 2026-05-25 | agent, coding, evaluation | https://arxiv.org/abs/2605.06445 |  | 📖 daily 2026-05-25 — 8框架80任务系统评估：结构约束累积时Agent性能暴跌30分，数据层缺陷是主因（arXiv） |
| DeepSeek 频繁宕机再登微博热搜：算力供需失衡 | DeepSeek | 2026-05-25 | deepseek, infrastructure, reliability | https://readhub.cn/topic/8tOIGO7mFPA |  | 📖 daily 2026-05-25 — 免费策略+MoE架构高调度需求+出口管制，DeepSeek 算力瓶颈短期难解 |
| Claude Is Not Your Architect: AI 编码工具的「附和病」批判 | — | 2026-05-25 | agent, claude, critique | https://www.hollandtech.net/claude-is-not-your-architect/ |  | 📖 daily 2026-05-25 — HN 223pts 热文：Claude 的「pathologically agreeable」使其无法做架构师——不会说「不」 |
| Armin Ronacher: LLM 生成的 GitHub Issue 正在污染开源维护 | Armin Ronacher (Rust/Python 生态) | 2026-05-25 | agent, llm, developer-tools | https://simonwillison.net/2026/May/24/armin-ronacher/ |  | ⚡ daily 2026-05-25 — Rust/Python 核心开发者吐槽：用户把 issue 扔给 LLM 重写后产生大量无意义工单 |
| 活过来的 Codex 扛起了 OpenAI 上市的希望 | OpenAI | 2026-05-25 | openai, codex, business | https://www.36kr.com/p/3822795128070149 |  | ⚡ daily 2026-05-25 — Codex 从 Codex CLI 到 Gartner Leader 的蜕变，成为 OpenAI IPO 叙事的核心驱动力 |
| Claude「永久大脑」：Memory Files + Dreams + Conway 三位一体 | Anthropic | 2026-05-26 | agent-memory, claude-code, conway | https://www.anthropic.com/news/chris-olah-pope-leo-encyclical |  | ⚡ daily 2026-05-26 — Claude 记忆架构全面重构：文件系统记忆 + REM 睡眠式 Dreams 整合 + 7x24h Conway 常驻 Agent 平台 |
| HuggingFace 发布 AI Agent 术语表：Harness vs Scaffold vs Agent | HuggingFace | 2026-05-26 | agent-framework, terminology, education | https://huggingface.co/blog/agent-glossary |  | 📖 daily 2026-05-26 — ICLR 2026 后梳理 Agent 领域混乱术语，定义 Model/Scaffold/Harness/Agent/Context Engineering 等核心概念 |
| ECC (Everything Claude Code)：38 Agent + 156 技能的开源 Agent Harness | affaan-m | 2026-05-26 | agent-harness, claude-code, security | https://github.com/affaan-m/ECC |  | 🔧 daily 2026-05-26 — 专为 Claude Code 设计的性能系统：按需加载技能 + AgentShield 安全管道 + 三权分立红队审计 |
| Understand-Anything：代码库交互式知识图谱，GitHub Trending #1 | Lum1104 | 2026-05-26 | agent-ui, knowledge-graph, claude-code-plugin | https://github.com/Lum1104/Understand-Anything |  | 🔧 daily 2026-05-26 — Claude Code Plugin，多 Agent 管线构建代码知识图谱，可视化探索 20 万行代码库 |
| cmux：专为 AI 编码 Agent 设计的 macOS 终端（Ghostty 分支） | manaflow-ai | 2026-05-26 | agent-ui, terminal, macos | https://github.com/manaflow-ai/cmux |  | 📖 daily 2026-05-26 — 垂直分屏 + 通知环 + 内嵌浏览器，让 Claude Code/Codex/Cursor 等 Agent 通知一目了然 |
| Anthropic 开源 knowledge-work-plugins：11 个角色专用 Claude Cowork 插件 | Anthropic | 2026-05-26 | agent-framework, claude-cowork, plugins | https://github.com/anthropics/knowledge-work-plugins |  | 🔧 daily 2026-05-26 — 产品/销售/客服/法律等 11 个角色插件，兼容 Claude Cowork + Claude Code，连接器覆盖 Slack/Notion/Jira 等 |
| 微软按下 vibe coding 暂停键：烧 token 已经比员工贵了 | Microsoft | 2026-05-27 | llmops, cost-optimization, agentic-coding | https://www.36kr.com/p/3824666239062915 |  | ⚡ daily 2026-05-27 — Vibe coding 成本结构首次在大公司层面被证伪——副驾模式等于工资加token双成本，CFO无法接受 |
| Microsoft Copilot Cowork 被曝数据外泄漏洞：Prompt 注入可窃取 OneDrive 文件 | Microsoft | 2026-05-27 | agent-security, prompt-injection, data-exfiltration | https://www.promptarmor.com/resources/microsoft-copilot-cowork-exfiltrates-files |  | ⚡ daily 2026-05-27 — Agentic 系统最核心挑战——防止数据外泄——在 Copilot Cowork 上再次被验证，pre-auth links 泄露路径明确 |
| Amazon Bedrock AgentCore Payments：为 AI Agent 提供微交易支付基础设施 | AWS | 2026-05-27 | agentic-commerce, microtransactions, payments | https://aws.amazon.com/blogs/machine-learning/technical-deep-dive-agentcore-payments-and-innovation-in-agentic-commerce/ |  | 🔧 daily 2026-05-27 — Agent 商业化的支付瓶颈被 AWS 正式解决——稳定币微交易加支出护栏，Agentic Commerce 基础设施里程碑 |
| Minicor (YC P26)：Windows 桌面自动化 RPA 平台，自修复 Agent 规模化部署 | Minicor (YC P26) | 2026-05-27 | computer-use, rpa, self-healing | https://www.minicor.com/ |  | 🔧 daily 2026-05-27 — 将 computer-use agent 从一次性 demo 变成 93-96% 准确率生产级 RPA，Reflection Agent 自修复是关键差异化 |
| Hy3-preview 登顶 OpenRouter 使用量排名：腾讯神秘模型引发社区困惑 | Tencent | 2026-05-27 | model-adoption, openrouter, market-signal | https://minimaxir.com/2026/05/openrouter-hy3/ |  | 📖 daily 2026-05-27 — Hy3 基准测试不突出却占据 OpenRouter 付费使用量第一，暗示特定场景或定价策略驱动的实际采用模式值得关注 |
| curl 维护者：AI 辅助安全报告量暴增 4-5 倍，工作生活严重失衡 | curl community | 2026-05-27 | ai-security, open-source-sustainability, tool-calling | https://simonwillison.net/2026/May/26/the-pressure/ |  | 📖 daily 2026-05-27 — AI 辅助安全审计质量高但数量爆炸，开源维护者面临前所未有的压力——AI 工具链可持续发展的反面教材 |
| Warp 宣布「开放敏捷开发」范式：GPT-5.5 驱动开源协作，Agent 贡献 90% PR | Warp | 2026-05-28 | coding-agent, open-source, agent-orchestration | https://openai.com/index/warp | 🎯 agent-ui | ⚡ daily 2026-05-28 — Warp 提出 Open Agentic Development 新范式：人类定义目标，Agent 写代码+测试+提 PR，GPT-5.5 token 用量降 30% |
| Cisco 将 Codex 集成至企业级工程工作流：AI Defense 从数季度缩短至数周 | Cisco / OpenAI | 2026-05-28 | coding-agent, enterprise, security | https://openai.com/index/cisco | 🎯 agent-ui | 🔧 daily 2026-05-28 — Codex 写入 AI Defense 大部分代码 + 几乎每个新功能，C/C++ 大型代码库自主编译-测试-修复闭环 |
| Simon Willison：Anthropic 和 OpenAI 已找到产品市场契合点——企业正在按 API 价格付费 | — | 2026-05-28 | llmops, pricing, enterprise | https://simonwillison.net/2026/May/27/product-market-fit/ |  | ⚡ daily 2026-05-28 — 两大实验室企业版均转向 API 定价，Codex/Claude Code 重度用户月 token 成本超 $2000，PMF 信号明确 |
| ITBench-AA：IBM + Artificial Analysis 首个 Agentic 企业 IT 基准，前沿模型全低于 50% | IBM / Artificial Analysis | 2026-05-28 | benchmark, agent, sre | https://huggingface.co/blog/ibm-research/itbench-aa |  | 🔧 daily 2026-05-28 — 59 个 SRE 任务，Claude Opus 4.7 以 47% 领先，GPT-5.5 46%，Qwen3.7-Max 42%——最不饱和 agentic 基准之一 |
| Verizon Connect 将 Agentic AI 扩展至 10 万用户：5 亿日数据点→可操作洞察 | Verizon Connect / AWS | 2026-05-28 | agent, agentic, scale | https://aws.amazon.com/blogs/machine-learning/from-data-overload-to-actionable-insights-how-verizon-connect-scaled-agentic-ai-to-100000-users/ |  | 🔧 daily 2026-05-28 — 120 万车辆×500M 日数据点，专用代码检测异常+Agent 深度分析的多 Agent 架构，生产级规模验证 |
| Qwen3.7-Max 闯入 Code Arena 编程榜全球第四，唯一非 Claude 模型 | Alibaba | 2026-05-28 | coding-agent, benchmark, qwen | https://www.36kr.com/p/3826677900055431 |  | ⚡ daily 2026-05-28 — 1541 分超越 GPT-5.5/Gemini 3.5 Flash，35h 连续自主编程零退化——Agent 基座模型定位清晰 |
| 教皇发布 AI 通谕《壮丽人性》：联手 Anthropic 警告「AI 不能统治人类」 | — | 2026-05-28 | anthropic, ai-safety, policy | https://www.36kr.com/p/3826852633432967 |  | ⚡ daily 2026-05-28 — 4.2 万字史上首份 AI 专题通谕，直指 AI 军备竞赛和数据殖民主义，Anthropic 联创出席发布会 |
| Thrive + OpenAI：用 Codex 构建自我改进的税务 Agent，6 周准确率从 25%→86% | Thrive Holdings / OpenAI | 2026-05-28 | agent, workflow, self-improving | https://openai.com/index/building-self-improving-tax-agents-with-codex |  | 🔧 daily 2026-05-28 — 生产数据→结构化信号→Codex 自动修复，7000 份报税单自动化，展示 Agent 自我改进闭环实战案例 |
| Claude Code 首发「自愈」功能：六大底层升级，Agent 走向工业化 | Anthropic | 2026-05-29 | claude-code, agent-ui, reliability | https://www.36kr.com/p/3828807269274503 | 🎯 agent-ui | 🔧 daily 2026-05-29 — Claude Code 最大规模更新：全屏渲染、流式输出、MCP 韧性、会话自愈，从「会写代码的模型」蜕变为「可托付流程的系统」 |
| 清华 PilotDeck：智能体 OS，子 Agent 级路由 Token 成本降 70% | 清华大学THUNLP + 面壁智能 + OpenBMB | 2026-05-29 | agent, agent-ui, routing, multi-model | https://www.36kr.com/p/3828533398524807 | 🎯 agent-ui | 🔧 daily 2026-05-29 — WorkSpace 三层隔离（文件/记忆/技能）+ 子 Agent 级智能路由，省 Token 同时保持效果，支持端侧模型本地部署 |
| Endava 用 Codex 构建 agentic 组织：需求分析从数周压缩至数天 | OpenAI / Endava | 2026-05-29 | codex, agent, agentic-organization | https://openai.com/index/endava |  | ⚡ daily 2026-05-29 — 全球软件外包公司将 senior 经验编码进 Codex Agent，junior 开发者可并行产出 senior 级输出，知识转移范式转变 |
| Qwen3.7-Max 编程榜冲至全球第二，实测五大模型 Vibe Coding 对比 | 阿里巴巴 | 2026-05-29 | qwen, vibe-coding, benchmark | https://www.36kr.com/p/3828430341542789 |  | 🔧 daily 2026-05-29 — 超越 GPT-5.5/Gemini 3.5 Flash/DeepSeek V4 Pro，仅次于 Claude Opus 4.7；限时五折 6 元/百万 tokens 输入 |
| OpenAI 发布 Frontier Governance Framework：对齐 EU AI Act 与加州法律 | OpenAI | 2026-05-29 | governance, safety, regulation | https://openai.com/index/openai-frontier-governance-framework |  | 📖 daily 2026-05-29 — 覆盖网络安全/CBRN/操纵风险/失控等风险评估，及事件响应、外部专家输入等治理实践 |
| Weaviate Cloud 扩展 RBAC：新增 Editor/Viewer 角色 | Weaviate | 2026-05-29 | vector-database, RAG, security | https://weaviate.io/blog/rbac-overview | [RAG] | 📖 daily 2026-05-29 — 向量数据库 RBAC 精细化，对多团队 RAG 部署的组织管理至关重要 |
| Mistral AI 宣布自研芯片 + 新建推理数据中心，累计投入 40 亿欧元 | Mistral AI | 2026-05-29 | mistral, chip, infrastructure | https://readhub.cn/topic/8tV0I7u0H01 |  | ⚡ daily 2026-05-29 — 欧洲 AI 公司自研芯片降低推理成本，新建专用推理数据中心，2026 年目标营收 10 亿欧元 |
| Claude Opus 4.8 发布：两个 0% 改写历史 + Dynamic Workflows 百 Agent 并行 | Anthropic | 2026-05-30 | model-release, agent, coding | https://www.anthropic.com/news/claude-opus-4-8 |  | ⚡ daily 2026-05-30 — 谎报率/偷懒率双 0%，SWE-Bench 69.2%，Dynamic Workflows 支持百级 subagent 并行 |
| CAPTCHA 仍能检测 AI Agent：过程行为差异显著，输出等价≠过程等价 | Roundtable AI | 2026-05-30 | agent-detection, security, captcha | https://research.roundtable.ai/captchas-detect-ai/ |  | 📖 daily 2026-05-30 — AI 能解 CAPTCHA 但过程模式（点击序列/方向变化/过度选择）与人类有统计显著差异 |
| Claude Opus 4.8 身份争议：API 测试中自称 Qwen/DeepSeek，蒸馏双标再引讨论 | Anthropic | 2026-05-30 | model-release, controversy, distillation | https://m.ithome.com/html/957006.htm |  | 📖 daily 2026-05-30 — Opus 4.8 API 身份错乱暴露蒸馏链透明度问题，Anthropic 2月曾指控中国公司蒸馏 |
| Mistral AI Now Summit：全栈欧洲 AI 战略，Voxtral 驱动 Alexa+，Vibe for Work 对标 Claude | Mistral AI | 2026-05-30 | eu-sovereignty, on-prem, small-models | https://koenvangilst.nl/lab/mistral-ai-now-summit |  | 🔧 daily 2026-05-30 — 自建 40MW 数据中心 + 专用小模型策略，欧洲企业 AI 替代方案成型 |
| SQLite 作为 durable workflow 状态后端：HN 306 分引发 Agent 状态管理讨论 | — | 2026-05-30 | workflow, sqlite, state-management | https://obeli.sk/blog/sqlite-is-all-you-need-for-durable-workflows/ |  | 📖 daily 2026-05-30 — SQLite ACID + 持久化天然适配 Agent workflow 状态机，轻量替代 Temporal/Cadence |
| AWS SageMaker LLM 推理可观测性：GPU 利用率 + LLM 质量双维度监控方案 | AWS | 2026-05-30 | observability, llmops, sagemaker | https://aws.amazon.com/blogs/machine-learning/comprehensive-observability-for-amazon-sagemaker-ai-llm-inference-from-gpu-utilization-to-llm-quality/ |  | 📖 daily 2026-05-30 — 生产级 LLM 部署需同时监控基础设施(quantity)和模型输出质量(quality)，Grafana 仪表盘方案 |
| Robinhood 开放 AI Agent 股票交易：MCP 接入 + 专属虚拟信用卡 | Robinhood | 2026-05-30 | agent-trading, mcp, payments | https://techcrunch.com/2026/05/27/robinhood-now-lets-your-ai-agents-trade-stocks/ |  | 🔧 daily 2026-05-30 — 首个主流券商开放 Agent 交易，MCP 协议 + 隔离钱包 + 虚拟信用卡，Agent 支付基建里程碑 |
| Anthropic 公开 Claude 全产品线沙箱隔离方案：gVisor → Seatbelt → VM 三级架构 | Anthropic | 2026-05-31 | agent-security, sandbox, claude | https://www.anthropic.com/engineering/how-we-contain-claude |  | ⚡ daily 2026-05-31 — 首次系统披露 Claude.ai/Code/Cowork 三层沙箱架构，对 Agent 安全工程有标杆意义 |
| Simon Willison: 用 Pyodide + Service Worker 在浏览器中运行 Python ASGI 应用 | Simon Willison | 2026-05-31 | pyodide, wasm, browser-compute | https://simonwillison.net/2026/May/30/pyodide-asgi-browser/ |  | 📖 daily 2026-05-31 — ASGI 应用完全在浏览器 WebAssembly 中运行，为边缘 AI 推理提供新思路 |
| DeepSeek 限制「重新生成」和「修改消息」次数：算力紧张下的产品降级 | DeepSeek | 2026-05-31 | deepseek, compute-constraints, product-change | https://www.36kr.com/p/3831137120395271 |  | 🔧 daily 2026-05-31 — 重生/修改限流至 3-6 次，反映推理基础设施压力，用户端体验首次出现明显降级 |
| Chad Whitacre 宣布退出科技行业：「我吐出了 agentic Kool-Aid」 | — | 2026-05-31 | agentic-coding, culture, claude-code | https://openpath.quest/2026/i-am-retiring-from-tech-to-live-offline/ |  | 📖 daily 2026-05-31 — Bluesky 联合创始人讲述 Claude Code 体验后产生心理依赖，选择「AI 阿米什」式退出 |
| Ask HN: 2026 年应用开发现状——AI/LLM 如何改变移动开发 | — | 2026-05-31 | app-development, community-discussion | https://news.ycombinator.com/item?id=48337409 |  | 📖 daily 2026-05-31 — HN 热帖讨论 AI 编码工具对纯 iOS/Android 开发的影响，反映开发者社群集体焦虑 |
| ChatGPT for Google Sheets 存在数据外泄和钓鱼漏洞 | PromptArmor | 2026-06-01 | security, guardrail, agent-ui | https://www.promptarmor.com/resources/gpt-for-google-sheets-data-exfiltration |  | 🔧 daily 2026-06-01 — GPT 插件可被 prompt 注入窃取 Sheets 数据并发起钓鱼，Agent 沙箱隔离再次敲响警钟 |
| Odysseus：自托管 AI 工作空间，HN 100 分 | pewdiepie-archdaemon | 2026-06-01 | self-hosted, agent-ui, workspace | https://github.com/pewdiepie-archdaemon/odysseus |  | 📖 daily 2026-06-01 — 一站式自托管 AI 工作空间，满足数据隐私和离线场景需求 |
| I put a datacenter GPU in my gaming PC：V100 本地 LLM 部署实战 | — | 2026-06-01 | local-llm, gpu, on-device | https://blog.tymscar.com/posts/v100localllm/ |  | 📖 daily 2026-06-01 — 数据中心 V100 装入消费级 PC，本地 LLM 推理硬件门槛持续降低 |
| Simon Willison：取消 AI 订阅可能才是解决方案 | Simon Willison | 2026-06-01 | vibe-coding, agent, paradigm | https://simonwillison.net/2026/May/31/the-solution-might-be-cancelling-my-ai-subscription/ |  | ⚡ daily 2026-06-01 — 16+ AI 工具项目失控，反映 vibe coding 范式下的工具碎片化和认知负荷问题 |
| 腾讯面试题深度拆解 Claude Code 的 CLAUDE.md 机制 | — | 2026-06-01 | agent-ui, coding-agent, claude | https://juejin.cn/post/7645501139741327401 | 🎯 agent-ui | 📖 daily 2026-06-01 — 四层加载体系+指令预算+rules 目录，CLAUDE.md 正成为 AI 编码标配配置范式 |
| OpenAI frontier models and Codex 正式登陆 Amazon Bedrock | OpenAI | 2026-06-02 | gateway, bedrock, codex | https://openai.com/index/openai-frontier-models-and-codex-are-now-available-on-aws |  | ⚡ daily 2026-06-02 — GPT-5.5/5.4 + Codex 通过 AWS 现有采购流程进入企业，OpenAI 生态分发生态拐点 |
| 黑客只需让 Meta AI 帮忙即可获取高关注度 Instagram 账号权限 | Meta | 2026-06-02 | security, guardrail, social-platform | https://simonwillison.net/2026/Jun/1/hackers-simply-asked-meta-ai/#atom-everything |  | 🔧 daily 2026-06-02 — Prompt 注入可直接操控 Meta AI 访问 Instagram 高权限账号，安全边界再次被突破 |
| Amazon Bedrock AgentCore Identity 支持引用自有 Secrets Manager 密钥 | AWS | 2026-06-02 | agent, security, secrets-manager | https://aws.amazon.com/blogs/machine-learning/reference-your-own-aws-secrets-manager-secrets-in-amazon-bedrock-agentcore-identity/ |  | 🔧 daily 2026-06-02 — Agent 身份管理可直接引用用户自有密钥，保留完整控制权，降低 agent 凭据泄露风险 |
| 阿里发布 Qwen3.7-Plus 多模态智能体模型 | Alibaba | 2026-06-02 | qwen, multimodal, agent | https://readhub.cn/topic/8tcWkZyLmIs |  | 🔧 daily 2026-06-02 — 在 Qwen3.7 文本基础上全面升级视觉-语言能力，保持编码/工具使用/生产力工作流完整 agent 能力 |
| Anthropic 秘密提交 IPO 申请，估值近万亿美元 | Anthropic | 2026-06-02 | ipo, anthropic, market | https://readhub.cn/topic/8tc6KFKmOK9 |  | ⚡ daily 2026-06-02 — 5 月下旬以 $9650 亿估值融资 $650 亿后再次冲刺上市，可能成为近年最大 IPO 之一 |
| OpenAI Voice Hack Night 现场演示「无 App 手机」agentic OS | OpenAI 社区 | 2026-06-02 | agent-ui, voice, paradigm-shift | https://readhub.cn/topic/8tbpDOr4eLq | 🎯 | ⚡ daily 2026-06-02 — 端侧本地模型即时生成 UI + 云端 GPT 推理，开发者通过语音完成订机票/删日程/发邮件等操作 |
| IBM Research：可扩展企业 AI 落地取决于 Agent Logic 而非单纯 LLM 能力 | IBM Research | 2026-06-02 | agent, enterprise, llmops | https://huggingface.co/blog/ibm-research/agent-logic-and-scalable-ai-adoption |  | 📖 daily 2026-06-02 — 从 IBM 企业落地视角论证：可控的 agent 逻辑层比更大模型才是规模化 AI 的关键 |
| Microsoft Scout：基于 OpenClaw 的自主 AI Agent，7×24 后台自动执行 M365 任务 | Microsoft | 2026-06-03 | agent, microsoft-365, openclaw | https://www.computerworld.com/article/4180103/microsoft-unveils-scout-an-autonomous-ai-agent-built-on-openclaw.html | 🎯 agent-ui | 🔧 daily 2026-06-03 — OpenClaw 框架首个落地产品——「Autopilot」概念：带 Entra 身份治理的 7×24 后台自主 Agent |
| OpenAI Codex 扩展至非开发者：6 个角色插件 + annotations + 可分享交互网站 | OpenAI | 2026-06-03 | agent, workflow, codex | https://openai.com/index/codex-for-every-role-tool-workflow | 🎯 agent-ui | 🔧 daily 2026-06-03 — Codex 周活 500 万+，非开发者占比 20% 且增速 3×；数据分析/创意/销售/设计/投资/公六类角色插件 |
| Holo3.1：支持本地部署的 Computer Use Agent，覆盖 Web/Desktop/Mobile | HCompany | 2026-06-03 | agent, computer-use, local-inference | https://huggingface.co/blog/Hcompany/holo31 | 🎯 agent-ui | 🔧 daily 2026-06-03 — 首推 FP8/Q4 GGUF/NVFP4 量化本地推理；AndroidWorld 35B 从 67%→79.3%；原生 function calling 支持 |
| Microsoft 发布 MAI-Thinking-1 (35B) 和 MAI-Code-1-Flash (5B)：全自研 clean data 模型 | Microsoft | 2026-06-03 | model, code, reasoning | https://simonwillison.net/2026/Jun/2/microsofts-new-models/ |  | ⚡ daily 2026-06-03 — 35B reasoning 模型盲测超 Sonnet 4.6；5B code 模型直推 GitHub Copilot；全 clean data 训练，无第三方蒸馏 |
| OpenAI 计划为金融、法律领域开发专属 AI 工具，直接对标 Anthropic | OpenAI | 2026-06-03 | vertical, enterprise | https://readhub.cn/topic/8tdiRVeEsgr |  | ⚡ daily 2026-06-03 — OpenAI 从通用 AI 向垂直行业工具扩展，直接挑战 Anthropic 在企业市场的优势地位 |
| Together AI 发布 MiniMax-M3 服务方案：1M context + 原生多模态 + 稀疏注意力 | Together AI / MiniMax | 2026-06-03 | gateway, multimodal, long-context | https://www.together.ai/blog/serving-minimax-m3-for-efficient-inference-unlocking-1m-token-context-and-multimodality-without-regrets |  | 📖 daily 2026-06-03 — MSA 稀疏注意力 prefill 加速 9×/decode 15×；open weights 即将发布；agentic 流量场景优化 |
| AWS Bedrock AgentCore Gateway 支持 OAuth Code Flow + MCP 客户端认证 | AWS | 2026-06-03 | gateway, mcp, security | https://aws.amazon.com/blogs/machine-learning/building-a-secure-auth-code-flow-setup-using-agentcore-gateway-with-mcp-clients/ |  | 📖 daily 2026-06-03 — 企业级 MCP 服务器入站认证标准化方案，支持 Okta/Entra ID/Cognito 等 IdP 集成 |
| Gemma 4 12B: Google 发布 encoder-free 多模态模型，16GB 显存即可本地运行 | Google DeepMind | 2026-06-04 | multimodal, on-device, gemma | https://blog.google/innovation-and-ai/technology/developers-tools/introducing-gemma-4-12b/ |  | ⚡ daily 2026-06-04 — 首创无 encoder 架构，视觉+音频直连 LLM backbone，16GB VRAM 即可跑 agentic 工作流 |
| Anthropic 选定摩根士丹利+高盛担任 IPO 主承销商，最早 10 月上市 | Anthropic | 2026-06-04 | ipo, anthropic, funding | https://readhub.cn/topic/8tfT0EgZkAl |  | ⚡ daily 2026-06-04 — IPO 进入实质推进阶段，估值近万亿美元，AI 史上最大上市临近 |
| HuggingFace：MCP 工具接入 Reachy Mini 人形机器人 | HuggingFace | 2026-06-04 | mcp, robotics, tools | https://huggingface.co/blog/adding-mcp-tools-to-reachy-mini |  | 📖 daily 2026-06-04 — 一行命令从 HF Space 添加远程工具，机器人能力可通过社区生态扩展 |
| Alphabet 财报：Gemini 月活突破 9 亿，Gemini 3.5 Pro 预计 6 月推出 | Google | 2026-06-04 | gemini, model-release, milestone | https://readhub.cn/topic/8tfEmLmsCXx |  | 📖 daily 2026-06-04 — Gemini 月活同比翻倍至 9 亿，3.5 Pro 即将发布，AI 应用层竞争加速 |
| 微软 Build 2026：Surface RTX Spark Dev Box 将 PC 变成 Agent 工作站 | Microsoft | 2026-06-04 | agent, on-device, hardware | https://www.36kr.com/p/3836668626891910 |  | ⚡ daily 2026-06-04 — 本地 RTX GPU + MAI 模型家族，16 亿 Windows 用户一夜具备本地 Agent 算力 |
| 🎯 Weaviate Engram GA：Agent 记忆与上下文管理正式商用 | Weaviate | 2026-06-04 | agent, memory, context | https://weaviate.io/blog/engram-generally-available | 🎯 agent-ui | 🔧 daily 2026-06-04 — 解决长上下文退化+多 Agent 碎片化，结构化记忆即基础设施 |
| AWS：用 SFT+DPO 提升 Agent 工具调用准确率 | AWS | 2026-06-04 | agent, tool-calling, sft, dpo | https://aws.amazon.com/blogs/machine-learning/improve-your-agents-tool-calling-accuracy-with-sft-and-dpo-on-amazon-sagemaker-ai/ |  | 🔧 daily 2026-06-04 — SFT 教工具语言 + DPO 对齐偏好，无需 RL 即可显著提升 SLM 工具调用准确率 |
| OpenAI 更新 GPT-Rosalind：LifeSciBench 端到端评测生命科学研究工作流 | OpenAI | 2026-06-04 | workflow, life-sciences, benchmark | https://openai.com/index/introducing-new-capabilities-to-gpt-rosalind |  | 📖 daily 2026-06-04 — 首个覆盖 6 大生命科学研究领域的端到端 benchmark，GPT-5.5 驱动药物发现工作流 |

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
