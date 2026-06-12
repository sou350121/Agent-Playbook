---
auto_generated: true
generated_at: "2026-06-12T11:09:48Z"
source_url: "https://www.36kr.com/p/3842475940268552"
signal_type: "significant_update"
---
# OpenAI 芯片元老 Clive Chan 加盟 Anthropic：AI 基础设施人才战升级 (Clive Chan Leaves OpenAI for Anthropic — The Chip War Intensifies)

> 🔍 本文由 Moltbot 自动生成 | 2026-06-12
>
> **项目/工具**: OpenAI 自研 AI 芯片项目 / Anthropic 硬件团队
> **链接**: https://www.36kr.com/p/3842475940268552
> **核心定位**: OpenAI 自研芯片团队"002 号员工"Clive Chan 离职加入 Anthropic，折射出前沿 AI 公司自研芯片从可选项变为生存必需品的战略拐点

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**: 这不是普通的跳槽新闻——这是 OpenAI 自研芯片核心成员在关键节点（10GW 部署即将启动）流向 Anthropic，标志着 AI 基础设施人才战进入白热化
- **现在值得关注吗**: 是。芯片自研正在成为前沿 AI 实验室的核心壁垒，人才流动方向反映了战略重心
- **适合关注**: AI 基础设施、芯片自研趋势、前沿实验室竞争格局、Claude Code 长期能力预期
- **不适合关注**: 寻找具体工具/框架使用指南的读者（本文侧重战略+技术分析）
- **与 Karpathy 跳槽的关联**: 2026 年 5 月 Karpathy 从 OpenAI 加入 Anthropic，6 月 Clive Chan 跟进——Anthropic 正在系统性挖角 OpenAI 核心人才

## 是什么 / 解决什么问题

2026 年 6 月 7 日，OpenAI 自研芯片项目的"002 号员工"Clive Chan 在 X 平台宣布离职并加入 Anthropic。作为 OpenAI 硬件团队第二位招聘的员工，Clive Chan 亲历了 OpenAI 自研芯片项目从早期组建到与博通战略合作的全过程。

这个事件之所以重要，是因为它发生在三个关键时间窗口的交汇点：

1. **OpenAI 芯片部署倒计时**: OpenAI 与博通 2025 年 10 月宣布战略合作，目标建设总规模 10GW 的自研 AI 加速器系统，首批机架计划 2026 年下半年交付——正是现在
2. **Anthropic 融资里程碑**: 2026 年 6 月 1 日，Anthropic 完成 650 亿美元 H 轮融资，投后估值 9650 亿美元，距离万亿美元仅一步之遥，有充足弹药扩张
3. **人才流动加速**: 仅一个月前（2026 年 5 月），OpenAI 联合创始成员 Andrej Karpathy 宣布加盟 Anthropic

这不再是"竞争对手之间的正常人才流动"——这呈现出一种系统性的人才迁移模式。

## 技术架构拆解

### Clive Chan 的技术背景与核心价值

| 时间段 | 公司 | 角色 | 关键技术积累 |
|--------|------|------|-------------|
| 2021 前 | 滑铁卢大学 | 学生 | Hyperloop 组织建设 |
| 2021 | Google | 实习生 | 机器学习基础设施 |
| 2021 | SpaceX | 实习生 | 液体火箭发动机项目 |
| 2021-2022 | QuEra | 任职 | 量子计算 |
| 2022-2024.01 | Tesla Autopilot | SWE → SWE II | GPU 优化、集群调度、数据中心软件、训练基础设施 |
| 2024.01-2026.06 | OpenAI | 技术团队成员 | Matmul 优化、Roofline 分析、自研 AI 芯片项目 |
| 2026.06-至今 | Anthropic | 技术团队成员 | 待披露 |

Clive Chan 的独特价值在于他横跨了**四个**顶级 AI 基础设施团队（Google、Tesla、OpenAI、Anthropic），每个团队代表了不同的基础设施哲学：

- **Google**: TPU 路线——专用 ASIC，长期主义，v2→v3→v4 持续迭代
- **Tesla**: Dojo 路线——自研 D1 芯片，垂直整合，最终放弃
- **OpenAI**: 博通合作路线——定制化 AI 加速器，大规模部署
- **Anthropic**: 待观察——但显然在积极构建硬件能力

### Matmul 优化与 Roofline 分析：为什么这些技能在芯片设计中至关重要

Clive Chan 在 OpenAI 的核心职责是 **Matmul（矩阵乘法）优化** 和 **Roofline 分析**。这两个概念是理解 AI 芯片设计的关键：

**Matmul 优化**: 大模型推理和训练中，矩阵乘法（GEMM）占计算量的 70-90%。优化 Matmul 意味着：
- 选择最优的分块策略（tiling）来最大化 L1/L2 cache 命中率
- 利用硬件特定的张量核心（Tensor Core / MXU）指令
- 调整数据布局（row-major vs column-major）减少 cache miss

**Roofline 分析**: 一种性能建模方法，通过计算强度（FLOPs/Byte）来识别瓶颈：
- 计算受限区（compute-bound）：瓶颈在算力，需要更多 FLOPS
- 内存受限区（memory-bound）：瓶颈在带宽，需要更高 HBM 带宽或更好的数据复用

```
         Roofline Model (简化示意)
         
  Performance (FLOPS/s)
  │
  │        ╱────────────── 算力上限 (peak FLOPS)
  │       ╱│
  │      ╱ │
  │     ╱  │
  │    ╱   │
  │___╱____│────────────── 内存带宽上限 (peak BW × intensity)
  │  ╱     │
  │ ╱      │
  │╱       │
  └────────┴────────────── 计算强度 (FLOPs/Byte)
       ↑
   内存受限区  │  算力受限区
```

OpenAI 自研芯片时，Clive Chan 的 Matmul 优化和 Roofline 分析经验直接用于：
1. **定义芯片的算力/带宽需求**: 通过 Roofline 模型确定目标计算强度
2. **指导微架构设计**: Matmul 的张量核心规格、SRAM 大小、数据流
3. **验证芯片性能**: 实测 Matmul 性能 vs Roofline 上限，定位瓶颈

### OpenAI 自研芯片项目架构（公开信息）

```
┌─────────────────────────────────────────────────────────┐
│                    OpenAI Chip Strategy                  │
├──────────────┬──────────────────┬───────────────────────┤
│ 芯片设计      │ 系统/网络部署     │ 部署时间表            │
│ (OpenAI)     │ (Broadcom)       │                       │
├──────────────┼──────────────────┼───────────────────────┤
│ AI 加速器     │ 加速器系统开发    │ 首批机架: 2026H2      │
│ 系统设计      │ 网络系统开发      │ 持续至: 2029 年底      │
│ Matmul 优化   │ 10GW 总规模       │                       │
│ Roofline 分析 │                  │                       │
└──────────────┴──────────────────┴───────────────────────┘
```

根据 OpenAI 与博通 2025 年 10 月的合作博客披露：
- **总规模**: 10GW 的自研 AI 加速器系统（作为对比，NVIDIA DGX H100 集群约 5-10MW/机架）
- **分工**: OpenAI 负责芯片及系统设计，博通负责加速器和网络系统开发与部署
- **时间表**: 首批机架 2026 年下半年启动交付

### 与前版/竞品的关键差异

| 维度 | OpenAI (自研芯片) | Anthropic (传统路线) | Anthropic (Clive 加入后) |
|------|-------------------|---------------------|------------------------|
| 芯片策略 | 自研 + 博通合作 ASIC | 主要依赖 NVIDIA GPU | 开始构建自研能力？ |
| 人才密度 | 极高（Clive 评价"世界上没有更好的芯片团队"） | 高 | 持续增强（Karpathy + Clive Chan） |
| 部署规模 | 10GW 目标 | 未公开 | 未公开 |
| 时间线 | 2026H2 首批交付 | - | 加速建设中 |
| 核心技能 | Matmul 优化、Roofline 分析 | - | 获得 OpenAI 验证过的优化方法论 |

### Anthropic 人才吸纳模式

```
2026-05: Andrej Karpathy (OpenAI 联合创始人/研究员) → Anthropic
                │
                ▼  研究方向: 自主 AI 系统 / AI 原生应用
2026-06: Clive Chan (OpenAI 芯片 002 号) → Anthropic
                │
                ▼  方向推测: 硬件性能优化 / 芯片架构评估
                │
   趋势: Anthropic 系统性吸纳 OpenAI 核心人才
                │
                ▼
   驱动因素: $65B 融资 + 接近 $1T 估值 + "从山脚爬山"叙事
```

## 实战陷阱（Practical Pitfalls）

### 陷阱 1: 自研芯片的"Tesla Dojo 陷阱"——技术可行 ≠ 工程可行

Tesla 的 Dojo 芯片在理论上有出色的计算密度和带宽，但最终 Tesla 放弃了自研路线，转而大规模采购 NVIDIA GPU。**教训**: 自研芯片不仅需要优秀的微架构设计，还需要完整的软件栈（编译器、运行时、调试工具）、生态系统（开发者工具、模型兼容性）和规模经济（流片成本摊薄）。Anthropic 如果选择自研，必须评估自己是否有能力跨越从"芯片设计成功"到"大规模部署成功"的鸿沟。

### 陷阱 2: 人才流动的"逆向选择"风险——离开的可能是已经看到瓶颈的人

Clive Chan 说"从山脚攀登一座新高山"，但需要问：OpenAI 芯片项目是否已经遇到了他无法解决的瓶颈？如果 OpenAI 的芯片路线在 Matmul 优化或 Roofline 层面遇到了架构性限制，Clive 的离开可能不是"追求新挑战"，而是"看到了天花板"。Anthropic 需要验证：Clive 在 OpenAI 积累的优化经验，在 Anthropic 的架构假设下是否同样适用。

### 陷阱 3: Claude Code 用户的"模型能力幻觉"

Anthropic 硬件能力增强 → 模型训练成本降低 → 模型迭代加速。但这个传导链有 12-18 个月的延迟。Clive Chan 2026 年 6 月加入，即使立刻启动芯片项目，第一批自研芯片部署也要到 2027 年底。**Claude Code 用户不应期待短期内的能力跃升**。Anthropic 在 2026 年下半年的模型能力仍然依赖 NVIDIA GPU 采购。

## 实用评估

### 什么场景值得关注

- **AI 基础设施投资者**: 芯片自研能力正在成为 AI 实验室的核心竞争壁垒。OpenAI 和 Anthropic 的芯片竞争，最终会增加 AI 算力供给、降低训练成本
- **AI 从业者**: 理解前沿实验室的基础设施竞争格局，有助于判断未来 1-2 年 AI 能力的供给曲线
- **Claude Code 长期用户**: Anthropic 硬件能力增强 → 模型迭代加速 → Claude Code 能力持续提升。但这个传导需要 12-18 个月

### 什么场景不值得关注

- **寻找具体工具使用指南**: 本文分析的是行业战略层面的人才流动
- **短期交易决策**: 人才流动的影响是中期的（6-24 个月），不是即时的
- **开源社区贡献者**: 芯片自研是封闭生态的竞争，与开源 AI 生态关系有限

### 迁移成本分析

这不是技术迁移，而是战略观察。但如果类比到企业层面：

- **从 NVIDIA 依赖到自研芯片**: 需要 2-3 年周期（芯片设计 → 流片 → 部署 → 软件栈适配）
- **从通用芯片到定制加速器**: 需要重建整个训练/推理基础设施的软件栈
- **Anthropic 的窗口**: Clive Chan 在 OpenAI 积累的 Matmul 优化和 Roofline 分析经验，可以帮助 Anthropic 缩短评估周期，但大规模部署仍需时间

## 对你的意义

### 对 VLA 研究者的启示

- **芯片供给决定训练成本**: OpenAI 和 Anthropic 的芯片自研竞争，最终会增加 AI 算力供给、降低训练成本——这对 VLA 研究者是间接利好
- **Anthropic 的硬件能力增强**: 如果 Anthropic 开始自研芯片，其模型迭代速度可能加快，Claude 系列的 VLA 相关能力（如多模态理解、长上下文）可能受益
- **Tesla Dojo 的教训**: VLA 系统选型时，不要过度依赖单一硬件平台。Tesla Dojo 的失败说明即使是顶级工程团队也可能在芯片自研上踩坑

### 对 AI 应用开发者的启示

- **模型成本下降趋势**: 芯片自研 → 训练成本降低 → API 价格下降。Anthropic 已证明这一点：Fable 5 / Mythos 5 定价 $10/M input tokens，不到 Mythos Preview 的一半
- **基础设施多样性**: 不要把所有 AI 应用押注在单一模型提供商上
- **国产替代窗口**: 小米 MiMo 等国产模型也在加速生态扩展——基础设施竞争是全球性的

### Claude Code 视角

Clive Chan 的加入对 Claude Code 有间接但重要的影响：

1. **长期能力预期**: Anthropic 硬件团队增强 → 训练/推理成本降低 → Claude Code 可以使用更大、更强的模型 → 复杂编码任务成功率提升
2. **短期无影响**: 2026 年下半年 Claude Code 的能力仍然依赖 NVIDIA GPU 集群，自研芯片至少 2027 年底才能部署
3. **竞争格局**: OpenAI 失去芯片核心人才后，自研芯片进度可能受影响 → Codex (OpenAI 的 coding agent) 的长期竞争力可能相对下降

### 建议

- **观望芯片自研进度**: Clive Chan 加入后是否会主导芯片项目，还是只做性能优化，需要观察 3-6 个月
- **关注 Anthropic 后续招聘**: 如果 Anthropic 继续从 OpenAI 硬件团队挖人，说明芯片自研是认真投入
- **跟踪 OpenAI 芯片交付**: 2026 年下半年首批机架交付是重要里程碑，将验证自研芯片路线的可行性
- **Claude Code 用户**: 短期继续正常使用，长期（2027+）可以期待 Anthropic 硬件能力增强带来的模型能力提升

## 关键信息引用

> "自己是 OpenAI 硬件团队的第二位招聘员工，亲历了 OpenAI 自研芯片项目从早期组建到如今逐步推进的全过程。他评价称，OpenAI 芯片团队拥有令人难以置信的人才密度，自己不认为世界上还有更好的芯片设计团队。"
> — Clive Chan 离职声明

> "自己始终无法摆脱'再次从山脚下攀登一座新高山'的冲动。"
> — Clive Chan 解释加入 Anthropic 的原因

> "Anthropic 团队的人才、价值观和野心给自己留下了深刻印象，而加入后的短短几天里，他已经感受到了极高强度的工作节奏。"
> — Clive Chan

> "现在每次看到'我决定离开 OpenAI'，我就知道下一句话一定会提到 Anthropic。"
> — 网友评论

> "这就像离开皇马加盟巴萨。"
> — 网友类比

## 关键代码/配置片段

本文引用的技术概念（Matmul 优化、Roofline 分析）来自 Clive Chan 在 OpenAI 的工作职责描述，以下为这些概念的标准技术定义（非来自源材料的直接引用）：

```python
# Roofline 模型核心公式（通用定义，非源材料引用）
#
# 性能上限 = min(peak_flops, peak_bw * computational_intensity)
#
# 其中:
#   peak_flops = 芯片峰值算力 (FLOPS)
#   peak_bw = 内存峰值带宽 (Bytes/s)
#   computational_intensity = FLOPs / Bytes (计算强度)
#
# 当 computational_intensity < peak_flops / peak_bw 时:
#   → 内存受限 (memory-bound)，优化方向是减少内存访问
# 当 computational_intensity >= peak_flops / peak_bw 时:
#   → 算力受限 (compute-bound)，优化方向是增加并行计算
```

---

> **⚠️ 信息局限说明**: 本文基于 36 氪/智东西的报道撰写。Clive Chan 在 Anthropic 的具体职责、Anthropic 是否有芯片自研计划等关键信息尚未公开。以下 TODO 标记待后续验证。
>
> - TODO: Clive Chan 在 Anthropic 的具体职责
> - TODO: Anthropic 是否有自研芯片计划
> - TODO: OpenAI 10GW 芯片系统首批机架实际交付时间
> - TODO: Anthropic 硬件团队规模变化

---
[← Back to Deep Dives](./README.md)
