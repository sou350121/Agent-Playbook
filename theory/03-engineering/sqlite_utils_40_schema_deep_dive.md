---
auto_generated: true
generated_at: "2026-10-16T13:20:44Z"
source_url: "https://simonwillison.net/2026/Jul/7/sqlite-utils-4/"
signal_type: "significant_update"
---
# sqlite-utils 4.0：六年首次大版本升级，把 schema 迁移带进 SQLite 工具链 (sqlite-utils 4.0, now with database schema migrations)

> 🔍 本文由 Moltbot 自动生成 | 2026-10-16
>
> **项目/工具**: sqlite-utils
> **链接**: https://simonwillison.net/2026/Jul/7/sqlite-utils-4/
> **核心定位**: Simon Willison 的 SQLite 命令行/Python 工具库六年来首次大版本升级（3.0 → 4.0），新增数据库 schema 迁移、嵌套事务与复合外键三大能力，让「轻量 SQLite」也能拥有正规的演进式数据库管理。

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句話定位**：sqlite-utils 4.0 是该项目自 2020 年 11 月 3.0 以来第一次 major 版本跳变（第 124 个 release），核心补齐了此前只能靠手写脚本解决的 schema 迁移能力。
- **現在值得用嗎**：看場景——如果你的项目已经用 sqlite-utils 且有「表结构会随版本演进」的需求，值得升；如果只是临时查询工具，升级收益有限，但需注意 breaking changes。
- **適合場景**：多版本演进的小型应用数据库、CLI 数据管道、需要给 SQLite 加「迁移历史表」的个人项目。
- **不適合場景**：大型多用户生产库（SQLite 本身的并发限制）、已经上了 Alembic/Django migrations 等成熟迁移框架且无迁移必要的项目。
- **與前版核心差異**：3.x 改表结构只能靠 `table.transform()` 手动调用，无「已应用迁移」追踪；4.0 引入了带 `_sqlite_migrations` 记录表的迁移系统 + `db.atomic()` 嵌套事务 + 复合外键支持。

## 是什么 / 解决什么问题

sqlite-utils 是一个把 SQLite 当作「够用就行」数据库的 Python 库兼 CLI。它的定位从来不是替代 PostgreSQL 或 ORM，而是让开发者用几行命令或几行 Python 就能建表、导入 CSV/JSON、查询、改结构。

问题在于：SQLite 的 `ALTER TABLE` 能力极其有限——它不支持改列类型、不支持加约束、不支持任意重排列。想在 SQLite 上做「正规」的 schema 演进，历来要么手写那套「建临时表 → 拷数据 → 删旧表 → 改名」的样板逻辑（SQLite 官方文档推荐的模式），要么干脆放弃迁移、每次重建数据库。

sqlite-utils 3.x 已经用 `table.transform()` 封装了这套样板，但缺了关键一环：**没有迁移历史追踪**。也就是说，你知道「当前的表长什么样」，却不知道「它是从哪个版本一步步变过来的」，也无法在部署时自动补齐未应用的变更。

4.0 补的正是这一环。Simon Willison 在发布 blog 里明确列出三大新特性：**数据库迁移（database migrations）、嵌套事务（新增 `db.atomic()` 方法）、复合外键支持（compound foreign keys）**，外加「若干小而重要的 breaking changes」。

## 技术架构拆解

### 核心设计决策

- **迁移即 Python 文件**：迁移不是 SQL 字符串，而是用 `sqlite_utils.Migrations` 装饰器定义的 Python 函数。好处是迁移步骤可以复用 `table.transform()` 的全部能力，而 SQLite 原生 `ALTER TABLE` 做不到。
- **迁移集（migration set）命名空间**：`Migrations("creatures")` 中第一个参数形成独立的 migration set，配合 `_sqlite_migrations` 表里的 `migration_set` 字段，可以在一张库里维护多组互不干扰的迁移序列。
- **依赖 `table.transform()` 而非原生 `ALTER TABLE`**：官方文档推荐的「新建临时表 → 拷数据 → 删旧表 → 重命名」模式被封装进 `transform()`，迁移文件中直接调用 `transform(types={...})` 等即可。
- **幂等追踪**：`_sqlite_migrations` 表记录每个迁移的 `name` 与 `applied_at`，并建了 `(migration_set, name)` 唯一索引，保证同一迁移不会被重复应用。
- **AI 协同开发**：据发布说明，这一版本由 Claude Fable 5 与 GPT-5.5 协同参与开发——这也是本次升级值得关注的元层面信号（见后文）。

### 与前版/竞品的关键差异

| 维度 | sqlite-utils 3.x / 手写脚本 | sqlite-utils 4.0 |
|------|----------------------------|------------------|
| 迁移历史追踪 | 无，需自行维护版本表 | 内置 `_sqlite_migrations` 记录表 + 唯一索引 |
| 改列类型 | 手动调 `transform()`，易漏步骤 | 迁移文件中声明即可，可编排多步 |
| 事务嵌套 | 不支持真正的嵌套事务 | 新增 `db.atomic()` 方法 |
| 外键 | 仅单列外键 | 支持复合外键（compound foreign keys） |
| 迁移定义形式 | 无标准形式 | Python 文件 + `@migrations()` 装饰器 |
| 多迁移序列 | 不适用 | 通过 migration set 命名空间隔离 |

### 架构/信息流图

```
迁移定义 (migrations.py)
        │
        │  @migrations() 装饰器注册
        ▼
  Migrations("creatures")  ── 一个 migration set
        │
        │  create_table / add_weight / change_column_types ...
        ▼
  ┌──────────────────────────────┐
  │  执行: sqlite-utils migrate   │
  │        data.db migrations.py  │
  └──────────────┬───────────────┘
                 │  比对已应用记录
                 ▼
  ┌──────────────────────────────┐
  │  _sqlite_migrations 表         │
  │  id | migration_set | name |   │
  │       applied_at               │
  │  UNIQUE(migration_set, name)   │
  └──────────────┬───────────────┘
                 │  只跑未应用的迁移
                 ▼
  每步调用 table.transform()
  (临时表 → 拷数据 → 删旧表 → 重命名)
```

发布 blog 给出的最小可用示例（原样引用）：

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

运行方式：

```bash
uvx sqlite-utils migrate data.db migrations.py
uvx sqlite-utils schema data.db
```

迁移后数据库里会多出一张内部表，其 DDL 为（引自发布 blog）：

```sql
CREATE TABLE "_sqlite_migrations" (
  "id" INTEGER PRIMARY KEY,
  "migration_set" TEXT,
  "name" TEXT,
  "applied_at" TEXT
);
CREATE UNIQUE INDEX "idx__sqlite_migrations_migration_set_name"
  ON "_sqlite_migrations" ("migration_set", "name");
```

### 4.0 之后的快速迭代（值得注意的信号）

4.0 并非终点。根据官方 changelog，随后几个月项目持续高密度发版：

- **4.1（2026-07-11）**：`insert`/`upsert` 新增 `--code` 选项（可直接传一段 Python 定义 `rows()`）；`--type column-name type` 覆盖自动类型推断（如 ZIP 码保留前导零）；新增 `table.drop_index()`；`transform()` 支持 `strict=True/False` 切换 SQLite STRICT 模式。
- **4.1.1（2026-07-12）**：修复 `transform()` 在开启外键且存在破坏性 `ON DELETE` 动作时可能静默删改引用行的问题，改为抛 `TransactionError`。
- **4.2（2026-08-13）**：新增 `table.checks` / `column_checks` / `table_checks` 内省属性；新增 `sqlite_utils.ANY` 标记类型；`transform()` 大量边界修复（保留 UNIQUE/CHECK/AUTOINCREMENT/注释、支持被视图引用的表）。
- **4.2.1（2026-08-13）**：修复 4.2 误发导致的 `No module named 'typing_extensions'` 崩溃。

> 这一串密集的小版本修复说明：4.0 的三大特性（尤其迁移与 `transform()`）触及了大量此前未被覆盖的边界情况，真实世界的 schema 复杂度远超初始设计假设。

## 实用评估

### 什么场景值得用

- **有版本演进需求的小型应用数据库**：给一个自托管应用、桌面工具或 CLI 数据管道加上「迁移」能力，4.0 让这件事从「手写版本表」变成「写几个装饰器函数」。
- **已有 sqlite-utils 依赖的项目**：升级即可获得迁移系统，无需引入 Alembic 这类重型框架。
- **数据管道脚本**：`sqlite-utils migrate` + `--code` 插入，能把「建表—改结构—导入」编排进单个可版本化的 Python 文件。

### 什么场景不值得用

- **大型多用户生产库**：SQLite 的并发写入限制依旧存在，迁移系统不解决这个问题。
- **已有成熟迁移框架的项目**：如果团队已经用 Alembic / Django migrations / Rails migrations 且运转良好，为 sqlite-utils 再引入一套迁移语义只会增加认知负担。
- **一次性/临时脚本**：迁移追踪表 `_sqlite_migrations` 会让「只是建个表查一下」的轻量场景多出无用结构。

### 迁移成本

- **从 3.x 升级到 4.0**：存在「若干小而重要的 breaking changes」，发布说明指向一份专门的 upgrade guide。务必先读该指南再升。
- **工作量估计**：小项目通常数小时内可完成；若项目大量依赖已被 `transform()` 语义变更影响的行为（如列类型转换时空字符串处理），需要额外回归测试。
- **新增采用（新项目直接用 4.0）**：几乎零成本，直接写 `migrations.py` 即可。

## 对你的意义

对 Ken 的 AI App 监控/工具箱方向而言，这条更新有两层含义：

1. **工程层面**：Agent-Playbook 或其它个人数据管道里，凡是用 SQLite 存 RSS 采集结果、日报索引、deep-dive 文章元数据的场景，4.0 的迁移系统能让「schema 随字段增长而演进」变得可控——不用再为加一个字段就重建库。
2. **元层面（更值得注意）**：据发布说明，4.0 由 **Claude Fable 5 + GPT-5.5 协同开发**。一个由资深开发者维护、跨越六年的成熟开源项目，把大版本开发和大量边界修复部分交给 AI 协同——这本身是「Agentic Coding 进入真实维护型工程」的一个具体案例，比任何 benchmark 都更有说服力。结合紧接着几个月密集发布的边界修复（4.1/4.1.1/4.2），也可以观察「AI 协同写的复杂特性，需要多少人类后续修补」这一现实问题。

**建议**：观望偏试用。如果你的 SQLite 管道正处于「想加字段/改结构又不想重建」的阶段，值得立刻升；纯查询工具则可等 4.2.x 稳定后一次性升。

## 关键代码/配置片段

迁移文件的 CLI 运行与 schema 查看（引自发布 blog）：

```bash
uvx sqlite-utils migrate data.db migrations.py
uvx sqlite-utils schema data.db
```

4.1 引入的 `--type` 覆盖（对 ZIP 码这类「看似整数实为文本」的列尤其有用，引自 changelog）：

```bash
sqlite-utils insert data.db zips zips.csv --type zip TEXT
```

> TODO: 官方 4.0 upgrade guide 的具体 breaking change 条目清单未能直接抓取（文档 URL 返回 404），如需精确迁移清单，建议以 `sqlite-utils.datasette.io` 上标为 "upgrade guide" 的最新页面为准。

---
[← Back to Deep Dives](./README.md)
