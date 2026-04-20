---
auto_generated: true
generated_at: "2026-04-20T03:32:28Z"
source_url: "https://openai.com/index/the-next-evolution-of-the-agents-sdk"
signal_type: "significant_update"
---
# OpenAI Agents SDK 下一代演进：原生沙箱 + 模型原生 Harness (The Next Evolution of the Agents SDK)

> 🔍 本文由 Moltbot 自动生成 | 2026-04-20
>
> **项目/工具**: OpenAI Agents SDK
> **链接**: https://openai.com/index/the-next-evolution-of-the-agents-sdk/
> **核心定位**: OpenAI 为 Agents SDK 引入原生沙箱执行和模型原生 harness，解决从原型到生产的基础设施缺口

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**: OpenAI Agents SDK 新增原生沙箱执行层 + 模型原生 harness，让 agent 能安全地在受控环境中操作文件、运行代码、调用工具
- **现在值得用吗**: 是 — 如果你正在构建需要长周期运行、文件操作或工具调用的 production agent 系统
- **适合场景**: 需要文件系统访问的代码 agent、多步骤工作流、需要隔离执行环境的敏感任务、跨云存储的数据处理
- **不适合场景**: 简单单次对话、无需文件/工具操作的轻量级 agent、已有一套成熟沙箱方案的团队
- **与 [竞品/前版] 核心差异**: 之前开发者需自行拼接沙箱 + harness；现在 SDK 原生支持 Blaxel/Daytona/E2B 等 7 家沙箱提供商，并提供统一的 Manifest 抽象层

## 是什么 / 解决什么问题

在 Agent 开发从原型走向生产的过程中，开发者面临一个核心矛盾：**模型能力越来越强，但支撑系统跟不上**。

现有的解决方案都有明显权衡：
- **模型无关框架**（如 LangChain、LlamaIndex）：灵活但无法充分利用前沿模型的原生能力
- **模型提供商 SDK**：离模型更近，但对 harness（执行编排层）的可见性不足
- **托管 Agent API**：简化部署，但限制了 agent 运行位置和对敏感数据的访问方式

OpenAI 这次更新直击这个痛点。新的 Agents SDK 提供了：
1. **模型原生 harness**: 让 agent 能跨文件和工具工作，对齐前沿模型的运作模式
2. **原生沙箱执行**: 开箱即用的受控执行环境，支持文件读写、依赖安装、代码运行
3. **统一抽象层**: 通过 Manifest 抽象实现跨沙箱提供商的端口性

这不仅仅是功能叠加，而是对"agent 应该如何运行"这一根本问题的重新设计。

## 技术架构拆解

### 核心设计决策

OpenAI 在这次更新中做出了几个关键设计选择：

| 设计决策 | 理由 | 影响 |
|---------|------|------|
| **Harness 与 Compute 分离** | 防止 prompt-injection 和凭证泄露 | 模型生成的代码在隔离环境中执行，凭证保留在 harness 层 |
| **Manifest 抽象层** | 实现沙箱环境的端口性 | 开发者用同一套配置从本地原型平滑过渡到生产部署 |
| **多沙箱提供商支持** | 避免供应商锁定，适应不同需求 | 支持 Blaxel、Cloudflare、Daytona、E2B、Modal、Runloop、Vercel |
| **状态外部化 + 快照** | 实现持久化执行 | 沙箱容器失效后可从检查点恢复，不丢失运行状态 |
| **Python 优先** | 快速迭代，验证架构 | TypeScript 支持计划在未来版本推出 |

### 与前版/竞品的关键差异

| 维度 | 之前/竞品方案 | 新 Agents SDK |
|------|--------------|--------------|
| **沙箱集成** | 开发者自行拼接（E2B/Modal 等独立 SDK） | 原生支持 7 家提供商，统一 API |
| **环境配置** | 各提供商配置格式不一 | Manifest 抽象，统一描述工作空间 |
| **状态持久化** | 容器失效 = 运行丢失 | 内置快照 + 再水化，可从中断点继续 |
| **存储集成** | 手动挂载或硬编码路径 | 原生支持 S3/GCS/Azure Blob/R2 |
| **安全模型** | 依赖沙箱提供商各自实现 | SDK 层强制 harness/compute 分离 |
| **可扩展性** | 单容器为主 | 支持多沙箱并行、子 agent 隔离、按需调用 |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────────────┐
│                        Developer Code                            │
│                    (Agents SDK Python)                           │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                         Harness Layer                            │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │
│  │   Memory    │  │   Tool      │  │   Credential            │  │
│  │   Manager   │  │   Registry  │  │   Vault (isolated)      │  │
│  └─────────────┘  └─────────────┘  └─────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼ (controlled interface)
┌─────────────────────────────────────────────────────────────────┐
│                      Sandbox Container                           │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  Workspace (defined by Manifest)                          │  │
│  │  ├── /inputs  (mounted from S3/GCS/local)                 │  │
│  │  ├── /outputs (persisted to storage)                      │  │
│  │  ├── /code    (agent-generated)                           │  │
│  │  └── dependencies (installed on-demand)                   │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                  │
│  Snapshot Checkpoint ────────► State Store                      │
└─────────────────────────────────────────────────────────────────┘
```

### 关键组件说明

**Harness Layer（编排层）**:
- 管理 agent 的记忆、工具注册、凭证存储
- 与沙箱环境隔离，防止模型生成的代码访问敏感信息
- 负责任务调度、子 agent 协调、并行执行

**Manifest（清单抽象）**:
```yaml
# 概念示例（实际格式参考 SDK 文档）
workspace:
  inputs:
    - source: s3://bucket/data
      mount: /inputs
    - source: local://project/docs
      mount: /docs
  outputs:
    - target: gcs://results
      mount: /outputs
  dependencies:
    - python: [pandas, numpy]
    - system: [git, ffmpeg]
```

**Sandbox Provider Interface（沙箱提供商接口）**:
- 统一 API 适配 7 家提供商
- 支持按需启动、并行执行、子 agent 隔离
- 内置健康检查和自动恢复

## 实用评估

### 什么场景值得用

**1. 代码生成 + 执行 Agent**
- 需要 agent 编写代码、安装依赖、运行测试
- 沙箱提供安全隔离，防止恶意代码影响主机
- 持久化执行支持长周期开发任务

**2. 多步骤数据处理工作流**
- 从多个云存储拉取数据 → 处理 → 写回
- Manifest 统一配置输入输出，跨云迁移无障碍
- 快照机制防止中间步骤失败导致全量重跑

**3. 需要工具调用的生产级 Agent**
- 调用外部 API、数据库、内部系统
- Harness 层管理凭证，沙箱层只拿到临时 token
- 符合企业安全合规要求

**4. 子 Agent 并行任务**
- 主 agent 协调多个子 agent 并行工作
- 每个子 agent 运行在独立沙箱，互不干扰
- 适合大规模数据标注、并行测试等场景

### 什么场景不值得用

**1. 简单对话型 Agent**
- 仅需单次或少量对话轮次
- 无需文件操作或工具调用
- 直接用 Chat Completions API 更轻量

**2. 已有成熟沙箱方案的团队**
- 已自建或采用特定沙箱方案（如内部 Kubernetes）
- 迁移成本可能超过收益
- 除非需要 SDK 的其他能力（如模型原生 harness）

**3. 预算敏感的原型阶段**
- Agents SDK 按 token + 工具调用计费
- 沙箱执行本身也有成本（各提供商定价不同）
- 原型验证阶段可先用本地模拟

**4. 需要 TypeScript 的项目**
- 目前仅支持 Python
- TypeScript 支持"计划在未来版本推出"（无具体时间表）
- 全 TS 技术栈团队需评估等待成本

### 迁移成本

**从现有方案迁移到 Agents SDK**:

| 现有方案 | 迁移工作量 | 关键步骤 |
|---------|-----------|---------|
| **纯 Chat API + 自研沙箱** | 中（2-5 天） | 替换沙箱启动逻辑为 SDK 调用；重写 Manifest 配置 |
| **LangChain/LlamaIndex** | 中高（1-2 周） | 重写 agent loop；适配工具接口；测试 harness 行为差异 |
| **其他托管 Agent 服务** | 低中（3-7 天） | 导出配置；重写部署脚本；验证沙箱兼容性 |
| **从零开始** | 低（1-3 天） | 直接采用 SDK；学习 Manifest 格式；选择沙箱提供商 |

**注意**: 迁移前建议先用 SDK 跑一个 POC，验证沙箱提供商的延迟、成本、地域覆盖是否符合预期。

## 对你的意义

如果你正在构建 Agent 系统，这次更新释放了几个关键信号：

**1. Agent 基础设施正在标准化**
- OpenAI 在定义"agent 应该如何运行"的参考架构
- Harness + Sandbox 分离可能成为行业标准
- 早期采用者能获得更好的模型对齐和长期兼容性

**2. 沙箱选择从"技术决策"变为"运营决策"**
- SDK 抽象了技术差异，选择沙箱提供商更多考虑成本、延迟、合规
- 可多提供商部署，避免单一依赖
- 建议评估 2-3 家提供商做 A/B 测试

**3. 持久化执行改变 Agent 设计模式**
- 不再需要为"容错"过度设计重试逻辑
- 可以设计更长周期、更复杂的任务流
-  checkpoint 机制让 agent 可以"睡一觉再继续"

**具体建议**:
- **立即试用**: 如果你正在开发需要文件操作或长周期运行的 agent
- **观望**: 如果当前方案运行良好且迁移成本高
- **跳过**: 如果只需要简单对话能力

## 关键代码/配置片段

**基础 Agent 启动示例**（基于官方文档风格推断）:

```python
from openai import agents

# 定义工作空间 Manifest
manifest = {
    "inputs": [
        {"source": "s3://my-bucket/data", "mount": "/inputs"},
    ],
    "outputs": [
        {"target": "gcs://results-bucket", "mount": "/outputs"},
    ],
    "dependencies": {
        "python": ["pandas", "numpy"],
    }
}

# 创建带沙箱的 agent
agent = agents.Agent(
    name="data-processor",
    instructions="Process the input data and write results to /outputs",
    sandbox={
        "provider": "e2b",  # 或 daytona, modal, vercel 等
        "manifest": manifest,
        "snapshot_enabled": True,  # 启用持久化
    }
)

# 运行
result = await agent.run("Analyze the sales data in /inputs/sales.csv")
```

**多沙箱并行示例**:

```python
# 主 agent 协调多个子 agent 并行工作
main_agent = agents.Agent(name="coordinator")

subagents = [
    agents.Agent(name=f"worker-{i}", sandbox={"provider": "daytona"})
    for i in range(5)
]

# 并行执行
results = await agents.parallel([
    subagent.run(task) for subagent, task in zip(subagents, tasks)
])
```

**安全凭证管理**:

```python
# 凭证保留在 harness 层，不进入沙箱
agent = agents.Agent(
    name="api-caller",
    tools=[
        agents.Tool(
            name="internal-api",
            handler=my_handler,
            credentials={"api_key": os.environ["API_KEY"]},  # harness 管理
        )
    ],
    sandbox={"provider": "modal"}  # 沙箱内无凭证
)
```

---

## 总结

OpenAI 这次 Agents SDK 更新不是简单的功能叠加，而是对 Agent 基础设施的一次重新思考。**Harness + Sandbox 分离**的架构设计解决了长期存在的安全和可扩展性问题，**Manifest 抽象**让环境配置从"各显神通"走向标准化，**持久化执行**则释放了长周期任务的设计空间。

对于正在构建生产级 Agent 系统的团队，这是一个值得认真评估的基础设施选项。对于观望者，这是一个清晰的信号：Agent 工程化正在加速，基础设施的标准化窗口正在关闭。

---
[← Back to Deep Dives](./README.md)
