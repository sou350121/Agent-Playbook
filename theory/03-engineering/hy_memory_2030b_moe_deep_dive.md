---
auto_generated: true
generated_at: "2026-10-22T03:31:04Z"
source_url: "https://juejin.cn/post/7697199118263386139"
signal_type: "blog_post"
---
# 腾讯混元开源 Hy Memory 2.0：把"记忆"从模型软能力拆成可独立部署的三层基础设施 (Tencent Hunyuan Hy Memory 2.0: A Three-Layer, Separable Memory Stack for LLM Agents)

> 🔍 本文由 Moltbot 自动生成 | 2026-10-22
>
> **項目/工具**: Hy Memory 2.0（Hy-Memory-30B-A3B 模型 + hy-memory SDK + MemHub 应用）
> **链接**: https://github.com/Tencent-Hunyuan/Hy-Memory
> **核心定位**: 腾讯混元把"Agent 长期记忆"拆成模型层、框架层、应用层三件可独立取用的东西，同时开源；这次更新的实质是**记忆写入路径被单独训练成一个 30B-A3B 的专用 MoE 模型**，并配上一套覆盖 Chat/Working/Coding 三种场景的记忆框架。

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句話定位**：一套"记忆基础设施"三件套——专用记忆写入模型（30B 总参 / 约 3B 激活）、Python 记忆框架 `hy-memory`、本地优先的跨工具记忆应用 MemHub。解决的问题是：Agent 换会话、换工具就"失忆"。
- **現在值得用嗎**：**看场景**。你如果已经在做 Agent 长期记忆、手上有 GPU，写入模型值得花一周在自己流量上验证；如果只是想给个人 Coding 工具打通记忆，MemHub 现阶段只建议试玩、不建议托付重要数据。
- **適合場景**：Coding Agent 的跨会话工程经验复用；多工具（Cursor / Claude Code / Codex / OpenCode）共享同一份本地记忆；长程任务的"上次做到哪"找回。
- **不適合場景**：多租户 SaaS（隔离/合规成本未解决）；没有自托管推理能力的团队；需要独立第三方复现的严谨选型——目前全部数字来自腾讯自评，尚无外部复现。
- **與 Mem0 / MemOS 核心差異**：不把"该记什么"交给通用前沿模型即兴判断，而是训一个专门的小激活量模型来做确定性、低成本的记忆写入；同时把"存储占用"当作一等指标（记忆库 token 仅占输入 token 的 6.06%）。

## 是什么 / 解决什么问题

LLM Agent 的记忆问题从来不是"模型不够聪明"，而是架构上没人好好做。过去主流做法有一个共同的隐性成本：**用一个前沿大模型去判断"这轮对话该记什么、怎么改写记忆"**。这件事发生频率极高（几乎每轮触发）、输出极短，却是前沿模型最浪费的工作负载——贵、慢、且不稳定（同一段对话两次写入可能得到不同结果）。

Hy Memory 2.0 的核心主张就是把这半边拆出来。按官方技术报告的定位，它训练了一个 30B 总参、每 token 约激活 3B 的 MoE 模型（`tencent/Hy-Memory-30B-A3B`），用"attributed reinforcement learning"专门做高精度记忆抽取与冲突消解；配套的 `hy-memory` Python 框架负责记忆全生命周期；外加 MemHub 这个本地优先应用，把你十种 AI 工具的历史会话汇总到一份本地记忆里。

本次 2.0 相对 1.0（2026-05 首发）的最大结构变化是：**从"聊天记忆"扩展成 Chat / Working / Coding 三类记忆**。其中 Coding 记忆引入"两层事实 + 版本演化 diff-chain"跟踪，试图同时保住"可复用的工程经验"和"代码究竟改了什么轨迹"。

## 技术架构拆解

### 核心设计决策

- **写入与读取分离，写入侧下沉到专用模型**。官方 quick start 里该模型以 `reasoning_effort: "no_think"` 和 `temperature 0.0` 驱动——刻意不要它"思考"，要的是确定性、短输出、低成本。这是整份发布里最清晰的一个工程判断：记忆写入是高频低价值推理，不该吃前沿模型的算力。
- **双系统认知架构（System 1 / System 2）**。框架论文（EMNLP 2026 已接收）把 Chat 记忆组织成 8 层（原始对话、原子事实、摘要、schema、前瞻意图等），带冲突消解与跨领域 schema 归纳。快系统做近似召回，慢系统做深层整理。
- **存储后端全部可插拔**。向量库可选 ChromaDB / Qdrant / FAISS，图库可选 Kuzu / Neo4j，关系库 SQLite，可选 MySQL 缓存与本地多语 cross-encoder rerank。不绑定单一技术栈。
- **MemHub 的唯一数据面原则**。"一次安装、一个 Runtime、一份数据、多种客户端"，Python Core 是唯一记忆数据面和唯一业务 DB 写入者；来源读取、模型处理、宿主读取是三个相互独立的授权边界。
- **隐私边界写死在架构里**。官方明确产品不做屏幕、Accessibility/AXTree、OCR、键鼠、剪贴板或后台录音采集。
- **卸载与删除分三级**。`npm uninstall` 只移除 CLI；`memhub uninstall` 移除服务/受管 Runtime/CLI 链接但**保留记忆**；只有独立的 `memhub delete-data` 才删数据（需停止 Runtime 并二次确认精确路径）。这在记忆类工具里设计得比平均水准认真。

### 与前版/竞品的关键差异

| 维度 | Mem0 / 通用"前沿模型 + 提示词"方案 | Hy Memory 2.0 |
|------|-----------------------------------|---------------|
| 记忆写入主体 | 通用前沿 LLM（贵、非确定性） | 专用 30B-A3B MoE，`no_think` + `temperature 0` |
| 场景覆盖 | 以 Chat 记忆为主 | Chat / Working / Coding 三类，Coding 用版本 diff-chain |
| 存储占用（相对输入 token） | 竞品约 31.9% – 41.2% | 官方称 6.06% |
| 检索召回 token（LoCoMo 每题） | 基准未统一 | 官方称 1159 → 703（−39.3%） |
| 存储后端 | 通常固定 | 向量/图/关系库均可替换 |
| 部署形态 | 多为托管服务 | 权重 Apache 2.0 + 自托管 vLLM/SGLang |
| 独立复现 | — | **尚无**（截至写作时全部为腾讯自评） |

### 架构/信息流图

```
 授权来源（Claude Code / Cursor / Codex / OpenCode / Qwen Code ...）
        │  （来源读取授权）
        ▼
 ┌──────────────────────────────────────────────┐
 │ MemHub 受管 Runtime（Python FastAPI Kernel）   │
 │                                              │
 │  Evidence ──► Hy Memory ──► Governance ──►   │
 │  原始记录      记忆引擎        治理          │
 │                                              │
 │  ┌────────────┐  ┌─────────────┐             │
 │  │ Chat 记忆  │  │ Working 记忆 │  ┌────────┐ │
 │  │ 8 层分层   │  │ 事实+经验两层│  │Coding  │ │
 │  └────────────┘  └─────────────┘  │diff链  │ │
 │                                   └────────┘ │
 │  多路检索：向量 + 关键词 + 关系图谱            │
 └───────────────┬──────────────────────────────┘
                 │  精准注入（只放相关记忆，不倒全文）
                 ▼
        宿主导入的其他 AI 工具（宿主读取授权）
                 │
        ~/.one-memory  （SQLite + ChromaDB + Kuzu 默认组合）
```

## 实用评估

### 什么场景值得用

- **Coding Agent 的跨会话经验复用**。这是本次发布里最具体的差异化：CodeMemoryBench 代码问答 64.2%、任务解决率 35.6%；SWE-ContextBench 任务解决率 28.3%（官方称高于 MemOS / Mem0 的 25.3%）。如果你在跑长程多轮编程任务，这套"可复用经验 + 适用条件判断"的结构是对的。
- **多工具记忆打通**。你如果在 Cursor、Claude Code、OpenCode 之间来回切，MemHub 把十种工具的会话汇到 `~/.one-memory` 的统一记忆里，理论上"在哪个工具里说过的话，下一个工具能接上"。
- **已经在自托管推理的团队**。权重 Apache 2.0、针对 vLLM v0.31.0 测试、兼容 OpenAI 端点，也支持 SGLang。仓库后续又放了 FP8 与 GGUF 版本，工作站的评估路径补上了。
- **在意存储成本的多租户前夜**。6.06% vs 约 40% 的量级差异，在长期运行的生产系统里是运营命题，不只是排行榜。

### 什么场景不值得用

- **需要独立验证的选型**。所有数字来自腾讯自评：主矩阵基于固定 **20% 基准子样本**，评测只变写入模型、其它全固定，且评判模型由腾讯指定。跨框架迁移的关键证据（留出的 EverMemOS 上 56.89 vs 54.04）只有单供应商一次运行。
- **多租户 / 强合规场景**。持久化记忆意味着敏感数据长期留存，身份隔离、脱敏、按时自动销毁、单条被遗忘权擦除都得自行设计。官方隐私边界只解决了"不采集屏幕/剪贴板"这一类问题，不解决隔离。
- **Windows 用户**。MemHub 明确不支持 Windows。
- **只想要托管端点的团队**。模型没有托管推理提供商，卡上也没指定 provider；自建 vLLM 是唯一路径。
- **记忆越多越好的直觉**。把噪声一起记住只会让召回变差——官方自己也在提醒这点。

### 迁移成本

- **只接框架**：`pip install hy-memory==2.0.4`，配一个 OpenAI 兼容 LLM 端点 + 一个 embedding 端点即可跑。Step 成本主要是把现有 prompt 里的"上下文拼接"改成 `client.add` / `client.search`，大约半天。
- **换写入模型**：需要能跑 30B-A3B 的 GPU，vLLM v0.31.0；FP8/GGUF 版本降低了门槛但仍非笔记本级。上线前建议用自己的流量做 A/B，别只看官方表。
- **从 Mem0 迁移**：数据模型差异体现在"分层结构"与"冲突消解"上，时间主要在重写记忆写入的触发逻辑与召回注入策略，不是一次性搬数据能解决的。

### 版本现状（务必按实际制品核对）

官方 quick start 指向 `hy-memory==2.0.4`；MemHub 为 v1.0.4（build 13），npm 包 `memhub-cli` 1.0.5，macOS App 经 Developer ID 签名与公证。MemHub 仍标注 **preview 阶段**，部分平台制品与安装路径仍在补齐——安装前请查看对应 Release 的实际制品与 `release-manifest.json`，只有同时出现在两者中并通过公开校验的制品才属于正式支持范围。

> TODO: 记忆写入的实际 per-conversation 成本（每轮写入 token 数 / 每用户每月运行成本）。官方与其他来源均未公布，需实测。

## 对你的意义

对做 Agent + UI / RAG 工具链方向的团队，这次发布有两个值得带走的东西，而不是"要不要换记忆库"。

**第一，"写入路径专用化"是一个可迁移的架构模式。** 你现在如果把记忆整理塞在主管线的 prompt 里，本质是在用最贵的模型做最便宜的事。哪怕不换 Hy Memory，也值得把写入拆成独立调用：固定 `temperature=0`、短输出、明确 schema，再把读取路径留在前沿模型上。写入侧降级只会让回答质量下降，不会拖垮整个应用——这个失效模式是可控的。

**第二，MemHub 的授权边界设计值得抄。** "来源读取 / 模型处理 / 宿主读取 三条独立授权" + "卸载不等于删数据、删数据需二次确认精确路径" ——这套分级在多数 Agent 工具里缺失。你们的 RAG 工具链如果涉及用户数据回流，这套边界划分比任何性能数字都更有参考价值。

**建议动作**：MemHub 这周可以装上试，但别拿重要工作数据试，先自己核一遍 `delete-data` 的实际路径行为；`hy-memory` SDK 适合找一个内部长程 Agent 做小流量实验，重点测"召回 token 是否真降到 40% 以下"和"冲突消解是否引用了过期事实"。至于 55.49 对 54.62 这件事——三个框架上几乎是平手，真实差距只出现在那个没人复现过的留出框架上，不要按发布标题做技术选型。

## 关键代码/配置片段

安装（官方 Quick Start，摘自仓库 README）：

```bash
pip install hy-memory==2.0.4                 # core (includes ChromaDB and Kuzu)
pip install "hy-memory[qdrant]==2.0.4"       # + Qdrant
pip install "hy-memory[faiss]==2.0.4"        # + FAISS
pip install "hy-memory[graph]==2.0.4"        # + Neo4j
pip install "hy-memory[rerank]==2.0.4"       # + local multilingual cross-encoder rerank
```

配置只需一个 LLM 端点 + 一个 embedding 端点（OpenAI 兼容即可）：

```bash
export MEMORY_LLM_API_KEY="sk-your-key"
export MEMORY_LLM_BASE_URL="https://api.deepseek.com"
export MEMORY_LLM_MODEL="deepseek-chat"

export MEMORY_EMBEDDER_API_KEY="sk-your-key"
export MEMORY_EMBEDDER_BASE_URL="https://dashscope.aliyuncs.com/compatible-mode/v1"
export MEMORY_EMBEDDER_MODEL="text-embedding-v3"
export MEMORY_EMBEDDING_DIMS=1024
```

Chat 记忆的写入与召回：

```python
from hy_memory import HyMemoryClient

client = HyMemoryClient(mode="pro")

# Write: plain text or OpenAI-format messages
client.add("I love sci-fi movies, especially Interstellar", user_id="user_1")
client.add([
    {"role": "user", "content": "Recommend a movie"},
    {"role": "assistant", "content": "Try Interstellar — a sci-fi masterpiece by Nolan"},
], user_id="user_1")

# Search: returns the profile / normal / proactive channels
results = client.search("What movies does the user like?", user_ids=["user_1"], limit=10)
for mem in results["memories"]["normal"]:
    print(f" [{mem['score']:.2f}] {mem['content']}")

client.close()
```

注：官方说明工作记忆与代码记忆的写入必须包含 tool-call trace（`tool_calls` 或 `role="tool"` 消息），且仅在 `pro` / `ultra` 模式下生效。

## 参考来源

- GitHub：https://github.com/Tencent-Hunyuan/Hy-Memory（README / memhub/README.md）
- 模型权重：https://huggingface.co/tencent/Hy-Memory-30B-A3B（Apache 2.0）
- 技术报告：https://arxiv.org/abs/2610.22196（Attributed RL for Long-Term Memory Writing）
- 框架论文：https://arxiv.org/abs/2606.09483（EMNLP 2026 接收）
- 第三方评测梳理：https://www.orcarouter.ai/zh-CN/blog/hy-memory-2-0-open-source-stack
- 中文报道：https://www.aitop100.cn/infomation/details/34848.html
- 原始信号：https://juejin.cn/post/7697199118263386139

---
[← Back to Deep Dives](./README.md)
