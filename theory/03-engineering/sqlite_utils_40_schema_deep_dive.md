---
auto_generated: true
generated_at: "2026-08-22T03:32:23Z"
source_url: "https://simonwillison.net/2026/Jul/7/sqlite-utils-4/"
signal_type: "significant_update"
---
# sqlite-utils 4.0：六年首次大版本升级，原生支持 Schema 迁移 (sqlite-utils 4.0: Database Schema Migrations Go GA)

> 🔍 本文由 Moltbot 自动生成 | 2026-08-22
>
> **项目/工具**: sqlite-utils
> **链接**: https://sqlite-utils.datasette.io/en/stable/changelog.html#v4-0
> **核心定位**: 一个 Python SQLite 工具库的六年首次大版本升级，将作者三年前提出的独立迁移方案 sqlite-migrate 合并为核心功能，同时引入嵌套事务和复合外键支持。

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句話定位**：sqlite-utils 是 Simon Willison 维护的 Python SQLite 工具库，4.0 是 2020 年 3.0 发布以来的首次大版本升级，核心新增是声明式 schema 迁移系统。
- **现在值得用吗**：是——如果你在用 SQLite 做持久化（尤其是 Datasette/LLM 生态），迁移系统让 schema 演进变得可追踪、可版本化。
- **适合场景**：基于 SQLite 的小型/中型应用、CLI 工具、数据管道、个人项目；需要 schema 版本控制但不想引入 Django ORM 重量级方案。
- **不适合场景**：需要自动从 model 定义生成迁移的场景（sqlite-utils 鼓励编程式建表，非 ORM）；需要自动回滚的场景（4.0 明确不支持回滚）。
- **与 Django Migrations 核心差异**：sqlite-utils 迁移是手动编写的 Python 函数序列，不支持自动回滚，但更轻量、更灵活；Django 迁移可从 model 自动生成但绑定 ORM。

## 是什么 / 解决什么问题

SQLite 的 `ALTER TABLE` 能力非常有限——不支持 `DROP COLUMN`（直到 SQLite 3.35.0）、不支持修改列类型、不支持重命名外键约束。SQLite 官方文档推荐的变通方案是：创建临时表 → 拷贝数据 → 删除旧表 → 重命名临时表。这套模式繁琐且容易出错。

sqlite-utils 3.x 时代已经通过 `table.transform()` 方法封装了这个模式，但缺乏**迁移追踪机制**——你不知道哪些变更已经应用、哪些还没跑。开发者要么自己维护版本表，要么靠约定管理。

sqlite-utils 4.0 引入了原生的 `Migrations` 类，解决了三个核心问题：

1. **声明式迁移定义**：用 Python 函数 + 装饰器定义迁移步骤
2. **迁移状态追踪**：自动创建 `_sqlite_migrations` 表记录已应用的迁移
3. **事务安全**：通过 `db.atomic()` 提供嵌套事务支持，确保迁移的原子性

此外，4.0 还解决了 sqlite-utils 自身设计史上遗留的多个问题——复合外键支持、CSV 导入类型自动检测、`db.query()` 语义修正等。

## 技术架构拆解

### 核心设计决策

| 决策 | 理由 | 取舍 |
|------|------|------|
| 手动编写迁移函数（非自动生成） | sqlite-utils 鼓励编程式建表，无 model 定义可反推 | 灵活性高，但需开发者手动维护迁移脚本 |
| 不支持自动回滚 | Simon Willison 认为回滚"很少被使用"；SQLite 下直接备份文件更可靠 | 简化实现，但失去回滚能力 |
| 迁移独立文件 + 自动扫描 | 支持 CLI 直接扫描 `migrations.py`，也支持 Python API 调用 | 兼顾 CLI 和编程两种使用模式 |
| 将 sqlite-migrate 合并为核心 | sqlite-migrate 三年 beta 验证了设计稳定性 | 消除额外依赖，所有 sqlite-utils 用户默认获得迁移能力 |

### 与前版/竞品的关键差异

| 维度 | sqlite-utils 3.x | sqlite-utils 4.0 | Django Migrations |
|------|------------------|------------------|-------------------|
| 迁移追踪 | 无内置支持 | `_sqlite_migrations` 表自动管理 | `django_migrations` 表 |
| 迁移定义方式 | 手动调用 `transform()` | 装饰器函数序列 | 从 model 自动生成 / 手动编写 |
| 回滚支持 | N/A | 不支持（建议备份文件） | 支持反向迁移 |
| 嵌套事务 | 有限支持 | `db.atomic()` 支持 Savepoint | 完整事务支持 |
| 复合外键 | 不支持 | 支持创建/转换/内省 | 支持 |
| CSV 类型检测 | 需 `--detect-types` 标志 | 默认开启 | N/A |
| 绑定 ORM | 否——编程式 API | 否——编程式 API | 是——Django ORM |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────┐
│                   Developer / CLI                       │
│              uvx sqlite-utils migrate data.db           │
└────────────────────────┬────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│              Migrations.apply(db)                        │
│                                                         │
│  1. 扫描 migrations.py 中的 Migrations 实例              │
│  2. 查询 _sqlite_migrations 表获取已应用记录              │
│  3. 计算 pending migrations                              │
│  4. 在 db.atomic() 事务中依次执行                        │
│  5. 成功后写入 _sqlite_migrations 记录                    │
└────────────────────────┬────────────────────────────────┘
                         │
          ┌──────────────┼──────────────┐
          ▼              ▼              ▼
   ┌──────────┐   ┌──────────┐   ┌──────────┐
   │ create_  │   │ add_     │   │ change_  │
   │ table()  │   │ weight() │   │ col_type │
   └──────────┘   └──────────┘   └──────────┘
          │              │              │
          ▼              ▼              ▼
   ┌─────────────────────────────────────────────────────┐
   │         SQLite Database (data.db)                    │
   │  ┌─────────────────────┐  ┌──────────────────────┐ │
   │  │ _sqlite_migrations  │  │ creatures            │ │
   │  │ - id (PK)           │  │ - id (PK, int)       │ │
   │  │ - migration_set     │  │ - name (text)        │ │
   │  │ - name              │  │ - species (int) ←改  │ │
   │  │ - applied_at        │  │ - weight (text) ←改  │ │
   │  └─────────────────────┘  └──────────────────────┘ │
   └─────────────────────────────────────────────────────┘
```

### 迁移执行流程详解

```
迁移文件 (migrations.py)
    │
    ├── Migrations("creatures")  ← 定义迁移集名称
    │
    ├── @migrations() def create_table(db)
    │       └── db["creatures"].create({...})  ← 建表
    │
    ├── @migrations() def add_weight(db)
    │       └── db["creatures"].add_column("weight", float)  ← 加列
    │
    └── @migrations() def change_column_types(db)
            └── db["creatures"].transform(types={...})  ← 改类型
                    │
                    ├── 创建临时表 (新 schema)
                    ├── 拷贝数据
                    ├── DROP 旧表
                    └── RENAME 临时表 → 原表名
```

## 实用评估

### 什么场景值得用

- **CLI 工具 + SQLite 持久化**：如 LLM 工具的 embeddings 存储（Simon Willison 自己的 LLM 项目就用了类似模式）。迁移系统让 schema 演进可追踪，多用户部署时不会因版本不一致导致 schema 错乱。
- **Datasette 生态项目**：Datasette 本身就是构建在 sqlite-utils 之上的 SQLite 浏览器/发布工具。4.0 的迁移能力直接惠及整个生态。
- **数据管道中间层**：ETL 流程中 SQLite 常作为临时存储。`table.transform()` 的增强能力让 schema 调整变得安全。
- **个人项目 / 原型开发**：不想引入 Django/SQLAlchemy 的重量级 ORM，但需要可靠的 schema 版本管理。

### 什么场景不值得用

- **需要自动回滚的生产系统**：4.0 明确不支持回滚。Simon 的建议是"迁移前备份数据库文件"——这在 SQLite 单文件架构下是合理的，但不适合需要自动回滚能力的场景。
- **需要自动从 model 生成迁移**：sqlite-utils 鼓励编程式建表（`db["table"].create({...})`），不是 ORM model 定义。如果你希望像 Django 那样 `makemigrations` 自动生成，sqlite-utils 迁移不适合你。
- **高并发多写场景**：SQLite 本身的写并发限制（单写者）不会因为 4.0 改变。如果写并发是瓶颈，应该考虑 PostgreSQL 而非升级工具库。
- **团队大型项目**：迁移系统的设计哲学是"简单够用"，缺少 Django 迁移的自动检测、依赖图解析、反向迁移等高级特性。

### 迁移成本

从 sqlite-utils 3.x 升级到 4.0 的破坏性变更需要关注：

| 变更项 | 影响范围 | 迁移工作量 |
|--------|----------|------------|
| `db.query()` 现在立即执行且拒绝非查询语句 | 使用 `db.query()` 做写操作的代码 | 低——改为 `db.execute()` |
| Upsert 自动检测 PK 并拒绝缺少 PK 的记录 | 依赖隐式 PK 行为的 upsert 调用 | 低——确保传入记录包含 PK |
| CSV/TSV 导入默认开启类型检测 | 依赖全部文本类型导入的代码 | 中——可能需要显式指定类型 |
| `table.foreign_keys()` 返回格式变更（支持复合外键） | 解析外键信息的代码 | 低——检查返回值结构 |
| `table.extract()` 不再为 null 值创建查找记录 | 依赖 null 查找记录的行为 | 低——通常是无害修复 |

整体评估：对于一个中等规模的项目（几十处 sqlite-utils 调用），迁移工作量约 **1-2 小时**，主要是 `db.query()` → `db.execute()` 的替换。

## 关键代码/配置片段

### 迁移定义（引用自官方文档）

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
    db["creatures"].transform(
        types={"species": int, "weight": str}
    )
```

### CLI 执行迁移

```bash
# 应用所有待执行的迁移
uvx sqlite-utils migrate data.db migrations.py

# 查看迁移状态（已应用 / 待执行）
uvx sqlite-utils migrate data.db migrations.py --list

# 不指定文件则自动扫描当前目录及子目录的 migrations.py
uvx sqlite-utils migrate data.db
```

### 嵌套事务（新增）

```python
with db.atomic():  # 外层事务
    db.table("dogs").insert({"id": 1, "name": "Cleo"}, pk="id")
    with db.atomic():  # 内层 Savepoint
        db.table("dogs").insert({"id": 2, "name": "Pancakes"})
    # 内层回滚不影响外层
```

### 复合外键（新增）

```python
# 创建带复合外键的表
db["scores"].create({
    "student_id": int,
    "course_id": int,
    "score": float,
})

db["scores"].add_foreign_key(
    columns=["student_id", "course_id"],
    other_table="enrollments",
    other_columns=["student_id", "course_id"],
)
```

## AI 辅助开发：一个值得注意的侧面

sqlite-utils 4.0 的开发过程本身就是一个 AI 辅助编程的案例研究：

- **Claude Fable 5** 负责了复合外键功能的 API 设计和实现——Simon Willison 评价其 "API taste 非常好"
- **Claude Fable 5 + Opus 4.8 + GPT-5.5** 协同完成了升级指南和 release notes 的撰写
- 在最终 RC 阶段，Simon 让 Fable 5 和 GPT-5.5 分别审查 changelog 并编写测试脚本：
  - GPT-5.5 编写了 5 个脚本，未发现重大问题
  - Fable 5 编写了 12 个脚本，发现了 **4 个 release blocker 和 10 个额外问题**

这个对比暗示：在代码审查和边界 case 发现方面，Claude Fable 5 表现出了更强的主动性和深度。Simon 将这种现象描述为 "relentlessly proactive"——给定一个开放目标时，Fable 5 会主动探索更多路径。

## 对你的意义

如果你正在用 SQLite 做数据持久化（特别是 Datasette、LLM 工具链、或个人数据管道），sqlite-utils 4.0 的迁移系统值得立即关注。它填补了 SQLite 生态中长期存在的一个空白——在 Django ORM 和裸 SQL 之间，提供了一个轻量但可靠的 schema 版本管理方案。

**建议**：如果你的项目已经用 sqlite-utils 3.x，升级成本很低（1-2 小时），且能获得迁移追踪、嵌套事务、复合外键三个新能力。值得升级。

如果还没用过 sqlite-utils，4.0 是一个很好的起点——迁移系统让 SQLite 项目的 schema 管理从"约定"变成了"工程"。

---
[← Back to Deep Dives](./README.md)
