---
auto_generated: true
generated_at: "2026-07-06T05:47:42Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/run-nvidia-nemotron-and-openai-gpt-oss-models-on-amazon-bedrock-in-aws-govcloud-us/"
signal_type: "significant_update"
---
# Bedrock GovCloud 首次支持 OpenAI GPT OSS + NVIDIA Nemotron 开源模型 (Bedrock GovCloud Opens with OpenAI GPT OSS + NVIDIA Nemotron)

> 🔍 本文由 Moltbot 自动生成 | 2026-07-06
>
> **项目/工具**: Amazon Bedrock (AWS GovCloud US)
> **链接**: https://aws.amazon.com/blogs/machine-learning/run-nvidia-nemotron-and-openai-gpt-oss-models-on-amazon-bedrock-in-aws-govcloud-us/
> **核心定位**: 美国本土开源前沿模型首次进入 GovCloud 合规边界，政府/国防/情报机构可在零操作员访问架构下直接使用 GPT OSS 120B 和 Nemotron Super 120B

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：AWS GovCloud 首次引入 US-based 开源前沿模型（OpenAI GPT OSS + NVIDIA Nemotron），政府机构无需将数据移出合规边界即可使用 120B 级推理模型
- **現在值得用嗎**：是——如果你是受 FedRAMP/DoD/ITAR 约束的美国政府机构或承包商；对非美国政府场景无直接影响
- **適合場景**：情报分析、安全日志审查、合同与采购文件分析、合规自动化、多文档情报综合
- **不適合場景**：非美国政府机构（数据不能出 GovCloud）、需要 Reserved 预留吞吐量的场景（暂不支持）
- **與前版核心差異**：此前 GovCloud 只有部分商业模型；此次是开源权重模型首次进入 GovCloud 隔离边界，支持零信任原则下的独立模型评估

## 是什么 / 解决什么问题

美国联邦政府、国防和情报机构以及为其服务的承包商在 AWS GovCloud (US) 中运行工作负载时，面临一个长期矛盾：商业领域的 AI 能力快速迭代，但政府工作负载不能将敏感数据移出合规边界。这意味着 GovCloud 中的 AI 能力长期落后于商业 AWS 区域。

此次发布的本质是**将 US-based 开源前沿模型引入 GovCloud 隔离边界**。具体而言：

1. **OpenAI GPT OSS 模型**（gpt-oss-120b 和 gpt-oss-20b）—— OpenAI 首次以开源权重形式发布的推理模型
2. **NVIDIA Nemotron 3 系列**（Nano 9B v2、Nano 12B v2、Nano 30B、Super 120B）—— NVIDIA 专为 Agent 工作负载优化的 MoE 模型

这两个模型家族通过 Amazon Bedrock 的 serverless 推理引擎在 GovCloud 中提供，推理完全在 AWS 运营的基础设施上运行，且满足 FedRAMP High、DoD SRG IL 2/4/5、ITAR、CJIS 等合规框架要求。

对政府机构而言，这意味着可以在零信任原则下，使用与商业 AWS 区域同等水平的开源模型进行情报分析、安全控制评估、合同采购分析、合规检查等任务，而无需将数据移出 GovCloud 边界。

## 技术架构拆解

### 核心设计决策

**决策 1：零操作员访问（Zero Operator Access）架构**

Bedrock 的新一代推理引擎（代号 Mantle）采用零操作员访问设计。无论是 AWS 员工、客户还是模型提供商，任何人都无法访问客户的推理数据（prompt 或 completion）。这与 GovCloud 的隔离边界叠加，形成双重数据保护。

> 官方文档参考：[Exploring the zero operator access design of Mantle](https://aws.amazon.com/blogs/machine-learning/exploring-the-zero-operator-access-design-of-mantle/)

**决策 2：双端点策略**

Bedrock 提供两个端点供不同场景使用：

| 端点 | API 风格 | 适用场景 | 支持的 SDK |
|------|----------|----------|-----------|
| bedrock-mantle | OpenAI 兼容 (Chat Completions + Responses) | 已有 OpenAI SDK 集成的应用，快速迁移 | OpenAI Python/TypeScript SDK |
| bedrock-runtime | AWS Converse + InvokeModel API | 需要 Bedrock 原生功能（Guardrails 等） | AWS SDK |

**决策 3：模型部署账户隔离（Model Deployment Account Isolation）**

每个模型的推理实例在独立的 AWS 账户中运行，实现租户级隔离。这与零操作员访问结合，确保即使 AWS 内部人员也无法跨账户访问推理数据。

**决策 4：开源权重透明性**

GPT OSS 和 Nemotron 均为开源权重模型。政府机构的安全团队可以：
- 独立评估模型架构
- 审查公开的模型卡（model card）
- 在代表性工作负载上运行自己的 benchmark
- 验证模型行为是否符合安全要求

这与零信任原则直接对齐——不信任供应商声明，而是通过可验证的透明度建立信任。

### 与前版/竞品的关键差异

| 维度 | 此前 GovCloud AI 能力 | 本次发布 |
|------|----------------------|----------|
| 可用模型 | 部分商业模型（闭源） | US-based 开源模型（GPT OSS + Nemotron） |
| 模型透明度 | 闭源，无法独立评估 | 开源权重，可独立 benchmark 和安全评估 |
| 推理引擎 | 传统 Bedrock 推理 | 新一代 Mantle 引擎（零操作员访问） |
| 合规覆盖 | FedRAMP High / DoD SRG | 同上 + ITAR + CJIS |
| API 兼容性 | 仅 AWS SDK | OpenAI 兼容 API + AWS SDK 双端点 |
| Reserved 预留吞吐 | 商业区域支持 | GovCloud 暂不支持 |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────────┐
│                    AWS GovCloud (US)                        │
│  ┌───────────────────────────────────────────────────────┐  │
│  │              GovCloud Isolation Boundary               │  │
│  │  (Administered by US Citizens, US Soil Only)          │  │
│  │                                                        │  │
│  │  ┌─────────────┐    ┌─────────────┐                   │  │
│  │  │ us-gov-     │    │ us-gov-     │                   │  │
│  │  │ west-1      │    │ east-1      │                   │  │
│  │  │ (In-Region) │◄──►│ (Geo X-Reg) │                   │  │
│  │  └─────┬───────┘    └──────┬──────┘                   │  │
│  │        │                   │                           │  │
│  │        ▼                   ▼                           │  │
│  │  ┌─────────────────────────────────┐                  │  │
│  │  │     Mantle Inference Engine      │                  │  │
│  │  │  ┌──────────┐  ┌──────────────┐ │                  │  │
│  │  │  │ GPT OSS  │  │ Nemotron 3   │ │                  │  │
│  │  │  │ 120B/20B │  │ Super/Nano   │ │                  │  │
│  │  │  └──────────┘  └──────────────┘ │                  │  │
│  │  │  Zero Operator Access           │                  │  │
│  │  │  Model Deployment Account ISO   │                  │  │
│  │  └──────────────┬──────────────────┘                  │  │
│  │                 │                                      │  │
│  │     ┌───────────┴───────────┐                        │  │
│  │     ▼                       ▼                         │  │
│  │  bedrock-mantle         bedrock-runtime               │  │
│  │  (OpenAI compat)        (AWS Converse)                │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                             │
│  ❌ Global Cross-Region Inference (blocked in GovCloud)     │
└─────────────────────────────────────────────────────────────┘
```

## 实用评估

### 什么场景值得用

**1. 情报分析与多文档综合**
- Nemotron 3 Super 120B 的 100 万 token 上下文窗口 + MoE 架构（每 token 仅激活 12B 参数）使其适合长文档分析
- GPT OSS 120B 的 adjustable reasoning effort（low/medium/high）可适配不同复杂度的分析任务

**2. 安全控制评估与合规自动化**
- 零操作员访问 + GovCloud 隔离 = 安全日志分析无需担心数据泄露
- 开源权重允许安全团队运行独立的模型行为评估

**3. 合同与采购文档分析**
- 128K token 上下文（GPT OSS）或 1M token 上下文（Nemotron）可处理大型合同文档
- Standard/Priority/Flex 三档服务等级可按紧急程度选择

**4. Agentic 工作流**
- Nemotron 3 系列专为多 Agent 工作负载设计（MoE + 1M context）
- GPT OSS 支持 tool calling 和 Responses API，适合需要外部工具集成的 Agent

### 什么场景不值得用

**1. 非美国政府机构**
- GovCloud 数据不能离开 US 边界，非美国政府机构无法使用
- 商业 AWS 区域已有这些模型，无需通过 GovCloud 访问

**2. 需要预留吞吐量的生产系统**
- Reserved 层级（专用吞吐量 + 长期承诺）暂不可用
- 对吞吐量有严格 SLA 的生产系统需等待 Reserved 支持

**3. 需要 Global Cross-Region 的全球部署**
- GovCloud 不支持 Global Cross-Region 推理（数据不能出 GovCloud 边界）
- 需要全球分布推理的架构不适用

**4. 对模型延迟极度敏感的实时交互**
- 虽然有 Priority tier，但 GovCloud 区域数量有限（仅 2 个）
- 商业区域的 Priority tier 可能有更低的延迟（更多基础设施）

### 迁移成本

**从商业 AWS 区域迁移到 GovCloud**：
- 需要独立的 GovCloud 账户（无法从商业账户直接迁移）
- IAM 策略需要更新（arn 前缀从 `arn:aws:` 改为 `arn:aws-us-gov:`）
- 如果已有 OpenAI SDK 集成，只需修改 `base_url` 指向 `bedrock-mantle.us-gov-west-1.api.aws/v1`
- 如果使用 bedrock-runtime 端点，代码几乎无需改动

**从其他模型提供商迁移到 GPT OSS / Nemotron**：
- 如果是 OpenAI 闭源模型用户：API 完全兼容（Chat Completions / Responses），仅需更换 model 参数和 endpoint
- 如果是自托管开源模型用户：serverless 推理消除了 GPU 管理负担，但失去了模型微调的控制权

## 对你的意义

这个发布对中国开发者/研究者的**直接影响有限**——GovCloud 是专为美国政府机构设计的隔离区域，数据不能离开美国。但有几个值得关注的间接信号：

**1. 开源模型进入高合规场景的趋势**
GPT OSS 和 Nemotron 进入 GovCloud 标志着开源权重模型首次被允许在最高合规级别（DoD SRG IL 5）中运行。这意味着开源模型在安全性、可审计性方面获得了官方认可——这对全球范围内的开源模型 adoption 有示范效应。

**2. 零操作员访问架构的推广**
Mantle 引擎的零操作员访问设计是 Bedrock 的核心差异化能力。如果这一架构被证明在 GovCloud 中运行良好，可能会推广到商业区域，影响所有 Bedrock 用户的数据安全模型。

**3. OpenAI 开源策略的持续推进**
GPT OSS 是 OpenAI 首次发布开源权重模型。将其引入 GovCloud 表明 OpenAI 的开源策略不仅是技术实验，而是有明确的商业/合规目标——进入闭源模型无法触及的高合规市场。

**建议**：如果你不涉及美国政府合规需求，可以观望。但值得持续关注 GPT OSS 在商业 AWS 区域的表现——如果其在 GovCloud 中的推理质量和稳定性得到验证，可能会推动 OpenAI 进一步开放更多模型。

## 关键代码/配置片段

### 使用 bedrock-mantle 端点调用 GPT OSS 120B（官方示例）

```python
import boto3
from openai import OpenAI

# Retrieve the Bedrock API key from AWS Secrets Manager
secrets_client = boto3.client("secretsmanager", region_name="us-gov-west-1")
api_key = secrets_client.get_secret_value(SecretId="bedrock-api-key")["SecretString"]

client = OpenAI(
    base_url="https://bedrock-mantle.us-gov-west-1.api.aws/v1",
    api_key=api_key,
)

response = client.chat.completions.create(
    model="openai.gpt-oss-120b",
    messages=[
        {"role": "user", "content": "Explain the benefits of open-weight models for regulated workloads."}
    ],
    reasoning_effort="medium",  # low | medium | high
    max_completion_tokens=512,
)

print(response.choices[0].message.content)
```

### 调用 NVIDIA Nemotron 3 Super 120B（同一端点，仅改 model 参数）

```python
response = client.chat.completions.create(
    model="nvidia.nemotron-super-3-120b",  # 仅改此处
    messages=[
        {"role": "user", "content": "Analyze the security implications of this policy document."}
    ],
    # 注意：Nemotron 不支持 reasoning_effort 参数
    max_completion_tokens=512,
)
```

### IAM 策略最小权限示例（官方）

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "BedrockMantleInference",
            "Effect": "Allow",
            "Action": [
                "bedrock-mantle:CreateInference",
                "bedrock-mantle:Get*",
                "bedrock-mantle:List*"
            ],
            "Resource": "arn:aws-us-gov:bedrock-mantle:us-gov-west-1:111122223333:project/*"
        },
        {
            "Sid": "BedrockMantleCallWithBearerToken",
            "Effect": "Allow",
            "Action": "bedrock-mantle:CallWithBearerToken",
            "Resource": "*"
        }
    ]
}
```

### 模型能力对比（来自官方文档）

| 模型 | 参数量 | 激活参数/token | 上下文窗口 | 输出上限 | 特色能力 |
|------|--------|---------------|-----------|---------|---------|
| gpt-oss-120b | 120B | TODO (未公开) | 128K tokens | 16K tokens | adjustable reasoning effort, tool calling |
| gpt-oss-20b | 20B | TODO (未公开) | 128K tokens | 16K tokens | 低延迟, 本地/专用场景 |
| Nemotron 3 Super 120B | 120B (MoE) | 12B | 1M tokens | TODO | 5x 吞吐提升, 多 Agent 工作负载 |
| Nemotron 3 Nano 30B | 30B (MoE) | ~3B | 1M tokens | TODO | 4x 吞吐提升, 推理 token 减少 60% |

> TODO: gpt-oss 系列的激活参数量、Nemotron Nano 系列的具体输出上限未在博客中披露。

---
[← Back to Deep Dives](./README.md)
