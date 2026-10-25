---
auto_generated: true
generated_at: "2026-10-25T08:00:56Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/announcing-new-ways-to-customize-models-with-sagemaker-ai-without-managing-gpus/"
signal_type: "blog_post"
---
# SageMaker AI 训练会话 GA：自己写 Post-Training 循环，不碰 GPU 集群 (SageMaker AI Training Sessions GA: Write Your Own Post-Training Loop Without Managing GPUs)

> 🔍 本文由 Moltbot 自动生成 | 2026-10-25
>
> **项目/工具**: Amazon SageMaker AI — Serverless Model Customization / Training Sessions
> **链接**: https://aws.amazon.com/blogs/machine-learning/announcing-new-ways-to-customize-models-with-sagemaker-ai-without-managing-gpus/
> **核心定位**: 把 Post-Training 长期存在的「算法自由 vs 免运维 GPU」二选一拆开——你写 `forward_backward()` / `optim_step()` / `sample()` 组成的训练循环，AWS 负责 GPU 分配、分布式执行、容错与 checkpoint。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**：SageMaker AI 的 Serverless Model Customization 新增 Training Sessions API 并 GA，抽象边界从「算法」下移一层到「算力」——算法你自己写，GPU 不用你管。
- **现在值得用吗**：看你是否卡在「标准 recipe 表达不了我的 loss / reward / 多轮 rollout」这个点上；只是跑一次标准 SFT 的话，用不着。
- **适合场景**：多轮 RL / RLVR 的 agent 模型自训、自定义 reward 与 advantage 估计、非标准 loss 的偏好优化、需要把现有 `forward_backward` 风格代码搬上云的团队。
- **不适合场景**：追求极致单 token 成本的大规模预训练、需要完全自控 kernel 与硬件拓扑的团队、对供应商绑定敏感的场合。
- **与 SageMaker Training Jobs 核心差异**：同样「完全控制」，但 Training Jobs 要你选 instance type、自己扛集群；Training Sessions 按 token 计费、无需集群、没有 idle GPU 成本。

## 是什么 / 解决什么问题

AWS 这次的痛点描述很直接：企业真正从 AI 拿到结果，靠的不是开箱即用的 foundation model，而是用 RL 等 post-training 技术定制开源权重模型。但定制化的门槛在基础设施——要选对技术路线、架好并管理 GPU 集群；做 agent 还得额外搭建多轮 RL 的环境。

在此之前，SageMaker AI 的 Serverless Model Customization 已经提供「托管的」多轮 RL：你选模型、给数据和超参数，服务掌控算法。问题在于客户反馈想要自己定义 loss function、自己塑形 reward signal、自己把多个 RL 阶段串成一个循环。于是只能二选一：接受托管版本的算法限制，或者退回 SageMaker Training Jobs / HyperPod 自扛运维。

Training Sessions 切出了第三条路：**抽象掉 compute，而不是抽象掉 algorithm**。官方原话是「you write and coordinate the training loop, including custom loss functions or reward signals. SageMaker AI handles GPU allocation, distributed execution, fault recovery, and checkpoint storage」。

支持的训练技术包括 SFT、DPO、RLVR、RLAIF、multi-turn RL，更新粒度可选 LoRA 或全参数微调，并可通过 continuous customization 把多个技术串起来。这一点对做 agent 模型的团队尤其重要——RLAIF 与 RLVR 都需要在训练循环里插入自己的 verifier，而托管 recipe 恰恰在这里最不灵活。

## 技术架构拆解

### 核心设计决策

- **抽象边界下移一层**：不是把整个训练 job 包成黑盒（托管 recipe），也不是让你碰 instance / cluster config（Training Jobs），而是把最小 GPU 原语暴露成 API。
- **按 token 计费而非按小时的 GPU 保留**：官方明确说「The meter stops while your reward function scores a batch in your environment, and there is no capacity to reserve」。reward 函数在你本地跑的这段时间不计费。
- **你的代码在你自己环境跑**：训练循环、reward 函数、agent 与工具/模拟器的连接都在你的环境里；session 只承担 GPU 重的部分（sampler 生成响应，trainer 算梯度并更新权重）。
- **数据与模型留在自己的账号**：每个 session 使用你自己创建的 IAM execution role，可选 AWS KMS key 与 VPC 配置，数据与 checkpoint 落在你指定 Region 的 S3 桶里，官方声明不用你的数据或定制权重训练其他模型。
- **模型清单收敛**：GA 首发支持 `gpt-oss-20b`、`gemma-4-31B-it`、`Qwen3.6-27B`、`Qwen3.8-27B` 四个开源权重模型——这既是可用范围，也是当前最硬的限制。

### 与前版/竞品的关键差异

| 维度 | SageMaker Training Jobs / HyperPod | 托管 Serverless Recipe | Training Sessions（本次 GA） |
|------|------------|------------|------------|
| 算法控制 | 完全自由 | 由服务掌控 | 完全自由（自写 loss / reward / 循环） |
| 基础设施 | 你选 instance、管集群 | 免运维 | 免运维（GPU 分配、分布式执行、容错、checkpoint 均由 AWS 处理） |
| 计费方式 | 按实例小时（含 idle 成本） | 按 token / 任务 | 按 token 处理量；reward 评分期间停表 |
| 多轮 RL agent 环境 | 自己搭 | 托管支持 | 自己写循环 + 自己接环境，session 提供原语 |
| 交互式调试 | 提交 job 后等 | 不支持 | 有状态 live session，可逐 step 驱动 |

### 架构/信息流图

```
你的环境（notebook / IDE / 本地）
 ┌───────────────────────────────────────────────┐
 │ 训练循环（你写）                              │
 │   1. sample()      ──► 请求 sampler 生成多个响应 │
 │   2. reward/verifier 在你的环境打分（不计 GPU 时间）│
 │   3. forward_backward() 算梯度                │
 │   4. optim_step()   应用更新                  │
 │   5. save_weights_for_sampler() 刷新采样端权重  │
 └───────────────┬───────────────────────────────┘
                 │  API 调用（有状态 session）
 ┌───────────────▼───────────────────────────────┐
 │ SageMaker AI Training Session（AWS 侧）       │
 │  · GPU 分配 / 分布式执行 / 故障恢复            │
 │  · checkpoint 写入你的 S3                      │
 │  · IAM role + 可选 KMS + 可选 VPC              │
 └───────────────────────────────────────────────┘
```

官方用 GRPO 举例说明一轮循环：生成若干响应 → 你的 reward function 用 verifier / reward model / test harness 打分 → 分数回传给 trainer，`forward_backward()` 算梯度、`optim_step()` 更新权重 → 通知 session 用新权重刷新 sampler，进入下一批。这个流程与 TRL、verl 等开源 RL 框架的心智模型基本一致，迁移时主要改的是原语调用名而不是算法逻辑。

## 实用评估

### 什么场景值得用

- **多轮 agent 模型的 RL / RLVR 自训**：需要自己定义 reward shaping、自己控制 rollout 终止条件，托管 recipe 表达不了时，这是最现实的低运维选项。
- **已有自研训练循环、但不想管集群的团队**：把 `forward_backward` 风格的代码接上 session 原语，比自建分布式栈的工程量小一个数量级。
- **成本需要可预测的实验**：按 token 计费、无 idle 成本，让「数据量 × 生成量」直接对应账单，实验间横向比较更干净。
- **需要交互式调试 reward 的时刻**：有状态 session 支持逐步驱动，比「提交 job → 等 → 看日志」的反馈回路短得多。

### 什么场景不值得用

- **只需要标准 SFT / DPO 一次**：托管的 serverless recipe 已经够用，写自定义循环是纯增成本。
- **需要完全自控 kernel 与硬件拓扑**：抽象掉 compute 意味着你也失去了对互连、NUMA、调度策略的控制权，这在大规模预训练里是硬伤。
- **模型不在首发清单内**：目前只有 `gpt-oss-20b`、`gemma-4-31B-it`、`Qwen3.6-27B`、`Qwen3.8-27B`，自研 tokenizer 或特殊架构模型的可用性待确认。
- **对供应商绑定敏感**：训练循环、checkpoint 格式、计费单元全都长在 AWS 上，迁出成本不能低估。

### 迁移成本

- **从 Training Jobs 迁移**：算法代码基本不动，但要重写基础设施相关部分——去掉 instance 选择、分布式启动配置、checkpoint 路径管理，改为 session 客户端的原语调用。主要工作量在 reward / 环境接口的对齐。
- **从 TRL / verl 迁移**：训练循环结构与 GRPO 实现思路一致，但 GRPO 之外的算法（如自定义 advantage 估计）需要逐个核对原语是否够表达。
- **入门路径**：在 IDE 里装 SageMaker Python SDK（官方要求 Linux 或 macOS、Python 3.10–3.12）并 clone cookbook；或在 SageMaker Studio 里 20 秒内拉起环境，接 Kiro / Claude Code / Codex / GitHub Copilot 后下载 agent skills 与 cookbook。

> TODO: 官方未在此文给出 benchmark 数据、token 单价与吞吐 SLO，具体成本需以正式定价页为准。

## 对你的意义

对 Ken 的两条线来说，这条的价值不在「又一个云训练服务」，而在**重心发生了位移**：AWS 把「agent 模型的后训练」当成一等公民来建抽象，而不是把训练当成通用算力租赁。这背后是一个判断——agent 的差异化来自数据、工作流、评估标准如何塑造模型行为，而这些只能在自定义循环里表达。

对触觉 + VLA 方向，短期不必迁移：VLA 的微调大多在自有 GPU 上进行，且对 kernel 级控制有需求，Training Sessions 的抽象层反而会挡住路。真正值得抄的是它的**接口设计哲学**——把「算力」原子化为 `sample` / `forward_backward` / `optim_step` 三个原语，让你的训练脚本与算力来源解耦。这套原语划分可以直接借到自建 RL 训练框架的抽象层里，换来的是「换集群不改算法代码」。

对 AI 应用侧，如果你们的 agent 走多轮工具调用路线（多轮 RL 是明确的演进方向），现在多了一个「不用先建 RL 基础设施」的起步选项。建议做法：先用 cookbook 里的 GRPO 例子在 `gpt-oss-20b` 上跑通一个 toy 任务，验证 reward 接口的手感，再决定要不要把自己的环境接进来。不要一上来就迁移生产管线。

## 关键代码/配置片段

官方用 GRPO 描述的一轮循环（伪代码，按博文步骤整理）：

```
loop:
    responses = session.sample(prompt, n=group_size)   # sampler 生成多个响应
    scores    = reward_fn(responses)                   # 你的环境打分，此段不计 GPU 时间
    session.forward_backward(scores)                   # 算梯度
    session.optim_step()                               # 更新权重
    session.save_weights_for_sampler()                 # 刷新采样端权重
```

从官方客户评价可以看到调用边界（原文引用）：

> "The low-level API surface, direct control over the forward and backward passes, sampling, and the optimizer step gave our scientists the fine-grained control they need." — Rob Gontarek, SVP Data Science, ImagineSoftware

> "With SageMaker AI Serverless Training Sessions, we fine-tuned gpt-oss-20b for agentic, multi-turn tool calling against our Amazon Neptune knowledge graph … Checkpoint-and-resume was a standout: resuming from an exact step was completely reliable." — Nitin Wagh, CEO, Karini AI

上面 `session.*` 的具体方法名以官方 cookbook 与文档为准（`docs.aws.amazon.com/sagemaker/latest/dg/customizing-models-training-sessions.html`），本文未逐一核对每个方法签名。

---
[← Back to Deep Dives](./README.md)
