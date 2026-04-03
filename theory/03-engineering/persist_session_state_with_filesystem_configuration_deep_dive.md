---
auto_generated: true
generated_at: "2026-04-03T11:04:55Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/persist-session-state-with-filesystem-configuration-and-execute-shell-commands/"
signal_type: "blog_post"
---
# AWS AgentCore 持久化会话状态与命令执行深度解析 (Persist Session State with Filesystem Configuration)

> 🔍 本文由 Moltbot 自动生成 | 2026-04-03
>
> **项目/工具**: Amazon Bedrock AgentCore Runtime
> **链接**: https://aws.amazon.com/blogs/machine-learning/persist-session-state-with-filesystem-configuration-and-execute-shell-commands/
> **核心定位**: 解决 AI Agent 会话间文件系统状态丢失和确定性操作必须经过 LLM 两大痛点

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**: Amazon Bedrock AgentCore Runtime 新增两项能力——托管会话存储（持久化 Agent 文件系统状态）和直接执行 shell 命令，让 Agent 开发工作流不再因会话中断而丢失进度
- **现在值得用吗**: 是，如果你正在用 Bedrock 构建生产级 Agent 且遇到会话状态丢失或测试/构建流程需要确定性执行
- **适合场景**: 编码 Agent、多日开发工作流、需要运行测试/构建/版本控制的 Agent 任务
- **不适合场景**: 简单问答型 Agent、无状态任务、非 Bedrock 平台的 Agent 系统
- **与竞品/前版核心差异**: 首次将持久化存储和命令执行原生集成到 Agent Runtime 中，无需外部编排或自定义 checkpoint 逻辑

## 是什么 / 解决什么问题

AI Agent 已经远远超越了简单的聊天对话。它们可以编写代码、管理文件系统状态、执行 shell 命令。随着 Agentic Coding 助手和工作流的成熟，文件系统已成为 Agent 的主要工作记忆，将其能力扩展到上下文窗口之外。

但这个转变带来了两个每个构建生产级 Agent 的团队都会遇到的问题：

**问题 1: 文件系统是临时的**
当 Agent 会话停止时，它创建的一切——安装的依赖、生成的代码、本地 git 历史——都会消失。想象一下：你的编码 Agent 花了 20 分钟搭建项目、安装依赖、生成样板代码、配置构建工具。你离开去吃午饭，回来后发现会话超时，一切归零。

**问题 2: 确定性操作被迫经过 LLM**
当工作流需要运行 `npm test` 或 `git push` 这类确定性操作时，你被迫要么通过 LLM 路由（增加 token 成本、延迟和非确定性），要么在 Runtime 外构建自定义工具（需要连接 Agent 文件系统，增加复杂度）。

Amazon Bedrock AgentCore Runtime 现在通过两项新能力解决这两个问题：
1. **托管会话存储**（Managed Session Storage，公开预览）—— 持久化 Agent 文件系统状态
2. **执行命令**（InvokeAgentRuntimeCommand）—— 直接在每个活跃 Agent 会话关联的 microVM 中运行 shell 命令

## 技术架构拆解

### 核心设计决策

**1. MicroVM 隔离架构**
- 每个会话在专用的 microVM 中运行，拥有独立的内核、内存和文件系统
- 提供强安全边界，但意味着每次会话启动都是干净的文件系统
- 会话终止（显式停止或空闲超时）后，microVM 及其所有内容消失

**2. 持久化存储挂载点设计**
- 在创建 Agent 时配置 `sessionStorage`，指定挂载路径（必须以 `/mnt` 开头，如 `/mnt/workspace`）
- 写入该路径的任何文件自动持久化到托管存储
- 默认保留 14 天空闲时间，超时后清理
- 每会话最大数据量 1 GB

**3. 命令执行与 Agent 共享文件系统**
- 命令在同一个容器、文件系统、环境中运行，不是 sidecar 或独立进程
- Agent 写入 `/mnt/workspace/fix.py` 后，命令可以立即 `cat /mnt/workspace/fix.py`
- 无需同步步骤、文件传输或共享卷配置

**4. 一次性执行模型**
- 每个命令生成一个新的 bash 进程，运行到完成（或超时）后返回
- 命令之间没有持久 shell 会话，没有 shell 历史，环境变量不携带
- 匹配 Agent 框架的使用模式：构造命令 → 运行 → 读取输出 → 决定下一步

### 与前版/竞品的关键差异

| 维度 | 之前/传统方案 | AgentCore Runtime 新方案 |
|------|------------|------------|
| 会话状态持久化 | 手动 checkpoint 到 S3 或保持会话活跃 | 原生托管存储，配置即持久化 |
| 确定性操作执行 | 通过 LLM 工具调用或外部编排 | 直接 InvokeAgentRuntimeCommand |
| 文件系统一致性 | 需要同步逻辑或共享卷 | 同一容器内，立即可见 |
| Agent 代码改动 | 需要保存/恢复逻辑 | 无需改动，正常读写即可 |
| 成本模型 | 保持会话活跃持续计费 | 会话可停止，仅存储计费 |
| 命令输出 | 批量返回或轮询 | HTTP/2 实时流式输出 |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────────┐
│                    AgentCore Runtime                         │
│  ┌───────────────────────────────────────────────────────┐  │
│  │                   MicroVM (Session)                    │  │
│  │  ┌─────────────┐    ┌─────────────┐    ┌───────────┐  │  │
│  │  │   Agent     │    │  Filesystem │    │   Bash    │  │  │
│  │  │  (LLM)      │───▶│  /mnt/      │◀───│  Process  │  │  │
│  │  │  Reasoning  │    │  workspace  │    │  Command  │  │  │
│  │  └─────────────┘    └──────┬──────┘    └───────────┘  │  │
│  │                            │                           │  │
│  └────────────────────────────┼───────────────────────────┘  │
│                               │                               │
│                    ┌──────────▼──────────┐                   │
│                    │  Managed Session    │                   │
│                    │     Storage         │                   │
│                    │  (Persisted 14d)    │                   │
│                    └─────────────────────┘                   │
└─────────────────────────────────────────────────────────────┘

Workflow Loop:
1. InvokeAgentRuntime → Agent writes to /mnt/workspace
2. InvokeAgentRuntimeCommand → Run tests/git/build in same filesystem
3. Stop Session → MicroVM terminates, storage persists
4. Resume (next day) → New MicroVM mounts same storage, continue
```

## 实用评估

### 什么场景值得用

**1. 编码 Agent 多日开发工作流**
- Agent 花数小时搭建项目、分析代码库、生成修复
- 使用持久化存储后，可随时停止会话（节省计算成本），第二天用相同 session-id 恢复，所有文件、依赖、git 历史完整保留
- 案例：下载代码库 → 分析 → 生成修复 → 停止 → 次日恢复 → 运行测试 → 提交

**2. 测试驱动的 Agent 迭代**
- Agent 编写代码后，用 `InvokeAgentRuntimeCommand` 运行 `npm test` 或 `pytest`
- 流式输出实时返回，可早期检测失败并反馈给 Agent 迭代
- 避免将确定性测试路由经过 LLM，节省 token 并提高可靠性

**3. Git 工作流自动化**
- 分支、提交、推送是确定性操作，应作为命令执行而非 LLM 工具调用
- 保持版本控制逻辑在 LLM 之外，减少非确定性风险
- 示例：`git checkout -b fix/JIRA-1234` → `git add -A` → `git commit` → `git push`

**4. 环境引导加速**
- 在 Agent 开始工作前，用命令克隆仓库、安装包、设置构建工具
- 比通过 Agent 执行更快、更可靠
- 示例：`cd /mnt/workspace && npm install` 作为初始化步骤

**5. 验证门禁**
- 在 Agent 提交代码前，运行 linter、类型检查器、安全扫描器作为门禁
- 确保代码质量，同时保持验证逻辑确定性

### 什么场景不值得用

**1. 简单问答型 Agent**
- 如果 Agent 只是回答问题、不操作文件系统、不需要跨会话记忆，持久化存储是过度设计
- 增加配置复杂度但无实际收益

**2. 非 Bedrock 平台**
- 该能力是 Bedrock AgentCore Runtime 专属，无法迁移到其他平台
- 如果用 LangChain + 自托管 LLM，需要自行实现类似功能

**3. 超大型项目（>1 GB）**
- 每会话存储上限 1 GB，对于大型 monorepo 或多模型项目可能不足
- 需评估项目规模或考虑外部存储方案

**4. 需要命令间状态共享的场景**
- 每个命令是独立的 bash 进程，环境变量和 shell 历史不携带
- 如果需要复杂的状态传递，需在命令中显式编码（如 `cd /workspace && export X=Y && cmd`）

**5. 成本敏感的原型阶段**
- 托管存储会产生额外费用（虽然低于保持会话活跃的计算成本）
- 原型验证阶段可先用临时会话，确认价值后再启用持久化

### 迁移成本

**从现有 Bedrock Agent 迁移:**
- 低：只需在 `CreateAgentRuntime` 时添加 `filesystemConfigurations` 配置
- Agent 代码无需改动，正常读写 `/mnt/workspace` 即可
- 现有会话不受影响，新会话启用持久化

**从自建 Agent 系统迁移:**
- 中：需要切换到 Bedrock AgentCore Runtime
- 收益是原生集成，代价是平台锁定
- 评估标准：是否已用 AWS 生态、是否需要 Bedrock 模型

**从手动 checkpoint 方案迁移:**
- 低到中：移除自定义 S3 上传/下载逻辑
- 改为直接写入 `/mnt/workspace`
- 测试 stop/resume 流程确保符合预期

## 对你的意义

如果你正在用 Bedrock 构建生产级 Agent，这两项能力解决了两个最痛的工程问题：

**立即试用的理由:**
1. **成本优化**: 可停止空闲会话（停止计费），需要时恢复（状态完整），而非保持会话活跃
2. **开发体验**: 多日工作流不再因超时中断，Agent 真正支持"暂停 - 恢复"
3. **可靠性**: 测试/构建/版本控制作为命令执行，消除 LLM 非确定性风险
4. **简化架构**: 无需外部编排层，平台原生支持完整开发循环

**观望的理由:**
1. 公开预览阶段，API 可能有变动
2. 1 GB 存储限制对大型项目可能不足
3. 仅限 Bedrock 平台，多平台战略需权衡

**具体建议:**
- 如果你已有 Bedrock Agent 在生产运行 → **立即试用**，先从非关键会话开始
- 如果你在选型阶段 → **纳入评估**，这是 Bedrock 相比其他平台的差异化优势
- 如果你用自托管方案 → **关注但无需迁移**，可参考其设计思路自建类似能力

## 关键代码/配置片段

### 配置持久化存储（创建 Agent 时）

```python
import boto3

control_client = boto3.client('bedrock-agentcore-control', region_name='us-west-2')

response = control_client.create_agent_runtime(
    agentRuntimeName='coding-agent',
    agentRuntimeArtifact={
        'containerConfiguration': {
            'containerUri': '123456789012.dkr.ecr.us-west-2.amazonaws.com/my-agent:latest'
        }
    },
    roleArn='arn:aws:iam::111122223333:role/AgentExecutionRole',
    protocolConfiguration={
        'serverProtocol': 'HTTP'
    },
    networkConfiguration={
        'networkMode': 'PUBLIC'
    },
    filesystemConfigurations=[{
        'sessionStorage': {
            'mountPath': '/mnt/workspace'  # 必须以 /mnt 开头
        }
    }]
)
```

### 完整工作流示例：Agent  reasoning + 命令执行 + 持久化

```python
import boto3
import json

client = boto3.client('bedrock-agentcore', region_name='us-west-2')

AGENT_ARN = 'arn:aws:bedrock-agentcore:us-west-2:111122223333:runtime/my-coding-agent'
SESSION_ID = 'fefc1779-e5e7-49cf-a2c4-abaf478680c4'

def run_command(command, timeout=60):
    """执行 shell 命令并返回退出码"""
    response = client.invoke_agent_runtime_command(
        agentRuntimeArn=AGENT_ARN,
        runtimeSessionId=SESSION_ID,
        contentType='application/json',
        accept='application/vnd.amazon.eventstream',
        body={'command': command, 'timeout': timeout}
    )
    for event in response.get('stream', []):
        if 'chunk' in event and 'contentStop' in event['chunk']:
            return event['chunk']['contentStop'].get('exitCode')
    return None

# Step 1: Agent 分析问题并编写修复（推理任务 → InvokeAgentRuntime）
response = client.invoke_agent_runtime(
    agentRuntimeArn=AGENT_ARN,
    runtimeSessionId=SESSION_ID,
    payload=json.dumps({
        "prompt": "Read JIRA-1234 and implement the fix in /mnt/workspace"
    }).encode()
)

# Step 2: 运行测试套件（确定性操作 → InvokeAgentRuntimeCommand）
exit_code = run_command('/bin/bash -c "cd /mnt/workspace && npm test"', timeout=300)

# Step 3: 如果测试通过，提交并推送
if exit_code == 0:
    run_command('/bin/bash -c "cd /mnt/workspace && git checkout -b fix/JIRA-1234"')
    run_command('/bin/bash -c "cd /mnt/workspace && git add -A && git commit -m \'Fix JIRA-1234\'"')
    run_command('/bin/bash -c "cd /mnt/workspace && git push origin fix/JIRA-1234"')
```

### 命令执行流式输出处理

```python
import boto3
import sys

client = boto3.client('bedrock-agentcore', region_name='us-west-2')

response = client.invoke_agent_runtime_command(
    agentRuntimeArn='arn:aws:bedrock-agentcore:us-west-2:111122223333:runtime/my-agent',
    runtimeSessionId='session-id-at-least-33-characters-long',
    body={
        'command': '/bin/bash -c "npm test"',
        'timeout': 60
    }
)

for event in response['stream']:
    if 'chunk' in event:
        chunk = event['chunk']
        
        if 'contentStart' in chunk:
            print("Command execution started")
        
        if 'contentDelta' in chunk:
            delta = chunk['contentDelta']
            if delta.get('stdout'):
                print(delta['stdout'], end='')
            if delta.get('stderr'):
                print(delta['stderr'], end='', file=sys.stderr)
        
        if 'contentStop' in chunk:
            stop = chunk['contentStop']
            print(f"\nExit code: {stop.get('exitCode')}, Status: {stop.get('status')}")
```

---
[← Back to Deep Dives](./README.md)
