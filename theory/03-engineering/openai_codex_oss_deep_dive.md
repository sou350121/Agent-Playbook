---
auto_generated: true
generated_at: "2026-06-27T03:33:48Z"
source_url: "https://www.36kr.com/p/3863532970120201"
signal_type: "significant_update"
---
# OpenAI Codex 开放 OSS 模式：从模型厂商到平台入口 (OpenAI Codex Opens OSS Mode: From Model Vendor to Platform Entry)

> 🔍 本文由 Moltbot 自动生成 | 2026-06-27
>
> **项目/工具**: OpenAI Codex CLI/SDK
> **链接**: https://developers.openai.com/codex/config-advanced#oss-mode-local-providers
> **核心定位**: Codex 从「只认 GPT」的封闭编程智能体，转变为可插拔模型接口的开放平台——OpenAI 有史以来最「开放」的一次，本质是从卖模型向卖入口的战略转身。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**: Codex CLI/SDK 新增 `--oss` 开关和 `model_providers` 配置层，允许开发者将任意兼容模型（本地 Ollama、LM Studio、第三方 API）接入 Codex 智能体工作流，不再绑定 GPT。
- **现在值得用吗**: 是——如果你需要降低 token 成本、实现本地离线编码、或混合使用不同模型做规划/执行分工。但需注意协议兼容性仍有摩擦。
- **适合场景**: 个人开发者本地离线编码、成本敏感的团队（GPT 规划 + 开源模型执行）、隐私敏感项目（代码不出本机）
- **不适合场景**: 需要完整 tool calling / function calling 能力的复杂 agent 任务（开源模型未必兼容）、追求开箱即用的用户
- **与竞品核心差异**: Cursor/Continue 等工具早已支持多模型，但 Codex 的独特之处在于它把 Responses API 作为统一接口标准——谁接入谁就得对齐 OpenAI 的协议规范，这是「接口战争」而非「模型战争」。

## 是什么 / 解决什么问题

2026 年 6 月下旬，OpenAI 在 Codex CLI（v0.92.0+）和 SDK 中悄然引入了一个名为 **OSS Mode（Open Source Software Mode）** 的功能，官方也称为 **Local Providers**。开发者只需在命令行加上 `--oss` 参数，或在配置文件 `~/.codex/config.toml` 中注册一个 `model_providers` 条目，就能让 Codex 智能体跑在本地开源模型或第三方 API 上。

在此之前，Codex 几乎就是「GPT 专属编程智能体」的代名词——它的 CLI、App 和 SDK 都只接受 OpenAI 自家的模型。这带来两个痛点：

1. **Token 成本**: Codex 的 agent 式工作流（自动读文件、写代码、跑 bash、反复迭代）消耗的 token 量远超普通对话。按 OpenAI 定价，一个复杂编码任务可能花费数美元。
2. **隐私与离线**: 许多开发者不希望自己的私有代码上传到云端 API，尤其是涉及商业项目或敏感数据时。

这次更新直接解决了这两个问题。通过 `--oss` 参数，Codex 默认连接本地 Ollama（`localhost:11434`）或 LM Studio（`localhost:1234`）服务，全程本地离线运行，代码一行不出本机。通过 `model_providers` 配置，还可以接入 Mistral API、DeepSeek、企业自建代理、甚至任意 OpenAI 兼容的第三方中转站。

但更深层的意义在于战略层面：OpenAI 正在从一个「卖模型」的厂商，转变为一个「卖平台和框架」的玩家。模型随你换，工具得是我的——谁占住了开发者每天打开的那个入口，谁就握住了分发，就能坐上生态的核心位置。

## 技术架构拆解

### 核心设计决策

Codex 的开放不是开放模型权重，而是开放了**模型接入层**。具体通过以下机制实现：

**1. `model_providers` 配置抽象层**

每个 provider 定义四类信息：

| 配置字段 | 作用 | 示例 |
|---------|------|------|
| `base_url` | 模型服务地址 | `http://localhost:11434/v1` |
| `wire_api` | 通信协议（目前只认 `responses`） | `responses` |
| `env_key` | 鉴权方式（API Key 环境变量名） | `OPENAI_API_KEY` |
| `model` | 模型映射关系 | `gpt-5.4` |

**2. `--oss` 快捷开关**

一行命令即可切换到本地开源模型：

```bash
codex --oss
```

默认连接 Ollama 或 LM Studio（可通过 `oss_provider` 配置项指定默认 provider）。

**3. Profile 系统**

支持保存命名配置档案，通过 `--profile` 快速切换：

```bash
# ~/.codex/local.config.toml
model = "openai/gpt-oss-20b"
model_provider = "ollama"

codex --profile local
```

**4. 认证灵活性**

支持环境变量鉴权（`env_key`）、命令式鉴权（`[auth]` 块调用外部命令获取 token）、以及内置的 Amazon Bedrock 和 Azure provider。

### 与前版/竞品的关键差异

| 维度 | 之前 (Codex < v0.92) | 现在 (Codex v0.92+) | Cursor / Continue 等竞品 |
|------|----------------------|---------------------|------------------------|
| 模型绑定 | 仅 GPT | 任意兼容模型 | 已支持多模型 |
| 本地运行 | 不支持 | 支持（Ollama/LM Studio） | 支持 |
| 协议标准 | 无公开标准 | Responses API 统一标准 | 各自为政 |
| 配置方式 | 无 | TOML + CLI flag + Profile | JSON/YAML |
| 战略定位 | 模型产品 | 平台入口 | 编辑器插件/独立 IDE |
| 生态锁定 | 模型层锁定 | 接口层锁定 | 编辑器层锁定 |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────┐
│                    Codex CLI / SDK                       │
│                                                         │
│  ┌──────────────┐    ┌───────────────────────────────┐  │
│  │  Agent 工作流  │───>│  model_providers 路由层       │  │
│  │  (规划/执行)   │    │  wire_api = "responses"       │  │
│  └──────────────┘    └───────────┬───────────────────┘  │
│                                  │                      │
│         ┌────────────────────────┼────────────────┐     │
│         ▼                        ▼                ▼     │
│  ┌────────────┐         ┌──────────────┐  ┌────────────┐│
│  │ OpenAI API │         │ Ollama Local │  │ DeepSeek   ││
│  │ (GPT-5.x)  │         │ localhost    │  │ + 路由层   ││
│  └────────────┘         └──────────────┘  └────────────┘│
│                                                         │
│  协议转换层 (社区方案): LiteLLM / CC Switch / 自建代理    │
│  (Responses API ←→ Chat Completions)                    │
└─────────────────────────────────────────────────────────┘
```

**关键约束**: Codex 以 **Responses API** 作为主要交互标准。DeepSeek 等大多数开源模型接口仍以 **Chat Completions** 为主，两套接口在请求结构、流式输出方式、工具调用机制上不完全一致。因此直接接入往往需要中间层转译——这是目前社区最活跃的「添砖加瓦」区域。

## 实用评估

### 什么场景值得用

- **个人开发者降本**: 用 GPT 做规划（拆解任务、设计架构），用本地开源模型（如 openai/gpt-oss-20b）做执行（批量改文件、写样板代码），同样任务成本可砍掉一大半。
- **隐私敏感项目**: 代码不出本机，通过本地模型服务完成编码。适合商业项目、个人私密代码库。
- **离线环境**: 网络不稳定或无网络的环境下（飞机上、安全隔离网络），本地模型仍可提供编码辅助。
- **多模型混合路由**: 团队可以针对不同任务类型配置不同 provider——简单任务走低成本模型，复杂推理走 GPT。

### 什么场景不值得用

- **复杂 tool calling 任务**: Codex 要求接入模型兼容其工具调用协议，而开源模型未必完整支持。function calling 等复杂能力能否跑通「得一个个试」。
- **追求开箱即用**: 接入 DeepSeek 等模型需要额外路由层（CC Switch、LiteLLM），配置和调试有学习成本。
- **企业级 SLA 需求**: 本地模型的稳定性、并发能力、错误恢复均不如云端 API，不适合对可用性有高要求的团队。

### 迁移成本

| 迁移路径 | 工作量 | 说明 |
|---------|--------|------|
| GPT → Ollama/LM Studio 本地 | 低（5-10 分钟） | `codex --oss` 即可，前提是本地已跑起模型服务 |
| GPT → DeepSeek（需路由层） | 中（30 分钟-1 小时） | 需要部署 CC Switch / LiteLLM 等协议转换器 |
| 其他 IDE 插件 → Codex OSS | 中 | 需适应 Codex 的 agent 式工作流和 TOML 配置体系 |
| 旧版 Codex（< v0.92）→ 新版 | 低 | 向后兼容，`--oss` 是新增可选功能 |

> TODO: 官方文档未明确列出支持的开源模型完整清单和 tool calling 兼容性矩阵，待社区进一步验证。

## 对你的意义

这个变化对 Ken 的双重身份都有直接关联：

**作为 AI 应用开发者**: Codex 的 model_providers 抽象层是一个值得关注的架构模式——它展示了如何将「模型选择」从硬编码变为可配置。Agent-Playbook 的 `landscape/app-index.md` 中 Codex 的定位可能需要从「OpenAI 编程工具」更新为「可插拔模型编程平台」。

**作为 VLA 研究者**: Codex 的架构思路（模型可插拔 + 统一接口标准）对具身智能系统也有启发——VLA 模型是否也能通过类似的抽象层实现「基础模型 + 领域适配器」的插拔架构？

**建议**: 立即试用 `--oss` 模式连接本地 Ollama，验证 openai/gpt-oss-20b 在编码任务上的实际表现。如果 tool calling 兼容性足够，可以将其纳入日常开发工具链，显著降低 Codex 的使用成本。

## 关键代码/配置片段

### 基础 OSS 模式配置

```toml
# ~/.codex/config.toml
oss_provider = "ollama"  # 或 "lmstudio"

[model_providers.local_ollama]
name = "Ollama"
base_url = "http://localhost:11434/v1"
```

### 接入第三方 API（以 Mistral 为例）

```toml
[model_providers.mistral]
name = "Mistral"
base_url = "https://api.mistral.ai/v1"
env_key = "MISTRAL_API_KEY"
```

### 命令式认证（企业场景）

```toml
[model_providers.proxy]
name = "OpenAI using LLM proxy"
base_url = "https://proxy.example.com/v1"
wire_api = "responses"

[model_providers.proxy.auth]
command = "/usr/local/bin/fetch-codex-token"
args = ["--audience", "codex"]
timeout_ms = 5000
refresh_interval_ms = 300000
```

### Amazon Bedrock 集成

```toml
model_provider = "amazon-bedrock"
model = "<bedrock-model-id>"

[model_providers.amazon-bedrock.aws]
profile = "default"
region = "eu-central-1"
```

### CLI 使用方式

```bash
# 快捷 OSS 模式
codex --oss

# 指定 profile
codex --profile local

# 运行时覆盖配置
codex --config model='"openai/gpt-oss-20b"'
codex --config model_provider='"ollama"'
```

> 以上配置片段引用自 [OpenAI 官方文档 - Advanced Configuration](https://developers.openai.com/codex/config-advanced#oss-mode-local-providers)。

---
[← Back to Deep Dives](./README.md)
