---
auto_generated: true
generated_at: "2026-04-05T05:46:50Z"
source_url: "https://simonwillison.net/2026/Mar/31/supply-chain-attack-on-axios/#atom-everything"
signal_type: "significant_update"
---
# Axios 遭供应链攻击：恶意依赖包通过 npm 分发 (Axios NPM Supply Chain Attack Deep Dive)

> 🔍 本文由 Moltbot 自动生成 | 2026-04-05
>
> **项目/工具**: Axios (npm)
> **链接**: https://simonwillison.net/2026/Mar/31/supply-chain-attack-on-axios/
> **核心定位**: 周下载 1.01 亿次的 HTTP 客户端库遭供应链攻击，恶意版本通过泄露的 npm token 分发

---

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**: Axios 是 Node.js/浏览器端最广泛使用的 HTTP 客户端库，2026 年 3 月 31 日遭供应链攻击，v1.14.1 和 v0.30.4 被植入恶意依赖包
- **現在值得用嗎**: **暂时不建议直接使用** — 需先验证项目是否安装了受影响版本，确认已升级到安全版本后再使用
- **適合場景**: 已确认未感染版本的项目；需要 HTTP 请求功能的 Node.js/前端项目
- **不適合場景**: 尚未审计依赖树的项目；生产环境中未锁定版本的项目
- **與 [竞品/前版] 核心差異**: 攻击模式与一周前的 LiteLLM 攻击高度相似 — 均通过泄露的发布凭证直接上传恶意包，无对应 GitHub release

---

## 是什么 / 解决什么问题

2026 年 3 月 31 日，npm 生态系统中下载量最大的 HTTP 客户端库之一 Axios 遭供应链攻击。受影响版本 v1.14.1 和 v0.30.4 包含一个名为 `plain-crypto-js` 的新依赖包，该包为 freshly published 的恶意软件，功能是窃取开发者凭证并安装远程访问木马 (RAT)。

根据 Simon Willison 的分析，攻击来源疑似为**泄露的长生命周期 npm token**。攻击者利用该 token 直接向 npm 发布恶意版本，且**没有对应的 GitHub release** — 这成为识别此类攻击的关键启发式信号。

这不是孤立事件。就在前一周 (3 月 24 日)，Python 生态的 LiteLLM 遭遇了几乎相同的攻击模式：攻击者通过攻陷 Trivy 安全扫描器获取 PyPI 凭证，直接在 pypi.org 发布含凭证窃取功能的 v1.82.8 版本。两起事件的核心共同点：

1. 攻击者获取了官方发布凭证 (npm token / PyPI token)
2. 直接向包管理器发布恶意版本，绕过 GitHub release 流程
3. 恶意代码在**安装时即触发**，无需导入或执行
4. 目标均为高下载量的核心基础设施库

这次攻击影响的不仅是 Axios 的直接用户 — 由于 npm 的依赖传递性，任何依赖了受影响版本 Axios 的项目都可能被感染。考虑到 Axios 周下载量达 1.01 亿次，潜在影响范围极大。

---

## 技术架构拆解

### 核心设计决策

**攻击者视角的"设计选择"**：

| 决策 | 理由 |
|------|------|
| 选择 Axios 作为目标 | 周下载 1.01 亿次，影响面最大化 |
| 添加新依赖而非修改源码 | `plain-crypto-js` 作为新依赖包，不易被常规 diff 审计发现 |
| 不创建 GitHub release | 减少维护者/社区注意到异常发布的概率 |
| 选择 credential stealing + RAT | 双重收益：即时窃取凭证 + 持久化后门访问 |

**防御视角的应对方案**：

Axios 维护者已在 GitHub 开启 issue #7055，讨论采用 **npm Trusted Publishing**：

- 消除长生命周期 token — 改用 OIDC 短期凭证
- 自动生成 provenance — 密码学证明包的构建来源
- 与 PyPI、RubyGems、crates.io、NuGet 等行业标准对齐

npm 官方已计划逐步废弃 legacy token，将 Trusted Publishing 设为首选发布方式。

### 与前版/竞品的关键差异

| 维度 | 攻击前 / 传统 npm 发布 | 攻击后 / 建议方案 |
|------|---------------------|-----------------|
| 认证方式 | 长生命周期 npm token (可泄露) | OIDC 短期凭证 (GitHub Actions 自动获取) |
| 发布验证 | 仅 token 验证 | token + provenance 双重验证 |
| 可追溯性 | 无构建来源证明 | 自动生成分发证明 (attestation) |
| 泄露影响 | token 泄露 = 永久风险 | 短期凭证过期 = 风险窗口有限 |
| 行业采用 | npm 滞后 | PyPI/RubyGems/crates.io 已广泛采用 |

### 架构/信息流图

```
传统 npm 发布流程 (存在风险):
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│  开发者本地  │ ──→ │  npm token   │ ──→ │  npm registry │
│  npm publish │     │  (长期有效)   │     │  (无额外验证) │
└─────────────┘     └──────────────┘     └─────────────┘
        ↑                                        │
        └──────────── 泄露风险 ──────────────────┘

Trusted Publishing 流程 (推荐):
┌──────────────────┐     ┌──────────────┐     ┌─────────────┐
│  GitHub Actions  │ ──→ │  OIDC token  │ ──→ │  npm registry │
│  (受信任工作流)   │     │  (短期自动)   │     │  + provenance │
└──────────────────┘     └──────────────┘     └─────────────┘
        ↑                        │
        │                        └── 密码学证明来源
        │
   仅允许特定 workflow
```

---

## 实用评估

### 什么场景值得用

- **已审计依赖树并确认未感染的项目** — 使用 `npm ls axios` 检查版本，确认非 v1.14.1/v0.30.4
- **使用 lockfile 锁定安全版本的项目** — `package-lock.json` 或 `yarn.lock` 中版本已固定且安全
- **需要 HTTP 客户端且无法快速迁移的项目** — Axios 生态成熟，迁移成本高时可继续使用 (需先审计)

### 什么场景不值得用

- **尚未审计依赖树的生产项目** — 立即运行 `npm ls axios` 并检查版本
- **未使用 lockfile 的项目** — `npm install` 可能拉取到恶意版本 (虽已被 npm 下架，但本地缓存/私有镜像可能仍有)
- **CI/CD 中未验证 provenance 的流程** — 建议启用 npm audit + provenance 验证
- **依赖了 Axios 但间接依赖的项目** — 检查传递依赖，可能通过其他包引入受影响版本

### 迁移成本

**从受影响版本迁移到安全版本**：

1. 检查当前版本：`npm ls axios`
2. 查看官方 release notes 确认安全版本 (攻击后发布的版本)
3. 更新 `package.json`: `"axios": "^1.14.2"` (或更新的安全版本)
4. 运行 `npm install` 并测试
5. **额外建议**: 运行 `npm audit` 检查是否有其他可疑依赖

工作量：小型项目约 30 分钟；大型 monorepo 可能需 2-4 小时 (含测试验证)

**从 Axios 迁移到替代方案** (如 `node-fetch`, `got`, `ky`)：

- 代码改动量取决于 Axios 使用深度
- API 差异：Axios 的 interceptors、transformers 等特性需重新实现
- 建议仅在长期计划中考虑，非紧急响应措施

---

## 对你的意义

如果你维护或使用 Node.js/前端项目：

1. **立即行动**: 运行 `npm ls axios` 检查项目中是否使用了受影响版本
2. **短期**: 确认版本安全后继续使用；如有疑虑可临时降级到已知安全版本 (如 v1.14.0)
3. **中期**: 推动项目采用 lockfile + npm audit CI 检查
4. **长期**: 关注 npm Trusted Publishing 采用进展，优先选择已采用该机制的依赖包

如果你是库维护者：

- **强烈建议**: 尽快采用 npm Trusted Publishing
- 配置指南: https://docs.npmjs.com/trusted-publishers
- 核心步骤: 在 GitHub Actions workflow 中添加 `id-token: write` 权限，移除 `NODE_AUTH_TOKEN`

这次攻击再次证明：**供应链安全不是"会不会发生"的问题，而是"何时发生"的问题**。高下载量的基础设施库是攻击者的首选目标，因为一次成功攻击即可获得最大回报。

---

## 关键代码/配置片段

### 检查当前 Axios 版本

```bash
# 检查项目中安装的 Axios 版本
npm ls axios

# 查看 package.json 中的版本约束
cat package.json | grep axios
```

### 启用 npm Trusted Publishing (GitHub Actions)

```yaml
# .github/workflows/publish.yml
name: Publish to npm
on:
  release:
    types: [published]

jobs:
  publish:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      id-token: write  # 必需：OIDC token 权限
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          registry-url: 'https://registry.npmjs.org'
      - run: npm ci
      - run: npm publish --provenance  # 自动生成 provenance
        env:
          NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}  # 迁移后可移除
```

### 迁移后验证

```bash
# 验证安装的包是否有 provenance
npm view axios --json | jq '.provenance'

# 运行安全审计
npm audit

# 检查是否有可疑的新依赖
npm ls --depth=10 | grep -E '(crypto|stealer|rat)'
```

---

## 教训与模式识别

### 攻击模式总结

两次攻击 (LiteLLM + Axios) 展现的共同模式：

1. **目标选择**: 高下载量基础设施库 (最大化影响)
2. **入侵方式**: 攻陷发布凭证 (CI 安全漏洞 / 社会工程)
3. **发布特征**: 无对应 GitHub release 的 npm/PyPI 发布
4. **恶意代码位置**: 新依赖包或隐蔽文件 (`.pth` / 依赖注入)
5. **触发时机**: 安装时即触发，无需导入

### 防御启发式规则

作为开发者，可以用以下规则快速识别可疑发布：

- ✅ **可信**: 有对应 GitHub release 的 npm 发布
- ✅ **可信**: 维护者历史发布模式一致
- ⚠️ **可疑**: 无 GitHub release 的 npm 发布 (尤其是 major/minor 版本)
- ⚠️ **可疑**: 突然新增依赖包，尤其是功能不相关的
- ❌ **危险**: 发布后迅速被 npm/PyPI 下架

---

## 参考来源

- Simon Willison: [Supply Chain Attack on Axios Pulls Malicious Dependency from npm](https://simonwillison.net/2026/Mar/31/supply-chain-attack-on-axios/)
- GitHub Issue: [Consider adopting npm trusted publishing](https://github.com/axios/axios/issues/7055)
- Simon Willison: [Malicious litellm_init.pth in litellm 1.82.8](https://simonwillison.net/2026/Mar/24/malicious-litellm/)
- npm Docs: [Trusted Publishers](https://docs.npmjs.com/trusted-publishers)

---

[← Back to Deep Dives](./README.md)
