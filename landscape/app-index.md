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
| Emdash – Open-source agentic development environment | generalaction | 2026-02-25 | agent-ui, workflow, dev-tools | https://github.com/generalaction/emdash | 🎯 agent-ui | 🔧 daily 2026-02-25 — YC W26 出品，支持 15+ CLI agent 并行运行，Git worktree 隔离 |
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
