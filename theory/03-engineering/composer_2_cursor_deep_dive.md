# Composer 2 深度解析：Cursor 自研模型的性能与成本突破 (Composer 2: Cursor's Proprietary Model Performance and Cost Breakthrough)

> 🔍 本文由 Moltbot 自动生成 | 2026-03-24
>
> **项目/工具**: Cursor Composer 2
> **链接**: https://cursor.com/blog/composer-2
> **核心定位**: Cursor 第二代自研编程模型，通过持续预训练 + 强化学习实现性能大幅跃升，同时保持极具竞争力的定价

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**：Cursor 第二代自研编程模型，性能接近 frontier 级别但成本仅为竞品的 1/3-1/5
- **现在值得用吗**：是 — 如果你已经在用 Cursor，Composer 2 是默认且最优选择
- **适合场景**：长 horizon 编程任务（数百步操作）、多文件编辑、终端操作自动化、多语言项目
- **不适合场景**：需要极低延迟的实时补全（此时用 fast variant）、非 Cursor 环境
- **与 Composer 1.5 核心差异**：CursorBench +17.1 分，Terminal-Bench 2.0 +13.8 分，SWE-bench Multilingual +7.8 分

## 是什么 / 解决什么问题

Cursor 在 2026 年 3 月推出了 Composer 2，这是其第二代自研编程模型。这次更新的核心突破在于：**首次引入了持续预训练（continued pretraining）作为强化学习的基础**，而非直接从基础模型开始 RL 训练。

这一架构变化解决了第一代 Composer 的两个关键瓶颈：

1. **长程任务能力不足**：Composer 1 系列在处理需要数百步操作的任务时表现不稳定
2. **性能 - 成本权衡**：要在 frontier 级别性能和合理成本之间做选择

Composer 2 同时解决了这两个问题：在三个主要 benchmark 上均超越 Composer 1.5 约 15-20%，同时定价为 $0.50/M input tokens 和 $2.50/M output tokens — 显著低于同类 frontier 模型。

## 技术架构拆解

### 核心设计决策

| 决策 | 说明 | 理由 |
|------|------|------|
| 持续预训练先行 | 在 RL 之前先做 continued pretraining | 提供更强的基础模型，使 RL 更高效 |
| 长程任务 RL | 针对数百步操作的任务进行强化学习 | 直接优化实际开发工作流中的复杂任务 |
| 双变体策略 | 标准版 ($0.50/$2.50) + 快速版 ($1.50/$7.50) | 满足不同延迟需求，fast 设为默认 |
| 独立用量池 | Composer 用量计入 standalone usage pool | 避免与基础补全功能竞争配额 |

### 与前版/竞品的关键差异

| 维度 | Composer 1.5 | Composer 2 | 说明 |
|------|-------------|------------|------|
| CursorBench | 44.2 | 61.3 | +38.7% 提升 |
| Terminal-Bench 2.0 | 47.9 | 61.7 | +28.8% 提升 |
| SWE-bench Multilingual | 65.9 | 73.7 | +11.8% 提升 |
| 输入价格 | 未公开 | $0.50/M | 极具竞争力 |
| 输出价格 | 未公开 | $2.50/M | 约为 Claude Code 的 1/5 |
| 训练方法 | 直接 RL | 持续预训练 + RL | 架构级改进 |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────┐
│                    Composer 2 Training Pipeline         │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Base Model → Continued Pretraining → RL Training      │
│                     ↑                    ↑              │
│              更强基础模型        长程任务优化            │
│                                                         │
│  Output: Composer 2 (Standard)    Composer 2 (Fast)     │
│          $0.50/$2.50              $1.50/$7.50           │
│          默认用于复杂任务         默认用于实时补全       │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## 实用评估

### 什么场景值得用

1. **多文件重构任务**：Composer 2 的 SWE-bench Multilingual 73.7 分表明其在跨文件代码理解和修改方面显著优于前代
2. **终端自动化**：Terminal-Bench 2.0 61.7 分 — 适合需要执行 shell 命令、调试、环境配置的任务
3. **长程开发任务**：官方明确提到"数百步操作"的能力 — 适合功能开发、bug 修复等需要多轮迭代的工作
4. **成本敏感的生产环境**：$0.50/$2.50 的定价使得大规模使用成为可能

### 什么场景不值得用

1. **单行补全场景**：Composer 2 针对长程任务优化，简单补全可能过度杀伤且延迟较高
2. **非 Cursor 环境**：Composer 2 仅在 Cursor 内可用（包括新的 Glass 界面 alpha）
3. **需要确定性的任务**：RL 训练模型可能存在行为不一致性，关键任务需人工审核
4. **极小项目**：如果项目只有几个文件，Composer 1.5 或基础模型可能已足够

### 迁移成本

- **从 Composer 1.5 迁移**：零成本 — Cursor 自动将 Composer 2 设为默认
- **从 Claude Code 迁移**：需调整 prompt 风格（Composer 2 对长 context 优化更好），成本约 1-2 小时适应
- **从 GitHub Copilot 迁移**：需切换到 Cursor IDE，学习 Composer 工作流，成本约 1 天

## 对你的意义

如果你正在构建 Agent 系统或评估编程模型：

1. **性能基准**：Composer 2 的 benchmark 数据（尤其是 Terminal-Bench 2.0 和 SWE-bench）应成为你评估其他编程模型的参照点
2. **成本参考**：$0.50/$2.50 的定价可能成为 2026 年编程模型的价格锚点
3. **架构启发**：持续预训练 + RL 的两阶段训练策略值得在其他垂直领域复制

**建议**：
- 如果你已在用 Cursor：**立即切换到 Composer 2**（默认已启用）
- 如果你在评估编程模型：**将 Composer 2 纳入对比**，其性能 - 成本比极具竞争力
- 如果你在构建类似系统：**研究两阶段训练策略**，这是 Composer 2 成功的关键

## 关键代码/配置片段

根据官方文档，在 Cursor 中选择 Composer 2 的方式：

```json
// Cursor 设置中自动启用 Composer 2（默认）
{
  "model": "composer-2",
  "usagePool": "standalone",
  "fastVariant": true  // 默认启用快速变体用于实时补全
}
```

对于需要强制使用标准版的场景（如复杂任务）：

```json
{
  "model": "composer-2",
  "fastVariant": false  // 使用标准版，更低成本
}
```

完整模型文档见：https://cursor.com/docs/models/cursor-composer-2

---

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-002: Agentic Coding 在初级任务达 80% 成功率 | 支持 | Composer 2 在 SWE-bench Multilingual 达 73.7%，Terminal-Bench 2.0 达 61.7%，显示编程 Agent 正快速接近 80% 门槛；持续预训练 + RL 架构可能是达成该目标的关键路径 |

---

[← Back to Deep Dives](./README.md)
