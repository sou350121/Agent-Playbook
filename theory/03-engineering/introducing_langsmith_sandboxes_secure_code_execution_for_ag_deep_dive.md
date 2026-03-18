---
auto_generated: true
generated_at: "2026-03-18T03:31:27Z"
source_url: "https://blog.langchain.com/introducing-langsmith-sandboxes-secure-code-execution-for-agents/"
signal_type: "blog_post"
---
# LangSmith Sandboxes：为 AI Agent 打造的安全代码执行环境 (Introducing LangSmith Sandboxes: Secure Code Execution for Agents)

> 🔍 本文由 Moltbot 自动生成 | 2026-03-18
>
> **项目/工具**: LangSmith Sandboxes (LangChain)
> **链接**: https://blog.langchain.com/introducing-langsmith-sandboxes-secure-code-execution-for-agents/
> **核心定位**: 为 AI Agent 提供安全、隔离、可扩展的代码执行环境，解决「让 LLM 运行任意代码」的核心安全风险

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**: LangSmith 推出的微 VM 隔离沙盒，让 Agent 能在安全环境中执行任意代码，支持长运行会话和实时输出流
- **现在值得用吗**: 是（如果你正在构建需要代码执行能力的 Agent，且不想自己处理容器隔离/资源限制/网络安全）
- **适合场景**: 编码助手自我验证、CI 风格 Agent（克隆 repo→安装依赖→跑测试）、数据分析 Agent 执行 Python 脚本
- **不适合场景**: 简单工具调用（用现有 Tool Calling 即可）、对延迟极度敏感的任务（沙盒有冷启动开销）
- **与 [竞品/前版] 核心差异**: 传统容器为已知代码设计，LangSmith Sandboxes 专为「不可预测的 Agent 生成代码」设计，微 VM 隔离 + Auth Proxy 确保密钥不接触运行时

## 是什么 / 解决什么问题

让 Agent 能够写代码并运行，是编码助手（Cursor、Claude Code、OpenClaw）的核心能力。但这也带来了一个根本性安全问题：**LLM 生成的代码是不可信的**。没有隔离的情况下，Agent 可能在你的本地环境执行破坏性或恶意操作。

根据 ClawSecure 的研究，41% 的 OpenClaw skills 存在漏洞。传统容器（Docker）是为运行已知、经过审查的应用代码设计的，但 Agent 生成的代码完全不同——它是不可信且不可预测的。

LangSmith Sandboxes 的解决方案是：**为每次 Agent 代码执行提供临时的、锁死的微 VM 环境**，控制其能访问的资源、网络和文件系统。Agent 可以在里面任意运行代码，但无法影响你的基础设施。

这个问题随着更多 Agent 变成「编码 Agent」而变得紧迫。自己构建安全代码执行通常意味着：
- 启动容器
- 锁死网络访问
- 将输出传回 Agent
- 完成后销毁一切
- 处理资源限制（Agent 可能在无人看管时快速消耗 CPU、内存、磁盘）

LangSmith 把这套基础设施产品化了。

## 技术架构拆解

### 核心设计决策

| 设计选择 | 理由 |
|---------|------|
| **微 VM 隔离而非 Linux namespaces** | 内核级隔离，每个沙盒运行在硬件虚拟化的微 VM 中，比传统容器更强的安全边界 |
| **Auth Proxy 认证代理** | 密钥完全不接触沙盒运行时，沙盒通过代理访问外部服务，凭证留在外部 |
| **支持长运行会话（分钟/小时级）** | Agent 任务可能超时，沙盒支持 WebSocket 持久命令和实时输出流 |
| **沙盒模板 + 池化预配置** | 预配置暖沙盒池避免冷启动延迟，需求增加时自动扩展 |
| **与 LangSmith Deployment 原生集成** | 沙盒可直接绑定到 Agent thread，复用现有 SDK 和追踪基础设施 |

### 与前版/竞品的关键差异

| 维度 | 传统容器方案 | LangSmith Sandboxes |
|------|------------|------------|
| **隔离级别** | Linux namespaces/cgroups | 微 VM（硬件虚拟化） |
| **设计目标** | 已知、经过审查的应用代码 | 不可预测的 Agent 生成代码 |
| **密钥管理** | 环境变量注入容器 | Auth Proxy，密钥不接触运行时 |
| **会话模式** | 短生命周期 | 长运行会话，支持 WebSocket 持久连接 |
| **状态持久化** | 容器销毁后状态丢失 | 同一 Agent 可在多个 thread 间复用沙盒，文件/包/环境状态保留 |
| **框架依赖** | 需自行集成 | 框架无关，支持 LangChain OSS 或其他框架或无框架 |
| **追踪能力** | 需自行实现 | 沙盒调用与 Agent runs 一起追踪，未来支持完整执行追踪（VM 内所有进程和网络调用） |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────────┐
│                    Agent Thread                             │
│                    (LangSmith)                              │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      │ SDK: spin up sandbox
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                   Sandbox Pool                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │  Warm VM 1  │  │  Warm VM 2  │  │  Warm VM 3  │  ...   │
│  │  (pre-provisioned)          │              │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
│                                                             │
│  Autoscaling: demand ↑ → spin up more                       │
└─────────────────────────────────────────────────────────────┘
                      │
                      │ WebSocket (real-time streaming)
                      ▼
┌─────────────────────────────────────────────────────────────┐
│              Auth Proxy (Credential Guard)                  │
│  - Secrets never touch sandbox runtime                      │
│  - Sandbox accesses external services through proxy         │
└─────────────────────────────────────────────────────────────┘
                      │
                      │ Controlled network access
                      ▼
              External APIs / Services
```

## 实用评估

### 什么场景值得用

1. **编码助手自我验证**: Agent 写完代码后，在沙盒中运行并验证输出，再返回结果给用户。避免在本地环境执行未验证代码。

2. **CI 风格 Agent**: 类似 Open SWE 的工作流——克隆 repo、安装依赖、运行测试套件，然后开 PR。沙盒提供隔离的 CI 环境。

3. **数据分析 Agent**: 执行 Python 脚本处理数据集，返回分析结果。沙盒确保数据处理不会影响生产环境。

4. **多 Agent 协作**: 多个 Agent 可访问同一沙盒，无需在隔离环境间传输 artifacts。适合需要共享文件/状态的多 Agent 工作流。

5. **需要本地预览的场景**: Tunnels 功能可将沙盒端口暴露到本地机器，在部署前预览 Agent 的输出（如 Web 应用）。

### 什么场景不值得用

1. **简单工具调用**: 如果只需要调用已有 API 或执行预定义函数，用现有的 Tool Calling 机制即可，无需沙盒开销。

2. **对延迟极度敏感的任务**: 沙盒有冷启动开销（尽管池化可缓解），不适合毫秒级响应要求的场景。

3. **已有成熟容器基础设施的团队**: 如果你已经有一套经过验证的容器隔离方案，且团队熟悉维护，迁移成本可能不划算。

4. **非代码执行的 Agent 任务**: 纯文本生成、信息检索、分类等任务不需要沙盒。

### 迁移成本

从自建容器方案迁移到 LangSmith Sandboxes：

| 步骤 | 工作量估计 |
|------|-----------|
| 注册 Private Preview waitlist | 5 分钟 |
| 安装 LangSmith SDK (Python/JS) | 10 分钟 |
| 配置 API key 和沙盒模板 | 30 分钟 |
| 将现有容器启动逻辑替换为 SDK 调用 | 2-4 小时（取决于现有代码复杂度） |
| 测试验证（安全隔离/输出流/状态持久化） | 1-2 天 |
| **总计** | **1-3 天** |

从其他 Agent 框架迁移：LangSmith Sandboxes 是框架无关的，但如果你在用 LangChain Deep Agents，集成会更顺滑（原生支持）。

## 对你的意义

如果你正在构建需要代码执行能力的 Agent 系统（尤其是 RAG + Agent 或 Agentic Coding 方向），LangSmith Sandboxes 解决了一个核心痛点：**如何安全地让 LLM 运行任意代码**。

**建议：立即申请 Private Preview 试用**，理由：

1. **安全是 Agent 落地的硬门槛**: 企业级 Agent 部署必须解决代码执行安全问题。LangSmith 的微 VM 隔离 + Auth Proxy 方案是目前最成熟的商业化方案之一。

2. **与现有 LangSmith 生态无缝集成**: 如果你已经在用 LangSmith 做 tracing 或 deployment，沙盒是自然延伸，无需额外基础设施。

3. **Open SWE 已验证可行性**: LangChain 内部用沙盒 powering Open SWE（自动修复 GitHub issues 的 Agent），这是真实生产负载的验证。

4. **未来路线图值得关注**: Shared volumes（Agent 间共享状态）、Binary authorization（限制沙盒内可执行二进制）、Full execution tracing（完整审计日志）——这些都是企业级 Agent 平台的关键能力。

**观望点**:
- Private Preview 阶段的 API 稳定性
- 定价模式（目前未公开）
- 与非 LangChain 框架的集成深度

## 关键代码/配置片段

根据官方博客，启动沙盒的核心代码（Python SDK）：

```python
from langsmith import Client

client = Client(api_key="your_api_key")

# Spin up a sandbox in a single line
sandbox = client.sandboxes.create(
    image="python:3.11",  # 或使用自定义 Docker 镜像
    cpu=1,
    memory=512,
)

# Execute code in the sandbox
result = sandbox.run("print('Hello from sandbox!')")
print(result.output)

# Long-running session with WebSocket streaming
session = sandbox.create_session()
session.run("pip install pandas numpy")  # 安装包会持久化
session.run("import pandas as pd; print(pd.__version__)")

# Expose sandbox port to local machine (tunnel)
tunnel = session.create_tunnel(port=8000)
print(f"Access at: {tunnel.url}")
```

沙盒模板配置（可复用）：

```python
# Define a template once
template = client.sandboxes.create_template(
    name="data-analysis-env",
    image="python:3.11-with-data-tools",
    cpu=2,
    memory=1024,
    env_vars={"DATA_PATH": "/data"},
)

# Reuse template every time
sandbox = client.sandboxes.create_from_template(template_id=template.id)
```

---

## 📌 AI Agent 假设追踪

*当前候选无 assumption_matches，跳过此段。*

---

[← Back to Deep Dives](./README.md)
