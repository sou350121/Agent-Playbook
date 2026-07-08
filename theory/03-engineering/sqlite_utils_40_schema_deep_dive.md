---
auto_generated: true
generated_at: "2026-07-08T03:37:08Z"
source_url: "https://simonwillison.net/2026/Jul/7/sqlite-utils-4/"
signal_type: "blog_post"
---
# sqlite-utils 4.0：六年磨一剑的数据库迁移革命 (sqlite-utils 4.0: Database Schema Migrations After Six Years)

> 🔍 本文由 Moltbot 自动生成 | 2026-07-08
>
> **项目/工具**: sqlite-utils
> **链接**: https://sqlite-utils.datasette.io/en/stable/changelog.html#v4-0
> **核心定位**: Python SQLite 工具库六年来的首次大版本升级，引入了完整的数据库迁移系统、嵌套事务和复合外键支持

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**: sqlite-utils 是 Simon Willison 维护的 Python SQLite 工具库，4.0 是 2020 年 3.0 以来的首次大版本升级，核心新增数据库 schema 迁移系统
- **现在值得用吗**: 是——如果你在用 SQLite 做持久化，尤其是 Datasette / LLM 生态的用户；现有 3.x 用户需评估 breaking changes
- **适合场景**: 小型/中型 SQLite 项目的 schema 版本管理、CLI 驱动的数据库操作、Python ETL 管道
- **不适合场景**: 需要自动从 ORM 模型生成迁移的场景（sqlite-utils 是 programmatic schema，不是 ORM）、需要 rollback 迁移的场景
- **与 Django Migrations 核心差异**: sqlite-utils 迁移是手动编写的 Python 函数，不支持自动生成和 rollback，但更轻量、更适合 SQLite 场景

## 是什么 / 解决什么问题

sqlite-utils 是 Simon Willison 在 2018 年开始维护的 Python 库，目标是让 SQLite 的常见操作（建表、插入、导入 CSV、schema  introspection）变得极其简单。它是 Datasette 和 LLM 等工具的底层依赖，也是整个 sqlite-utils/Datasette/LLM 生态的基础设施。

六年间，sqlite-utils 从 3.0 走到了 124 个 release，但一直没有正式的迁移系统。开发者管理 SQLite schema 变更的方式很原始：手动写 SQL 脚本、用触发器追踪变更、或者直接复制数据库文件做 rollback。Simon 之前尝试过独立包 `sqlite-migrate`，但一直停在 beta。

4.0 解决的核心问题：**给 SQLite 项目一个结构化的、可追踪的 schema 演进机制**，同时修复了多年来积累的事务行为不一致、API 设计缺陷等技术债。

## 技术架构拆解

### 核心设计决策

1. **迁移 = Python 函数**: 每个迁移是一个用装饰器标记的 Python 函数，接收 `db` 对象。这比 SQL 文件更灵活，可以利用 `table.transform()` 等高级能力。

2. **无自动生成、无 rollback**: 刻意区别于 Django。sqlite-utils 鼓励 programmatic table creation（`db["table"].create({...})`），没有 ORM 模型可以反向生成迁移。Simon 的判断是：rollback 在实际中很少使用，SQLite 的 rollback 最简单方式是复制数据库文件。

3. **迁移追踪表 `_sqlite_migrations`**: 自动创建，记录每个迁移函数的名称、所属迁移集（MigrationSet）、应用时间。幂等性保证——已应用的迁移不会重复执行。

4. **事务安全**: 4.0 重构了事务模型，引入 `db.atomic()` 上下文管理器。所有写入操作自动在事务中执行，迁移系统利用 savepoint 实现嵌套事务。

### 与前版/竞品的关键差异

| 维度 | sqlite-utils 3.x | sqlite-utils 4.0 | Django Migrations |
|------|-----------------|-----------------|-------------------|
| Schema 迁移 | 无（需 sqlite-migrate beta） | 内置 Migrations 系统 | 内置，自动生成 |
| 事务模型 | 隐式、不一致 | db.atomic() + savepoint | 显式事务 |
| 复合外键 | 不支持 | 支持（含 ON DELETE/UPDATE） | 支持 |
| 迁移 rollback | N/A | 不支持（手动复制文件） | 支持 migrate app label version |
| 类型检测 | CSV 导入默认 TEXT | 自动检测（默认开启） | N/A |
| Python 版本 | 3.7+ | 3.10+ | 3.10+ |
| upsert 实现 | INSERT OR IGNORE + UPDATE | INSERT ... ON CONFLICT | N/A |

### 架构/信息流图

```
用户/CLI 调用
    │
    ▼
┌─────────────────────────────────────────┐
│           sqlite-utils 4.0              │
│                                         │
│  ┌─────────────┐  ┌──────────────────┐  │
│  │ Migrations  │  │  db.atomic()     │  │
│  │ 系统        │──│  事务管理器      │  │
│  │             │  │                  │  │
│  │ @migrations()│ │  savepoint 嵌套  │  │
│  │ def fn(db)  │  │  自动 commit     │  │
│  └──────┬──────┘  └──────────────────┘  │
│         │                                │
│         ▼                                │
│  ┌──────────────────────────────────┐   │
│  │  table.transform()               │   │
│  │  (重建表 + 数据迁移 + 原子切换)   │   │
│  └──────────────┬───────────────────┘   │
│                 │                        │
│                 ▼                        │
│  ┌──────────────────────────────────┐   │
│  │  SQLite 引擎                      │   │
│  │  _sqlite_migrations 追踪表        │   │
│  └──────────────────────────────────┘   │
└─────────────────────────────────────────┘
```

迁移执行流程：
```
1. 扫描目录找到 migrations.py
2. 读取 _sqlite_migrations 表，确定 pending 迁移
3. 对每个 pending 迁移：
   a. 开启 savepoint
   b. 执行迁移函数（可能调用 transform/add_column/create）
   c. 成功 → commit + 写入 _sqlite_migrations
   d. 失败 → rollback to savepoint，抛出异常
```

## 实用评估

### 什么场景值得用

- **SQLite 驱动的小型 Web 应用**: 用 Datasette 或自定义 Flask/FastAPI + SQLite 的项目，可以用迁移系统管理 schema 演进，替代手动 SQL 脚本
- **ETL / 数据管道**: 需要频繁调整表结构的数据处理项目。`table.transform()` 支持改列类型、加列、改主键，比手写 `CREATE TEMP + COPY + DROP + RENAME` 安全得多
- **LLM 工具链**: Simon 的 LLM 工具已经在用类似模式管理 embeddings 表。如果你的工具用 SQLite 存储向量嵌入、对话历史等，迁移系统能显著降低维护成本
- **CLI 工具内置数据库**: 任何用 SQLite 做本地持久化的 CLI 工具（如 sqlite-chronicle），迁移系统让 schema 版本升级变成一行命令

### 什么场景不值得用

- **需要 ORM 自动生成迁移**: 如果你用 SQLAlchemy / Django ORM，sqlite-utils 不会帮你生成迁移——它没有模型定义层
- **需要 rollback 能力**: 迁移系统不支持回滚。Simon 的建议是复制数据库文件，但这在生产环境中可能不够优雅
- **大型多表复杂关系**: 迁移函数需要手动编写每个变更，表数量多时维护成本较高。Django 的自动生成 + 依赖图更适合复杂 schema
- **团队协作场景**: 迁移函数没有内置冲突检测机制（如两个开发者同时创建了同名迁移）

### 迁移成本

从 3.x 到 4.0 的 breaking changes 主要集中在三个方面：

| 变更类型 | 影响范围 | 预计工作量 |
|---------|---------|-----------|
| `db.query()` → `db.execute()` | 所有用 query() 执行写操作的代码 | 低（grep + 替换） |
| `ForeignKey` namedtuple → dataclass | 所有解包 foreign_keys 的代码 | 中（改为属性访问） |
| CLI `--detect-types` 移除 | 使用旧标志的脚本 | 低（删除标志或加 `--no-detect-types`） |
| `ensure_autocommit_off()` → `ensure_autocommit_on()` | 使用 WAL 模式的代码 | 低（重命名） |
| 事务行为变化 | 依赖隐式事务回滚的代码 | 中（需用 `db.begin()` 显式开启事务） |

Simon 自己在升级时提到：`db.query()` → `db.execute()` 是他自己代码中最常见的改动。整体而言，如果你的代码量在几百行以内，迁移可以在 1-2 小时内完成。

## 对你的意义

sqlite-utils 4.0 的迁移系统对 AI 应用开发有直接意义：

1. **Agent 工具的本地持久化**: 如果你在用 SQLite 存储 Agent 状态、对话历史、或工具调用日志，迁移系统让 schema 演进变得安全可控。不再需要担心「这个表加个列会不会丢数据」。

2. **LLM 工具链的底层依赖**: Simon 的 LLM 工具（向量嵌入管理）已经用迁移模式多年。4.0 把它变成一等公民后，整个生态的工具链都会受益——你的 RAG pipeline 如果基于 Datasette/LLM，未来升级会更平滑。

3. **AI 辅助开发的典型案例**: Simon 明确提到 Claude Fable 5 和 GPT-5.5 参与了 4.0 的开发——Fable 5 写了 12 个测试脚本，发现了 4 个 release blocker 和 10 个额外问题。这是 AI coding agent 在真实开源项目中的高质量贡献案例，值得持续关注。

**建议**: 如果你当前用 SQLite 做持久化且没有迁移系统，值得升级到 4.0 并引入迁移机制。如果只是简单读写、schema 稳定，可以观望。

## 关键代码/配置片段

### 定义迁移

```python
from sqlite_utils import Migrations

migrations = Migrations("creatures")

@migrations()
def create_table(db):
    db["creatures"].create(
        {"id": int, "name": str, "species": str},
        pk="id",
    )

@migrations()
def add_weight(db):
    db["creatures"].add_column("weight", float)

@migrations()
def change_column_types(db):
    db["creatures"].transform(types={"species": int, "weight": str})
```

### CLI 执行迁移

```bash
# 执行所有 pending 迁移
uvx sqlite-utils migrate data.db migrations.py

# 查看迁移状态
uvx sqlite-utils migrate data.db migrations.py --list

# 不指定文件时自动扫描当前目录
uvx sqlite-utils migrate data.db
```

### 嵌套事务

```python
with db.atomic():  # 外层事务
    db.table("dogs").insert({"id": 1, "name": "Cleo"}, pk="id")
    with db.atomic():  # 内层 savepoint
        db.table("dogs").insert({"id": 2, "name": "Pancakes"})
        # 如果这里失败，只回滚到内层 savepoint
```

### 复合外键

```python
# 创建带复合外键的表
db["orders"].create({
    "id": int,
    "warehouse": str,
    "product_code": str,
}, pk=("warehouse", "product_code"))

db["inventory"].create({
    "id": int,
    "warehouse": str,
    "product_code": str,
    "quantity": int,
})

db["inventory"].add_foreign_key(
    columns=["warehouse", "product_code"],
    other_table="orders",
    other_columns=["warehouse", "product_code"],
)
```

### AI 辅助开发——Simon 的 prompt 策略

```
review the changes on main since the last tagged 3.x release
- I am about to ship them as sqlite-utils 4.0
- review the changelog and upgrade guide
- write yourself scratch scripts to try out all of the new features
- save those scripts but don't commit them
```

这个 prompt 让 Claude Fable 5 输出了 12 个测试脚本 + 详细的 bug 报告，其中 4 个是 release blocker。Simon 的评论：「Fable has really good taste in API design, and is relentlessly proactive if you give it a more open goal.」

---
[← Back to Deep Dives](./README.md)
