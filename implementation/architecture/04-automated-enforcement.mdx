# 04-自动化执法：让架构导轨“带电”

理念再好，没有执法也是一纸空文。在 10x 开发中，我们必须建立一套自动化的反馈回路，让 AI 的“越轨”行为在分钟级被拦截。

## 1. 电子警察：Lint 规则的深度利用

不要只把 Linter 当成格式检查器。通过 `eslint-plugin-import` 或同类工具，你可以强制执行物理分层。

### 1.1 禁区配置 (Forbidden Imports)
如果你规定 `Domain` 层严禁调用 `Infrastructure` 层，你可以配置：
```json
{
  "rules": {
    "import/no-restricted-paths": ["error", {
      "zones": [{
        "target": "./src/domain",
        "from": "./src/infrastructure",
        "message": "❌ 禁止从 Domain 层引用 Infrastructure 层的代码！请保持业务逻辑纯净。"
      }]
    }]
  }
}
```
**治理效果：** AI 在生成代码后，`read_lints` 会立即报错。Agent 看到报错后会产生“知觉”，自动修正其分层逻辑。

## 2. 架构快照检查 (Structure Snapshot)

针对目录结构的治理，可以编写一个简单的测试脚本（如 `tests/arch.test.ts`），利用文件系统扫描来验证：
- 所有的 `service` 文件是否都放在了 `/services/` 下？
- 所有的 `hook` 是否都以 `use` 开头？

## 3. CI/CD 强制闸门

在 GitHub Actions 中配置治理检查点。如果架构校验不通过，严禁合并 PR。
- **治理逻辑：** 让 AI 明白，架构合规是“准生证”，不合规的代码永远无法进入主分支。

---

**下一步：** [05-架构决策记录 (ADR)：给 AI 建一座记忆宫殿](./05-adr-mind-palace.mdx)
