---
auto_generated: true
generated_at: "2026-11-26T05:46:08Z"
source_url: "https://www.together.ai/blog/qwen4-max"
signal_type: "significant_update"
---
# Qwen4-Max 单调用吞下整个仓库修 bug — 65 万 token「无检索直读」路线值得押注吗？ (Qwen4-Max on Together AI: One 652K-Token Call, No Tools, No Retrieval)

> 🔍 本文由 Moltbot 自动生成 | 2026-11-26
>
> **项目/工具**: Qwen4-Max（阿里巴巴旗舰模型）· Together AI Serverless Inference
> **链接**: https://www.together.ai/blog/qwen4-max
> **核心定位**: 用一次 65 万 token 的整仓库输入 + 纯 bug 描述，在没有工具、没有检索的前提下产出能被上游维护者回归测试接住的补丁——这次更新真正要回答的问题是：长上下文能不能替代 Agent 检索脚手架？

## 快速判断

- **一句話定位**：Qwen4-Max（2.4T 参数 MoE，71B 激活/ token）上线 Together AI，官方演示「整仓库丢进去 → 只描述症状 → 直接出补丁」，单次 69 美分。
- **現在值得用嗎**：看场景。当你的问题是「局部修补一个症状明确、可在上下文内读完的中型仓库」，值得一试；当是跨模块重构或需要运行测试反馈的任务，仍应回到带工具的传统 harness。
- **適合場景**：中型代码库（数十万 token 量级）的根因定位、可解释性强的 patch 生成、一次性代码审计、离线仓库问答。
- **不適合場景**：需要执行/验证的迭代任务、超大单体仓库（超出 1M token）、对成本极度敏感的高并发调用、需要微调定制的场景（目前 serverless only，不支持微调）。
- **與前版/竞品核心差異**：这不是「更好的补全」，而是把「检索+多轮工具」压缩成「一次超长上下文推理」，且官方声称 Qwen4-Max 比 Qwen3.8-Max 少用 35% token、单任务成本低约 60%（阿里巴巴自报数据）。

## 是什么 / 解决什么问题

Qwen4-Max 是阿里巴巴在 2026-11-16 发布的旗舰模型，官方定位是「Qwen 家族迄今最强」，明确瞄准**长程 agent 工作**，包括大规模仓库上的编码任务。Together AI 在 2026-11-26 上线该模型（serverless），并用一个可复现的案例做背书。

这个案例解决的是一个真实的工程疲劳点：当下的主流 Agentic Coding 依赖「检索相关文件 → 多轮工具调用 → 跑测试 → 再改」这一套脚手架。脚手架本身是复杂度来源——检索召回失败、工具调用陷入循环、上下文拼装出错，都会让任务失败，而且失败原因难以归因。Qwen4-Max 的演示走了另一条路：**不做检索、不给工具，把整个 checkout 直接塞进上下文，让模型自己在大海捞针。**

这不是单纯的 benchmark 秀。演示选的是 Tornado（Python web 框架）一个由维护者在 2026-11-18 提交、并且**带有维护者自己写好的回归测试**的真实 bug——评审基准是上游测试，而不是厂商自拟的评价标准。这一点值得单独记一笔：判卷人是项目维护者，不是模型厂商。

## 技术架构拆解

### 核心设计决策

- **长上下文替代检索**：344 个文件、652,519 token 一次性作为 system message 输入；模型侧不给任何文件筛选提示，全部 `git ls-files` 追踪的文本文件原样灌入。
- **症状式输入**：bug report 只描述现象（连接关闭时未 await 的 `write_message()` 会在 ERROR 级别打 "Task exception was never retrieved"），不提供文件名、不给堆栈位置，刻意剥夺「人肉检索」的先验线索。
- **思考默认开启**：reasoning 走 `delta.reasoning` 流式输出，思考 token 计入 output 价格；简单请求可用 `reasoning={"enabled": False}` 关闭，硬问题用 `reasoning_effort: "max"` 加码。
- **仅允许流式调用**：Together 侧对 Qwen4-Max 只接受 `stream: true`，否则返回 400 `streaming_required`。这是平台级约束，不是模型能力问题，但会直接卡住一批同步调用的老代码。
- **自动 prompt 缓存**：重复发送同一仓库时，缓存命中让首 token 从 54s 降到 8s，输入成本从约 66 美分降到约 3 美分——这把「整仓库塞上下文」从一次性奇观变成了可持续的工作流。
- **MoE 稀疏结构**：2.4T 总参数，每 token 激活 71B。这是让「1M 上下文 + 低单 token 边际成本」在商业上成立的结构性前提。

### 与前版/竞品的关键差异

| 维度 | 传统 Agentic Coding（检索 + 工具 + 测试循环） | Qwen4-Max 演示路线 |
|------|------------|------------|
| 输入方式 | 检索召回的少量文件 + 多轮补充 | 整个仓库一次入档（652,519 token） |
| 工具依赖 | 文件搜索、编辑器、测试运行器、shell | 零工具 |
| 轮次 | 多轮迭代，每轮都有人/agent 判断 | 单次请求，72 秒一次生成 |
| 失败归因 | 难（检索错？工具错？推理错？） | 相对清晰（单次推理链路） |
| 成本结构 | 多轮 token 累计 + 工具开销 | 单次 69 美分（促销价），列表价 98 美分；重复调用约 3 美分 |
| 首 token 延迟 | 每轮短，但轮数多 | 首 token 54s（冷）/ 8s（缓存命中），总时长 72s |
| 与前代对比 | — | 阿里自报：对比 Qwen3.8-Max，高推理档少用 35% token，单任务成本约低 60%，Work360 基准综合更优 |

### 架构/信息流图

```
+-------------------------------------------------------------+
|  git ls-files  -->  全部文本文件（跳过二进制/非 UTF-8）        |
|        344 files / 652,519 tokens                            |
+-------------------------------------------------------------+
                        |
                        v  (system message)
+-------------------------------------------------------------+
|  user message: bug_report.md（只描述症状，无文件/堆栈）        |
+-------------------------------------------------------------+
                        |
                        v
+=============================================================+
|  Qwen4-Max (2.4T MoE, 71B active, 1M ctx, thinking on)       |
|       - 自行定位 WebSocketProtocol13.write_message           |
|       - 自行检索到 tornado/iostream.py 的同类先例             |
|       - 生成 patch + 解释                                     |
+=============================================================+
                        |
                        v  stream=True（唯一支持的调用方式）
+-------------------------------------------------------------+
|  patch: 为 task 挂 add_done_callback(_mark_retrieved)         |
|         -> 未 await 时不再报 "Task exception was never       |
|            retrieved"；仍 await 的调用方仍拿到 WebSocketClosedError |
+-------------------------------------------------------------+
                        |
                        v
+-------------------------------------------------------------+
|  验证: 维护者写的 2 个回归测试 -> 均通过                       |
|        Tornado 全量 1,673 个测试 -> 0 失败                     |
+-------------------------------------------------------------+
```

## 实用评估

### 什么场景值得用

- **症状明确、原因隐蔽的中型仓库修补**：当 bug report 能写成「用户可观察到的现象」，而根因藏在调用链深处时，这正是长上下文 + 代码先例检索的强项——演示里模型主动找到 `tornado/iostream.py` 中 `BaseIOStream.write` 的同类处理方式，而这层关联 bug report 从未提及。
- **一次性代码审计 / 仓库级答疑**：不需要迭代，只要「读完全部代码回答一个问题」，单位经济性很可观（约 1 美元一次全库读取，重复读取降到几分钱）。
- **离线/受限环境下的编码辅助**：没有可用的检索基础设施、也不方便跑工具链时，「纯上下文推理」是可行的兜底路径。
- **风格一致性要求高的仓库贡献**：演示中 patch 之所以「看起来像项目自己的代码」，是因为模型找到了项目内部已有的同类先例——这对有强内部惯例的代码库尤其有价值。

### 什么场景不值得用

- **需要执行反馈的任务**：这次演示是一次成功，但它不会跑测试、不会看失败、不会自己重试。任何需要「改 → 测 → 再改」的任务，仍应使用带工具的 harness。
- **超出 1M token 的仓库**：上下文窗口是硬边界，且 65 万 token 已让首 token 延迟达到 54 秒。更大的单体仓库在这一路线下不可行。
- **高并发、低延迟的生产调用**：冷启动 54 秒首 token + 流式强制，对在线产品是硬伤。
- **需要微调或专用端点**：Together 侧目前 serverless only、不支持 fine-tuning；有私有数据适配需求的项目应等 Qwen4 系列的开源小模型（阿里称会跟进）。
- **把单例当统计结论的决策场景**：Together 明确说明「这是选取的一个例子」，用来展示单次调用能做什么、花多少钱，**不是 benchmark**。据此推断模型在 SWE-bench 类任务上的成功率是过度外推。

### 迁移成本

- **从同步调用迁移**：必须改为 `stream=True`，否则直接 400。SDK 层是一行改动，但任何封装了「一次性返回」的服务层都需要重构解析逻辑。
- **从检索式 Agent 迁移**：不是替换，而是**新增一条路径**。合理的做法是在 harness 里加一个「全库直读」分支，用 token 预算和仓库体积作为路由条件，而不是整体切换。
- **成本前置评估**：整库输入的成本与仓库 token 数线性相关。列表价 $1.50/1M 输入意味着一个 65 万 token 仓库的单次冷调用约 1 美元——必须配合缓存命中率来算账，否则高并发场景会失控。
- **安全审查**：官方示例脚本明说会发送所有 git 追踪的文本文件，**要求先检查仓库里有没有 secrets**。这一步在企业环境里通常意味着需要一套脱敏流水线，成本容易被低估。

## 对你的意义

如果 Ken 的团队在做 VLA 研究代码库（训练脚本 + 环境封装 + 评测 harness，规模通常在几万到几十万 token），这条路线实际上比通用 Agentic Coding 更贴切：**研究代码的耦合度极高，检索式工具最容易漏掉「看起来无关但定义了约定」的文件**——比如调度器里一个默认参数、或者环境封装里未成文的状态假设。整库直读天然规避了召回失败。

具体建议：**观望 2-4 周再用于生产，但本周就可以做一次小规模验证**。找一个已知的、已有回归测试的真实 bug，用整库直读跑一次，对照「传统检索 harness 能否解出」。关键观察三个数字：首 token 延迟、缓存命中后的边际成本、以及补丁是否被已有测试接住。如果第二三次调用能稳定落在「缓存命中 → 3 美分、8 秒首 token」，这条路就具备做常驻工具的资格。

另一点值得留意的是范式信号：当「上下文足够长」让检索环节变得可选，Agent 架构的复杂度重心就会从「检索与工具编排」下移到「上下文工程与预算路由」。这对我们自己的系统设计有直接借鉴——长上下文不是免费午餐，它把复杂度从工程层搬到了成本层。

## 关键代码/配置片段

来自 Together AI 官方 blog 的真实示例（整库单调用）：

```python
import subprocess
from pathlib import Path

from together import Together

repo = Path("tornado")
bug_report = Path("bug_report.md").read_text()

# Every file git tracks, skipping the ones that aren't text
names = subprocess.check_output(
    ["git", "-C", str(repo), "ls-files"], text=True
).splitlines()
files = []
for name in names:
    try:
        files.append(f"=== FILE: {name} ===\n{(repo / name).read_text()}\n")
    except UnicodeDecodeError:
        continue

client = Together()

stream = client.chat.completions.create(
    model="Qwen/Qwen4-Max",
    messages=[
        {
            "role": "system",
            "content": f"This is a complete repository, {len(files)} files.\n\n"
            + "".join(files),
        },
        {
            "role": "user",
            "content": f"Here is a bug report.\n\n{bug_report}\n\n"
            "Explain the cause, then write a patch.",
        },
    ],
    stream=True,
)

for chunk in stream:
    if not chunk.choices:
        continue
    delta = chunk.choices[0].delta
    # delta.reasoning carries the model's thinking, delta.content the answer
    if delta.content:
        print(delta.content, end="", flush=True)
```

模型生成的补丁核心改动（原文引用）：

```diff
- return asyncio.ensure_future(wrapper())
+ task = asyncio.ensure_future(wrapper())
+
+ # Awaiting the returned Future is optional, so an error nobody looks
+ # at must not be reported as "Task exception was never retrieved".
+ # Retrieving it here leaves it in place for callers that do await.
+ def _mark_retrieved(t: "asyncio.Task[None]") -> None:
+     if not t.cancelled():
+         t.exception()
+
+ task.add_done_callback(_mark_retrieved)
+ return task
```

关键配置点：

- `stream=True` 强制（否则 400 `streaming_required`）
- 关闭思考：`reasoning={"enabled": False}`；加大思考：`reasoning_effort="max"`
- 定价（列表价）：输入 $1.50 / 1M，输出 $4.50 / 1M，缓存输入 $0.075 / 1M；2026-11-22 前 7 折（$1.05 / $3.15 / $0.0525）。思考 token 按 output 计价。
- 上下文：1M token。仅 serverless，不支持微调。

> TODO: 未在 Together blog 中找到 Qwen4-Max 在公开编码 benchmark（如 SWE-bench 系列）的独立验证分数；阿里 Work360 对比数据为厂商自报，需第三方复现。

---
[← Back to Deep Dives](./README.md)
