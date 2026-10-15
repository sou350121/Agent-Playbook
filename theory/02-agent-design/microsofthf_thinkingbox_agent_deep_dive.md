---
auto_generated: true
generated_at: "2026-10-15T08:01:00Z"
source_url: "https://huggingface.co/blog/microsoft/thinkingbox"
signal_type: "significant_update"
---
# ThinkingBox：按 agent 留下的数据库终态评分，而不是按它说的话 (ThinkingBox: Grade Agents on Terminal State, Not Sentences)

> 🔍 本文由 Moltbot 自动生成 | 2026-10-15
>
> **项目/工具**: Microsoft ThinkingBox / ThinkingBox-Bench (与 Hugging Face 联合发布)
> **链接**: https://huggingface.co/blog/microsoft/thinkingbox
> **核心定位**: 一个把 AI Agent 放在"有状态业务工作流"里跑了 20 遍的沙盒与基准——评分对象是 agent 留下的后端数据终态与副作用，而不是它生成了什么句子。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：现有 eval 只看 tool call 格式和最终回复；ThinkingBox 去看 agent 改完之后数据库里到底变成了什么，并强制每个任务跑 20 遍来区分"做得到一次"和"每次都对"。
- **現在值得用嗎**：是——如果你在构建任何"会写真实记录"的 agent（退款、保险理赔、订单、预约），这个基准会把你的评估盲区直接照出来。前提是你愿意接受它的结论：你现在的 90% 成功率可能是幻觉。
- **適合場景**：有状态业务工作流的 agent 评估、模型选型（选"最稳"而不是"最强"）、给团队的 eval 体系补上"终态校验"这一层。
- **不適合場景**：无状态问答/生成任务的评估；想直接拿它当训练数据（发布的是评估用适配器，训练版本标注为 coming soon）；把它当排行榜刷分——作者明确说"有用的不是我们的 pass@1 排行榜，而是这个环境"。
- **與現有 eval（tool-call 合格率 / LLM-as-judge）核心差異**：那些方法看轨迹（trajectory），ThinkingBox 看证据（database state）。轨迹是主张，数据库状态才是事实。

## 是什么 / 解决什么问题

现有 Agent 评估几乎都停在两个代理指标上：**tool call 是否格式正确** 和 **最终回复是否听起来对**。这两个都是 proxy，不是 outcome。一个 agent 可以一边语气完美地说"您的问题已解决"，一边把工单状态写成 `solved`，而业务要求的终态其实是 `hold`（挂起待处理）。tool-call 检查器看到 9 个格式完美的调用，写库检查器看到它确实写了库，只有数据库本身"不同意"。

ThinkingBox 精确地量了这道裂缝有多大。在一组覆盖 12 个 LLM、121,680 次有效 trial 的 common-set 消融实验里，有 **79,853 次尝试未能通过可执行检查**。这些失败里，**67.24% 依然"干净地"结束了**——调用了状态变更工具、没有报任何 tool error、给了用户一个完整的回复。但可执行检查发现：**77.61%** 留下了错误字段值，**43.30%** 产生了非预期的额外副作用，**25.36%** 漏掉了必需的效果（这些发现之间有重叠）。

换句话说：一个 agent 越是"自信地错"，越容易骗过只读轨迹的评估器。ThinkingBox 的第二刀更狠——它问的不是"能不能做到"，而是"能不能每次都对"。每个任务在**全新初始化的隔离后端**上独立跑 20 遍，两次尝试之间不共享任何数据库行或缓存工具状态，这样的重复才有可比性。

## 技术架构拆解

### 核心设计决策

| 决策 | 理由 | 取舍 |
|------|------|------|
| 评分对象是终端后端状态与副作用，不是轨迹 | 轨迹是 claim，数据库是 evidence；只有留下的记录能定案 | 需要为每个任务写可执行的断言（executable checks），构建成本高 |
| 每个任务跑 20 遍、每遍独立后端 | 一次成功 ≠ 可靠；"做得到"和"每次都对"是两个问题 | 评估成本 ×20，需要耐心与算力 |
| 三种指标分开报：pass@1 / pass@20 / observed 20/20 | 三个数回答三个不同问题（平均表现 / 广度 / 稳定性），避免用一个数掩盖真相 | 报告更复杂，非专业读者容易只看 pass@1 |
| 副作用提取器 + 确定性 judge | 接受任何能产出正确结果的轨迹，只拒绝"错的/漏的/多的"副作用 | 对无法用干净数据库值表达的需求（如"是否披露了不保证"）需额外的二值 rubric |
| 信任边界分离 | 模型只看得到任务、对话、tool schema；golden state、断言、评分内部逻辑、凭证都在评估器一侧 | 需要严格的沙盒隔离，工程复杂度上升 |
| 失败签名确定性归类 | 让结论可行动——诊断出"是工具处理问题不是推理问题" | 是每模型的未加权平均 + 可观测标签，非唯一因果解释 |

### 与前版/竞品的关键差异

| 维度 | 典型 Agent 评估（tool-call / LLM-judge） | ThinkingBox |
|------|----------------------------------------|-------------|
| 评分对象 | 轨迹（tool call 格式、回复措辞） | 终端后端状态 + 副作用（数据库实际内容） |
| 可靠性度量 | 单次运行得分 | 20 遍独立运行：pass@1 / pass@20 / observed 20/20 |
| 失败可见性 | 干净结束即视为成功 | 干净结束仍可能失败，专门检测"沉默的错误" |
| 任务来源 | 多为无状态问答 | 507 个有状态业务工作流（零售/车险/旅行/数字银行/咨询） |
| 隔离性 | 常共享状态或缓存 | 每次尝试全新隔离 MCP session，无共享行/缓存 |
| 可复现性 | 常不可验证 | runs 锁定框架 commit + 数据 release + bundle hash，结果可验证 |

### 架构/信息流图

```
        每个任务定义（起点状态 + 用户目标 + 可用 MCP 工具 + 域策略 + 可执行断言）
                                    │
                                    ▼
        ┌───────────────────────────────────────────────┐
        │  隔离的 MCP tool session（每次尝试全新初始化）    │
        │  ┌─────────┐   ┌──────────────┐  ┌──────────┐  │
        │  │  Agent  │◄─►│  模拟用户     │  │  MCP 工具 │  │
        │  │ (被测)  │   │ (私有上下文，  │  │ (写后端)  │  │
        │  └────┬────┘   │  被问才释放)  │  └────┬─────┘  │
        │       │        └──────────────┘        │        │
        └───────┼─────────────────────────────────┼───────┘
                ▼                                 ▼
        轨迹（claim，不作为评分主依据）      后端终态 + 副作用（evidence）
                                                  │
                    ┌─────────────────────────────┘
                    ▼
        ┌───────────────────────────┐
        │ 副作用提取器 + 确定性 judge  │  → 接受任何得到正确结果的轨迹
        │ (477/507 仅看状态；30 条加   │  → 拒绝 错误 / 缺失 / 额外 副作用
        │  二值 rubric 判语义)         │
        └──────────────┬────────────┘
                       ▼
        重复 20 遍 ─► pass@1 | pass@20 | observed 20/20
```

## 实用评估

### 什么场景值得用

- **你要给"会写真实记录"的 agent 做模型选型**：基准直接把"最强模型"和"最可靠模型"拆开了。Claude Opus 5.5 总体 pass@1 领先（67.16%，比 Opus 5 高 0.66 个点），但两者在"20/20 全对"的任务数上**完全相同，都是 241 个**——多出的半个点准确率，一点可靠性都没换来。
- **你想给自己的 eval 体系补"终态校验"层**：作者给的最实操建议是——去抓一个"干净结束却失败"的 run，看数据库到底变了什么，这会重定义你的评估在量什么。
- **你需要区分"广度"和"稳定性"**：Kimi-K3 是覆盖面最广的模型（至少解出一次 93.89%，即 507 中的 476 个；零售域 82.24% pass@1，领先所有闭源），但它也是**最不稳定**的之一——只有 68/507（13.41%）任务 20 遍全对。Claude Opus 5 正好相反：至少解出一次的比例更低（79.09%，106 个任务完全解不出），但 47.53% 的任务**每一遍都对**。选谁取决于你的业务是"偶尔做到就够"还是"必须每次都对"。

### 什么场景不值得用

- **无状态问答 / 纯生成任务**：这套环境的全部价值来自"有状态"——没有真实记录被改，就没有终态可评。
- **想直接拿它做 RL 训练**：发布的是**面向评估**的适配器（evaluation 用途），训练用场景被作者标注为 "coming soon"（`microsoft/thinkingbox-training`）。别把评估集当训练集用。
- **当成一个新排行榜**：作者自己泼冷水——"有用不是我们的 pass@1 排行榜，而是这个环境"。基准确立的是方法论，不是名次。
- **小算力快评**：20 遍 × 507 任务 × 3 个模型端点（agent / 模拟用户 / judge，可共用一个端点）+ Typesense 30.1 + Docker + MCP servers，这是一套要自己搭的完整系统，不是一次 API 调用。

### 迁移成本

从现有 eval 迁移到 ThinkingBox 不是"改个 endpoint"，而是一次体系升级：

1. **环境搭建**：Python 3.11+ / uv / Docker；`uv sync` 拉 OpenEnv 的 thinkingbox_env，checkout `microsoft/thinkingbox-data` 到 `thinkingbox-bench-v1.0`，`uv tool install` 装 `tb` CLI。
2. **起三个服务**：Typesense 30.1（Docker）、Session Proxy + MCP servers（`tb mcp-start`）、OpenEnv server（`OPENENV_TB_CONFIG=... uv run ... server`）。
3. **确认就绪**：`curl http://127.0.0.1:8000/ready` 返回 503 直到其可观测数据/配置/Session Proxy 检查通过（注意它**无法**观察 Typesense 或探活每个模型端点，需自行确认）。
4. **配置模型端点**：agent、模拟用户、judge 三个角色，最简单是共用一个 endpoint。
5. **跑一次评分**：`thinkingbox-eval one_task.yaml --config ... --repeat 1 --message-timeout 1800`。

工作量评估：熟悉容器 + MCP 的工程师，半天到一天能跑通单任务；要接入自有模型并得到合规的 canonical 结果（需处理 errors sidecar 里的系统错误，作者将系统错误计为不成功 trial），则需要更多调试。**注意**：全部任务都是**合成重建**（synthetic reconstruction）——工作流与策略模拟真实企业 agentic 模式，客户不是真人。

## 对你的意义

如果你正在做 Agent + UI / RAG 工具链这类"最终要落到真实记录"的产品，ThinkingBox 给了两个可以直接搬用的东西，比排行榜更有价值：

1. **"终态校验"作为独立评估层**。你现有的 eval 大概率还在看 tool call 和回复质量。加一层"改完之后后端到底变成什么"的确定性断言——哪怕只是几个字段的比对——就能照出那 67% "干净结束却错误"的沉默失败。
2. **报一个重复指标并定义它**。作者的原话：报一个 repeat metric，并说清楚你报的是 best-of-k 还是 every-of-k、怎么算的。对任何写真实记录的 agent 来说，"每次都对"（observed 20/20 那类）才是有意义的可靠性数字。

**是否跟进**：值得。短期建议是**先复现一个任务**——按 `Run it yourself` 用你自己的模型跑通一个 retail task，亲眼看一下失败签名（下面那段）。它给你的不是"用哪个模型"的答案，而是"我的 eval 一直量错了什么"的认知。这类方法论层面的补课，比多接一个框架更值钱。

## 关键代码/配置片段

ThinkingBox 的失败签名给出了最有行动价值的诊断（来自论文 Table 5 的消融，是每模型份额的未加权平均，非唯一因果解释）：

```
失败签名        占失败比例
Tool usage      79.9%   ← 约五分之四的失败是"工具处理"，不是"推理"
Wrong state updates    10.3%
Incomplete user resolutions  7.0%
No state-changing action     2.9%
```

作者对这条结论的解读：agent 通常**跑得够远、能发起工作流，然后栽在**"从 tool error / 前置条件失败 / 空查询结果里恢复"上——**这是重试与错误恢复问题，早于它是个模型问题**。对应的三条工程建议（作者注明未在本基准上测量过提升幅度）：

```
1. 在 commit 之前校验终态，而不是信任模型对终态的描述
2. 对工具错误与系统错误分类，让重试只针对可恢复的那一类
3. 把工具面裁剪到工作流真正需要的范围
4. 对无法低成本回滚的变更，强制人工审批
```

环境搭建（作者给出的完整命令，Linux/WSL + Python 3.11+ + uv + Docker）：

```bash
# 1. OpenEnv + ThinkingBox 环境
git clone https://github.com/huggingface/OpenEnv
cd OpenEnv
uv sync --project envs/thinkingbox_env --frozen

# 2. 可执行基准（锁定到 pinned release）
git clone https://github.com/microsoft/thinkingbox-data
git -C thinkingbox-data checkout thinkingbox-bench-v1.0

# 3. ThinkingBox CLI（提供 tb 命令）
uv tool install "thinkingbox @ git+https://github.com/microsoft/thinkingbox"

# 起 Typesense 30.1
docker run --rm -d --name thinkingbox-typesense \
  -p 8108:8108 -v "$PWD/.typesense-data:/data" \
  typesense/typesense:30.1 \
  --data-dir /data --api-key=Fake --enable-cors
until curl -fsS http://127.0.0.1:8108/health; do sleep 1; done

# 起 MCP servers + Session Proxy
cd OpenEnv
tb mcp-start --host 127.0.0.1 --port 7111 \
  --servers "$PWD/thinkingbox-data/servers/servers.yaml"
curl -fsS http://127.0.0.1:7111/health

# 起 OpenEnv server（需先写 thinkingbox.yaml 指定三个模型）
OPENENV_TB_CONFIG="$PWD/thinkingbox.yaml" \
  uv run --project envs/thinkingbox_env --frozen server

# 就绪检查 → 评分一个 episode
curl -sS http://127.0.0.1:8000/ready
echo "- sandbox_external_retail_group1.py:test_case_ST002_001" > one_task.yaml
uv run --project envs/thinkingbox_env thinkingbox-eval \
  one_task.yaml --config "$PWD/thinkingbox.yaml" \
  --output results.jsonl --errors-output errors.jsonl \
  --repeat 1 --message-timeout 1800
```

评分口径参考（ThinkingBox-Bench，pass@1 %，task-weighted，507 任务）：

| 模型 | Retail (98) | Auto insurance (100) | Travel (104) | Neobank (104) | Consulting (101) | 总体 (507) |
|------|------------|---------------------|-------------|--------------|-----------------|-----------|
| Claude Opus 5.5 | 80.97 | 68.40 | 54.28 | 71.25 | 61.58 | **67.16** |
| Claude Opus 5 | 80.71 | 65.80 | 49.95 | 70.62 | 66.19 | 66.50 |
| GPT-5.4 | 76.33 | 62.65 | 68.12 | 65.34 | 54.60 | 65.36 |
| GPT-5.6 Sol | 67.65 | 65.30 | 60.34 | 59.09 | 57.52 | 61.91 |
| Claude Sonnet 4.6 | 72.35 | 54.40 | 58.94 | 56.39 | 54.31 | 59.19 |
| GPT-6 Astra | 71.73 | 46.55 | 55.87 | 60.87 | 56.83 | 58.31 |
| Kimi-K3 (开源) | **82.24** | 50.80 | 61.83 | 41.35 | 51.63 | 57.37 |
| Qwen3.8-27B (开源) | 64.03 | 47.85 | 53.41 | 47.88 | 45.69 | 51.70 |
| DeepSeek-V4-Pro (开源) | 68.21 | 29.65 | 43.13 | 44.86 | 31.04 | 43.26 |
| Claude Opus 4.6 | 68.62 | **8.30** | 21.11 | 35.67 | 27.82 | 32.09 |

> 注意域差异：Claude Opus 4.6 在零售域拿到 68.62%，在车险域只有 8.30%。跨模式平均后的零售域 pass@1 为 59.52%，车险域仅 33.83%。

**稳定性（20 遍全对）**：GPT-6 Astra 保留 78% 的单次成绩，Claude Opus 5.5 与 Claude Opus 5 各保留 71%；最差一端 GLM-5.1、Kimi-K2.6、DeepSeek-V4-Pro 各只剩约 8%。

**成本维度的两个 frontier（作者口径）**：cost per successful task attempt 上，GPT-5.6 Sol 最低（$0.127/次成功尝试），GPT-5.4 多 $0.004 换 +3.45 个点，Claude Opus 5.5 再多 $0.276/次。Claude Opus 5 是反面案例：$0.475/次成功尝试，比 Opus 5.5（$0.276 / 67.16%）**又贵又更差**。作者强调这是"比较用效率指数，不是账单，也不是生产单次请求价格"。

> TODO: 成本数据基于 2026-09-20 的 OpenRouter 快照（Opus 5.5 按 Anthropic 官网定价），实际部署成本需按自身 provider 与折扣重算。

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-004: 推理模型在 Agent 任务展现持续优势 | 支持 | 推理能力强的模型（Claude Opus / GPT 系列）确实在 pass@1 上领先；但基准同时指出，头部推理模型之间的"半个点"进步（Opus 5→5.5）**未转化为任何可靠性提升**（20/20 任务数持平 241），提示"更强推理"≠"更可用"，为假设加了一个重要的限定条件 |

---
[← Back to Deep Dives](./README.md)
