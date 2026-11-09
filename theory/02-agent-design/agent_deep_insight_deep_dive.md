---
auto_generated: true
generated_at: "2026-11-09T08:01:34Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/four-layers-of-context-engineering-for-production-ai-agents-how-deep-insight-applies-them-in-working-code/"
signal_type: "significant_update"
---
# 生产级 Agent 的四层上下文工程：AWS Deep Insight 工作代码拆解 (Four Layers of Context Engineering for Production AI Agents)

> 🔍 本文由 Moltbot 自动生成 | 2026-11-09
>
> **项目/工具**: AWS Deep Insight（构建于 Strands Agents SDK + Amazon Bedrock AgentCore）
> **链接**: https://aws.amazon.com/blogs/machine-learning/four-layers-of-context-engineering-for-production-ai-agents-how-deep-insight-applies-them-in-working-code/
> **核心定位**: 把 Anthropic 关于长时程 agent 的零散上下文工程建议，整理成四层可落地实践，并在一个开源多 agent 数据分析系统里给出可直接抄的工作代码——单个 write-and-execute 工具让每个脚本写入上下文的 token 降约 95%，按需加载 skills 让系统提示降约 97%。

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句話定位**：一篇「架构 → 提示 → 工具 → 验证」四层递进的上下文工程实操手册，附带 Deep Insight 的真实源码片段，而不是又一篇讲「上下文很重要」的玄学文章。
- **現在值得用嗎**：看场景。如果你在写**多阶段、长时间、会吃掉大半 context window 的 agent**（数据分析、报表生成、代码库改造），这里能直接省掉大量试错；如果你的 agent 只是一两次工具调用的薄封装，读完原理即可，不必照搬四层。
- **適合場景**：多 agent 编排、长任务拆解、需要 agent 产出报告/文件类交付物、想给每个子 agent 设 token 预算。
- **不適合場景**：单次问答型 chatbot、latency 敏感且任务短的场景（多 agent + 文件往返会显著增加 wall-clock 时间）、不想引入文件系统作为 agent 间通信总线的受限环境。
- **與前版的差異**：不是新框架新版本，而是把 Anthropic《Effective Context Engineering》等分散建议**重新分层并落到代码**；真正的增量是「层与层之间为什么不够、下一层补什么」的因果链。

## 是什麽 / 解决什么问题

背景痛点很具体：Claude Sonnet 4.5 在 Bedrock 上有 200K 上下文窗口，看起来宽松，但文章给的例子是——

> 「分析销售数据并生成 DOCX 报告」这一个任务，拆成数据加载与探索（5 分钟）、按类别销售分析（3 分钟）、生成 5 张时序图（10 分钟）、统计验证（3 分钟）、最终报告生成（5 分钟），合计超过 150K token、15 分钟。

单上下文跑这种任务会同时踩三个坑：窗口在任务中途溢出、陈旧上下文导致注意力衰减（文中引 Anthropic 的 "context rot" 说法）、一旦出错整条流水线重跑，按 token 计费的成本直接翻倍。

Deep Insight 的答案不是「等更大的窗口」，而是把上下文当作一种**需要被架构、提示、工具、验证四道闸门共同管理的稀缺资源**。这篇文章的核心价值就在于：四层不是并列的 checklist，而是**每一层专门补上一层的漏**。

## 技術架構拆解

### 核心设计决策

- **隔离优先（Layer 1）**：Coordinator / Planner / Plan Reviewer / Supervisor / Tool Agents（Coder、Validator、Reporter、Tracker、Auditor）各持独立上下文窗口。即便是 token 消耗最大的 Coder，总计也被压在 25K 以内——相当于 200K 窗口只用 1/8 左右。
- **共享状态只留四样东西**：`shared_state` 字典只存 `messages`（上一 agent 的**最终消息**，不是完整对话历史）、`clues`（压缩摘要）、`full_plan`（planner 生成、tracker 更新的检查清单）、`history`（agent 名 + 消息的简要日志）。关键判断：跨 agent 传递的是「结论」，不是「过程」。
- **提示层做 token 预算（Layer 2）**：每个 agent 的系统提示写明输出上限——Coder 1000–1500、Validator 800、Reporter 1000。理由不是省 prompt 长度，而是**防止长回复把 Supervisor 的上下文撑爆**。
- **自包含代码原则（Layer 2）**：Coder 提示强制「变量不跨脚本存活」，每个脚本自带 import 并从缓存文件重新加载数据。这条看似是代码规范，实质是上下文工程——只有不依赖上一段代码，上一段代码才能被安全地从上下文中删除。
- **只传指针，数据落文件（Layer 3）**：把「写文件」和「执行」合并成单个 `write_and_execute_tool`，代码不再以消息形式进入上下文。
- **文件系统即 agent 间通信总线（Layer 3）**：`all_results.txt`（Coder → Reporter 累积分析结果）、`calculation_metadata.json`（Coder → Validator 供独立核算）、`citations.json`（Validator → Reporter 的已验证引用）、`audit_findings.json`（Auditor → Reporter 驱动定向重试）。
- **Skills 按需加载（Layer 3）**：启动时只加载约 500 token 的 skill 目录（名称 + 简述），命中后再读取约 3K token 的 `SKILL.md` 全文。
- **独立验证收尾（Layer 4）**：隔离的代价是 agent 互相看不见彼此的活，Coder 算错会被 Reporter 一路带进报告——所以保留 Validator/Auditor 作为最后防线。

### 与前版/竞品的关键差异

| 维度 | 常规单 agent + 长上下文 | 常规多 agent（prompt 串联） | Deep Insight 四层 |
|------|------------|------------|------------|
| 上下文规模 | 全流程累积，轻松 >150K | 有所隔离，但下游接收上游全文 | Coder 亦 <25K |
| 代码/数据是否进上下文 | 是，千行级累积 | 视实现，通常部分 | 否，只留约 3 行摘要 |
| 专业知识加载 | 全塞系统提示（>20K token） | 同左 | 目录 500 token + 按需 3K |
| 错误传播 | 整链重跑 | 静默传播到最终交付物 | Validator/Auditor 定点拦截 |
| 新增能力成本 | 改提示、重新部署 | 改提示、重新部署 | 丢一个 `SKILL.md` 进目录即被发现 |

### 架構/信息流圖

```
              ┌───────────────┐
   user ────▶ │  Coordinator  │
              └───────┬───────┘
                      ▼
                 Planner ──▶ full_plan(检查清单)
                      ▼              │
              Plan Reviewer          │
                      ▼              │
              ┌───────────────┐      │
              │  Supervisor   │◀─────┘ (只读 checklist 状态 + clues)
              └──┬────┬───┬───┘
                 │    │   │   agents-as-tools（各自独立上下文）
        ┌────────┘    │   └────────┐
        ▼             ▼            ▼
      Coder       Validator     Reporter
        │             │            ▲
        │             │            │
        ├─ all_results.txt ────────┤
        ├─ calculation_metadata.json ─▶ Validator（独立复算）
        │             └─ citations.json ─▶ Reporter
        ▼
   coder_analysis_utils.py（共享模块，写一次 import 多次）
              ▲
           Auditor ──▶ audit_findings.json ──▶ Reporter 定向重试

共享状态 shared_state = {messages, clues, full_plan, history}
```

## 實用評估

### 什麼場景值得用

- **多阶段分析/生成流水线**：任务天然可以切开（加载 → 分析 → 验证 → 成文），每一刀就是一次上下文隔离的机会。
- **交付物是文件而非聊天文本**：报告、DOCX、图表、PR——只要产物落在文件系统，就可以执行「只传指针」策略，收益最大。
- **工具域知识较重**：skills 目录 + 按需加载这套，本质是给 agent 做一个「技能黄页」，比往系统提示里堆 20K 说明书可维护得多。
- **你需要给子 agent 设成本护栏**：逐 agent 的 token 预算表是很少见的、可量化的工程细节。

### 什麼場景不值得用

- **任务短、一次工具调用能解决**：四层带来的额外 agent 往返、文件读写、验证开销会远大于省下的 token。
- **延迟敏感**：文中自述单任务 15 分钟、5 个阶段；拆成多 agent 并加验证，wall-clock 只会更长。这不是一个「更快」的方案，是一个「能跑完、且跑得起」的方案。
- **审计/合规要求全量 trace 的场景**：压缩后的 clues 会丢细节，出问题时要靠 `calculation_metadata.json` 这类结构化记录回溯，而不是原始对话。
- **受限运行环境**：文件系统作为通信总线意味着你需要可控的沙箱与产物目录；多租户或强隔离环境要额外设计。

### 遷移成本

- **从单 agent 迁移**：主要工作量是**任务切分**和**定义文件契约**（每份中间产物谁写、谁读、格式什么），代码量不大但设计时间不少。文中给出的顺序是「先隔离，再加预算提示，再把重内容外移，最后补验证」——按这个顺序逐层加，比一次性重写稳。
- **从现有多 agent 迁移**：改动集中在两处，(1) 把「传全文」改成「传摘要 + 文件引用」，(2) 合并 write/execute 类工具为单一工具。第二项通常是最快见效的，官方数据是单脚本约 95% token 降幅。
- **Skills 体系**：新建 `skills/<name>/SKILL.md`（YAML frontmatter + markdown 指南）即被自动发现，不需要重新部署。这一条对内部工具链团队很值钱。

## 對你的意義

如果你正在给 Ken 的 **Agent + UI** 方向做 agent builder 或可视化 workflow，这套分层几乎可以直接照搬成产品级的「上下文治理」模块：把四个层做成画布上的显式节点/配置项（隔离边界、输出预算、文件交接、验证 agent），比让用户在提示框里手写「请简洁回答」要靠谱得多。

值得立刻试的三件事：

1. **把你的 agent 工具表里所有「写文件」+「执行」成对出现的工具合并**，这是投入产出比最高的一步。
2. **给每个子 agent 的提示加一行 token 预算**，并统一输出格式（Status / Completed Tasks / Key Insights / Generated Files）。格式统一本身就让 Supervisor 的解析和判断变便宜。
3. **如果 agent 有专业领域知识**（比如你们的 VLA 分析流程、RAG 评估规范），改成 `SKILL.md` 目录 + 按需加载，而不是塞系统提示——顺带解决「加能力要重新部署」的痛点。

判断：**分层理念立即用，完整四层视任务形态决定**。小任务直接照搬只会增加复杂度；长任务、多交付物的流水线则值得一开始就按四层设计。

## 關鍵代碼/配置片段

**1. 合并写 + 执行，代码不进上下文（官方称约省 95% token）**

```python
# write_and_execute_tool.py
def _handle_write_and_execute_tool(file_path, content, timeout=300):
    """Write a Python script and immediately execute it."""
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    result = subprocess.run(
        f"python {file_path}",
        shell=True,
        capture_output=True,
        timeout=timeout
    )
    # 只返回摘要，代码留在文件里
    return f"Written {len(content.split(chr(10)))} lines to {file_path}\n" \
           f"Execution successful\n" \
           f"Output: {result.stdout[:500]}"  # 只保留前 500 字符
```

**2. 跨 agent 只传压缩结论**

```python
# coder_agent_tool.py -- context passing format
CLUES_FORMAT = "Here is clues from {}:\n\n<clues>\n{}\n</clues>\n\n"
RESPONSE_FORMAT = "Response from {}:\n\n<response>\n{}\n</response>\n\n*Please execute the next step.*"

# Coder 完成后仅把压缩结果追加到 clues
clues += CLUES_FORMAT.format("coder", response["text"])
```

**3. 统一输出格式（每 agent 共用，便于 Supervisor 解析）**

```
## Status
[SUCCESS | PARTIAL_SUCCESS | ERROR]
## Completed Tasks
- [任务 1，措辞需与 FULL_PLAN 一致以便 Tracker 匹配]
## Key Insights
- [带数字与比例的结论]
## Generated Files
- ./artifacts/chart.png -- 简述
- ./artifacts/calculation_metadata.json -- N 个计算
```

**4. Skills 按需加载（启动约 500 token，命中再读约 3K）**

```python
# 初始化：只加载目录
from src.utils.skills.skill_utils import initialize_skills
available_skills, skill_prompt = initialize_skills(
    skill_dirs=["./skills"],
    verbose=True
)
system_prompt = base_prompt + skill_prompt   # ~500 token 目录

# 运行时：命中后 skill_tool(skill_name="readme-generator") 返回完整 SKILL.md
```

**5. 自包含脚本原则（上下文才能安全丢弃上一段代码）**

```python
# WRONG -- 跨轮次引用变量，迫使旧代码留在上下文
# Turn 1: df = pd.read_csv('data.csv'); total = df['Amount'].sum()
# Turn 2: print(f"Total: {total}")   # NameError

# CORRECT -- 每个脚本自包含
import pandas as pd
df = pd.read_csv('./artifacts/cache/df_main.csv')
total = df['Amount'].sum()
print(f"Total: {total}")
```

> TODO: 文中未给出端到端延迟增益、成本下降绝对值或任务成功率对比数据；「约 95% / 约 97%」均为单点 token 降幅的自述口径，未经独立 benchmark 复核。Deep Insight 仓库地址文中未直接给出，需另行确认。

---
[← Back to Deep Dives](./README.md)
