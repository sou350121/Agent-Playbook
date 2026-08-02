---
auto_generated: true
generated_at: "2026-08-02T05:59:29Z"
source_url: "https://github.com/openai/codex-security/releases/tag/npm-v0.1.5"
signal_type: "significant_update"
---
# OpenAI Codex Security：AI Agent 安全扫描工具正式上线 (OpenAI Codex Security: AI Agent Security Scanning Tool)

> 🔍 本文由 Moltbot 自动生成 | 2026-08-02
>
> **项目/工具**: OpenAI Codex Security (`@openai/codex-security`)
> **链接**: https://github.com/openai/codex-security/releases/tag/npm-v0.1.5
> **核心定位**: OpenAI 首款专用安全扫描工具，CLI + TypeScript SDK，用于发现、验证和修复代码中的安全漏洞。标志着 Agent 安全从"附加功能"变为"独立产品类别"。

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句話定位**：OpenAI 推出的开源 CLI 和 TypeScript SDK，用 AI Agent 驱动的方式对代码仓库进行安全漏洞扫描、验证和修复建议。
- **現在值得用嗎**：看場景 — 如果你已经在用 OpenAI API / ChatGPT 企业版做开发，它是一个零摩擦的安全层；如果你依赖其他 LLM 供应商或需要传统 SAST 工具的确定性，暂不推荐。
- **適合場景**：OpenAI 生态内的代码安全审计、CI/CD 流水线安全门禁、大规模仓库批量扫描
- **不適合場景**：非 OpenAI 生态（需要 API Key）、对扫描结果确定性要求极高的合规场景（AI 扫描本质有不确定性）、预算敏感的小型项目（按扫描计 API 成本）
- **與傳統 SAST 核心差異**：传统 SAST（如 SonarQube、CodeQL）基于规则/数据流分析，Codex Security 基于 LLM 推理 + 多 Agent 协作，能理解上下文但结果有不确定性

## 是什么 / 解决什么问题

代码安全扫描是一个成熟但仍有巨大痛点的领域。传统静态应用安全测试（SAST）工具如 CodeQL、Semgrep、SonarQube 依赖预定义规则和数据流分析，误报率高、覆盖有限、难以理解业务上下文。另一方面，开发者已经开始用 ChatGPT/Claude 等通用 AI 工具做代码审查，但这种方式不可自动化、不可集成到 CI/CD、结果不可追溯。

OpenAI Codex Security 填补了这个空白 — 它不是一个简单的"用 AI 包装 SAST"的工具，而是一个**专门设计的 AI-Native 安全扫描平台**：

1. **AI Agent 驱动**：每个扫描由 LLM Agent 执行，能理解代码语义、业务逻辑和安全上下文
2. **多 Agent 协作**：支持 workers 和 subagents 配置，可以并行扫描大规模代码库
3. **完整生命周期**：从扫描 → 验证 → 修复建议 → 结果对比 → 导出，覆盖安全审计全流程
4. **深度集成 CI/CD**：支持 API Key 认证、容器化批量扫描、SARIF/CSV/JSON 导出格式

当前版本 v0.1.5（2026 年 7 月）显示项目处于快速迭代期，已实现自动化 verified release、容器化部署、扫描结果自动匹配等关键功能。

## 技术架构拆解

### 核心设计决策

| 设计决策 | 理由 |
|----------|------|
| **TypeScript SDK + CLI 双接口** | 覆盖开发者（CLI 命令行）和平台工程（SDK 编程集成）两类用户 |
| **ChatGPT 登录 + API Key 双认证** | 个人开发者用 ChatGPT 账号零配置上手，企业 CI 用 API Key 自动化 |
| **Standard / Deep 双模式** | Standard 快速扫描，Deep 模式支持多 worker + subagent 深度分析 |
| **Knowledge Base 注入** | 允许注入架构文档、安全策略、威胁模型，让 AI 理解项目特定上下文 |
| **结果存于仓库外** | 安全考量 — 扫描结果含敏感代码片段，必须隔离存储 |
| **成本上限控制** | `maxCostUsd` 参数防止 AI 扫描成本失控 |

### 与前版/竞品的关键差异

| 维度 | 传统 SAST (CodeQL/Semgrep) | ChatGPT 手动审查 | Codex Security |
|------|---------------------------|-------------------|----------------|
| **扫描方式** | 规则匹配 + 数据流分析 | 人工粘贴代码 | AI Agent 自主分析 |
| **上下文理解** | 低（仅语法/数据流） | 高（但依赖人工描述） | 高（自动理解 + Knowledge Base） |
| **CI/CD 集成** | 成熟 | 不支持 | 原生支持（API Key + 容器化） |
| **误报率** | 中高（规则盲区） | 不可量化 | 中等（AI 不确定性） |
| **可追溯性** | 高（规则编号） | 无 | 高（Scan ID + 结果对比） |
| **成本模型** | 订阅/开源 | 免费（时间成本） | 按扫描计 API 成本 |
| **修复建议** | 有限 | 高质量但不可自动化 | AI 生成 + 可验证 |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────────┐
│                    Codex Security CLI/SDK                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────┐    ┌──────────────┐    ┌──────────────────┐   │
│  │ Auth     │───▶│ Scan Runner  │───▶│ Worker Pool      │   │
│  │ (ChatGPT │    │ (Mode: Std/  │    │ (workers,         │   │
│  │  /API)   │    │  Deep)       │    │  subagents)       │   │
│  └──────────┘    └──────┬───────┘    └────────┬─────────┘   │
│                         │                      │             │
│                         │              ┌───────▼────────┐    │
│                         │              │ LLM Agent      │    │
│                         │              │ (gpt-5.6-terra │    │
│                         │              │  / other model)│    │
│                         │              └───────┬────────┘    │
│                         │                      │             │
│                         │              ┌───────▼────────┐    │
│                         │              │ Findings       │    │
│                         │              │ (vuln + fix +   │    │
│                         │              │  reproduction) │    │
│                         │              └───────┬────────┘    │
│                         │                      │             │
│                         └──────────────────────┼─────────────┤
│                                                │             │
│  ┌──────────┐    ┌──────────────┐    ┌────────▼──────────┐  │
│  │ Scan     │◀───│ Comparison   │◀───│ Export            │  │
│  │ History  │    │ (match by    │    │ (SARIF/CSV/JSON)  │  │
│  │ (work-   │    │  root cause) │    │                   │  │
│  │  bench)  │    │              │    │                   │  │
│  └──────────┘    └──────────────┘    └──────────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### v0.1.5 版本关键变更

从 release notes 可以看出 v0.1.5 是一个重要的稳定性/生产就绪版本：

- **自动化 Verified Release**：npm 和 GitHub release 实现自动化签名和验证（#91），这是开源项目信任链的关键一步
- **扫描结果自动匹配**：`scans match` 命令按 root cause 自动关联两次扫描的结果，识别 new/persisting/reopened/resolved/unknown（#114）
- **容器化多架构镜像**：支持多架构的容器化批量扫描，带 image attestation 和 AppArmor 加固（#17）
- **嵌套 Git 仓库支持**：扫描快照支持嵌套 Git 仓库（#116）
- **扫描隐私保护**：扫描输出在完成和导出前保持私有（#118）

## 实用评估

### 什么场景值得用

**1. OpenAI 生态内的安全审计**
- 如果团队已经在用 ChatGPT Enterprise 或 OpenAI API，Codex Security 是零摩擦的附加安全层
- 支持 `gpt-5.6-terra` 等模型，与 OpenAI 生态深度整合

**2. CI/CD 安全门禁**
- API Key 认证 + `--fail-on-severity` 参数可以嵌入 CI 流水线
- SARIF 导出格式兼容 GitHub Advanced Security、Azure DevOps 等主流平台
- 容器化批量扫描适合大规模多仓库场景

**3. 需要上下文感知的安全审查**
- Knowledge Base 注入（架构文档、威胁模型、安全策略）让 AI 理解项目特定安全要求
- 传统 SAST 无法做到这一点 — 它们只看代码，不看业务逻辑

**4. 扫描结果趋势追踪**
- `scans compare` 自动按 root cause 匹配，识别新发现/持续存在/重新打开/已修复
- 适合安全团队的定期审计和合规报告

### 什么场景不值得用

**1. 非 OpenAI 生态 / 多供应商策略**
- 目前仅支持 OpenAI 模型（`gpt-5.6-terra` 等），不支持 Anthropic、Google 或其他 LLM
- 需要 `OPENAI_API_KEY` 或 `CODEX_API_KEY`，增加了供应商锁定

**2. 预算敏感项目**
- AI 扫描按 token/API 调用计费，Deep 模式 + 多 worker 可能成本较高
- `maxCostUsd` 可以控制上限，但也意味着可能扫描不完整
- 传统 SAST 工具（Semgrep OSS、CodeQL）是免费的

**3. 高确定性合规要求**
- AI 扫描本质有不确定性（误报/漏报），不适合需要 100% 确定性的合规场景（如金融监管、医疗软件）
- 传统 SAST 的规则匹配提供确定性结果，更适合审计追踪

**4. 超大型单体代码库（无 Knowledge Base）**
- 没有项目上下文注入的情况下，AI Agent 可能在大代码库中迷失方向
- 需要投入时间准备 architecture docs 和 threat models 才能发挥最大价值

### 迁移成本

| 从...迁移 | 工作量 | 说明 |
|-----------|--------|------|
| 无安全工具 → Codex Security | 低 | `npm install` + `npx codex-security login` + `scan .` 即可开始 |
| Semgrep/CodeQL → Codex Security | 中 | 需要重新配置 CI 流水线、调整扫描策略、建立 Knowledge Base |
| ChatGPT 手动审查 → Codex Security | 低 | 自动化替代手动流程，主要工作是集成到 CI |
| 传统 SAST + ChatGPT 双轨 → 统一到 Codex Security | 中高 | 需要验证 AI 扫描能否覆盖现有规则，可能需要并行运行一段时间 |

## 对你的意义

OpenAI Codex Security 的发布标志着一个重要趋势：**AI Agent 安全正在从"功能"变成"产品"**。

对于关注 Agent 安全的开发者来说，这个工具值得留意几个信号：

1. **Agent 安全工具化**：OpenAI 将安全能力产品化为独立 CLI/SDK，而非嵌入 ChatGPT 或 Codex 的子功能。这意味着安全扫描正在成为 Agent 基础设施的标准层。
2. **多 Agent 协作模式**：workers + subagents 的架构设计展示了 AI 安全工具如何扩展 — 不是靠更大的模型，而是靠更多的 Agent 协作。这与 Agent-Playbook 中追踪的多 Agent 编排趋势一致。
3. **Verified Release 的信任链**：自动化签名和验证 release 是供应链安全的基础设施。当 AI 工具本身也成为供应链的一环时，其自身的可信度变得至关重要。

**建议**：如果你在 OpenAI 生态内开发，可以立即试用 Standard 模式做小规模扫描验证效果。Deep 模式和 CI 集成建议先在小项目上跑通流程，评估成本/效果比后再推广到生产项目。

## 关键代码/配置片段

### TypeScript SDK 基本用法

```typescript
import { CodexSecurity } from "@openai/codex-security";

const security = new CodexSecurity();
const result = await security.run(".", {
  mode: "deep",
  workers: 2,
  subagents: 0,
  stopAfterNoNew: 3,
  maxDiscoveryRuns: 10,
});

console.log(result.reportPath);
await security.close();
```

### CLI 深度扫描

```bash
npx @openai/codex-security scan . \
  --mode deep \
  --workers 2 \
  --subagents 0 \
  --stop-after-no-new 3 \
  --max-discovery-runs 10
```

### CI 集成（API Key 认证）

```bash
# 环境变量设置，不存储密钥
export OPENAI_API_KEY="<your-key>"
npx @openai/codex-security scan . --auth api-key --fail-on-severity high --json
```

### 扫描结果对比（自动匹配 root cause）

```bash
# 自动匹配两次扫描的结果
npx @openai/codex-security scans match BEFORE_SCAN_ID AFTER_SCAN_ID

# 对比显示新发现/持续/重新打开/已修复
npx @openai/codex-security scans compare BEFORE_SCAN_ID AFTER_SCAN_ID
```

### Knowledge Base 注入（上下文感知扫描）

```bash
npx @openai/codex-security scan /path/to/repo \
  --knowledge-base /path/to/threat-models \
  --knowledge-base /path/to/architecture.pdf
```

---
[← Back to Deep Dives](./README.md)
