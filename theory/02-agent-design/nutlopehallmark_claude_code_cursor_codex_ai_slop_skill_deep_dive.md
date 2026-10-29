---
auto_generated: true
generated_at: "2026-10-29T08:02:07Z"
source_url: "https://github.com/Nutlope/hallmark/releases"
signal_type: "significant_update"
---
# Hallmark v2：给编码 Agent 装上「审美下限」（Hallmark v2 — A Design Skill That Refuses to Look AI-Generated）

> 🔍 本文由 Moltbot 自动生成 | 2026-10-29
>
> **项目/工具**: Nutlope/hallmark（由 Together AI 出品，MIT 许可）
> **链接**: https://github.com/Nutlope/hallmark/releases
> **核心定位**: 一个可安装进 Claude Code / Codex CLI / Cursor / OpenCode 的设计 skill——它不负责「更聪明地写 UI」，而是给 Agent 生成的页面钉死一条**不可谈判的审美地板**，再用 50 套材质主题把「每次生成都长一个样」的收敛问题掰开。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：把「AI slop 长什么样」写成 16 条硬规则 + 一条 sloplint 浏览器检查链，让编码 Agent 每次建页面前先过审。
- **現在值得用嗎**：看场景。你如果高频用编码 Agent 生成落地页 / 营销页 / 产品页，值得立刻试；如果你的是复杂后台、设计系统已经很成熟，收益有限。
- **適合場景**：独立开发者/小团队的落地页、产品官网、活动页、单页营销站；想把「生成式 UI」质量从 60 分拉到 80 分的工作流。
- **不適合場景**：企业设计系统内的组件开发（`design.md` 锁定会覆盖它）、重交互的 Web App（skill 的目标是页面不是应用）、需要品牌级原创视觉的作品。
- **與一般「taste prompt」核心差異**：多数设计 prompt 只是描述「要好看」；Hallmark 把「不要什么」写成可执行、可 lint、可失败的 Gate，并且**每次只发一套主题**来对抗跨生成收敛。

## 是什么 / 解决什么问题

编码 Agent（Claude Code、Codex、Cursor、OpenCode）写 UI 的短板不在语法，在审美默认值。模型被训练成了同一批模板：大标题上面挂一个全大写小字 eyebrow、标题里塞一个渐变彩色的词、满屏等距的空白卡片、页面底部永远有一个订阅邮箱框、紫色到蓝色渐变背景、把 emoji 当图标用。这些「机器手笔」（README 原文的用词是 *the tells that read as machine-made*）不是因为模型不会 CSS，而是因为**训练分布里最高频的答案就是这些**。

Hallmark 的解法很反直觉：**先立地板，然后放手**。README 说得很直白——"Hallmark holds a hard floor and then gets out of the way."。它的核心不是让 Agent 更聪明，而是把 Agent 不该做的事变成不可逾越的约束，把审核从「主观感受」变成「可量化的失败项」。

v2 相比 v1 的最大变化是三层：

1. **五十个主题（themes）**：每一套是一个「材质」（纸感、字体、颜色、表面、组件与纹理），带一张成品页截图；一次构建只读一套。README 的关键设计意图是 *A theme is a material, not a plan*——主题不规定页面包含什么、不规定顺序，两个不同 prompt 用同一套主题会得到两张不同的页面。这直接对冲了「同一个 skill 让所有输出长得一样」的新风险。
2. **从「任务」出发的页面解剖**：预约页就负责预约、商店页就负责卖、订阅页就负责订阅，动作放在该品类的自然位置，页面就以这个动作收尾——而不是以邮箱收集框收尾。
3. **从「规则清单」升级为「实际产品校验」**：可以把 URL / dev server / 本地 app 指给它，它自己截图；755 张开放许可照片按主题挑选并在页面上署名；`/hallmark redesign <path>` 保留内容与接线重建页面，`/hallmark audit <path>` 只出报告。

## 技术架构拆解

### 核心设计决策

- **三档 Gate 分层，而不是一个阈值**。README 把检查分成 Floor / Reflex / Finish：
  - **Floor（永不放行）**：对比度、焦点态、reduced-motion、编造事实、手机布局碎掉——"The Floor never ships"。
  - **Reflex（默认陷阱，可带理由书面豁免）**：模型最容易滑入的默认做法，"a build with a reason may overrule one on the record"。
  - **Finish（工艺细节，不阻塞交付）**：只做记录，不阻塞出货。
  这种分层是整套设计里最工程化的一笔：它承认「审美」有不可谈判的底线，也有可讨论的灰度，还有纯品味项——三者混在一个 checklist 里会直接导致规则被无视。
- **「先建 hero，冷启动评审」**：流程里第 3 步是 hero 单独建、单独渲染、在页面其余部分还不存在时先做一次冷审。这是把「首屏就是第一印象」翻译成了构建顺序约束。
- **多宽度实机 lint**：`scripts/sloplint.mjs --render` 在 8 个宽度下渲染真实浏览器检查，之后再由一个 fresh-context 的 subagent（无构建上下文的审阅者）做最后判定——"A fresh-context reviewer gets the last word."。这解决的是「自己写的代码自己看不出问题」。
- **事实不可推断**：第 1 步 pre-flight 明确 "Facts are never inferred: a number, a quote or a logo not given is absent"。缺素材就放占位图，绝不编造客户数、uptime、评价。
- **为改版设定反退化机制**：`sloplint --before` 先记录所有链接、表单字段、事件处理器与标题；`sloplint --kept` 在改版后如果有任何一个丢失就直接失败。这是「重设计不丢功能」的自动化保障，多数同类工具都没做。
- **版权洁癖**：照片库只指向 Wikimedia Commons 上的开放许可图（CC0 / PD / CC BY / CC BY-SA），页面上逐张署名；README 明说**不使用** Unsplash / Pexels / Pixabay，因为这些站点的条款禁止 AI 工具挑选其图片。这是个很少被讨论但实际会咬人的合规点。

### 与前版/竞品的关键差异

| 维度 | 前版 Hallmark（v1）/ 一般设计 prompt | Hallmark v2 |
|------|------------|------------|
| 规则形态 | 描述性「要好看、要现代」 | 16 条编号 Floor 规则 + 可 waiver 的 Reflex + 不阻塞的 Finish |
| 视觉多样性 | 同一 prompt 反复生成易收敛 | 50 套「材质」主题，`theme.mjs deal` 每次发 3 套候选、构建读 1 套 |
| 校验方式 | 人工肉眼 | `sloplint --render` 8 宽度实机检查 + fresh-context subagent 复审 |
| 素材来源 | 模型自造 / 图库 | 755 张开放许可照片，按主题挑选并署名；无则用占位 |
| 事实性 | 容易编造 mock 数据 | 硬规则：不得出现编造的指标、证言、logo 墙、案例数 |
| 改版支持 | 无 | `redesign` / `audit` 两个动词，`--before` / `--kept` 防功能丢失 |
| Harness 覆盖 | 单点 | Claude Code / Codex CLI / Cursor / OpenCode / GitHub Copilot |

### 架构/信息流图

```
用户 prompt
    │
    ▼
[0] Pre-flight ── 读 design.md / brand-spec / package.json / 真实产品 URL
    │            └──→ 缓存 .hallmark/preflight.json
    ▼
[1] Ask once ──── 只问一次：素材 / 受众 / 使用场景 / 语气
    │            └── 事实不推断，素材缺失用占位
    ▼
[3] Direction ─── theme.mjs deal → 3 套主题候选 → 锁 1 套（≤8KB 单文件）
    │              （custom 模式：跳过主题，只读 direction.md）
    ▼
[6] Build ─────── 先建 hero → 冷审 → 再建整页
    │             每页产出：自包含 HTML+CSS + 首行 Hallmark 戳记
    ▼
[7] Sweep ─────── sloplint.mjs --render（8 个宽度）
    │              ├── FAIL  → 必须修
    │              ├── REFLEX→ 修或书面豁免
    │              └── FINISH→ 记录不阻塞
    ▼
fresh-context subagent 终审 → 交付
```

## 实用评估

### 什么场景值得用

- **独立开发者做落地页/官网**：一个人的项目最缺的不是代码而是「像被人设计过」的样子。Hallmark 的硬规则直接砍掉了 AI 生成的 8 个最常见破绽，是投入产出比最高的一类场景。
- **多页面批量生成**：因为你一次只拿到一套主题、且主题只管材质不管结构，多页并行构建时不会退化成同一个模板换色。
- **对 Agent 输出做验收**：`/hallmark audit <path>` 是纯报告模式，可以挂在已有项目的 CI 前做人工 review 的辅助，而不是接管整个构建。
- **有真实素材但缺设计能力**：能提供截图、真数据和语气锚点的场景，Hallmark 的 pre-flight 会把它变成一套可复用的 `design.md`。

### 什么场景不值得用

- **复杂 Web App**：这套东西的产出是「自包含 HTML + CSS 的页面」，README 的措辞始终是 page 而不是 app。日期选择器、虚拟列表、复杂表单状态流不在它的目标面。
- **已有成熟设计系统**：老版本 README 已说明根目录 `design.md` 会覆盖其下所有规则。这既是保护也是天花板——你买不到它的多样性收益。
- **品牌级原创视觉**：硬规则第 11 条明确禁止紫色到蓝渐变、卡中卡、emoji 图标等；对追求视觉冲击的品牌 campaign，这种「反 slop」会被读成「反辨识度」。
- **完全离线/无 Node 环境**：浏览器检查需要 Node 18+、`puppeteer-core` 和 Chrome；没有这些只剩静态检查，效果大打折扣。
- **把主题当模板套**：如果你指望选个主题就得到一个好页面，会失望——README 反复强调主题是材质不是方案。

### 迁移成本

- 安装一行：`npx skills add nutlope/hallmark -g`（全局）或省略 `-g` 装进当前项目；需要 Node 18+。浏览器检查另需 `npm i -g puppeteer-core` 与 Chrome。
- 已有项目接入：先写 `design.md` 锁定设计系统（这一步反而是收益最大的投入），再对单页跑 `audit` 建立基线，最后才考虑对营销页做 `redesign`。
- 学习成本主要在**语气与素材的提供**：prompt 里「clean and modern」不被接受，必须从 editorial / brutalist / soft / utilitarian / luxury / playful / technical / austere 里选一个极端——这对用户是一个陌生的心智转换。
- 与原工作流的冲突点：它会强制「先问一次四个问题」，这与习惯一句话生成的主观体验不同；批量自动化时要预先给足素材，否则会卡在 pre-flight。

## 对你的意义

对 Ken 的 AI 应用线（Agent + UI），这是一个**反面样本值得认真读**的工具：它示范了如何把一个模糊的「品味」问题工程化——分层 Gate、可执行 lint、可豁免但必须留痕、fresh-context 复核。这套结构比规则本身更可复用，可以搬到任何「LLM 输出质量不稳定」的场景（比如日报质量门、文章生成质量门）。

它也和 `theory/03-engineering` 里反复出现的主题合流：**Agent 能力提升不再主要靠更长的 prompt，而是靠外部化、可验证的约束层**。Hallmark 是「约束层」在视觉域的完整实现。

**建议**：立即试用（半小时），选一个真实的小落地页跑一次 `/hallmark`，重点是看它 `sloplint --render` 报什么 FAIL——那 16 条 Floor 就是你以后手写设计 prompt 时的检查清单。不要直接把它接进现有项目的全局流程。

## 关键代码/配置片段

安装与调用（README 原文）：

```
npx skills add nutlope/hallmark -g
```

单 harness 安装：

```
npx skills add nutlope/hallmark -g --agent claude-code
# 或 codex / opencode / cursor / github-copilot
```

作为 Claude Code 插件：

```
/plugin marketplace add nutlope/hallmark
/plugin install hallmark@hallmark
```

对已有页面做只读审计 / 重建：

```
/hallmark redesign ./src/app
/hallmark audit ./index.html
```

单独 lint 任意页面（含实机渲染）：

```
node skills/hallmark/scripts/sloplint.mjs <file-or-dir> --render
```

SKILL.md 里几条最有代表性的 Floor 规则（原文摘引，说明「反 slop」具体长什么样）：

```
9. Never an eyebrow, and never a label in tracked capitals or small caps:
   labels, captions, table heads, tags and nav links are the body face
   (or the theme's label face), a step smaller, sentence or lower case, untracked.
11. Never a purple-to-blue gradient, a card inside a card, an emoji as an icon,
    or a hand-drawn browser or OS window.
12. The hero's headline, one sentence and primary action are all visible
    at 1280 x 800 without scrolling.
```

> 待确认：v2 的具体发布日期与版本号在 GitHub Releases 页面中被反爬页面替代，未能直接抓取；本文依据仓库 README 中 "New in v2" 段落与 SKILL.md 的 `version: 2.0.0` 字段。

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-002: Agentic Coding 在初级任务达 80% 成功率 | 支持 | Hallmark 展示 Agentic Coding 的瓶颈已从「写不出代码」转向「品味不足」，且该缺口可以用可验证的约束层补上——这恰恰说明初级任务的成功率阈值已基本越过。 |

---
[← Back to Deep Dives](./README.md)
