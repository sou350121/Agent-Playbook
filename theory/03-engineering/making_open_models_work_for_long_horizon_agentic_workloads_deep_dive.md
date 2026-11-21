---
auto_generated: true
generated_at: "2026-11-21T03:30:51Z"
source_url: "https://www.together.ai/blog/making-open-models-work-for-long-horizon-agentic-workloads"
signal_type: "significant_update"
---
# 长会话 Agent 的成本命门：前缀缓存 (Making Open Models Work for Long-Horizon Agentic Workloads)

> 🔍 本文由 Moltbot 自动生成 | 2026-11-21
>
> **项目/工具**: Together AI × Ollama（开源模型 + 推理引擎 + Harness 集成）
> **链接**: https://www.together.ai/blog/making-open-models-work-for-long-horizon-agentic-workloads
> **核心定位**: 这是一篇工程指南而非版本发布——它把「Agent 每轮重发全量上下文」这一流量特征拆开，指出**长会话成本与延迟的決定变量是 prefix cache 命中率**，并分别从 harness（请求怎么组）与推理引擎（请求到了之后怎么排）两侧给出具体规则。

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句話定位**：Together AI 的推理引擎团队和 Ollama 的 harness 团队联署，说明「为什么你的 agent 在第 90 轮会突然变慢变贵」，以及两端各自要守住哪些纪律。
- **現在值得用嗎**：是——如果你在跑长会话 coding agent（Claude Code / Codex / Pi 类 harness 接开源模型），这篇是可以直接改代码的清单；如果只是跑单轮问答，收益有限。
- **適合場景**：多小时 coding agent、工具调用密集的 agent、多 subagent 派发、自建推理集群或使用托管 API 的团队。
- **不適合場景**：一次性生成、批处理离线任务、上下文永远短于几百 token 的轻量调用。
- **與「换更快的模型」的核心差異**：本文的主张是——agent 场景下「模型多快」几乎等于「它多快读回上一轮的记录」，**缓存比模型选择更影响体验**。

---

## 是什么 / 解决什么问题

Coding agent 的流量特征很怪：agent 每走一步，harness 就把**整个对话**重新发给模型——system prompt、全部 tool 定义、用户请求、agent 读过的每个文件、跑过的每条命令。回来的通常只是一个几十 token 的 tool call。下一轮再来一次，内容只多不少。

这就是典型的大输入序列（ISL）、小输出序列（OSL）。如果 GPU 每轮都从头算一遍这段记录，长会话会随轮次线性变慢、成本线性堆高——实际上，**没有缓存时重算量随会话长度呈平方增长**。官方的算式很直白：

```text
无缓存：10 轮 = 1+2+...+10 = 55 单位 prompt
有缓存：10 轮 = 10 单位
100 轮：5,050 vs 100
```

（原文注明这是理想化数字，真实轮次大小不等；且缓存并非完全免费，每个新 token 仍要 attend 到历史。）

prefix cache 的匹配规则只有一句，全文其余结论都从它推导出来：**从 prompt 开头匹配到第一个不同的 token 为止，之后全部重算。** 往末尾追加内容不额外花钱；改动前面任何一个字符，后面全部作废。

分工也很清楚：**harness 决定「第一个差异点落在哪里」，推理引擎决定「下一轮请求来时缓存还在不在」。任何一端失手，整条链路白干。**

## 技术架构拆解

### 核心设计决策

**Harness 侧（Ollama）：**

- **工具延迟加载（loading tools late）**：tool 检索能力出现后，搜到的 tool 定义该放哪里？放回 tool 列表 = 放在 prompt 顶部 = 之后全部重算，长会话可能是几十万 token。正确做法是**追加到对话末尾**，因为那里本来就是新增内容的位置。限制：部分模型的 chat template 不接受「对话中途出现 tool 定义」，会直接报错——所以能不能便宜地晚加载 tool，取决于模型。
- **System prompt 必须逐字稳定**：每轮变化的当前时间戳、git status、频繁切换的工作目录，是最容易毁掉缓存的凶手。**会话内固定、会话间不同的信息（用户名、会话开始日期）不伤当天会话，但会让新会话无法复用已缓存的 setup。** 统一解法：这类信息只放进任务消息里，system prompt 全场保持一致。
- **reasoning effort 是个陷阱**：GLM-5.3-Flash 的 chat template 把 effort 写进**最前面的 system block**。任务跑到一半把 low 调成 high，第一个 token 就变了 → 整个会话重算。建议：开始就定好档位；真要加思考，**新开一个高 effort 会话往往比续跑旧会话更便宜**，也顺便得到一个干净的上下文；或先 compact 再改。
- **大 tool 结果必须截断，而且必须说明截断**：agent 读了 3000 行文件但只需要 40 行，这笔账不是付一次，而是付到会话结束（即使命中缓存，也吃 context window）。更危险的失败模式是静默截断——原文给了一个很具体的案例：修 calendar 导出里的时区 bug，工具返回 640 行文件的第 1 到 100 行却不说，模型不知情，而关键函数 `convert_timezone` 在第 420 行。修法是输出里加一行：告诉模型「这是第 1–100 行，共 640 行，可以搜索或请求其它区间」。预算省了，但「静默截断」换来的是模型自信地改它没看过的代码。
- **subagent 是否继承父会话**：继承（同 system prompt、同 tools、同完整对话）能让整段 prefix 命中，聊天侧线就是这么做的；但缓存前缀「处理便宜不等于免费」——subagent 生成的每个 token 仍要读穿它，并且整段时间占着 GPU 显存。一个只需要两个文件加一份检查清单的 reviewer，不需要三百轮历史。另外，**给 subagent 单独的 system prompt 会让它与父会话共享为零，连 setup 都不能复用。**

**引擎侧（Together AI）：**

- **路由决定命中**：会话缓存落在某个数据中心的某个节点上。请求打偏了，那个节点要从头算，并且两个节点各存一份相同前缀。选节点有两条路：客户端带 `prompt_cache_key` 之类的 key 固定路由；或对 prefix 做哈希，发给持有最长匹配前缀的节点（哪怕前缀是别的会话缓存的）。**这正是「system prompt 保持一致」在引擎侧的第二个理由**——所有会话开头完全一样时，新会话可能直接捡到已缓存的 setup。
- **负载感知路由**：不能无脑发往热节点。热节点排队 vs. 冷节点重算，有时**缓存未命中反而是更划算的选择**。
- **空闲时把缓存挪到 CPU 内存**：agent 跑测试要等几分钟，一直占着 GPU 显存会挤压活跃用户；直接丢弃则恢复时要重读全部历史。
- **显存才是真正瓶颈**：用 PagedAttention 按块分配（像操作系统管 RAM），用 continuous batching 每轮重建批次，让并发的 5 个 subagent 一有空位就插入，而不是等最慢的跑完。文章明确点出：**限制单卡并发数的通常不是算力，而是缓存显存余量。** 每一个超大的 tool 结果、每一个背着无关历史的 subagent，都在吃别的会话本可以用的显存。
- **prefill / decode 分离部署**：agent 把两相推到极端（超大 prompt、极小回答）。compute 优化的集群做 prefill，memory bandwidth 优化的集群同时服务上百条 decode 流，缓存通过 RDMA 在两集群间搬运。

### 与前版/竞品的关键差异

| 维度 | 常见做法（朴素 harness + 普通推理服务） | 本文给出的做法 |
|------|------------|------------|
| 工具定义 | 全部塞在 prompt 顶部、search 到后插回列表 | 追加到对话末尾（需模型 chat template 支持） |
| system prompt | 每轮注入时间戳 / git status / cwd | 逐字稳定，动态信息只放进任务消息一次 |
| reasoning effort | 任务中途随时上调 | 开始时定档；要加思考就新开会话或先 compact |
| tool 输出 | 静默截断成前 N 行 | 截断 + 显式告知总行数与可请求区间 |
| subagent | 一律继承全量上下文 | 按需 brief：同 setup、只给需要的文件 |
| 请求路由 | 随机 / 轮询到任意节点 | cache key 或 prefix 哈希 + 负载感知 |
| 空闲会话 | 缓存常驻显存或直接丢弃 | offload 到 CPU 内存，回来时恢复 |

### 架构/信息流图

```text
         ┌──────────────── Harness（Ollama 侧） ────────────────┐
用户/Agent │ system prompt(逐字固定) + tools + 历史tool结果 + 新请求 │
         │   ├─ 新 tool 定义 → 追加到末尾（不改前面）             │
         │   ├─ tool 输出截断 → 附带「1-100 / 共640行」说明        │
         │   └─ subagent → 继承 or brief（按任务裁剪历史）        │
         └───────────────────────┬────────────────────────────┘
                                 │ HTTP + prompt_cache_key
         ┌───────────────────────▼────────────────────────────┐
         │ 引擎（Together AI 侧）                               │
         │  1. 选数据中心：跑该模型 + 有容量 + 会话曾在此        │
         │  2. 选节点：key 路由 / prefix 哈希最长匹配           │
         │  3. 负载感知：热节点排队 vs 冷节点重算 → 取更便宜     │
         │  4. 空闲 → 缓存 offload 到 CPU 内存                 │
         │  5. PagedAttention 分块 + continuous batching        │
         │  6. prefill 集群 ══RDMA══> decode 集群              │
         └─────────────────────────────────────────────────────┘
```

## 实用评估

### 什么场景值得用

- **长会话 coding agent**：百轮级别的任务，缓存收益是平方级的；第 90 轮还快不快，基本由这套纪律决定。
- **工具调用密集的 agent**：每一轮大输入小输出，正是 prefix cache 的最佳收益结构。
- **多 subagent 编排**：显存预算管理（brief 而不是全量继承）直接决定并发上限。
- **自建推理 / 托管 API 的选型阶段**：可以照着清单去问供应商「空闲会话缓存怎么处理、路由是否 cache-aware」。

### 什么场景不值得用

- **单轮或少数几轮调用**：prefix cache 的前提（跨请求复用前缀）不存在，读本文收益接近零。
- **上下文本身只有几百 token**：平方级增长的基数太小，优化 tool 截断说明反而增加复杂度。
- **模型 chat template 不支持中途插入 tool 定义**：晚加载工具这条路走不通，只能在顶部全量注入并接受上下文开销。
- **缓存改动过于频繁的工作流**（每轮都要重写 system prompt 的业务）：需要先改业务逻辑，而不是调推理参数。
- 文中提到的开源模型（DeepSeek-V4.1-Flash、GLM-5.3、GLM-5.3-Flash、Kimi K3）具体表现**本文未给 benchmark**，`> TODO: 各模型 cache 复用率与长会话成本对比数据缺失`。

### 迁移成本

- **Harness 侧**：中等。system prompt 去动态化、tool 输出加截断说明、effort 提到启动参数——通常是几十到几百行改动，不需要换框架。
- **推理侧**：高。路由、缓存 offload、分块显存管理不是应用开发者能改的，取决于推理供应商是否已实现；自建引擎则等同于重做调度层。
- **实测建议**：先在长会话里打点「每轮 input token 数 / 缓存命中率 / TTFT」，再改一处、复测一处。缓存问题几乎不会表现为报错，只会表现为「越来越慢」。

## 对你的意义

如果你在做 Agent + UI 方向的工程实践，这篇的价值不在「学一个新工具」，而在**它把一类隐性故障说清了**：很多「模型变笨 / agent 跑到一半迷路 / 第 80 轮开始变慢」，根因其实在请求组装与缓存纪律上。

三条我会立刻拿来用的判据：

1. **system prompt 是资产，不是模板**。任何每轮变化的值（时间、状态、路径）都必须挪出去。这一条同时决定「新会话能不能捡到已缓存的 setup」——直接影响首 token 延迟。
2. **截断必须留痕**。这是 agent 工程里最容易犯的静默错误：省了 token，换来一个自信地改它没看过的代码的模型。你的 tool 层应该统一加这行说明。
3. **subagent 默认走 brief，不走继承**。除非任务确实需要完整历史，否则每多带一轮历史都是在抢别的会话的显存。

对 VLA 侧的迁移思考（软关联，非本文结论）：同样是长时序、每步全量上下文的场景——机器人策略的观测历史、仿真 rollout 的状态序列，结构上和 agent 的「重发全量」是同构的。缓存/增量计算的纪律在那里同样成立，只是介质从 KV cache 换成了状态估计与记忆压缩。`> TODO: 该类比尚未在 VLA 推理栈上验证。`

**建议动作**：立即给你的 agent harness 加两项打点（input token / cache hit），然后按上文逐条体检 system prompt 与 tool 输出层。这是一次低风险、可见收益的排查。

## 关键代码/配置片段

文章没有给出 API 形式的代码，以下是原文明确提到的配置/协议要点（非虚构代码）：

```text
# 路由：客户端每请求带同一个 key，让同一会话落到同一节点
prompt_cache_key = "<session-id>"

# 引擎侧路由备选：对 prefix 做哈希，命中「持有最长匹配前缀」的节点
# （即使该前缀是其它会话缓存的，也可复用）

# 空闲会话：KV cache offload 到 CPU 内存，下一轮恢复，而不是丢弃
# 显存分配：PagedAttention 按块按需分配；continuous batching 每轮重建批次
```

```text
# tool 输出截断（原文案例的修法）——只加一行，避免模型在不知情下改代码
Lines 1-100 of 640 returned. File is truncated.
Search the file or request another range (e.g. lines 410-450).
```

```text
# Ollama 侧：用 launch 命令把现有 harness 接到开源模型上
ollama launch   # 支持 Claude Code / Codex / Pi 等 harness 接 DeepSeek-V4.1-Flash、GLM-5.3 等
```

---
[← Back to Deep Dives](./README.md)
