---
auto_generated: true
generated_at: "2026-07-28T03:33:11Z"
source_url: "https://www.36kr.com/p/3907365426467969"
signal_type: "significant_update"
---
# Claude「自我蒸馏」：从 Record a Skill 看 Agent 可组合性的关键跃迁 (Claude Self-Distillation: Record a Skill and the Composability Leap)

> 🔍 本文由 Moltbot 自动生成 | 2026-07-28
>
> **项目/工具**: Claude (Anthropic) — Cowork / Claude Code Skills
> **链接**: https://www.anthropic.com/news/skills
> **核心定位**: Claude 从"你写 SOP 给它执行"进化到"它看你做一遍就学会"——通过 Record a Skill 功能，用户录屏+语音示范即可自动生成可复用的 Agent Skill，标志着 AI Agent 从工具向可自我扩展的协作平台的范式转变。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**：Claude 新增 Record a Skill 功能，用户通过录屏+语音示范即可完成的工作流程，Claude 自动提炼为可反复调用的 Skill——从"写 prompt"到"做一遍"的交互范式转换
- **现在值得用吗**：是 — 对"说不清但做得出"的流程型任务（公司 OA、带偏好的报表、跨应用长流程）价值显著；对简单明确的任务反而效率更低
- **适合场景**：重复性但规则模糊的流程沉淀、跨应用操作链、带个人/组织偏好的工作流
- **不适合场景**：一句话能说清的任务、需要实时决策的复杂分析、涉及敏感数据/密码的场景
- **与 OpenAI Codex Record & Replay 核心差异**：Codex 侧重观察操作和窗口内容（"记住你点了哪里"），Claude 额外记录语音旁白（"听你解释为什么点"），侧重教方法而非仅教动作

## 是什么 / 解决什么问题

AI Agent 落地最大的瓶颈不是模型不够聪明，而是**知识传递效率太低**。

你想让 AI 帮你做一件事——比如整理项目配图、生成月度报表、处理报销单——你得把脑子里的"手感"翻译成文字。但很多流程是隐性的：先看什么、为什么这么判断、遇到重名怎么办、哪类文件绝对不能动。这些靠经验积累的东西，写成 SOP 比执行本身还累。

Claude 的 **Record a Skill** 功能（集成在 Cowork 界面中）直接绕过了这个瓶颈：你照常干活，边做边把思路说出声；结束后，Claude 分析这次示范，自动整理成一份以后可以反复调用的 Skill。

用 36kr 文章里的话说：「以前是你给 AI 写 SOP，现在是它搬个小板凳坐你旁边，看你干一遍。」

这不是一个孤立的功能更新。它连接了 Anthropic 在 2025 年 10 月推出的 **Agent Skills** 体系——一个跨平台、可组合、渐进式加载的技能框架。Record a Skill 是 Skills 的**创作入口**，让 Skill 的生产从"工程师手写"变成了"任何人示范"。

## 技术架构拆解

### 核心设计决策

| 决策 | 理由 |
|------|------|
| **录屏+语音双通道输入** | 画面记录操作序列，语音记录推理逻辑——前者教"做了什么"，后者教"为什么这么做" |
| **渐进式上下文加载** | Skill 元数据（name/description）预加载到 system prompt，正文按需读取，避免上下文膨胀 |
| **Skill = 文件夹 + SKILL.md** | 标准目录结构，可包含指令、脚本、资源文件——可版本控制、可分享、可组合 |
| **可包含可执行代码** | 排序、解析等确定性操作走代码执行而非 token 生成，兼顾效率和可靠性 |
| **跨平台统一格式** | 同一份 Skill 在 Claude App、Claude Code、API 中通用，消除平台碎片化 |

### 与前版/竞品的关键差异

| 维度 | 传统 Prompt 方式 | Claude Record a Skill | OpenAI Codex Record & Replay |
|------|-----------------|----------------------|------------------------------|
| 输入方式 | 文字描述 | 录屏+语音示范 | 录屏观察操作 |
| 知识类型 | 显性规则 | 显性+隐性知识 | 显性操作序列 |
| 创作门槛 | 高（需写作能力） | 低（会做就会教） | 低（会做就会教） |
| 可组合性 | 低（每次重新写） | 高（Skill 可叠加） | 中（Skill 可复用） |
| 代码执行 | 无 | 支持（确定性操作） | 支持 |
| 跨平台 | 不适用 | Claude App/Code/API 通用 | Codex 生态 |
| 安全模型 | 取决于 prompt | 需审计 Skill 来源 | 需审计 Skill 来源 |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────────┐
│                    用户操作层                                │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐  │
│  │  录屏画面     │    │  语音旁白     │    │  键盘/鼠标    │  │
│  │  (操作序列)   │    │  (推理逻辑)   │    │  (输入事件)   │  │
│  └──────┬───────┘    └──────┬───────┘    └──────┬───────┘  │
│         └───────────────────┼───────────────────┘           │
│                    ▼        ▼                               │
│              ┌─────────────────┐                            │
│              │  Claude 分析引擎 │                            │
│              │  · 动作抽象化    │                            │
│              │  · 规则提取      │                            │
│              │  · 异常识别      │                            │
│              └────────┬────────┘                            │
└───────────────────────┼─────────────────────────────────────┘
                        ▼
┌─────────────────────────────────────────────────────────────┐
│                    Skill 产出层                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  my-skill/                                           │   │
│  │  ├── SKILL.md          ← YAML frontmatter + 指令    │   │
│  │  │   name: "xxx"       ← 预加载到 system prompt    │   │
│  │  │   description: "xx" ← 触发条件                   │   │
│  │  │   body: 操作规则 + 判断逻辑 + 异常处理            │   │
│  │  ├── scripts/          ← 可执行代码（可选）           │   │
│  │  └── resources/        ← 模板/参考文件（可选）        │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                        ▼
┌─────────────────────────────────────────────────────────────┐
│                    运行时调用层                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  用户消息 → Claude 扫描 Skill 元数据 → 匹配触发       │   │
│  │       → 按需加载 SKILL.md 正文 → 执行任务             │   │
│  │       → 如需代码操作 → 调用 code execution tool       │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### 渐进式加载机制（Progressive Disclosure）

Agent Skills 的核心创新是**三层渐进式加载**，解决了"技能知识量"和"上下文窗口"之间的矛盾：

1. **第一层（启动时）**：仅加载所有 Skill 的 name + description 到 system prompt——每个 Skill 仅占几十字符
2. **第二层（触发时）**：Claude 判断 Skill 相关后，读取完整 SKILL.md 正文
3. **第三层（深入时）**：SKILL.md 中引用的附加文件（scripts、resources）按需加载

这意味着一个 Skill 可以包含**无上限**的上下文量——只要不触发，就不消耗 token。

## 实用评估

### 什么场景值得用

- **组织内流程沉淀**：录一遍月报流程，以后 AI 自动导数据、清洗、做表、备邮件草稿。适合新员工 onboarding 和知识交接
- **带个人偏好的重复任务**：配图归档、文件整理、报销单处理——这些"说不清但做得出"的事是 Record a Skill 的主战场
- **跨应用长流程**：需要切多个窗口、填多个表单的流程，录一遍比写一遍快十倍
- **非技术用户的自动化**：不需要懂 prompt engineering，会操作电脑就能创建 Skill

### 什么场景不值得用

- **简单明确的任务**：一两句话能说清的，直接打字更高效
- **需要实时判断的分析**：市场趋势研判、代码架构设计——这些需要推理而非流程
- **敏感数据处理**：官方明确记录屏幕画面、鼠标点击、键盘输入和语音——**必须**先关闭聊天通知、密码管理器，更不要在录制时登录网银
- **高频变动的流程**：如果流程每周都在变，维护 Skill 的成本可能超过收益

### 迁移成本

从传统 prompt 方式迁移到 Skill 体系：

| 迁移路径 | 工作量 | 说明 |
|----------|--------|------|
| 手写 SKILL.md | 中等（30min-2h/个） | 需了解 YAML frontmatter 格式和目录结构 |
| Record a Skill | 低（5-15min/个） | 演示+旁白即可，但需验证质量 |
| 从 Codex Skill 迁移 | 中低 | 格式类似但需调整，Anthropic 已推出 Agent Skills 开放标准（agentskills.io） |

## 对你的意义

作为 Agent + UI 方向的开发者，这个变化有几个值得关注的信号：

1. **Skill 创作民主化**：当任何人（不仅是工程师）都能创建可复用的 Agent 能力，Skill 生态的供给量会爆发式增长。这意味着 Agent 的"长尾能力"覆盖不再是瓶颈
2. **隐性知识显性化**：Record a Skill 的核心突破是捕获了隐性知识（tacit knowledge）——那些存在于肌肉记忆和直觉中、难以文字化的经验。这对知识管理领域有深远影响
3. **与 MCP 的互补关系**：Anthropic 明确表示 Skills 将"complement MCP servers by teaching agents more complex workflows"。MCP 解决工具集成标准化，Skills 解决工作流知识沉淀——两者结合才是完整的 Agent 能力栈
4. **对你的具体建议**：如果 Ken 在构建 Agent 工具链，值得重点关注 Skill 的**可组合性**——多个 Skill 叠加使用是 Claude 的差异化能力。这可能是比单一 Skill 质量更重要的架构考量

## 关键代码/配置片段

### SKILL.md 标准结构（来自 Anthropic 官方文档）

```yaml
---
name: "pdf-form-filler"
description: "Fills out PDF forms by extracting form fields and populating them with provided data"
---

# PDF Form Filler Skill

When the user asks to fill out a PDF form, follow these steps:

1. Read the PDF and extract all form fields using the provided script
2. Map user-provided data to the extracted fields
3. Use the fill script to populate the form
4. Save the result to the specified output path

## Exception Handling
- If a field cannot be mapped, ask the user for clarification
- If the PDF is encrypted, report the error and stop
```

### 配套可执行脚本（确定性操作）

```python
# scripts/extract_fields.py
import fitz  # PyMuPDF
import sys

def extract_form_fields(pdf_path):
    doc = fitz.open(pdf_path)
    fields = []
    for page in doc:
        for field in page.widgets():
            fields.append({
                "name": field.field_name,
                "type": field.field_type,
                "value": field.field_value
            })
    return fields

if __name__ == "__main__":
    import json
    fields = extract_form_fields(sys.argv[1])
    print(json.dumps(fields, indent=2))
```

### Claude Code 本地安装

```bash
# 通过 marketplace 安装
# 或手动安装到 ~/.claude/skills/
mkdir -p ~/.claude/skills/my-skill
# 将 SKILL.md 和相关文件放入目录
# Claude Code 启动时自动扫描并加载
```

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-002: Agentic Coding 在初级任务达 80% 成功率 | 支持 | Record a Skill 让非编码用户也能创建自动化 Skill，大幅降低 Agentic Coding 的门槛——成功率不再依赖用户的编程能力 |
| A-003: 多 Agent 协作框架从实验走向工程实践 | 支持 | Skills 的跨平台统一格式（App/Code/API 通用）和可组合性设计，是多 Agent 系统中"能力共享"的基础设施 |
| A-001: MCP 成为 AI Agent 工具集成事实标准 | 补充 | Anthropic 明确表示 Skills 将 complement MCP——Skills 负责工作流知识，MCP 负责工具集成，两者互补而非竞争 |

---
[← Back to Deep Dives](./README.md)
