# 案例复盘：端到端机器学习实验自动化 (Open-R1)

> **目标**：微调 Qwen3-0.6B 模型，提升其在 Codeforces 编程题上的代码解题能力。

## 1. 实验背景
传统的微调流程涉及繁琐的格式验证、硬件选型和指标监控。本实验展示了如何利用 Codex + HF Skills 将这些步骤完全交给 Agent 自动执行。

## 2. 执行过程 (Codex 自主流程)

### 阶段一：指令下达
输入指令：
> "Start a new fine-tuning experiment to improve code solving abilities on using SFT. Maintain a report, evaluate with openai_humaneval benchmark, use open-r1/codeforces-cots dataset."

### 阶段二：自动化预处理
- **数据集验证**：Codex 自动检查 `open-r1/codeforces-cots` 格式。发现 `messages` 列，确认 Ready。
- **硬件自动选型**：由于是 0.6B 小模型，Codex 自动选择了成本最低的 `t4-small` (~$0.75/hour)。

### 阶段三：训练与监控
- **实时报告**：Codex 在 `training_reports/` 下创建 Markdown 报告，自动填入训练参数。
- **动态更新**：随着训练进行，Codex 自动抓取 Trackio 日志链接并更新到报告中。

### 阶段四：评估与对比
- **基准测试**：自动运行 `HumanEval pass@1` 评估。
- **决策反馈**：Codex 汇总得分，结果显示微调后模型（0.342）优于基础模型（0.306）。

## 3. 关键决策点记录
| 决策环节 | Agent 行为 | 理由 | 效果 |
| :--- | :--- | :--- | :--- |
| **硬件选择** | 选用 `t4-small` | 模型参数量 < 1B | 最小化实验成本（约 $0.30） |
| **评估策略** | 每 500 步保存并评估 | 监控过拟合风险 | 及时获得 pass@1 反馈 |
| **导出格式** | 导出为 GGUF Q4_K_M | 满足本地部署需求 | 可直接通过 llama-server 运行 |

## 4. 可迁移的结论
1. **Agent 担任 MLOps**：复杂的 ML 任务（如 DPO/RL）可以通过 `AGENTS.md` 标准化为 Agent 技能。
2. **报告即服务**：让 Agent 实时更新 Markdown 报告，极大减轻了工程师的文档负担，使实验可追溯。
3. **闭环决策**：Agent 不仅是执行者，更是评估者，能根据 benchmark 分数给出最终建议。

---
> 💡 **总结**：AI 代理不再只是写几行代码，它们正在接管整个科学实验的生命周期。

