# 01-物理层治理：项目组织与结构导轨

在 AI 编码中，文件夹结构就是 AI 的“认知地图”。如果地图是乱的，AI 就会到处乱跑。

## 1. 强制目录拓扑 (Strict Directory Topology)

在大型项目中，必须在 `AGENT.md` 中为 AI 划定“物理禁区”：

### 1.1 分层规范示例
- `/src/core/`：只允许存放无副作用的业务逻辑（Domain Logic）。
- `/src/adapters/`：所有外部依赖（HTTP, DB, Storage）必须通过适配器进入。
- `/src/entrypoints/`：所有的接口入口（CLI, Web API, UI Controllers）。

### 1.2 AI 指令集
> "你严禁在 `src/core/` 下引入任何外部库，所有的 IO 操作必须在 `src/adapters/` 中声明。"

## 2. 模块边界 (Module Boundaries)

AI 往往会为了方便，在模块间乱连 `import`。治理手段包括：
- **Barrel Files 限制**：强制使用 `index.ts` 暴露 API，禁止跨模块引用私有文件。
- **Lint 规则介入**：通过 `eslint-plugin-import` 等工具，配合 `read_lints` 实时约束 AI 的依赖行为。

## 3. 物理层的“拆迁”策略

当一个文件夹下的文件超过 10 个，或者职责开始混淆时，AI 往往会感到困惑并产生幻觉。
- **治理动作**：开发者应主动发起“目录重构 Story”，指令 AI 按照 [单一职责原则 (SRP)](https://en.wikipedia.org/wiki/Single-responsibility_principle) 进行物理拆分。

---

**下一步：** [02-逻辑层治理：编码规范与契约](./02-logical-contracts.mdx)
