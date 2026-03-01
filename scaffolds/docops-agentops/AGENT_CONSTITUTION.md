# Agent Constitution

> 这份文件定义“代理的边界、权限与产出格式”。建议放在仓库根目录，作为 SSOT。

## 1. 权限与边界
- 允许修改的目录：`src/`, `docs/`, `tests/`（按你的项目调整）
- 禁止修改：CI/CD 关键配置（除非明确授权）
- 禁止把任何 token/密钥写入仓库（必须使用环境变量/secret manager）

## 2. 输出标准（DNA 级）
每次输出必须遵循：
1. 结论（是否完成、改动点）
2. 分析（风险/兼容性/回滚）
3. 方案（具体实现）
4. 里程碑（可勾选 checklist）
5. PR（提交说明与验证命令）

## 3. 证据链要求（Prompt VCS）
- 每个 Story 必须有：`stories/S-xxxx.md`
- 每个实现必须回填：`prompts/S-xxxx.md` 和/或 `sessions/S-xxxx/failures.md`
- PR description 必须包含：Story 链接 + Prompt/Failures 链接 + Verification

## 4. 风险分层
- 低风险：允许更 vibe 的尝试
- 中风险：必须有回滚与可观测性
- 高风险：必须审查 + 测试/证据
