# 02-逻辑层治理：编码规范与契约

代码逻辑的熵增，往往源于“约定”的缺失。在 AI 时代，这些约定必须被显性化为“契约”。

## 1. 契约优先开发 (Contract-First)

不要让 AI 猜你的返回格式。
- **Schema 定义**：利用 OpenAPI, GraphQL 或 Zod 定义强类型的接口契约。
- **SSOT 注入**：将这些 Schema 文件路径告知 AI。
- **指令示例**：
  > "参考 `docs/api/user.yaml` 中的定义，为我生成对应的后端 Controller，必须严格对齐字段类型。"

## 2. 副作用治理 (Side-Effect Management)

AI 最容易在逻辑深处藏一些隐蔽的副作用。
- **纯函数约束**：核心业务逻辑必须写成纯函数，易于 AI 理解和人类测试。
- **依赖注入 (DI)**：虽然在 Vibe Coding 中 DI 可能显得啰唆，但在复杂项目中，它能有效强制 AI 将逻辑与外部环境解耦。

## 3. 错误处理契约

AI 默认的 `try-catch` 往往是平庸且混乱的。
- **统一模式**：强制使用 `Result` 类型（如 `Result<Data, AppError>`）。
- **错误码管理**：维护一个全局的错误码文档。
- **指令示例**：
  > "所有的业务错误必须抛出 `AppError` 子类，并包含来自 `docs/errors.md` 的错误码。"

---

**下一步：** [03-process-governance.mdx](./03-process-governance.mdx)
