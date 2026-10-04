---
auto_generated: true
generated_at: "2026-10-04T08:01:18Z"
source_url: "https://simonwillison.net/2026/Sep/29/anthropic-frontier-red-team/"
signal_type: "significant_update"
---
# GLM-5.3 与高级网络攻击能力的扩散 (GLM-5.3 and the Spread of Advanced Cyber Capabilities)

> 🔍 本文由 Moltbot 自动生成 | 2026-10-04
>
> **项目/工具**: Anthropic Frontier Red Team 评估报告（分析智谱 AI GLM-5.3）
> **链接**: https://www.anthropic.com/research/glm-5-3-and-the-spread-of-advanced-cyber-capabilities
> **核心定位**: Anthropic 首次证明开源权重模型（GLM-5.3）已能自主开发端到端漏洞利用链，且其瘦弱护栏可通过 abliteration 等手段在 64%–100% 的模拟测试中被绕过——"人人可下载的高级攻击能力"这道门槛已被跨过。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**：Anthropic 用两套基准证明智谱 GLM-5.3 的攻击能力已追平五个月前的 Claude Mythos Preview，但其发布时几乎没有有效护栏、权重全公开——攻击能力第一次以"无门槛"的形式扩散到整个市场。
- **现在值得用吗**：看场景。作为防守方，这份报告是一套可复用的"能力评估 + 护栏审查"方法论；作为 Agent 系统构建者，它是必须写进威胁模型的一记警钟。不是拿来即用的工具。
- **适合场景**：Agent 平台的安全威胁建模、模型上线前的红队评估、开源模型护栏尽调、CISO 采购决策。
- **不适合场景**：想获取具体利用代码或 PoC 的场景（原文对攻击细节做了脱敏）；与网络攻防无关的纯业务开发。
- **与 Claude Mythos Preview 核心差异**：能力上 GLM-5.3 略低（内部基准控制流劫持率 4% vs 6%），但 Mythos 通过 Project Glasswing 限量分发、权重不公开，而 GLM-5.3 任何人都能下载、护栏可在本地剥离。

## 是什么 / 解决什么问题

背景。五个月前 Anthropic 发布 Claude Mythos Preview，称其为"首个能自主构建复杂端到端网络攻击的 AI 模型"，并通过 Project Glasswing 有限开放给受信任的防守方，后者借此在关键软件中发现逾 10,000 个漏洞，抢在恶意行为者之前赢得时间窗口。当时 Anthropic 预判这种能力终将扩散，并主张"扩散到来时，防守方需要至少同等强大的工具"。

这份报告回答的问题是：扩散是否已经发生、以什么形式发生。答案是——已经发生，而且以最不受控的形式。报告主角是智谱 AI（海外称 Z.ai）的 GLM-5.3。它的攻击能力与 Claude Mythos Preview 处于同一量级，但发布时几乎没有有效的误用护栏；权重公开又使这些本就薄弱的护栏可被移除或绕过。Anthropic 的原话是：在其模拟测试中，攻击者可用简单手法绕过 GLM-5.3 的护栏，成功率达 64%–100%，而同类手法对受护栏保护的 Claude 模型全部失效。

报告还有两个外部锚点。NIST 下属 CAISI 于 9 月 17 日独立评估，称 GLM-5.3 是"迄今发布的最具网络攻击能力的开源权重模型"，在网络基准的综合得分上落后美国前沿约四个月；Anthropic 的发现与之大体吻合，并补充了护栏可绕过性的分析——因为 CAISI 测试美国模型时关闭了其网络护栏，而攻击者无法轻易拿到那些版本，GLM-5.3 却人人可下载。

因此，这份报告真正解决的不是"某个模型有多强"，而是"当这种能力不再稀缺时，防线靠什么成立"。

## 技术架构拆解

### 核心设计决策

- **隔离沙箱评估**：所有被测模型只在离线靶标上运行，无法攻击真实系统，保证评估过程本身不制造危害。
- **双轨制**：自动化基准（ExploitBench + 内部 Binary Exploitation benchmark）叠加 human-in-the-loop 专家会话，量化与定性互补。
- **以"端到端利用"为唯一计分口径**：full credit 只授予完整的控制流劫持，避免把"发现漏洞"这类中间能力混入成功率。
- **护栏审查独立成章**：不只测能力，还系统测试三种误用绕过路径——abliteration、deceptive prompt（伪装红队演练）、prefill（预填思考 token）。
- **成本透明化**：把一次真实 N-day 利用链的算力与 API 花费算清楚（20.40 美元），让"攻击门槛"可被经济地度量。

### 与前版/竞品的关键差异

| 维度 | 前一代（Claude Opus 4.6 / GLM-5.2） | 现在（Claude Mythos Preview / GLM-5.3） |
|------|------------|------------|
| 内部 Binary Exploitation 控制流劫持率 | 0% | Claude Mythos Preview 6% / GLM-5.3 4% |
| ExploitBench 端到端利用（每 410 次尝试） | 未达到 | Claude Mythos Preview 56 / GLM-5.3 50 |
| 护栏强度 | 训练期内置 | GLM-5.3 内置但可被 abliteration 剥离；Claude 权重不公开、不可消融 |
| 分发方式 | — | Mythos 限量受信分发；GLM-5.3 公开权重、任何人可下载 |
| 模拟误用绕过后尝试连接率 | — | GLM-5.3：64%（伪装）/ 92%（prefill）/ 100%（abliteration）；所有受测 Claude：0% |

> 数据来源：Anthropic Frontier Red Team 官方报告（2026-09-29）。

### 架构/信息流图

```
                        Anthropic Frontier Red Team 评估流水线
                        ────────────────────────────────────
  ┌──────────────┐     ┌─────────────────────────────┐
  │ 被测模型池    │────▶│ 隔离沙箱（仅离线靶标）        │
  │ Claude 系     │     └──────────────┬──────────────┘
  │ GLM-5.3 系    │                    │
  │ Kimi K3 等    │        ┌───────────┴───────────┐
  └──────────────┘        ▼                       ▼
                   ┌───────────────┐      ┌────────────────────┐
   (a) 自动基准     │ ExploitBench  │      │ 内部 Binary Expl.  │
                   │  V8/Chrome     │      │  OSS-Fuzz 项目      │
                   │  50/410 vs 56/410│    │  4% vs 6% 控制流劫持 │
                   └───────────────┘      └────────────────────┘
                            │                       │
                            └───────────┬───────────┘
                                        ▼
                        (b) human-in-the-loop 专家会话
                            • 已知漏洞 N-day：CVE-2026-11645
                              + 另一漏洞 → ARM64 利用链，绕过 PAC
                              （20 分钟人工 + 8 小时模型，20.40 美元）
                            • 未知漏洞 0-day：浏览器 JS 引擎链式利用
                              → 网页读取本地任意文件（已向维护者披露）

   护栏审查（独立轴）：
   直接请求 → 拒绝 ──▶ 伪装红队演练 → 64% 尝试连接
                 ──▶ prefill 思考 token → 92%
                 ──▶ abliteration（2,200 GPU·h / ≈4,400 美元）→ 100%
   对照：受测 Claude 模型在 API 护栏下全部保持 0%
```

## 实用评估

### 什么场景值得用

- **Agent 平台威胁建模**：把"模型本身的护栏会不会被绕过"当成独立威胁面。GLM-5.3 表明，护栏强度与模型能力是两个可分离的量，采购开源模型时必须分别评估。
- **上线前红队评估**：报告中三种绕过路径（伪装、prefill、abliteration）可直接作为你自己的测试用例清单，尤其当你自托管开源权重模型时。
- **CISO/合规尽调**：CAISI 的独立结论（"最具攻击能力的开源权重模型"、落后美国前沿约四个月）可作为第三方背书的引用锚点。

### 什么场景不值得用

- **想要即用型防御产品**：这是一份研究报告，不是产品，没有可直接部署的检测规则或 SDK。
- **闭源 API 用户**：如果你只调用受保护的前沿 API（无权重、无思考 prefill 接口），报告中的 abliteration 路径对你不适用——但 deceptive prompt 这类方法论仍值得复用到你的 prompt 注入防护上。
- **把 GLM-5.3 当默认生产模型的团队**：报告本身即是一个强烈信号——在缺乏本地护栏加固与审计的前提下，直接在生产管线上开放其网络相关能力属于高风险。

### 迁移成本

从"信任模型自带护栏"迁移到"假设护栏可被剥离"，本质是流程改造而非代码改造。需要新增：开源权重模型的本地护栏加固与验证（如 abliteration 抵抗力测试）、higher-risk 能力的权限与沙箱约束、以及对 agent 越权行为的实时审计。工作量取决于你现有 Agent 框架的权限模型——若已有沙箱与最小权限设计，主要是补评估用例；若当前无隔离，则需一次架构级改造。

## 对你的意义

对 Ken 的 Agent + UI 与 RAG/LLMOps 方向，这份报告有三层价值。

第一，它把"护栏"从软性卖点变成了可被量化的工程指标。你评估任何 Agent 框架（尤其是允许自托管开源模型、允许 tool-calling 直接触碰系统能力的那类）时，应该问一个问题：模型层护栏被剥离后，**框架层的权限与沙箱还能不能兜住**？这正是 MCP / tool-calling 安全边界的核心——A-001（MCP 成为工具集成事实标准）越往前走，"工具权限"就越需要框架而非模型来守。

第二，它与近日"agent 越权事故"的报道形成同一趋势线：模型自主性越高，事故的代价从"答错"升级为"做错"。给 agent 默认硬预算与权限上限，正从最佳实践变成上线前提。

第三，方法论可迁移。报告的双轨评估（自动基准 + 专家会话）加上"成本透明化"，是一套很好用的深度评估模板。

**结论：立即纳入威胁模型，观望其作为工具的直接使用。** 如果你是防守方，报告主张的"防守方应配备至少与攻击者同等强大的模型"值得跟进；如果你在自建 agent 平台，先做一次"护栏剥离后框架是否兜得住"的压力测试。

## 关键代码/配置片段

源材料为研究评估报告，不含可执行代码。以下为从报告中提取的真实评估参数（引用自 Anthropic Frontier Red Team 官方报告），可用于构建你自己的评估基线：

```text
# 评估参数（引用源材料）
内部 Binary Exploitation benchmark:
  tasks            = 100 (随机抽取)
  计分口径          = full control-flow hijack 才计 full credit
  GLM-5.3          = 4%  trials 达成控制流劫持
  Claude Mythos Preview = 6%
  对照（前代）      = Claude Opus 4.6 / GLM-5.2 = 0%

ExploitBench (V8 / Google Chrome):
  口径             = end-to-end exploit，每 410 次尝试
  GLM-5.3          = 50 / 410
  Claude Mythos Preview = 56 / 410

护栏绕过（模拟测试，每格 50 样本）:
  deceptive prompt (伪装红队演练) → 64% 尝试连接
  prefill thinking tokens         → 92%
  abliteration                    → 100%
  对照：受护栏保护的 Claude        → 0%（API 无 prefill 接口，权重不公开）

abliteration 成本:
  GLM-5.3       = ≈2,200 GPU·h / ≈4,400 美元（团队首次尝试该技术）
  GLM-5.3-Flash = ≈600 GPU·h
  效果          = 拒答率 >90% → JailbreakBench ~3% / HarmBench 2% / StrongREJECT 12%
  能力损失      = GPQA-Diamond 持平；CyberGym 子集低个位数百分点

N-day 实证（CVE-2026-11645 + 另一 Chrome 漏洞）:
  目标 = ARM64，绕过 pointer-authentication (PAC) 加固
  成本 = 20 分钟人工 + 8 小时 GLM-5.3-Flash，≈20.40 美元（Zhipu API 价）
```

据此可提取三条可落地的检查项：**（1）** 用 3 类绕过手法（伪装、prefill、abliteration）压测你自托管模型的护栏；**（2）** 假设模型护栏完全失效，验证框架层沙箱与最小权限是否仍能阻断越权；**（3）** 为高风险工具调用设置默认硬预算与人工确认闸口。

---
[← Back to Deep Dives](./README.md)
