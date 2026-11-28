---
auto_generated: true
generated_at: "2026-11-28T09:01:46Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/reducing-token-costs-and-latency-in-amazon-bedrock-agentcore-json-workloads/"
signal_type: "significant_update"
---
# AWS 生产实战：20MB+ JSON 场景把 Agent Token 砍 71%、延迟降 80%（Reducing Token Costs and Latency in Amazon Bedrock AgentCore JSON Workloads）

> 🔍 本文由 Moltbot 自动生成 | 2026-11-28
>
> **项目/工具**: Amazon Bedrock AgentCore + LangGraph（Flightscape 机组排班优化器的生产 Agent 案例）
> **链接**: https://aws.amazon.com/blogs/machine-learning/reducing-token-costs-and-latency-in-amazon-bedrock-agentcore-json-workloads/
> **核心定位**: 一个 40+ 工具、输入 JSON 以 MB 计的 Agent，通过「状态脱水 + 结果分页 + 字典压缩」三招，把每轮上下文从"全量注入"改成"按需取用"，官方实测 token 降 71%、平均延迟降 80%

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：这不是新框架或新模型，而是一份**可复制的生产架构处方**——教你怎么让 agent 在处理超大结构化数据时不再每轮重复喂一遍全量 payload。
- **现在值得用嗎**：**看场景**——只要你的 agent 单次工具返回超过几万 token、或输入是 MB 级 JSON/日志/报告，就值得立刻照抄；如果只是普通几百 token 的轻量 RAG，收益有限。
- **適合场景**：企业级数据分析 agent、结构化文档校验、日志/台账查询、任何「工具返回集远大于模型实际需要」的场景。
- **不適合场景**：低延迟预算极紧且数据量小的场景（S3 往返反而是新增开销）、纯文本对话类应用、无法引入外部对象存储（S3 兼容层）的部署环境。
- **与「塞大上下文窗口」路线核心差異**：不是靠 100 万/200 万 token 窗口硬扛，而是**让上下文内容变成引用（handle）**，从"容量竞赛"转向"访问模式设计"。

## 是什么 / 解决什么问题

这篇 AWS 官方博客讲的不是产品发布，而是一个**真实生产 agent 的性能改造复盘**。客户 Flightscape 做航空运营平台，其中「训练排班优化」agent 需要校验机组培训安排是否符合业务规则。它接入 40+ 工具，输入是优化请求 JSON、优化响应 JSON、校验报告 JSON 三份文档，规模达到 **20MB+**。

问题很典型：LangGraph 的图状态里直接内联这些重型 payload，每次工具调用都把它们完整注入 LLM 上下文。后果是三层叠加的灾难——单次工具响应最高超过 **80,000 token**；多轮对话里上下文窗口在大数据集上还没推理完就被塞满；平均请求延迟普遍 **超过 15 秒**，最重的单轮查询耗时约 **165 秒**。

AWS 的解法不是换更强的模型，而是把"上下文里放什么"重新设计了一遍，提出三个可组合策略：**轻量状态持久化 + 重型工件外置（S3）**、**大列表按需分页**、**超大字典结构化压缩**。这三者形成一个完整闭环：外置解决持久化、分页解决列表型返回、压缩解决字典型返回。

值得注意的是，这套思路对 AI 应用开发者有直接可迁移价值——它跟模型供应商无关，只依赖「图编排框架 + 对象存储」两个通用能力。

## 技术架构拆解

### 核心设计决策

- **状态脱水（dehydrate）/ 复水（hydrate）**：每轮开始时 `hydrate_state()` 从 AgentCore Memory 恢复轻量状态，运行时按引用从 S3 拉取重型 payload；每轮结束时 `dehydrate_state()` 把重型数据写回 S3，只保存引用。内存里永远只有"索引"，没有"全文"。
- **内容寻址（content addressing）替代随机 key**：引用不是随机生成的，而是对 payload 做 canonical 序列化（排序 key + 紧凑分隔符）后取 SHA-256。好处是**写入幂等**——内容没变的请求不会重复上传，同一轮里重复序列化会自动命中已有对象。
- **进程内缓存兜底**：`S3ArtifactStore` 保留一个小型 in-process cache，当前调用内已读写的 payload 不再走 S3 往返，避免"S3 成新瓶颈"。
- **阈值驱动的自动降级**：工具返回超过 `_LLM_SAMPLE_SIZE` 或 `_MAX_TOOL_CONTENT_CHARS` 时，自动切成分页摘要或描述符，而不是靠开发者手工判断。
- **保留完整能力，牺牲即时可见性**：完整数据始终在 S3，模型可通过 handle 逐片取回。这是设计上的有意取舍——先给"地图"，需要时再要"页"。

这三条策略在单轮内的分工是：策略 1 在每轮首尾执行，策略 2 和 3 在每次工具返回时触发。

### 与前版/竞品的关键差异

| 维度 | 改造前（内联全量 payload） | 改造后（引用 + 按需取用） |
|------|------------|------------|
| 会话状态存储 | 重型 JSON 直接写 AgentCore Memory | 只写引用，重型工件落 S3 |
| 工具返回方式 | 全量列表/字典注入上下文 | 摘要 + sample + result handle |
| 单次工具响应上限 | 出现过 80,000+ token | 受限，固定摘要体量 |
| 5 轮对话总 token | ~289,500 | ~82,900（−71%） |
| 平均 trace 延迟 | 15.4 s | 3.1 s（−80%） |
| 100 问批量总 token | 23.6 M | 8.5 M（−64%） |
| 100 问平均延迟 | 7,930 ms | 2,461 ms（−69%） |
| 最重单轮输入 token | ~32,000 | ~8,000（−75%） |
| 最重单轮耗时 | ~165 s | 9.9 s（−94%） |

### 架构/信息流图

```
                       ┌─────────────────────────────┐
   User turn  ────────▶│  hydrate_state()            │
                       │  ← AgentCore Memory (轻量)   │
                       │  messages / *_ref            │
                       └──────────────┬──────────────┘
                                      │  按 ref 按需取重型数据
                                      ▼
                          ┌───────────────────────┐
                          │  S3ArtifactStore      │
                          │  key = SHA256(JSON)   │
                          │  + in-process cache   │
                          └───────────┬───────────┘
                                      │
          ┌───────────────────────────┼──────────────────────────┐
          ▼                           ▼                          ▼
   Tool 返回 list                Tool 返回 dict            普通小结果
   超阈值？                     序列化超字符上限？          直接放上下文
     │是                            │是                        │
     ▼                              ▼                          │
 {_oversized, total,          {_oversized, _result_handle,     │
  _result_handle, sample}      fields:{list→count+sample,     │
     │                          dict→key数, scalar→原值}}     │
     │                              │                          │
     └─────────▶ get_result_page_tool(handle, offset, limit) ◀─┘
                                      │
                       ┌──────────────▼──────────────┐
                       │  dehydrate_state()          │
                       │  → S3 写重型工件             │
                       │  → Memory 只留 *_ref         │
                       └─────────────────────────────┘
```

## 实用评估

### 什么场景值得用

- **单次工具返回达到数万 token**：文中实测单次响应曾超 80,000 token，这类场景收益最直接，几乎按比例下降。
- **MB 级结构化输入 + 多轮追问**：这是本案例的原始痛点，成本随轮次复利增长，越早改越省。
- **上下文反复被同一份数据占满**：如果同一份 request/response JSON 在 5 轮对话里被注入 5 次，那基本是纯浪费。
- **需要"全量可查但不必全量可见"**：报表、台账、校验结果这类数据天然适合"先摘要、后翻阅"。

### 什么场景不值得用

- **小体量对话类应用**：payload 都是几百到几千 token 时，引入 S3 写入/读取反而增加一次网络往返与运维负担。
- **延迟极敏感且 S3 不可就近部署**：S3 往返是新增延迟项，策略 1 本质上是"用少量 IO 换大量上下文"，IO 慢的地方要重新算账。
- **需要模型一次性看全数据做整体统计**：分页和描述符会牺牲"全局视野"，对必须整体推理的任务要谨慎——虽然文中声称未牺牲能力，但这是其特定场景下的结论。
- **强一致性/事务性状态**：S3 是对象存储不是数据库，AgentCore Memory + S3 两处状态之间没有分布式事务，需要自己做失效与回收策略（文中也提示了清理流程）。

### 迁移成本

| 改动项 | 工作量 | 难度 |
|--------|--------|------|
| 定义 `PersistedState` 轻量 schema + `*_ref` 字段 | 半天 | 低 |
| 实现 `dehydrate_state` / `hydrate_state` | 1–2 天 | 中（要处理领域对象序列化） |
| 建 `S3ArtifactStore`（内容寻址 + 缓存） | 半天 | 低 |
| 改造所有 >40 个工具的统一返回封装 | 2–3 天 | 中（容易漏工具） |
| 新增 `get_result_page_tool` 并告知模型何时用 | 半天 | 低 |
| 观测改造（AgentCore Observability / OTEL） | 1 天 | 低 |

整体看，官方提供了配套 GitHub 仓库（`aws-samples/sample-reducing-token-costs-and-latency-in-amazon-bedrock-agentcore-json-workloads`），核心逻辑可参考照搬。真正的成本不在写代码，而在**逐个梳理工具返回体、找到谁是上下文的最大消费者**——文中的第一条建议也正是这个。

## 对你的意义

对 Ken 的 AI App 线（Agent + UI、RAG 工具链）来说，这篇的价值在于它把"上下文工程"从口号变成了可落地的四条工程约束：

1. **先测量再优化**：用 OTEL trace 找出哪个工具的返回主导了上下文，别凭感觉优化。
2. **状态与工件分离**：这是最值得抄的一条模式——会话状态里放"指针"，重型内容放对象存储。你的 agent UI 如果做长会话，这条可以直接进架构。
3. **prompt 之外还有数据面**：RAG 通常优化检索质量，但这里优化的是**返回格式**——summary/handle/paging。对 RAG 工具链同样适用：检索结果返回 50 条全文 vs 返回 5 条 + 总数 + handle。
4. **模型无关性**：方案不依赖特定模型，对跨供应商网关（Vercel AI Gateway 那类）同样成立。

建议：**立刻试用其核心模式（策略 1+2），策略 3 视字典返回占比再上**。如果你近期在做任何「读文档/读日志/读 JSON 后追问」的 agent，这套改造成本远低于换模型的代价。

跨领域提示：这套"脱水/复水 + 内容寻址"的写法，与 VLA 线里"观测压缩成紧凑 latent、需要时再重建"的思路在结构上高度同构——都是**在有限带宽里传递引用而非原文**。这可能是两条线里值得长期跟踪的一个共性模式。

## 关键代码/配置片段

以下代码均引自 AWS 官方博客原文，可作为改造起点。

轻量持久化状态（写进 AgentCore Memory 的部分）：

```python
class PersistedState(TypedDict, total=False):
    """Serialized session state for AgentCore Memory.

    Heavy fields (request, responses) are stored in S3 and referenced by key.
    Lightweight fields are stored inline.
    """
    messages: List[Any]
    request_ref: Optional[str]          # S3 key for raw request JSON
    responses_ref: Optional[str]        # S3 key for raw responses JSON list
    cache_data_ref: Optional[str]       # S3 key for cache_data payload
    validation_report_ref: Optional[str]
    basic_stats_ref: Optional[str]
```

内容寻址引用（写入幂等的关键）：

```python
def _content_hash(payload: Any) -> str:
    return hashlib.sha256(_canonical_bytes(payload)).hexdigest()

class S3ArtifactStore:
    """Content-addressed artifact store backed by Amazon S3."""
    def put_json(self, payload: Any) -> str:
        ref = _content_hash(payload)
        with self._lock:
            if ref in self._cache:
                return ref          # 相同内容已上传，跳过 PUT
            self._s3.put_object(Bucket=self.bucket, Key=self._key(ref),
                                Body=_canonical_bytes(payload))
        return ref
```

大列表按需分页（策略 2）：

```python
if len(result) > _LLM_SAMPLE_SIZE:
    handle = artifact_store.put_json(result)
    return json.dumps({
        "_oversized": True,
        "_result_handle": handle,
        "total": len(result),
        "sample": result[:_LLM_SAMPLE_SIZE],
    }, default=str)

def get_result_page_tool(handle: str, field: Optional[str] = None,
                         offset: int = 0, limit: int = 50):
    payload = artifact_store.get_json(handle)
    if isinstance(payload, list):
        return {"handle": handle, "offset": offset, "limit": limit,
                "total": len(payload), "items": payload[offset: offset + limit]}
```

超大字典的结构化压缩（策略 3）：

```python
def _oversized_descriptor(payload: Dict[str, Any], handle: str) -> Dict[str, Any]:
    fields: Dict[str, Any] = {}
    for key, value in payload.items():
        if key.startswith("_"):
            continue
        if isinstance(value, list):
            fields[key] = {"type": "list", "count": len(value), "sample": value[:5]}
        elif isinstance(value, dict):
            fields[key] = {"type": "dict", "keys": len(value)}
        else:
            fields[key] = {"type": "scalar", "value": value}
    return {"_oversized": True, "_result_handle": handle, "fields": fields}
```

> TODO: 文中未公开 `_LLM_SAMPLE_SIZE` 与 `_MAX_TOOL_CONTENT_CHARS` 的具体取值，需从配套 GitHub 仓库确认后再定标。

---
[← Back to Deep Dives](./README.md)
