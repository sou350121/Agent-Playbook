# Technology Landscape（AI 应用开发生态全景图）

> **维护方式**：人写、低频更新。
>
> 目的不是“写得长”，而是提供一张稳定的地图：帮助你在 `stack/app_index.md` 的高频条目之上，形成对生态的分层理解。

---

## 1. 怎么用这张图？

- **快速查工具/应用**：看 [`stack/app_index.md`](./app_index.md)
- **读深度分析**：看 `stack/tools/`、`stack/frameworks/`、`stack/methodology/`
- **要落地做事**：看 `implementation/` 与 `use-cases/`
- **要看趋势推理**：看 `reports/biweekly/`

---

## 2. 分层视角（建议）

- **Agent 层**：编排（orchestration）、记忆（memory）、评估（evals）、工具使用（tool use）
- **Data 层**：RAG/检索、语义层、数据治理、权限与审计
- **Runtime 层**：沙箱、部署、成本/限额、弹性与容灾
- **UI 层**：对话 UI、工作流 UI、可视化编排、HITL
- **Governance 层**：安全边界、可回滚、可解释、可复现

---

## 3. TODO

- 补齐每一层的“代表性开源项目/商业产品”与关键分岔点
- 补齐“从信号到资产”的闭环：索引 → 深度 → 推理 → 调参
