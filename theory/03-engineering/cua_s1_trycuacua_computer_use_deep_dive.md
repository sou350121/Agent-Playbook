---
auto_generated: true
generated_at: "2026-09-24T06:46:36Z"
source_url: "https://github.com/trycua/cua/releases/tag/sandbox-v0.8.0"
signal_type: "significant_update"
---
# CUA-S1：把 computer-use 的「下一步点哪」拆给专用小模型 (CUA-S1: Specialist System-1 Decision Models for Computer-Use)

> 🔍 本文由 Moltbot 自动生成 | 2026-09-24
>
> **项目/工具**: trycua/cua — CUA-S1 专用决策模型族 + Cua Fleets / Driver / Lume / Bench 平台
> **链接**: https://github.com/trycua/cua/releases/tag/sandbox-v0.8.0
> **核心定位**: 一家做 computer-use 基础设施的开源项目，正式把「在哪点、点哪个元素」这类有界决策从通用大模型里剥离出来，交给 4B LoRA 和 85 万参数的专用分类器，并公开了带明确局限说明的评测结果。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**：CUA-S1 是 trycua/cua 推出的「System 1」专用计算机操作模型族，用一次前向传播在「封闭候选集」里选最优点，而不是逐 token 生成动作；配套 Fleet / Driver / Bench 平台一起开源。
- **现在值得用吗**：看场景 —— 如果你有大量结构化的 GUI 决策任务（填表、选项点击、安全门判定），值得立刻试 4B 适配器；如果你想找一个开箱即用的通用桌面 Agent，它并不适合。
- **适合场景**：表单类 GUI 决策、元素/动作候选打分、需要审计和 fail-closed 边界的受控自动化、多步 GUI rollout 数据生成。
- **不适合场景**：开放式、无候选集的通用操作；跨分布任务（国际象棋、游戏控制）；无人监督的生产账户操作。
- **与前版/通用 Agent 核心差异**：通用 Agent 用「大模型 + shell/截图」逐 token 决策，CUA-S1 用「小模型 + 封闭选项 + 单次前向」决策，官方实测 4B 文本模态跨数据集总体准确率 0.875、多模态 0.929。

## 是什么 / 解决什么问题

Cua（trycua/cua）是一个 MIT 许可的开源计算机操作基础设施项目，目标是「给 AI agent 一台能用的电脑」。截至目前仓库约 2.6 万 star、1800 fork，核心组件包括：Cua Fleets（隔离云桌面）、Cua Driver（跨 macOS/Windows/Linux 的桌面自动化驱动）、Lume（Apple Silicon 上的本地 macOS/Linux 虚拟机）、Cua Bench（建任务/评测/导出轨迹）。

本次的更新触发点是 `sandbox-v0.8.0`（2026-09-15），它把 OSWorld 磁盘接入了 Fleet：新增 `agent_type="osworld"` 选项并配了「Run OSWorld on Fleet」指南（issue #3686），同时修了镜像文件大小 JSON 序列化的问题（#3839）。这只是平台侧的一次增量，但候选话题真正的价值在于同周期发布的 **CUA-S1**——一套被官方明确标注为「早期研究阶段、按 checkpoint 分别评测」的专用模型族。

它想解决的问题很具体：通用 computer-use agent 依赖强推理模型、逐 token 生成动作，成本高、难审计、且需要给 agent 一个能联网的 shell 环境（风险大）。CUA-S1 的思路反其道而行——把「元素 + 动作」的决策收敛为**封闭选项分类**：应用代码负责编排动作顺序，模型只负责在给定的候选里打出一个最优点。官方把这称为「System 1」工程类比：快、有界，而不是替代通用 agent 的规划推理。

## 技术架构拆解

### 核心设计决策

- **封闭候选集 + 单次前向**：模型输入是「当前屏幕状态（可访问性树或截图）+ 一组固定的候选 (element, action) 选项」，输出是单个最优选项。不做开放式生成。
- **选项即单 token**：4B 模型的解码契约是——用 chat template 让模型只回答一个字母标识所选选项，每个选项字母都经过校验是单一 tokenizer token，跑一次前向，对末位 logits 做 softmax 得到各选项概率。
- **规划与执行分离（安全边界）**：可选运行时默认 dry-run，要求唯一明确的目标窗口，元素 token 绑定快照，每次变更后重新观察窗口；`execute` 和 `submit` 是彼此独立的显式开关。
- **提交动作极度收窄**：`submit=true` 最多允许一个高置信度的 `Button` 或 `AXButton`，且其归一化标签必须恰好是 `Submit` 或 `Submit Form`。
- **fail-closed 设计**：便携版 Cua Driver 契约目前不暴露 `set_value`，因此填值执行会失败关闭，除非连接的运行时显式声明支持基于 token 的值写入；规划阶段不受影响。

### 与前版/竞品的关键差异

| 维度 | 通用 computer-use Agent | CUA-S1 专用模型族 |
|------|------------------------|-------------------|
| 决策方式 | 逐 token 生成动作序列 | 单次前向在封闭候选集内打分选择 |
| 模型规模 | 依赖前沿大模型 | 855K 参数分类器 / 4B LoRA 适配器 |
| 可审计性 | 弱（自由文本动作） | 强（有界选项 + 显式动作边界） |
| 分布外表现 | 相对更稳 | 明确不承诺（chess/game_control 实测为 0） |
| 成本/延迟 | 高（生成长度决定） | 低（单次并行前向；nano 在 GPU 毫秒级、CPU <100ms） |
| 权重复用 base | 不适用 | 4B 系列复用冻结的 `Qwen/Qwen3.5-4B`，只发布 LoRA |

### 架构/信息流图

```
┌───────────────────────────────────────────────┐
│ 应用代码（负责动作排序 / 编排）                    │
│  · 枚举候选 (element, action) 选项               │
│  · 维护 step 上限 / 停止规则                      │
└───────────────┬───────────────────────────────┘
                │ 屏幕状态 + 封闭候选集
                ▼
┌───────────────────────────────────────────────┐
│ CUA-S1 决策模型（System 1，封闭选项分类）          │
│  nano-0.1 : option-attention 分类器 (~855K)     │
│  4b-0.1/2 : LoRA on frozen Qwen/Qwen3.5-4B      │
│  解码：单 token 字母 → 末位 logits softmax        │
└───────────────┬───────────────────────────────┘
                │ 选中的 (element, action)
                ▼
┌───────────────────────────────────────────────┐
│ Cua Driver（可选执行层，受显式动作边界约束）        │
│  dry-run 默认 / 快照绑定 token / 变更后重观察      │
│  execute 与 submit 独立 opt-in，fail-closed       │
└───────────────────────────────────────────────┘

执行环境：Cua Fleets（云桌面）/ Lume（本地 macOS/Linux VM）
评测闭环：Cua Bench（建任务 / 打分 / 导出轨迹）
```

### 四个 checkpoint（官方原文摘要）

| Checkpoint | 基础/架构 | 范围 | 状态 |
|---|---|---|---|
| `cua-s1-form-v0` | `nano-0.1` 的文本微调版 | 表单类 GUI 任务研究 | 仅源码，不发权重 |
| `cua-s1-nano-0.1` | 从零训练，~85.5 万参数 option-attention 分类器 | 通用封闭选项 GUI 决策 | 权重已发布 |
| `cua-s1-4b-0.1` | 冻结 `Qwen/Qwen3.5-4B` 上的 LoRA | 通用元素/动作决策（文本 + 多模态） | 权重已发布 |
| `cua-s1-4b-0.2` | 同上 base，两个独立 LoRA（text / multimodal），各含 SFT + 对实时 GUI 环境的 RL | 上述范围 + 多步 agentic rollout | 权重已发布 |

官方明确：`cua-s1-4b-0.2` 不取代 `0.1`，两者独立发布、独立评测。

## 实用评估

### 什么场景值得用

- **结构化 GUI 决策的「快路径」**：官方数据显示 `cua-s1-4b-0.2` 在跨数据集文本切分上，六个核心 GUI 家族中五个为 0.833–1.000，总体 0.875（ECE 0.121）；多模态（剥离可访问性树）总体 0.929（ECE 0.069）。对填表、勾选、安全门判定这类有界任务，性价比明显优于调大模型。
- **多步 GUI rollout 数据生成**：`4b-0.2` 在真实的 `cua-bench-basic` 环境（agentic、20 步上限、留出任务变体）上 episode 成功率 0.944（文本）/ 0.722（多模态），说明它能作为轨迹生成器使用。
- **需要审计与 fail-closed 边界的受控自动化**：规划/执行分离、快照绑定、提交收窄到精确 `Submit`，这套边界设计对企业/研究场景的合规要求友好。
- **研究与模型对比**：`nano-0.1` 仅 85.5 万参数却能作为同尺寸量级的对照基线，且延迟在 GPU 毫秒级、CPU <100ms，适合做控制变量实验。

### 什么场景不值得用

- **开放式通用操作**：模型只能在**调用方预枚举的选项**里选择，无法提出候选集之外的动作。不要把它当通用桌面助手。
- **跨分布任务**：官方实测 `chess` 与 `game_control` 任务准确率为 0.000（元素准确率 0.227–0.515 / 0.333，且未通过随机校正）；`nano-0.1` 文本切分某些家族甚至低至 0.000。
- **无人监督的生产账户操作**：官方在 MODEL_CARD 中把「对生产账户/敏感数据的无监督操作」「高影响后果动作」全部列入 out-of-scope，并要求对不可逆/财务/法律/医疗等动作设置人工确认门。
- **追求「最新版最好」的用户**：`0.2` 在 `safety_gate`、`chess`、`game_control`、`general_decision`、`osworld_next_action` 上**未评测**——官方强调这是「未测量，既非已知好也非已知差」。

### 迁移成本

| 迁移项 | 工作量 | 说明 |
|---|---|---|
| 前置环境 | 低 | Python 3.12/3.13 + uv；`cua-bench[browser]` 需装 `playwright install chromium` |
| 接入 CUA-S1 | 中 | 需自行提供「屏幕状态 + 封闭候选集」输入，并把选项字母映射回动作；调用方负责编排 |
| 连接执行层 | 中 | 需 Cua Driver 提供精确窗口快照、快照绑定 token、确认动作效果；填值需运行时声明支持否则 fail-closed |
| 加载 checkpoint | 低 | `tiny/tinyx` 需本地 safetensors + 匹配 JSON（拒绝 pickle）；4B 用标准 PEFT 布局（`adapter_config.json` + `adapter_model.safetensors`，按 `text/`、`multimodal/` 分目录） |
| 自建评测 | 中高 | 官方评测结果集中在 `libs/cua-bench-s1/README.md`，跨应用/OS/语言/布局不保证迁移 |

## 对你的意义

对 Ken 的 Agent + UI 方向，这次更新有三个值得留意的信号：

1. **「决策分离」正在成为一种工程范式**。CUA-S1 把「有界决策」交给专用小模型、把「编排与规划」留给应用代码/大模型。这与 Agent 架构里 planner/executor 分离、tool-calling 收敛到 schema 的趋势一致——如果你的 agent builder 支持「封闭选项」式工具选择，可以借鉴这套契约来换取可审计性和低延迟。
2. **封闭选项 + 单 token 解码是一个被低估的接口设计**。它把「动作空间」变成显式可枚举的集合，天然适合做评测、做缓存、做安全门。对任何需要可解释动作的应用层设计都有启发。
3. **负面结果同样有信息量**。chess / game_control 的 0.000、多模态 `toggle-switch` 的 0/3、`pagination` 行的标注错误——官方把这些「不好看」的数据一并公开，是判断「专用模型能力边界」的稀缺样本。这比一堆「SOTA」宣称更值得读。

**建议**：立即试用——但用在小切片上。先跑 `cua-bench` 的模拟任务（无需 VM/Docker/API key）验证闭环，再拿一个表单类内部流程做 PoC；通用桌面自动化暂时观望。

## 关键代码/配置片段

```sh
# Cua Driver：macOS / Linux 安装
/bin/bash -c "$(curl -fsSL https://cua.ai/driver/install.sh)"

# Windows (PowerShell)
irm https://cua.ai/driver/install.ps1 | iex
```

```sh
# CUA-S1 Python 包独立开发环境（源码不含权重/数据集）
uv sync --project libs/cua-s1/python --extra pdf --group test
uv run --project libs/cua-s1/python pytest libs/cua-s1/python/tests

# 启用 nano 的视觉骨干（smolvlm / siglip 显式配置）
uv sync --project libs/cua-s1/python --extra nano-vision
```

```python
# 包暴露研究原语，不会下载模型
import cua_s1
print(cua_s1.__version__)

# 4B 系列通过 cua_s1.four_b.FourBModel 按 modality 选择 text/ 或 multimodal/ 适配器
```

```sh
# 可选的 CUA-S1 MCP server（MCP stdio 传输）
uv sync --project libs/cua-s1/python --extra mcp --extra pdf
# 必需主机设置：
#   CUA_S1_PLANNER_FACTORY    可信 Python 代码，module:attribute 形式
#   CUA_S1_ALLOWED_PDF_ROOTS  允许读取的目录（未设置则用当前工作目录）
#   CUA_S1_DRIVER_BINARY / CUA_S1_DRIVER_TRANSPORT / CUA_S1_SESSION
```

模型权重与数据集（Hugging Face）：`cua-ai/cua-s1-nano-0.1`、`cua-ai/cua-s1-4b-0.1`、`cua-ai/cua-s1-4b-0.2`、`cua-ai/cua-s1-forms`（含 dataset）。源码 MIT，但官方说明该许可**不自动适用于**未来的官方权重、数据集、托管服务与商标。

> 数据来源：trycua/cua 仓库 README、`libs/cua-s1/README.md`、`libs/cua-s1/MODEL_CARD.md`、`sandbox-v0.8.0` release notes；评测数字引自官方指向的 `libs/cua-bench-s1/README.md` 结果章节。

---
[← Back to Deep Dives](./README.md)
