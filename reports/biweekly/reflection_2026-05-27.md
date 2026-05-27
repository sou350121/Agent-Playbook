🤔 *AI 应用双周反思* | 2026-05-27

_读完没立场 = 这两周在消费而不在研究_

━━━ 趋势与判断 ━━━

1️⃣ *MCP* 正在成为 AI 工具集成的"USB-C"——*AWS* Bedrock AgentCore、*Google* Vertex AI、*LangChain* LangGraph 全部原生支持。但同期 *Anthropic* 收购 Stainless（SDK/工具链供应商）走向垂直整合，*Google* 推出 Interactions API 对标 Responses API 另起炉灶。MCP 是在收敛为事实标准，还是在巨头各自筑墙中走向碎片化？你押哪边？

2️⃣ 本期出现 *Claude Code Routines*、*Statewright* 可视化状态机、*Multica* 多 Agent 编排、*LangChain Deep Agents v0.5* 异步子代理。如果只能深入学一个框架并把它作为团队标准，你选哪个？为什么？别回答"看场景"——选一个，给出理由。

3️⃣ 有人说 *Vibe Coding* 已经死了：*Bjarne Stroustrup* 直言 AI 代码质量极差，*Uber* 四个月烧光全年 AI 预算，*Microsoft* 强制 10 万工程师从 Claude Code 转 *Copilot*。但同期 *OpenAI* 和 *Anthropic* 用补贴战抢用户，*DeepSeek Reasonix* 原生编码 Agent 上线，*ECC* 开源 15 万星。Vibe Coding 是真退潮，还是只是从"叙事"进入了"工程化"阶段？你的判断是什么？

4️⃣ *Anthropic* 签下 *SpaceX* 450 亿美元算力协议，*OpenAI* 冲刺 IPO，*Cerebras* 募资 55 亿美元。巨头在底层疯狂买算力，但开发者却在退守 CLI 工具和状态机——因为 *Google Gemini* 悄然取消无限畅聊改用算力扣减，*Claude Code* 用量超预期被限流。底层军备竞赛和上层工程务实之间的"温差"会持续扩大，还是会在某个临界点汇合？

5️⃣ *Stanford AI Index* 报告：95 款顶级模型中 80 款未公开训练代码。但 GitHub 上 *DeepSeek TUI* 星标破 3.45 万，*academic-research-skills* 获 6.4k 星，*CLI-Anything* 让所有软件 Agent-Native。闭源基座 + 开源工具链的"悖论组合"是短期过渡还是长期格局？如果模型能力趋同，决定胜负的到底是参数规模还是工具链可控性？

━━━ 技术追问 ━━━

🔬 本期 *Anthropic* 发布 *Dreams* 机制——灵感来自人类 REM 睡眠的异步后台记忆整合，自动合并重复、替换过时、解决矛盾记忆。它能用 *Memory Files* 做结构化持久记忆，而非传统的滚动摘要。你能解释 Dreams 的异步记忆巩固机制与传统 RAG 检索-生成管道的核心区别吗？如果不能，建议阅读：https://www.anthropic.com/research/natural-language-autoencoders

🔬 *DeepSeek-V4-Flash* 让 *LLM steering*（激活向量引导）重回视野——*antirez* 的 DwarfStar 4 将 steering 内置 *llama.cpp*，通过修改模型内部激活而非 prompt 来实现精细行为控制。你能解释 activation steering 的核心原理吗？它与 prompt engineering 在控制粒度、稳定性和可迁移性上有什么本质差异？建议阅读：https://www.seangoedecke.com/steering-vectors/

🔬 *Claude Code Routines* 提供了确定性执行路径——预定义的任务模板，Agent 按固定流程执行而非自主决策。对比传统的 LLM Agent Loop（感知→推理→行动→循环），Routines 在什么场景下更可靠？什么场景下反而会成为瓶颈？你能给出一个具体的判断标准吗？

━━━ 上期回顾 ━━━

6️⃣ 2026-03-04 预测："多智能体编排将出现低代码可视化层"。本期证据：*Anthropic "Code w/ Claude"* 推出多智能体编排与异步 Routines，*LangChain Deep Agents v0.5* 提供异步子代理，*Multica* 开源多 Agent 编排平台支持 Squads 分组，*AWS Agent Registry* preview 提供 Agent 管理能力。基于这些证据，你的判断是 ✅ 已验证 / ❌ 落空 / ⏳ 待观察？（给出你的理由，不允许回答"两方面都有道理"）

---
_以上问题基于本期 AI 应用监控数据自动生成，旨在强迫你形成判断。_
