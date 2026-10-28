---
auto_generated: true
generated_at: "2026-10-28T06:45:40Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/multi-turn-reinforcement-learning-on-amazon-sagemaker-ai-a-hands-on-guide/"
signal_type: "significant_update"
---
# SageMaker AI 多轮强化学习（MTRL）：把 Agent 训练从论文搬进托管平台 (Multi-Turn RL on Amazon SageMaker AI: A Hands-on Guide)

> 🔍 本文由 Moltbot 自动生成 | 2026-10-28
>
> **项目/工具**: Amazon SageMaker AI — Multi-Turn Reinforcement Learning (MTRL / AgentRFT)
> **链接**: https://aws.amazon.com/blogs/machine-learning/multi-turn-reinforcement-learning-on-amazon-sagemaker-ai-a-hands-on-guide/
> **核心定位**: 用「整局结果奖励 + GRPO + LoRA」训练多步 Agent，不再需要标注正确轨迹；服务端全托管，按 token 计费。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：SageMaker AI 新增的 serverless 训练能力——你只需提供「一个可被调用的 Agent 运行时 + 一个打分函数」，平台负责 rollout 采样、GRPO 更新和模型打包。
- **現在值得用嗎**：看场景。如果你有**可自动判分**的、**专有的**多步任务（内部审批流、工单分诊、私有工具链），值得做一次 smoke test；如果你只是想让通用 Agent 更聪明，不建议。
- **適合場景**：可程序化验证结果的多轮任务；把 20B 级开源模型调教成业务专用小模型；LLMOps 团队想把 RL 后训练纳入现有 SageMaker 流水线。
- **不適合場景**：无法自动判分的创意/开放式任务；预算 < $400 且想要一次跑成的实验；需要跨 Region 部署（CreateJob 直接拒绝跨 Region 运行时 ARN）；只支持 4 个基础模型。
- **與之前/竞品核心差異**：过去多轮 RL 需要自建 rollout 集群 + 轨迹存储 + 奖励服务（如 verl、SkyRL 这一路的自研栈），现在 Agent 与环境以 Python 单文件部署到 AgentCore，平台按 prefill/sample/train 三维 token 单价收费。

## 是什么 / 解决什么问题

传统微调解决的是「对单个 prompt 产出更好的回答」。但 Agent 任务是另一回事：一个报销单提交流程、一次客服工单分诊，都是一串相互依赖的动作——第 3 步该做什么取决于第 2 步的返回。官方博客的原话是：这类任务「很少有一条正确的轨迹可以模仿，唯一可靠的反馈是整条序列是否成功」。监督微调没有这种标签，而单轮 RL 无法把信用分配回三步之前的那个决策。

SageMaker AI 的 MTRL 就是针对这个信号设计的：训练服务把一条训练样本发给**你自己托管的 Agent**（AgentCore runtime，或通过 AWS Lambda forwarder 转发到 EKS / EC2 / Fargate 上的自建 Agent），Agent 在环境里跑完整个多轮交互，Episode 结束时只回报**一个 reward**。你不需要写「正确轨迹」，只需要写「怎么给结果打分」。

官方示例用 Wordle（六次机会猜五字母单词）演示。选它是因为规则少、每步依赖上一步反馈、结果客观可判。博客也明确说明：Wordle 只是教学例子，前沿模型已经玩得很好；生产上应该用 MTRL 去训练一个小而便宜的模型，做**公网模型从没训练过的企业内部流程**。

## 技术架构拆解

### 核心设计决策

- **Agent 与奖励函数同居一地**：部署到 AgentCore 的**一个 Python 文件**里同时包含环境、工具（`guess_word`）和打分逻辑。这消除了「环境在 A 服务、奖励在 B 服务」的分布式调试地狱。
- **数据集只带任务，不带答案轨迹**：每行只有一条任务描述。示例中行内容是 `{"prompt": "...", "answer": "riser", "id": "wordle_train_0000"}`，`answer` 只被环境和奖励函数读取，policy model 永远看不到。服务端**不解析** prompt 字符串，原样透传给 Agent——所以生产任务可以把完整 message list、工具配置、奖励规格全塞进去。
- **结果主导的奖励设计**：解出得 1.05–1.55（越快越高），输掉得 -0.5，一个合法猜测都没做出得 -1.5。一个小的 shaping 项只在同一档位内区分优劣（权重：解出 0.04 / 失败 0.15）。
- **GRPO + LoRA**：用同一题多次 rollout 的**奖励方差**做组内相对优化，只更新 LoRA adapter，不动基座权重。
- **Serverless 计费**：不选实例、不组集群，只按 prefill / sample / train 三个维度的 token 量付费。

### 支持模型与区域（官方声明，截至本文写作时）

| 基础模型 | 区域 |
|---|---|
| Amazon Nova 2 Lite | us-east-1, us-west-2 |
| GPT-OSS-20B | us-east-1, us-west-2 |
| Gemma 4 31B (instruction-tuned) | us-west-2 |
| Qwen 3.6 27B | us-west-2 |

选 GPT-OSS-20B 的理由很务实：四个里每 token 价格最低，而且 reasoning effort 可以按请求控制。

### 与自建多轮 RL 栈的关键差异

| 维度 | 自建（verl / SkyRL 等） | SageMaker MTRL |
|---|---|---|
| 环境接入 | 自己实现 rollout worker，写专用 Adapter | 部署一个 HTTP Agent（AgentCore 或 Lambda forwarder），返回 `{"reward": ...}` 即可 |
| 奖励粒度 | 任意（可逐 step） | 默认整局一个 reward；也可用 UpdateReward API 逐 turn 上报 |
| 训练数据 | 需组织 prompt / response / 轨迹 | 无标签，一行一个任务 |
| 基础设施 | 自管 GPU 集群、调度、权重同步 | Serverless，平台自动扩缩 |
| 计费方式 | 按 GPU 小时 | 按 prefill / sample / train token 三维计费 |
| 可观测性 | 自建日志与面板 | 强制绑定 MLflow app + CloudWatch OTel trace |
| 平台锁定 | 低 | 中（IAM、AgentCore runtime、S3 同 Region 约束） |

### 架构/信息流图

```
┌──────────────────────────────────────────────────────┐
│  SageMaker AI 训练 Job (AgentRFT)                     │
│  - 持有 policy model + LoRA adapter                   │
│  - GRPO：同题 N 次 rollout 的奖励方差做组内相对优化      │
└───────────────┬──────────────────────────────────────┘
                │ 每次 rollout 发一条训练行（含 secret word）
                ▼
┌──────────────────────────────────────────────────────┐
│  AgentCore Runtime （你自己部署的 main.py）            │
│                                                      │
│   @app.entrypoint          ← 外层：启动 HTTP 服务      │
│   @sagemaker_rft_handler   ← 内层：把 reward 回报给平台 │
│        │                                             │
│        ├─ WordleGame 环境（per-letter 反馈）            │
│        ├─ @tool guess_word(...)                       │
│        └─ final_reward()  → {"reward": 1.375}         │
└───────────────┬──────────────────────────────────────┘
                │ OpenAI-compatible 采样请求
                ▼
   SageMaker Job Runtime 端点 → policy model 生成动作
                │
                └── 循环最多 6 轮 ──→ episode 结束 → 单一 reward

    观测面：MLflow (val/reward/pass_at_1) + CloudWatch OTel trace
```

## 实用评估

### 什么场景值得用

- **有确定性判分器的内部流程**：例如内部工单分诊（分对/分错）、私有 API 调用链（最终状态对不对）、表单填写（字段是否匹配）。只要你能写一个 reward 函数，就能用这条流水线。
- **廉价小模型替代大模型**：把 20B 开源模型调教到某个窄任务上足够好，推理成本远低于调用前沿模型。官方数据就是这个思路的证明。
- **已有 SageMaker/AgentCore 基础设施的团队**：IAM、S3、MLflow、CloudWatch 已经在用的话，边际接入成本很低。

### 什么场景不值得用

- **没有自动判分的任务**：开放式写作、设计评审、创意生成——没有可靠 reward，GRPO 只会学歪。
- **Wordle 之类的公开 benchmark 已解决任务**：前沿模型早就能玩好，训练没有边际收益。
- **需要自定义训练算法**：MTRL 只暴露超参（max_steps、max_epochs、global_batch_size、group_size、sampling_max_tokens 等），不能换 PPO/DPO 或者改损失函数。
- **成本敏感的小实验**：一次 100 步训练约 $338.50（token）+ 约 $79（AgentCore 运行时），合计约 $418。官方博客还坦承「下面每一个问题都至少赔进去一次训练 run」。
- **多 Region / 复杂网络拓扑**：`CreateJob` 拒绝跨 Region 的运行时 ARN；S3 桶、训练 Job、Agent 必须在同一 Region。

### 迁移成本

从零开始参考官方 `aws-samples/sample-multi-turn-rl-wordle` 仓库：

| 事项 | 工作量估计 |
|---|---|
| Agent 改造（换成你的任务解析 / 工具 / reward） | 0.5–2 天，取决于环境复杂度 |
| IAM 两个角色（注意训练角色 trust principal 必须是 `job.sagemaker.amazonaws.com`） | 0.5 天 |
| AgentCore CLI 部署（ARM64 依赖约 700MB） | 半天 |
| smoke test 打通全链路 | 半天（**必做**，见下文踩坑） |
| 正式训练 + 评估 | 1–2 天，含配额等待 |

总体而言，**两天能跑通教学例子，一周能上第一个真实任务**——前提是 reward 设计一次对。

## 对你的意义

对 Ken 的 Agent + UI / RAG 工具链这条线，这篇博客的价值不在「Wordle」，而在它把 **RL 后训练的产品化路径**讲清楚了：训练服务的接口边界被压缩成「一个 HTTP Agent + 一个 reward 数字」。这意味着 Agent 的可测试性（能否稳定跑完一局并自评分）直接变成了可训练性。

具体建议：**观望，但立刻做一件小事**——把你现有的某个 Agent 流程改造成「可被外部调用、结束时能返回一个客观 score」的形式。这个改造本身对评估体系就有价值；等 reward 设计成熟了，接 MTRL 只是换一个 launcher。

另外三个从踩坑区抽出的、与平台无关的工程教训，值得直接记进架构笔记：

1. **训练曲线不能代表服务表现**。官方在 temperature 0 下验证，曲线峰值 48%、终点 37%；但在实际服务配置（medium effort + temperature 1.0）下解出率是 84%。原话：**「在你服务时的设置下做评估」**。这条对任何评估体系都成立。
2. **奖励设计的经典陷阱：把逐步奖励求和**。他们最初沿用 `wordle-lora-rl` 的 per-guess 打分求和，结果「输掉六轮的游戏得到 +0.49 正奖励」，而且「第一次猜中 +0.99 反而低于第三次猜中 +1.61」，因为多打几轮攒了更多 bonus。修法是**结果项主导 + 有界的 shaping**（clip 到 [-1,1]，解出权重 0.04、失败 0.15）。
3. **rollout 里的错误状态会杀死整个 Job**。任何时候都要返回 reward，哪怕是 -1.5 的地板分；返回错误状态会导致训练 Job 整体失败。

## 关键代码/配置片段

Agent 入口的装饰器顺序是最大的隐形坑（来自官方博客原文）：

```python
app = BedrockAgentCoreApp()

@app.entrypoint # outermost: starts the HTTP server AgentCore invokes
@sagemaker_rft_handler # reports the returned reward to SageMaker AI
def handle_rollout(payload):
    prompt, answer = parse_task(payload["prompt"])
    game = WordleGame(answer)

    @tool
    def guess_word(guess: str) -> str:
        """Submit a 5-letter Wordle guess and get feedback."""
        return game.guess(guess)

    agent = Agent(model=build_model(), system_prompt=SYSTEM_PROMPT, tools=[guess_word])
    agent(prompt)
    return {"reward": game.final_reward()}
```

官方明确的告警：`sagemaker_rft_handler` **本身不启动 HTTP 服务**。如果不套 `BedrockAgentCoreApp` + `@app.entrypoint`（entrypoint 必须在外层），每次调用都会在 30 秒后超时。

训练 Job 的 IAM trust policy（注意 principal 不是通用的 `sagemaker.amazonaws.com`）：

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {"Service": "job.sagemaker.amazonaws.com"},
    "Action": ["sts:AssumeRole", "sts:TagSession"]
  }]
}
```

启动训练的关键超参覆盖（`sampling_max_tokens` 调到服务上限，因为默认 4096 时 gpt-oss 常在第一次工具调用前就耗尽 token）：

```bash
uv run python run_mtrl_training.py \
  --model openai-reasoning-gpt-oss-20b \
  --agent-runtime-arn <RUNTIME_ARN> \
  --role-arn arn:aws:iam::<ACCOUNT>:role/<JOB_ROLE> \
  --train-dataset s3://<BUCKET>/wordle-mtrl/train/training-data.jsonl \
  --val-dataset s3://<BUCKET>/wordle-mtrl/validation/validation-data.jsonl \
  --s3-output-path s3://<BUCKET>/wordle-mtrl/output/ \
  --mlflow-app-arn arn:aws:sagemaker:<REGION>:<ACCOUNT>:mlflow-app/<APP_ID>
```

（launcher 内部把 `sampling_max_tokens` 设为 8192、`max_epochs` 20、`max_steps` 100。）

### 官方数据速览

| 指标 | 数值 |
|---|---|
| 训练规模 | 100 步 / 105,486 次 rollout / 12 小时 40 分 |
| Token 消耗 | prefill 491.6M、sample 159.7M、train 643.3M（共 1.29B） |
| 训练成本 | $338.50（train 维度 $231.59 占大头） |
| 运行时成本 | 约 $79 |
| 解出率（medium effort, temp 1.0） | 61% → 84% |
| 解出率（low effort, temp 0） | 15% → 69% |
| 评估成本 | 两组评估约 $1.20 token，约 1 小时 |

> 备注：以上数字均为官方博客自述的单次实验，未在第三方复现；模型名称（Nova 2 Lite、Gemma 4 31B、Qwen 3.6 27B）以 AWS 文档当前列表为准，区域可用性可能变动。

---
[← Back to Deep Dives](./README.md)
