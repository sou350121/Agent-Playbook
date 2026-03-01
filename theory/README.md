# 知识骨架

> 理解"为什么"——在动手之前建立认知骨架。

工具会过时，框架会迭代，但底层的设计逻辑和认知模型是持久的。本目录不是操作手册，而是帮你建立判断力的基础文献库。

---

## 目录结构

### `architecture/` — 系统设计模式

8 篇文档，覆盖从术语定义到架构决策记录（ADR）的完整链路：

- 从零建立 AI Agent 系统的概念地图
- 常见架构陷阱与权衡分析
- 关键设计决策的 ADR 存档

关键文档：`ai_app_handbook_design.md`（完整 Holograph 设计蓝图）

### `frameworks/` — 概念深潜

47 个概念的深度解析，分为四个认知域：

| 域 | 内容 |
|----|------|
| 记忆 | 上下文管理、长期记忆、向量存储策略 |
| 推理 | CoT、ReAct、规划与反思机制 |
| 执行 | 工具调用、多 Agent 协作、错误恢复 |
| 范式转变 | Intent-Driven Development、Software 3.0、Vibe Coding |

关键文档：`anthropic-agentic-coding-trends-2026.mdx`（2026 年 Agent 编码全景）

### `methodology/` — 执行方法论

37 篇，分两个方向：

- **agent-management/**：提示词工程、评估体系、成本控制（7 篇）
- **planning/**：路线图制定、假设追踪、能力演进路径（30 篇）

---

## 推荐阅读顺序

**新手入口（建立基础认知）**：

```
architecture/00-glossary-for-beginners.mdx   # 先建立术语共识
    ↓
architecture/ 其余 7 篇                       # 系统化设计认知
    ↓
frameworks/ 按需深潜                          # 按当前问题选读
    ↓
methodology/ 结合实践使用                     # 有具体项目后再读
```

---

## 写作规范

新增 theory/ 文档须遵循 [AGENTS.md](../AGENTS.md) §6 规范：

- 双语标题：`# 中文标题 (English Title)`
- 必须包含 **X-Ray 开场**（2-3 句，回答：什么问题 / 什么发现 / 为何重要）
- 引用需链接原始来源（论文 / 官方文档优先）
- 推荐包含：系统对比表、工程实战示例、失效模式分析
