---
auto_generated: true
generated_at: "2026-04-20T05:48:55Z"
source_url: "https://github.com/saffron-health/libretto/releases/tag/v0.6.6"
signal_type: "significant_update"
---
# Libretto：让 AI 浏览器自动化从「黑盒运行时」走向「确定性脚本」(Libretto – Making AI Browser Automations Deterministic)

> 🔍 本文由 Moltbot 自动生成 | 2026-04-20
>
> **项目/工具**: Libretto v0.6.6
> **链接**: https://github.com/saffron-health/libretto/releases/tag/v0.6.6
> **核心定位**: 为 coding agent 提供「实时浏览器 + 低 token 消耗 CLI」，将浏览器自动化从「每次给 prompt 让 agent 即兴发挥」转变为「生成可调试、可复现的确定性脚本」

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**：Libretto 是一个 CLI + Agent Skill，让 coding agent 能直接操作真实浏览器来构建和维护自动化脚本，核心是从「运行时给 prompt」转向「生成可调试的 Playwright 脚本」
- **现在值得用吗**：是 — 如果你需要集成没有 API 的第三方系统（EHR、payer portal、旧 SaaS），或者你的 agent 浏览器自动化经常因为选择器变化而失败
- **适合场景**：无 API 的医疗/金融/政府系统集成、需要逆向工程网站 API、需要调试和修复失败的自动化脚本
- **不适合场景**：目标系统有稳定 REST/GraphQL API、简单的单页抓取任务（用 Playwright 直接写更快）
- **与 [竞品/前版] 核心差异**：BrowserUse/AutoGen 等是「纯 agent 运行时」，Libretto 是「agent + 确定性脚本混合」— 前者每次执行都是新的 LLM 调用，后者生成脚本后可离线复现

## 是什么 / 解决什么问题

Libretto 由美国数字健康公司 Saffron Health 内部开发并开源。团队花了一年时间构建和维护针对 EHR（电子健康记录）和 payer portal 的浏览器自动化 — 这些系统普遍没有公开 API，但又必须集成。

核心痛点：
1. **维护成本高**：网站 UI 稍有变化，自动化脚本就失效
2. **调试困难**：agent 在浏览器里「即兴发挥」，失败时难以复现和定位问题
3. **Token 消耗大**：每次执行都要 LLM 分析页面、决定下一步，成本不可控

Libretto 的解法：**把「agent 探索」和「脚本执行」分离**。
- 开发阶段：agent 用 Libretto 的浏览器实时交互、录制动作、捕获网络流量，生成 Playwright 脚本
- 运行阶段：直接执行生成的脚本（确定性、可调试、无 LLM 成本）

这类似于「Jupyter 交互式开发 → 导出为 .py 脚本」的工作流，但针对的是浏览器自动化场景。

## 技术架构拆解

### 核心设计决策

| 决策 | 理由 |
|------|------|
| **CLI + Agent Skill 双形态** | 既支持 agent 自主调用（skill），也支持开发者手动调试（CLI） |
| **基于 Playwright 而非自研引擎** | 复用成熟生态，脚本可独立于 Libretto 运行 |
| **Snapshot 分析用 LLM，脚本执行不用** | 只在「理解页面结构」时用 LLM，执行时是纯确定性代码 |
| **网络流量捕获为 JSONL** | 结构化日志便于逆向工程 API，也便于审计和回放 |
| **会话（session）持久化** | 支持长时间运行的工作流，避免重复登录 |

### 与前版/竞品的关键差异

| 维度 | BrowserUse / AutoGen / LangGraph | Libretto |
|------|----------------------------------|----------|
| **执行模式** | 纯 agent 运行时（每次执行都是新 LLM 调用） | 混合模式（开发时 agent 生成脚本，运行时执行脚本） |
| **可复现性** | 低（LLM 输出有随机性） | 高（生成的 Playwright 脚本确定性执行） |
| **调试能力** | 有限（只能看 agent 日志） | 强（可暂停、检查页面、手动修复选择器） |
| **Token 成本** | 每次执行都消耗 | 仅开发阶段消耗，运行阶段零 LLM 成本 |
| **网络 API 逆向** | 不支持 | 内置捕获和分析功能 |
| **适用系统** | 通用网页交互 | 针对无 API 的企业系统（EHR、payer portal） |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────────┐
│                    开发阶段 (Agent + Libretto)               │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Coding Agent                                               │
│       │                                                     │
│       ▼                                                     │
│  ┌─────────────┐    ┌──────────────┐    ┌───────────────┐  │
│  │ npx libretto│───▶│  实时浏览器   │───▶│  网络流量捕获  │  │
│  │   open      │    │  (Chromium)  │    │   (JSONL)     │  │
│  └─────────────┘    └──────────────┘    └───────────────┘  │
│       │                    │                    │           │
│       ▼                    ▼                    ▼           │
│  ┌─────────────┐    ┌──────────────┐    ┌───────────────┐  │
│  │ npx libretto│    │ 用户手动操作  │    │ 逆向工程 API   │  │
│  │  snapshot   │    │  (录制动作)   │    │   脚本生成    │  │
│  └─────────────┘    └──────────────┘    └───────────────┘  │
│                            │                                │
│                            ▼                                │
│                    ┌──────────────┐                         │
│                    │ 生成 Playwright│                        │
│                    │   脚本.ts     │                         │
│                    └──────────────┘                         │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    运行阶段 (纯脚本执行)                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│              ┌──────────────┐                               │
│              │ Playwright   │                               │
│              │ 脚本执行     │───────▶ 确定性结果             │
│              └──────────────┘                               │
│                                                             │
│              (无 LLM 调用，零 token 成本)                      │
└─────────────────────────────────────────────────────────────┘
```

## 实用评估

### 什么场景值得用

1. **医疗/金融/政府系统集成**
   - 这些领域的系统普遍没有公开 API，但又必须数据交换
   - Libretto 团队自己在 EHR 和 payer portal 场景验证过

2. **需要逆向工程网站 API**
   - 网络流量捕获功能可以直接生成 API 调用脚本
   - 比纯 UI 自动化更稳定、更快

3. **自动化脚本频繁失效**
   - 传统 Playwright 脚本需要手动维护选择器
   - Libretto 可以让 agent 自主修复（通过重新 snapshot 分析）

4. **团队有多个 agent 项目**
   - Libretto 作为通用 skill 可复用于不同 agent 框架
   - 支持 Claude Code、Cursor 等主流 coding agent

### 什么场景不值得用

1. **目标系统有稳定 API**
   - 直接用 REST/GraphQL 客户端更高效
   - 浏览器自动化永远是次优解

2. **简单单页抓取**
   - 直接写 Playwright 脚本更快
   - Libretto 的学习曲线和 overhead 不划算

3. **高并发/大规模爬虫**
   - Libretto 设计用于「维护少量关键集成」
   - 不是为大规模数据采集优化的

4. **需要完全离线运行**
   - 开发阶段需要 LLM（snapshot 分析）
   - 虽然运行阶段不需要，但修复时又需要

### 迁移成本

**从 BrowserUse/AutoGen 迁移到 Libretto**：
- 需要重写自动化逻辑为 Playwright 脚本（Libretto 可辅助生成）
- 好处：运行成本大幅下降，可调试性提升
- 预计工作量：每个工作流 2-4 小时（含测试）

**从纯 Playwright 脚本迁移到 Libretto**：
- 主要成本是学习 CLI 和 skill 集成
- 好处：agent 可自主修复失效脚本
- 预计工作量：1-2 小时/项目

**从零开始**：
- `npm install libretto` + `npx libretto setup`
- 配置 AI provider（OpenAI/Anthropic/Gemini）
- 开始用 natural language 让 agent 生成脚本
- 预计上手时间：30 分钟

## 对你的意义

如果你在做 Agent + UI 方向的开发（这是 Ken 的主攻方向之一），Libretto 代表了一个重要趋势：**从「纯 agent 运行时」转向「agent 生成 + 确定性执行」的混合架构**。

这个转变的意义：
1. **成本可控**：LLM 只用于开发/修复，不用于每次执行
2. **可调试**：生成的脚本可以像普通代码一样 review、debug
3. **可复现**：同样输入永远得到同样输出（测试友好）

**建议**：
- 如果你正在构建需要浏览器自动化的 agent 系统，**立即试用** Libretto
- 特别是如果你的目标系统没有 API（医疗、金融、旧 SaaS）
- 即使暂时不用，也值得研究其架构思路 — 「agent 生成 + 确定性执行」可能是未来 1-2 年的主流模式

**观望点**：
- 项目处于 early-stage（v0.6.6，未到 1.0）
- API 可能还有 breaking changes
- 建议 pin 具体版本用于生产

## 关键代码/配置片段

### 安装与配置

```bash
# 安装
npm install libretto

# 首次设置：检测 AI provider、下载 Chromium、配置 skill
npx libretto setup

# 检查状态
npx libretto status

# 切换 AI provider（可选）
npx libretto ai configure anthropic
```

### CLI 核心命令

```bash
# 打开浏览器并访问 URL
npx libretto open <url>

# 捕获页面 snapshot 并用 LLM 分析
npx libretto snapshot --objective "找出所有可点击的按钮"

# 执行 Playwright TypeScript 代码
npx libretto exec "await page.click('#submit-btn')"

# 关闭浏览器
npx libretto close
```

### Agent Skill 使用示例

```typescript
// 让 coding agent 用 Libretto skill 抓取 LinkedIn 帖子
// prompt 示例：
"Use the Libretto skill. Go on LinkedIn and scrape the first 10 posts 
for content, who posted it, the number of reactions, the first 25 
comments, and the first 25 reposts."

// Agent 会：
// 1. 用 libretto open 打开 LinkedIn
// 2. 提示用户登录（首次）
// 3. 用 snapshot 分析页面结构
// 4. 生成并执行 Playwright 脚本
// 5. 返回结构化数据
```

### 网络流量捕获（逆向工程 API）

```bash
# 启动浏览器并捕获网络流量
npx libretto open https://example.com

# 执行操作后，流量保存为 JSONL
# 可用于分析 API 端点、请求头、认证方式

# 基于捕获的流量生成直接 API 调用脚本
# (由 agent 自动完成)
```

### v0.6.6 关键更新

```json
// .libretto/config.json 格式简化（v0.6.6）
{
  "snapshotModel": "anthropic/claude-sonnet-4-20250514",
  "updatedAt": "已移除"
}

// 之前是嵌套结构：
// { "ai": { "model": "..." }, "updatedAt": "..." }
```

---

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-002: Agentic Coding 在初级任务达 80% 成功率 | 支持 | Libretto 让 coding agent 能自主生成和修复浏览器自动化脚本，降低了对人工干预的依赖 |
| A-005: AI 工作流自动化成为企业 AI 最快增长场景 | 支持 | 针对无 API 系统的浏览器自动化是企业集成的刚需，Libretto 提供了可落地的工程方案 |

---

[← Back to Deep Dives](./README.md)
