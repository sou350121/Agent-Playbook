---
auto_generated: true
generated_at: "2026-05-11T05:51:31Z"
source_url: "https://github.com/NousResearch/hermes-agent/releases/tag/v2026.5.7"
signal_type: "blog_post"
---
# Hermes Agent 登顶 OpenRouter 全球调用量榜首：271B Token/日，首超闭源竞品 (Hermes Agent Tops OpenRouter Global Usage: 271B Tokens/Day, First Open-Source Agent to Surpass Closed-Source Competitors)

> 🔍 本文由 Moltbot 自动生成 | 2026-05-11
>
> **项目/工具**: Hermes Agent (NousResearch/hermes-agent)
> **链接**: https://github.com/NousResearch/hermes-agent/releases/tag/v2026.5.7
> **核心定位**: 开源 AI Agent 框架，v0.13.0 "The Tenacity Release" 以多 Agent Kanban 板、/goal 持久目标锁定、会话持久化为核心升级；据 OpenRouter 数据，日 Token 消耗达 271B，首次超越闭源竞品登顶全球榜首

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句话定位**：Nous Research 出品的开源 AI Agent 框架，v0.13.0 是一次大规模架构升级，核心是多 Agent 协作与持久化能力
- **现在值得用吗**：是 — 适合需要多平台部署、多模型切换、持久化 Agent 工作流的团队和个人
- **适合场景**：多平台消息 Agent（Telegram/Discord/Slack/WhatsApp/Signal/Google Chat 等 20+ 平台）、多 Agent 并行任务编排、需要长期运行 + 断点恢复的自动化场景
- **不适合场景**：只需要简单单轮对话的场景（杀鸡用牛刀）、对安全性有极高要求但未读过安全审计的场景
- **与 Claude Code 核心差异**：Hermes 是持久化多平台 Agent（Gateway 常驻运行），Claude Code 是本地 CLI 编码工具（会话随终端结束）；Hermes 支持 200+ 模型，Claude Code 绑定 Claude；Hermes 有内置学习循环，Claude Code 无持久记忆

## 是什么 / 解决什么问题

Hermes Agent 是由 Nous Research 开发的开源 AI Agent 框架。它的核心定位是一个"与你一起成长的 Agent"——内置学习循环，能从经验中创建技能（skills）、在使用中自我改进、搜索自身历史对话、跨会话构建用户模型。

v0.13.0（代号 "The Tenacity Release"）是一次里程碑式的升级。从 v0.12.0 到 v0.13.0：864 次 commit、588 个合并 PR、829 个文件变更、128,366 行新增代码、282 个 issue 关闭（含 13 个 P0 和 36 个 P1）、295 名社区贡献者。这个规模在开源 Agent 项目中极为罕见。

本次升级解决的核心问题可以概括为三个维度：

1. **持久性（Tenacity）**：Agent 以前会"忘记"任务。现在通过 /goal 原语和多 Agent Kanban 板，Agent 能跨对话轮次锁定目标，多 worker 协作完成任务。
2. **可靠性（Reliability）**：Gateway 重启、会话中断、文件写入错误——以前这些都可能导致任务失败。现在 Checkpoints v2、会话自动恢复、写入后 delta lint 构成了三层保障。
3. **安全性（Security）**：一次安全波关闭了 8 个 P0 漏洞，包括默认开启 redaction、Discord 跨 guild DM bypass 修复（CVSS 8.1）、WhatsApp 默认拒绝陌生人等。

## 技术架构拆解

### 核心设计决策

| 设计决策 | 理由 |
|----------|------|
| **多 Agent Kanban 板** | 单 Agent 无法并行处理多任务；Kanban 板允许多个 Hermes worker 拾取、交接、关闭任务，带心跳检测、僵尸检测、自动阻塞 |
| **/goal 原语（Ralph loop）** | Agent 在多轮对话中容易偏离目标；/goal 锁定目标后跨轮次保持专注 |
| **Checkpoints v2 重写** | 旧版状态持久化有孤儿 shadow repo 问题；新版带真实 pruning 和磁盘防护 |
| **Provider 插件化** | 避免模型锁定；ProviderProfile ABC + plugins/model-providers/ 让第三方 provider 无需改核心代码即可接入 |
| **Gateway 会话自动恢复** | 生产环境中 Gateway 重启不可避免；会话自动恢复保证用户体验不断裂 |
| **默认安全（Security by Default）** | redaction 默认开启、WhatsApp 默认拒绝陌生人——降低用户配置错误导致的安全风险 |

### 多 Agent Kanban 板：核心机制解析

Kanban 板是 v0.13.0 最大的架构创新。它的核心机制如下：

```
任务生命周期状态机：

  [待办] ──→ [进行中] ──→ [完成]
     │            │          │
     │         [阻塞] ←─────┤
     │            │          │
     │      [重试中]         │
     │            │          │
     └────── [回收] ←────────┘

关键机制：
1. 心跳检测（Heartbeat）：每个 worker 定期上报心跳，超时未上报 → 标记为僵尸
2. 僵尸回收（Reclaim）：僵尸 worker 的任务自动回到 [待办]，由其他 worker 拾取
3. 自动阻塞（Auto-block）：子任务未完成时，父任务自动进入 [阻塞] 状态
4. 重试预算（Retry Budget）：每个任务有固定重试次数，耗尽后标记失败
5. 幻觉恢复（Hallucination Recovery）：检测到 agent 输出异常时自动回滚到上一 checkpoint
```

与 Claude Code 的 sub-agent 机制对比：Claude Code 的 sub-agent 是临时性的（随主会话结束而销毁），Hermes 的 Kanban worker 是持久化的（支持 Gateway 重启后恢复）。这意味着 Hermes 适合需要长时间运行的任务（如持续监控、定期报告），而 Claude Code 适合单次编码任务。

### /goal 原语：Ralph Loop 机制

/goal 的本质是一个持久化的目标约束器。当用户设置 /goal 后：

1. Agent 在每次对话轮次开始时，自动将 /goal 注入 system prompt
2. Agent 完成当前任务后，不会"闲着"，而是自动检查是否还有与 /goal 相关的子任务
3. 如果 /goal 已达成，Agent 会主动通知用户并询问下一步

这与 Claude Code 的 `/compact` 机制不同——`/compact` 只是压缩上下文，不维持目标约束。Hermes 的 /goal 让 Agent 从"被动响应"变为"主动推进"。

### 与前版/竞品的关键差异

| 维度 | Hermes Agent v0.12.x | Hermes Agent v0.13.0 | Claude Code |
|------|---------------------|---------------------|-------------|
| 多 Agent 协作 | 单 Agent 串行 | Kanban 板 + 多 worker 并行 + 心跳/僵尸检测 | sub-agent（临时，随会话销毁） |
| 目标持久化 | 无 /goal 原语 | /goal 锁定跨轮次目标（Ralph loop） | 无持久目标约束 |
| 会话持久化 | 基础 checkpoint | Checkpoints v2 + Gateway 自动恢复 | 无（会话随终端结束） |
| 模型支持 | 有限 | 200+ 模型（OpenRouter/NVIDIA NIM/小米 MiMo/GLM/Moonshot 等） | 仅 Claude |
| 开源 | ✅ | ✅ | ❌（CLI 工具，非框架） |
| 平台数量 | ~18 | 20+（新增 Google Chat） | 仅 CLI |
| 学习循环 | 基础 | 技能自创建 + 自改进 + FTS5 搜索 + Honcho 用户建模 | 无 |
| 安全默认值 | 需手动配置 | redaction 默认开启 + 8 个 P0 修复 | 内置安全沙箱 |
| Provider 扩展 | 硬编码 | 插件化（ProviderProfile ABC） | 不可扩展 |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────┐
│                    Hermes Gateway                        │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌────────┐  │
│  │ Telegram │  │ Discord  │  │  Slack   │  │ ... 20 │  │
│  │ WhatsApp │  │ Signal   │  │GoogleChat│  │ platforms│ │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └───┬────┘  │
│       └──────────────┴──────────────┴───────────┘       │
│                        │                                │
│  ┌─────────────────────┴─────────────────────────────┐  │
│  │              Session Manager                       │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌───────────┐ │  │
│  │  │ /goal Lock  │  │ Checkpoint  │  │ Auto-     │ │  │
│  │  │ (Ralph Loop)│  │    v2       │  │ Resume    │ │  │
│  │  └─────────────┘  └─────────────┘  └───────────┘ │  │
│  └─────────────────────┬─────────────────────────────┘  │
│                        │                                │
│  ┌─────────────────────┴─────────────────────────────┐  │
│  │            Multi-Agent Kanban Board                │  │
│  │  ┌──────┐ ┌──────┐ ┌──────┐                       │  │
│  │  │Worker│ │Worker│ │Worker│  ← 心跳/僵尸检测/重试  │  │
│  │  │  #1  │ │  #2  │ │  #N  │     预算/幻觉恢复     │  │
│  │  └──────┘ └──────┘ └──────┘                       │  │
│  └─────────────────────┬─────────────────────────────┘  │
│                        │                                │
│  ┌─────────────────────┴─────────────────────────────┐  │
│  │           Provider Plugins (ABC)                   │  │
│  │  OpenRouter(200+) │ NVIDIA NIM │ MiMo │ GLM │ ... │  │
│  └───────────────────────────────────────────────────┘  │
│                                                          │
│  ┌───────────────────────────────────────────────────┐  │
│  │          Learning Loop (Persistent Memory)         │  │
│  │  Skill Creation → Self-Improvement → FTS5 Search   │  │
│  │  → Honcho User Model → Cross-Session Recall        │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

## 实用评估

### 什么场景值得用

- **多平台统一 Agent 部署**：一个 Gateway 进程同时服务 Telegram、Discord、Slack、WhatsApp、Signal、Google Chat 等 20+ 平台，无需为每个平台单独开发 bot。适合需要跨平台覆盖的团队。
- **需要持久化工作流的自动化**：cron 调度 + 会话恢复 + Kanban 板让 Agent 可以长期运行复杂任务（日报生成、监控告警、数据收集），即使 Gateway 重启也不会丢失进度。
- **多模型灵活切换**：通过 OpenRouter 接入 200+ 模型，可以根据任务复杂度选择不同模型（简单任务用小模型省钱，复杂推理用大模型），且无需改代码。
- **研究/实验场景**：批量轨迹生成、Atropos RL 环境、轨迹压缩——适合训练下一代 tool-calling 模型的研究团队。
- **低成本部署**：支持 $5 VPS 到 GPU 集群，Modal/Daytona 提供 serverless 持久化（空闲时几乎零成本）。

### 什么场景不值得用

- **简单单轮对话**：如果只需要问答式的简单交互，Hermes 的多 Agent/Kanban/checkpoint 系统完全是过度工程。
- **对安全性有极高要求但未审计的场景**：虽然 v0.13.0 修复了 8 个 P0，但开源项目的安全审计责任在用户。金融/医疗等场景需要额外评估。
- **需要企业级 SLA 支持的场景**：开源项目没有商业支持合同，出问题靠社区和自行 debug。
- **Windows 原生环境**：Windows 支持仍为 early beta，文档明确说明"expect rough edges"。

### 迁移成本

- **从 Claude Code 迁移**：Hermes 不是 Claude Code 的直接替代品——它定位不同。Claude Code 是本地编码工具，Hermes 是持久化多平台 Agent 框架。如果你的需求是"让 Agent 长期运行并跨平台响应"，Hermes 是更好的选择；如果只是"在本地用 AI 辅助编码"，Claude Code 更轻量。
- **从零开始部署**：一行命令安装（`curl -fsSL ... | bash`），`hermes setup` 全配置向导，官方声称"2 分钟完成安装→配置→第一次对话"。
- **从其他 Agent 框架迁移**：主要成本在 skill 迁移（Hermes 使用 agentskills.io 开放标准）和平台适配（20+ 平台插件化架构降低了适配成本）。

### 实战陷阱与规避方案

**陷阱 1：Kanban 板 worker 数量设置不当**
- **现象**：worker 数量过多导致资源竞争（多个 worker 同时修改同一文件），过少导致任务积压
- **规避**：根据任务类型调整——I/O 密集型任务（如网络请求）可以设较多 worker（3-5），CPU/LLM 密集型任务（如代码生成）建议 1-2 个 worker
- **配置参考**：在 `config.json` 中设置 `kanban.max_workers`，默认值为 3

**陷阱 2：/goal 与 agent 的短期任务冲突**
- **现象**：设置了 /goal 后，agent 在短期任务中过度追求长期目标，导致当前任务偏离用户意图
- **规避**：/goal 适合设定方向性目标（如"构建一个 RAG pipeline"），不适合具体执行步骤。具体步骤用 /queue 命令排队，让 agent 先完成当前任务
- **最佳实践**：/goal 设定"做什么"，/queue 设定"先做什么"

**陷阱 3：Checkpoints v2 磁盘空间管理**
- **现象**：虽然 v2 修复了孤儿 shadow repo 问题，但长期运行的 agent 仍会积累大量 checkpoint
- **规避**：定期运行 `hermes curator prune` 清理过期 checkpoint；配置 `checkpoint.max_age_days` 限制保留天数
- **监控建议**：在 cron 中设置每日 checkpoint 大小检查，超过阈值时告警

**陷阱 4：Provider 插件化后的模型切换陷阱**
- **现象**：切换模型后，某些工具的 tool calling 格式不兼容（如 Gemini 和 OpenAI 的 tool calling schema 不同）
- **规避**：在切换模型前，先用 `hermes model test` 验证目标模型的工具调用兼容性；关键生产任务锁定已知兼容的模型
- **建议**：先用 OpenRouter 的自动路由（让 OpenRouter 选择最佳模型），稳定后再锁定具体模型

## 生存指南（3 条可落地建议）

### 建议 1：从小规模 Kanban 开始，逐步扩展

不要一开始就配置 5+ worker。先用 1 个 worker 跑通基本流程，确认任务能正确完成后再逐步增加。观察 `hermes kanban status` 的输出，确认没有任务积压或 worker 冲突。

```bash
# 查看 Kanban 状态
hermes kanban status

# 调整 worker 数量
hermes config set kanban.max_workers 2
```

### 建议 2：用 /goal + cron 组合实现持久化自动化

/goal 确保 agent 不偏离方向，cron 确保任务定期执行。两者结合可以实现"设定目标 → 定期执行 → 自动汇报"的闭环。

```bash
# 设置目标
/goal 每日生成 AI 研究日报

# 设置 cron 定时任务
hermes cron add --schedule "0 7 * * *" --task "生成今日 AI 研究日报并推送到 Telegram"
```

### 建议 3：善用 Provider 插件化，但生产环境锁定模型

开发阶段用 OpenRouter 自动路由（200+ 模型可选），找到最适合的模型后，在生产环境锁定该模型，避免模型切换带来的行为不一致。

```bash
# 开发阶段：使用 OpenRouter 自动路由
hermes model set openrouter:auto

# 生产阶段：锁定具体模型
hermes model set openrouter:anthropic/claude-sonnet-4
```

## 关键代码/配置片段

### 安装（一行命令）

```bash
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
```

### 快速上手

```bash
hermes              # Interactive CLI — start a conversation
hermes model        # Choose your LLM provider and model
hermes tools        # Configure which tools are enabled
hermes gateway      # Start the messaging gateway
hermes setup        # Run the full setup wizard
hermes update       # Update to the latest version
hermes doctor       # Diagnose any issues
```

### 从 OpenClaw 迁移

```bash
hermes claw migrate
```

### CLI vs Messaging 快速对照

| 操作 | CLI | 消息平台 |
|------|-----|---------|
| 开始对话 | `hermes` | 运行 `hermes gateway setup` 后发消息 |
| 新对话 | `/new` 或 `/reset` | `/new` 或 `/reset` |
| 切换模型 | `/model [provider:model]` | `/model [provider:model]` |
| 中断当前任务 | `Ctrl+C` | `/stop` |
| 压缩上下文 | `/compress` | `/compress` |

---
[← Back to Deep Dives](./README.md)
