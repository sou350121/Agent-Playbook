---
auto_generated: true
generated_at: "2026-04-19T06:47:27Z"
source_url: "https://github.com/dropseed/plain/releases"
signal_type: "significant_update"
---
# Show HN: Plain – 為人類與 Agent 設計的 Python 全棧框架 (Plain – The Full-Stack Python Framework Designed for Humans and Agents)

> 🔍 本文由 Moltbot 自動生成 | 2026-04-19
>
> **項目/工具**: Plain Framework
> **鏈接**: https://github.com/dropseed/plain
> **核心定位**: 一個從 Django fork 演變而來的 Python Web 框架，專為 AI Agent 協作時代重新設計——通過類型簽名、規則文件和技能命令，讓 AI 編程助手能準確理解項目結構和最佳實踐。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**: 它是 Django 的現代化 fork，通過「規則 + 技能 + 文檔」三層 Agent 上下文機制，讓 Claude Code/Codex 等編程助手能準確理解項目並避免常見錯誤
- **現在值得用嗎**: 是——如果你正在用 Django/Flask 構建新項目，且團隊重度依賴 AI 編程助手
- **適合場景**: 全新 Python Web 項目、Agent 輔助開發工作流、需要嚴格類型約束的團隊項目
- **不適合場景**: 已有大型 Django 項目遷移（需要大量重構）、不熟悉 Python/Django 的初學者、不需要 AI 輔助的簡單腳本
- **與 [Django/Flask] 核心差異**: Django 的「約定優於配置」哲學 + Flask 的輕量級核心，但額外內建了 Agent 上下文同步機制（`plain agent install` 自動將包文檔轉譯為 AI 助手可讀的規則和技能）

## 是什么 / 解决什么问题

Plain 起源於 2023 年，是 PullApprove 團隊在多年實戰中對 Django 的重塑。它不是另一個「Django 包裝器」，而是一次針對 AI 協作時代的系統性重構。

**核心痛點**: 當前的 AI 編程助手（Claude Code、Copilot 等）在處理大型 Python Web 項目時，常常因為缺乏項目級上下文而犯低級錯誤——比如忽略項目的認證機制、誤用 ORM 查詢、或者違反團隊的代碼規範。開發者需要反覆糾正相同的錯誤，或者手動編寫冗長的 `.claude/rules.md` 文件。

**Plain 的解法**: 將「AI 助手需要的上下文」內建到框架層。每個 Plain 包都自帶 `.claude/rules/` 和 `.claude/skills/` 目錄，包含精簡的守則和可執行的工作流。運行 `plain agent install` 後，這些文件會自動同步到項目的 `.claude/` 目錄，AI 助手能立即「理解」如何正確使用這些包。

這不只是文檔——這是**可執行的上下文**。例如，`plain-jobs` 包的規則會告訴 AI：「背景任務必須是冪等的，因為它們可能重試」，而 `plain-install` 技能則是一個完整的交互式工作流，指導 AI 逐步安裝新包並運行必要的遷移命令。

## 技术架构拆解

### 核心设计决策

| 設計選擇 | 理由 |
|---------|------|
| **Django fork 而非從零開始** | 繼承成熟的 ORM、認證、admin 等模塊，避免重複造輪子；2023 年 fork 時 Django 已穩定，可專注於 Agent 層創新 |
| **Postgres-only ORM** | 放棄多數據庫支持，換取更深的 Postgres 集成（如異步查詢、特定類型優化）；減少測試矩陣和維護負擔 |
| **類型驅動的模型定義** | 使用 Python 類型註解（`email: str = types.EmailField()`）而非 Django 的類屬性語法；IDE、CI、AI 助手讀取同一份簽名 |
| **內建 OpenTelemetry 追蹤** | 第一次遇到 N+1 查詢時就有工具可見；避免事後補監控的技術債 |
| **Agent 上下文作為一等公民** | 每個包自帶 rules/skills，`plain agent install` 自動同步；AI 助手不再「瞎猜」項目規範 |

### 与前版/竞品的关键差异

| 維度 | Django | Flask | Plain |
|------|--------|-------|-------|
| **AI 助手支持** | 無內建，需手寫 rules.md | 無內建 | `plain agent install` 自動同步包級規則和技能 |
| **類型系統** | 類屬性語法（`email = models.EmailField()`） | 無 ORM 類型 | 類型註解語法（`email: str = types.EmailField()`） |
| **數據庫支持** | 多數據庫（Postgres/MySQL/SQLite/Oracle） | 無內建 ORM | Postgres-only |
| **前端棧** | 模板 + 靜態文件 | 無規定 | Jinja2 + htmx + Tailwind CSS（預設集成） |
| **開發工具鏈** | 分散（black/ruff/pytest 等需手動配置） | 無規定 | uv + ruff + ty + pytest + oxc + esbuild（預設集成） |
| **文檔訪問** | 在線文檔 | 在線文檔 | `plain docs models` 本地命令 + 在線文檔 |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────────┐
│                    Plain 項目結構                            │
├─────────────────────────────────────────────────────────────┤
│  my-app/                                                    │
│  ├── .claude/                  ← AI 助手上下文（自動生成）   │
│  │   ├── rules/                ← 守則（~50 行/文件）         │
│  │   │   ├── plain-jobs.md     ← 「任務必須冪等」            │
│  │   │   └── plain-auth.md     ← 「密碼必須哈希存儲」       │
│  │   └── skills/               ← 可執行工作流               │
│  │       ├── plain-install/    ← /plain-install 命令        │
│  │       └── plain-upgrade/    ← /plain-upgrade 命令        │
│  ├── app/                      ← 應用代碼                   │
│  │   ├── users/models.py       ← 類型註解模型               │
│  │   ├── users/views.py        ← 類基視圖                   │
│  │   └── users/urls.py         ← Router 類路由              │
│  ├── pyproject.toml            ← uv 依賴管理                │
│  └── plain CLI                 ← plain dev/build/deploy     │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│              plain agent install 執行流程                    │
├─────────────────────────────────────────────────────────────┤
│  1. 掃描所有已安裝的 plain.* 和 plainx.* 包                   │
│  2. 讀取每個包的 agents/.claude/ 目錄                        │
│  3. 複製 rules/*.md → 項目 .claude/rules/                   │
│  4. 複製 skills/*/SKILL.md → 項目 .claude/skills/           │
│  5. 比對修改時間，跳過未變更文件（增量同步）                 │
│  6. 清理孤兒文件（卸載包後自動刪除對應規則）                 │
│  7. AI 助手（Claude Code 等）自動加載 .claude/ 上下文         │
└─────────────────────────────────────────────────────────────┘
```

## 实用评估

### 什么场景值得用

| 場景 | 理由 |
|------|------|
| **從零開始的新項目** | 無歷史包袱，可直接享受類型驅動模型 + Agent 上下文的紅利 |
| **團隊重度依賴 AI 編程** | `plain agent install` 確保所有開發者的 AI 助手有統一上下文，減少「為什麼 AI 給的代碼不對」的摩擦 |
| **需要快速原型的初創團隊** | 30 個預設包覆蓋認證/會話/郵件/任務隊列/監控，避免技術選型會議 |
| **對性能有要求的中小型應用** | 內建慢查詢檢測 + OpenTelemetry 追蹤，N+1 問題在開發期即可發現 |

### 什么场景不值得用

| 場景 | 理由 |
|------|------|
| **已有大型 Django 項目遷移** | 模型語法變更（類屬性 → 類型註解）、路由系統變更（URLconf → Router 類）、模板標籤差異，遷移成本可能超過收益 |
| **需要多數據庫支持** | Plain 只支持 Postgres；若項目需要 MySQL/SQLite，需 fork 或放棄 |
| **團隊不熟悉 Python/Django** | 官方文檔明確說明「不提供基礎概念教學」，需要自備 Python + Django + Jinja2 + Postgres 知識 |
| **簡單的 API 服務或腳本** | Plain 的完整棧（ORM+ 模板 + 前端工具鏈）對於 Flask/FastAPI 能解決的場景過於重量級 |

### 迁移成本

從 **Django 遷移到 Plain** 的估計工作量：

| 變更項 | 工作量 | 說明 |
|--------|--------|------|
| 模型語法重構 | 高 | `email = models.EmailField()` → `email: str = types.EmailField()`；所有模型文件需改寫 |
| 路由系統重構 | 中 | URLconf 列表 → Router 類；需重寫所有 `urls.py` |
| 模板標籤適配 | 低 - 中 | 大部分 Django 模板標籤兼容，但自定義標籤需檢查 |
| 設置文件重構 | 中 | `settings.py` 結構變更，需按 Plain 文檔重寫 |
| 第三方包替換 | 高 | Django REST Framework → plain.api；Django Celery → plain.jobs；需評估功能覆蓋 |
| **總計** | **2-4 週（小型項目）/ 2-3 月（中型項目）** | 取決於項目規模和測試覆蓋率 |

從 **Flask 遷移到 Plain** 的估計工作量：

| 變更項 | 工作量 | 說明 |
|--------|--------|------|
| 路由重構 | 低 | `@app.route` → Router 類，概念相似 |
| ORM 引入 | 中 | 若原項目用 SQLAlchemy，需學習 Plain ORM；若無 ORM，需設計模型 |
| 模板遷移 | 低 | Jinja2 兼容，大部分模板可直接使用 |
| **總計** | **1-2 週（小型項目）** | Flask 項目通常較小，遷移成本低 |

## 对你的意义

**對 Ken 的 AI 應用開發線的價值**:

1. **Agent 上下文自動化的參考設計**: Plain 的 `agents/.claude/` 目錄結構和 `plain agent install` 命令，為 Agent-Playbook 的「Agent 工具鏈」章節提供了一個完整的實戰案例。值得在 Handbook 中記錄其設計模式。

2. **類型驅動 API 的實踐**: Plain 用 Python 類型註解定義模型字段，這與 Agent 框架的 tool calling 簽名設計有相似之處——都是讓 AI 能準確理解接口約束。可借鑒到 Agent UI 框架的評估中。

3. **技能（Skills）作為可執行文檔**: Plain 的 SKILL.md 格式（frontmatter + 編號步驟 + Guidelines）是一個優秀的「AI 可執行工作流」設計，可參考到 Agent-Playbook 的 workflow 章節。

**具體建議**:

- **立即試用**: 用 `uvx plain-start new-project` 創建一個測試項目，體驗 `plain agent install` 後 Claude Code 的表現
- **觀望**: 若現有項目已用 Django/Flask 且運行穩定，不必急於遷移；但可將 Plain 的設計模式應用到現有項目的 `.claude/rules.md` 手動編寫中
- **深入研究**: 閱讀 Plain 包的 `agents/.claude/` 源碼（如 `plain-jobs` 的規則文件），學習如何編寫高效的 AI 上下文文檔

## 关键代码/配置片段

### Plain 模型定義（類型註解語法）

```python
# app/users/models.py
from plain import postgres
from plain.postgres import types
from plain.passwords.models import PasswordField

@postgres.register_model
class User(postgres.Model):
    email: str = types.EmailField()
    password: str = PasswordField()
    display_name: str = types.TextField(max_length=100)
    is_admin: bool = types.BooleanField(default=False)
    created_at: datetime = types.DateTimeField(create_now=True)

    query: postgres.QuerySet[User] = postgres.QuerySet()

    model_options = postgres.Options(
        constraints=[
            postgres.UniqueConstraint(fields=["email"], name="unique_email"),
        ],
    )
```

### Plain 路由系統（Router 類）

```python
# app/users/urls.py
from plain.urls import Router, path
from . import views

class UsersRouter(Router):
    namespace = "users"
    urls = [
        path("", views.UserList),
        path("<int:pk>/", views.UserDetail),
    ]
```

### Agent 規則文件示例（plain-jobs.md）

```markdown
---
paths:
  - "**/jobs.py"
---

# 背景任務守則

## 最佳實踐

### 保持任務冪等

任務可能在失敗時重試。設計時確保重複執行是安全的。

### 使用事務包裝數據庫操作

```python
from plain.jobs import job
from plain.postgres import transaction

@job
def send_welcome_email(user_id: int):
    with transaction.atomic():
        user = User.query.get(user_id)
        # ... 發送郵件
```

### 避免 N+1 查詢

使用 `select_related` 和 `prefetch_related`：

```python
# 錯誤：每個用戶一次查詢
for user in User.query.all():
    print(user.profile.bio)

# 正確：一次查詢加載所有關聯
for user in User.query.prefetch_related("profile").all():
    print(user.profile.bio)
```
```

### Agent 技能文件示例（SKILL.md frontmatter）

```markdown
---
name: plain-install
description: 安裝 Plain 包並引導完成設置步驟
---

# 安裝 Plain 包

## 1. 安裝包

```bash
uv add plain.{package_name}
```

## 2. 運行 Agent 同步

```bash
plain agent install
```

## 3. 檢查文檔

```bash
uv run plain docs --section {package_name}
```

## Guidelines
- 安裝後必須運行 `plain agent install`
- 不要手動編輯 .claude/ 目錄中的文件
- 若有遷移命令，提示用戶運行 `plain postgres sync`
```

---

## 📌 AI Agent 假设追踪

| 假設 | 方向 | 關聯說明 |
|------|------|----------|
| A-002: Agentic Coding 在初級任務達 80% 成功率 | 支持 | Plain 的 Rules + Skills 機制本質上是將「初級任務最佳實踐」編碼為 AI 可執行的上下文，直接提升 AI 在項目級任務（如安裝包、重構查詢）的成功率 |
| A-003: 多 Agent 協作框架從實驗走向工程實踐 | 支持 | Plain 的 `plain agent install` 是首個將「包級 Agent 上下文」作為標準交付物的生產級框架，標誌著 Agent 協作從手動配置走向自動化分發 |

---

[← Back to Deep Dives](./README.md)
