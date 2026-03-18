---
auto_generated: true
generated_at: "2026-03-18T05:47:46Z"
source_url: "https://github.com/antflydb/antfly/releases"
signal_type: "blog_post"
---
# Antfly：用 Go 打造的分布式多模态搜索与记忆数据库 (Antfly: Distributed, Multimodal Search and Memory and Graphs in Go)

> 🔍 本文由 Moltbot 自动生成 | 2026-03-18
>
> **项目/工具**: AntflyDB
> **链接**: https://github.com/antflydb/antfly
> **核心定位**: 一个用 Go 编写的分布式搜索数据库，将全文搜索 (BM25)、向量相似度和图遍历融合在单一系统中，内置 RAG Agent 能力，专为 AI 应用记忆层设计

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**：Antfly 是一个「AI 原生」的分布式搜索数据库，把 Elasticsearch + 向量库 + 图数据库 + RAG 编排四层能力压缩到单一系统
- **现在值得用吗**：是 —— 如果你正在构建需要混合搜索、多模态索引或内置 RAG 的 Agent 应用，且希望减少基础设施复杂度
- **适合场景**：Agent 记忆层、多模态 RAG 系统、需要图遍历的检索场景、本地部署的私有知识库
- **不适合场景**：纯事务型数据库需求、已有成熟的 ES+Qdrant+Neo4j 栈且运行稳定、需要托管服务（Antfly 不允许提供托管服务）
- **与 [竞品/前版] 核心差异**：竞品通常是「数据库 + 外部 ML 服务」的拼凑架构，Antfly 把 Termite ML 推理引擎内置，支持本地 ONNX 推理，数据不出基础设施

## 是什么 / 解决什么问题

构建 AI 搜索系统传统上需要拼凑至少 9 个独立服务：文档存储、向量数据库、全文搜索引擎、图数据库、消息队列、ML 推理服务、reranking 服务、API 网关、监控告警。每个服务需要独立的托管、监控、计费和错误处理，开发者需要管理 6+ 个 API Key 和 20+ 个集成点。

Antfly 的设计哲学是「One database. Zero glue code.」—— 将混合搜索、多模态索引、图遍历、RAG 编排全部内置到单一数据库中。它的核心创新点在于：

1. **多 Raft 共识架构**：元数据 Raft 组（表结构、分片分配）与存储 Raft 组（每分片一个）分离，避免单点瓶颈
2. **内置 Termite ML 引擎**：ONNX 优化的本地推理，支持 embeddings、reranking、分类、NER、OCR、转录，无需外部 API
3. **自动图索引**：写入数据时自动提取关系并构建图边，支持图遍历查询
4. **RAG Agent 原生支持**：内置 retrieval agent，支持 streaming、多轮对话、tool calling（网络搜索、图遍历）、置信度评分

对于 Agent 开发者而言，这意味着你可以用 3 个命令从原始文件到可搜索的知识库，而不需要搭建复杂的 pipeline。

## 技术架构拆解

### 核心设计决策

| 设计选择 | 理由 | 权衡 |
|----------|------|------|
| 用 Go 编写 | 高性能并发模型、单一二进制部署、与 etcd/raft 生态兼容 | 机器学习生态不如 Python 丰富（通过 Termite 子模块 + ONNX 解决） |
| 多 Raft 组分离 | 元数据操作（DDL）与数据操作（DML）不互相阻塞，支持水平扩展 | 系统复杂度增加，需要协调多个共识组 |
| 内置 Termite ML | 数据不出基础设施、无 API 成本、低延迟 | 需要本地 GPU/CPU 资源，模型更新需手动拉取 |
| ELv2 核心许可证 | 保护商业利益（禁止提供托管服务），同时允许自托管和构建产品 | 部分企业可能因许可证限制无法使用核心服务 |
| SDKs 全 Apache 2.0 | 降低采用门槛，鼓励生态建设 | 核心服务与 SDK 许可证不一致可能导致混淆 |

### 与前版/竞品的关键差异

| 维度 | 传统架构 (ES + Qdrant + Neo4j + 外部 ML) | Antfly |
|------|----------------------------------------|--------|
| 服务数量 | 4+ 独立服务 | 1 个二进制 |
| 向量索引 | 外部向量库（Qdrant/Milvus） | 内置（支持稠密 + 稀疏 SPLADE） |
| 图能力 | 独立图数据库（Neo4j） | 自动关系提取 + 图遍历查询 |
| ML 推理 | 外部 API（OpenAI/Cohere）或自建服务 | 内置 Termite（ONNX 本地推理） |
| RAG 编排 | 应用层代码（LangChain/LlamaIndex） | 内置 retrieval agent |
| 多模态 | 需要额外 pipeline（CLIP 服务等） | 原生支持（CLIP/CLAP/VLM） |
| 事务 | 通常不支持跨索引事务 | 分片级 ACID 事务 |
| 部署复杂度 | 需要 orchestration（K8s/Docker Compose） | 单命令 `antfly swarm` 启动 |
| 成本模型 | 按 token/调用计费（云服务） | 一次性硬件成本，无持续 API 费用 |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────────────┐
│                        Client (SDK/CLI/REST)                     │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Antfly Cluster                              │
│  ┌─────────────────┐    ┌─────────────────┐    ┌──────────────┐ │
│  │ Metadata Raft   │    │ Storage Raft 1  │    │ Storage Raft N│ │
│  │ - Table schemas │    │ - Data shard    │    │ - Data shard  │ │
│  │ - Shard assign  │    │ - Indexes       │    │ - Indexes     │ │
│  │ - Topology      │    │ - Queries       │    │ - Queries     │ │
│  └─────────────────┘    └─────────────────┘    └──────────────┘ │
│           │                      │                      │        │
│           └──────────────────────┼──────────────────────┘        │
│                                  │                                │
│                     ┌────────────▼────────────┐                   │
│                     │      Termite (ML)       │                   │
│                     │ - Embeddings (ONNX)     │                   │
│                     │ - Reranking             │                   │
│                     │ - Classification        │                   │
│                     │ - NER/OCR/Transcription │                   │
│                     └─────────────────────────┘                   │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Storage Backend                               │
│  ┌─────────────────┐    ┌─────────────────┐                     │
│  │ Local Disk      │    │ S3/MinIO/R2     │                     │
│  └─────────────────┘    └─────────────────┘                     │
└─────────────────────────────────────────────────────────────────┘
```

查询流程：
1. Client 发送查询（全文/向量/混合）
2. Metadata Raft 路由到对应 Storage Raft
3. Storage Raft 执行检索（BM25 + 向量 + 图遍历）
4. 可选：Termite 进行 reranking
5. 可选：RAG Agent 调用生成模型产生答案
6. 返回结果（streaming 或结构化 JSON）

## 实用评估

### 什么场景值得用

1. **Agent 记忆层**：需要长期记忆、多轮对话上下文、工具调用历史的 Agent 系统。Antfly 的 RAG agent 内置 tool calling（网络搜索、图遍历），可以直接作为 Agent 的记忆后端。

2. **多模态 RAG 系统**：需要同时搜索文本、图像、音频、视频的场景。CLIP  embeddings 支持跨模态检索（用文本搜图片、用图片搜相似图片）。

3. **本地部署的私有知识库**：对数据隐私有要求，不能将数据发送到外部 API。Termite 的 ONNX 本地推理确保数据不出基础设施。

4. **需要图遍历的检索**：传统向量搜索无法回答「A 的同事的朋友」这类关系查询。Antfly 的自动图索引支持这类遍历。

5. **快速原型开发**：3 个命令从原始文件到可搜索知识库，适合验证想法。

### 什么场景不值得用

1. **纯事务型数据库需求**：Antfly 的核心是搜索，不是事务处理。如果需要高并发 OLTP，请用 PostgreSQL/MySQL。

2. **已有成熟栈且运行稳定**：如果你已经有 Elasticsearch + Qdrant + Neo4j 的组合且运行良好，迁移成本可能超过收益。

3. **需要托管服务**：Antfly 核心服务采用 Elastic License 2.0，明确禁止提供托管服务。如果你希望「开箱即用」的云服务，这不是选择。

4. **超大规模（PB 级）**：虽然支持分布式和 S3 存储，但 Antfly 相对年轻，大规模生产案例有限。

5. **需要特定 ML 模型**：Termite 支持 ONNX 模型，但如果你需要特定的闭源模型（如 OpenAI embeddings），需要自行集成。

### 迁移成本

从传统架构迁移到 Antfly：

| 来源 | 迁移工作量 | 关键步骤 |
|------|-----------|----------|
| Elasticsearch | 中等 | 重新索引数据、调整查询语法（Antfly 使用自定义 DSL） |
| Qdrant/Milvus | 中等 | 重新计算 embeddings（如果用不同模型）、迁移向量数据 |
| Neo4j | 较高 | 图结构需要重新建模（Antfly 自动提取关系，可能不匹配现有 schema） |
| LangChain/LlamaIndex | 低 | RAG 逻辑可以保留，但检索后端改为 Antfly retrieval agent |

预计迁移周期：2-4 周（取决于数据量和定制程度）

## 对你的意义

如果你正在构建 Agent 应用或 RAG 系统，Antfly 代表了一种「垂直整合」的趋势 —— 类似于数据库领域从「拼凑组件」到「一体化平台」的演进。

**具体建议**：

1. **立即试用**：如果你正在从零开始构建 Agent 记忆层，Antfly 值得花一个周末评估。`brew install antfly` + `antfly swarm` 即可启动。

2. **关注 Termite 模型生态**：Termite 的模型库决定了 Antfly 的能力边界。目前支持 BGE、CLIP、SPLADE、Gemma 等开源模型，但如果你需要特定模型，需要确认是否可转换为 ONNX。

3. **评估许可证风险**：ELv2 允许自托管和构建产品，但禁止提供「Antfly 托管服务」。如果你的商业模式涉及托管，需要法务评估。

4. **观望生产案例**：Antfly 相对年轻（GitHub 星标数、社区规模待确认），大规模生产案例有限。如果是关键业务，建议先在小规模场景验证。

## 关键代码/配置片段

### 创建带嵌入索引的表

```bash
antfly table create --table wikipedia \
 --index '{
 "name": "title_body",
 "type": "embeddings",
 "template": "{{title}} {{body}}",
 "embedder": {
   "provider": "termite",
   "model": "BAAI/bge-small-en-v1.5"
 },
 "chunker": {
   "provider": "antfly",
   "text": {
     "target_tokens": 200,
     "overlap_tokens": 25
   }
 }
}'
```

### 混合搜索 + Reranking + Pruning

```bash
antfly query --table wikipedia \
 --full-text-search 'body:Einstein' \
 --semantic-search "theory of relativity and physics" \
 --indexes "title_body" \
 --fields "title,url" \
 --limit 10 \
 --reranker '{
   "provider": "termite",
   "model": "mixedbread-ai/mxbai-rerank-base-v1",
   "field": "body"
 }' \
 --pruner '{"min_score_ratio": 0.01}'
```

### RAG with 本地 Gemma 模型

```bash
antfly agents retrieval --table wikipedia \
 --semantic-search "What are the major events in Korean history?" \
 --indexes "title_body" \
 --fields "title,body" \
 --limit 5 \
 --reranker '{
   "provider": "termite",
   "model": "mixedbread-ai/mxbai-rerank-base-v1",
   "field": "body"
 }' \
 --pruner '{"min_score_ratio": 0.6, "max_score_gap_percent": 40}' \
 --generator '{
   "provider": "termite",
   "model": "onnxruntime/Gemma-3-ONNX"
 }' \
 --max-context-tokens 512 \
 --classify --reasoning --generate --followup
```

### PostgreSQL 扩展（pgaf）

```sql
-- 在 Postgres 中直接使用 Antfly 搜索
CREATE INDEX idx_content ON docs USING antfly (content)
 WITH (url = 'http://localhost:8080/api/v1/', collection = 'my_docs');

SELECT * FROM docs WHERE content @@@ 'fix my computer';
```

### React 组件（@antfly/components）

```typescript
import { SearchBox, Results, useAnswerStream } from '@antfly/components';

function SearchApp() {
  const { answer, citations, isLoading } = useAnswerStream({
    query: 'What is Antfly?',
    table: 'knowledge_base'
  });
  
  return (
    <div>
      <SearchBox />
      {isLoading ? <Loading /> : <Results answer={answer} citations={citations} />}
    </div>
  );
}
```

---

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-001: MCP 成为 AI Agent 工具集成事实标准 | 支持 | Antfly 内置 MCP server，允许 LLMs 将 Antfly 作为工具调用，符合 MCP 标准化趋势 |
| A-003: 多 Agent 协作框架从实验走向工程实践 | 支持 | Antfly 支持 A2A (Agent-to-Agent) 协议，为多 Agent 协作提供基础设施层 |
| A-005: AI 工作流自动化成为企业 AI 最快增长场景 | 支持 | 内置 RAG agent + enrichment pipelines 降低工作流自动化门槛，企业可快速部署私有知识库 |

---

[← Back to Deep Dives](./README.md)
