---
auto_generated: true
generated_at: "2026-10-28T08:01:05Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/orchestrating-sagemaker-ai-endpoint-auto-scaling-with-aws-cdk/"
signal_type: "significant_update"
---
# AWS CDK 编排 SageMaker AI Endpoint 自动扩缩容 (Orchestrating SageMaker AI Endpoint Auto Scaling with AWS CDK)

> 🔍 本文由 Moltbot 自动生成 | 2026-10-28
>
> **项目/工具**: SagemakerAutoscalingConstruct（AWS Sample: `aws-samples/sample-sagemaker-endpoint-autoscaling`）
> **链接**: https://aws.amazon.com/blogs/machine-learning/orchestrating-sagemaker-ai-endpoint-auto-scaling-with-aws-cdk/
> **核心定位**: 一个可复用的 CDK construct，把「改 endpoint 配置就必须先注销 scalable target」这个 SageMaker 与 CloudFormation 的先天冲突，包装成单次 `cdk deploy` 可完成的自动编排。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：解决 SageMaker AI endpoint 用 CDK/CloudFormation 部署时，「改配置就炸 / 静默丢自动扩缩容 / 回滚也失败」三类故障。
- **現在值得用嗎**：看场景——只要你**用 IaC 管 SageMaker endpoint 且开了 Application Auto Scaling**，就值得；纯控制台/纯 API 部署的团队用不上。
- **適合場景**：多环境（dev/staging/prod）需要重复部署的推理服务；实例类型或实例数频繁迭代的模型上线流程。
- **不適合場景**：Serverless Inference（无 scalable target 概念）、只在 Console 手动点点点的团队、对额外 12 个 Lambda 计费敏感的小规模部署。
- **與前版/競品核心差異**：之前只能「手动 `aws application-autoscaling deregister-scalable-target` → deploy」两步走且静默失败；现在是单次 deploy，带显式依赖顺序与异步等待。

## 是什么 / 解决什么问题

SageMaker AI 有一个长期的 IaC 痛点：实时 endpoint 的配置（实例类型、实例数、环境变量）一旦注册了 Application Auto Scaling 的 scalable target，SageMaker 会**拒绝**更新 endpoint 配置并在部署层抛出错误：

```
The variant(s) "[AllTraffic]" must be deregistered as scalable targets
with Application Auto Scaling before they can be removed or have their
instance type updated.
```

AWS 官方 blog（2026-10-19）把三种失败路径拆得很清楚，这是全文信息密度最高的一段：

| 操作路径 | 结果 |
|---|---|
| 带着已注册的 scalable target 直接改 endpoint 配置 | CloudFormation 更新被 SageMaker 拒绝，部署失败 |
| 手动 deregister 后，**只改** endpoint 配置 | 部署成功，但 scalable target **不会重新注册**——endpoint 静默失去自动扩缩容，无任何报错 |
| 手动 deregister 后，**同时改** autoscaling 参数 | CloudFormation 找不到 `ScalableTarget` 资源 → 更新失败，且回滚也失败（`UPDATE_ROLLBACK_FAILED`），栈进入需人工去控制台救援的破损状态 |

第二种最危险：它不报错。你可能三周后才发现某条线上推理服务在流量尖峰时无法扩容，而 CloudWatch 告警配置其实也存在——因为 target tracking policy 根本没挂上。

第三种最痛苦：`UPDATE_ROLLBACK_FAILED` 是 CloudFormation 里最难自动化处理的死状态之一。

## 技术架构拆解

### 核心设计决策

- **用 Custom Resource 替代原生资源**：放弃 `AWS::ApplicationAutoScaling::ScalableTarget` / `ScalingPolicy`，改成三个 `CustomResource`，从而可以在 endpoint 更新前后自由插入 deregister / register 动作。
- **显式依赖顺序**：通过 `props.endpoint.node.add_dependency(deregister)` 等 `node.add_dependency` 调用把顺序写死，而不是依赖 CloudFormation 的隐式资源图推断。
- **异步完成模式（Async Provider）**：Register / Attach 两个资源不阻塞单次 Lambda 调用，而是 `on_event` 立刻返回 + `is_complete` 由 provider waiter 每 30 秒轮询。
- **超时上移到 provider 层**：`total_timeout` = 1 小时（Register Scalable Target）/ 15 分钟（Attach Scaling Policy），因此不被 Lambda 15 分钟上限约束。
- **ConfigHash 强制重入**：endpoint 与 autoscaling 参数合并成一个 `config_hash`，任一变化都会让 CloudFormation 重新调用所有相关 Lambda——这是解决「参数没变所以 CFN 不动手」那个静默 bug 的关键。
- **首次部署容错**：Deregister handler 捕获 `ObjectNotFoundException` 直接 `pass`，因为第一次部署时根本没有 scalable target。

### 与前版/竞品的关键差异

| 维度 | 原生 CloudFormation 资源 | 本 Construct |
|------|------------|------------|
| 改 endpoint 配置（实例类型/数） | 失败（scalable target 未注销） | 成功，串联三资源自动处理 |
| 自动扩缩容是否保留 | 视操作路径而定，可能静默丢失 | 守恒，deploy 后必重新注册 |
| 触发机制 | 仅当 autoscaling 参数变化 | `ConfigHash` 包含 endpoint 参数，任一变化即触发 |
| 回滚风险 | `UPDATE_ROLLBACK_FAILED` 需人工救援 | 依赖顺序确定，避免该场景 |
| 部署资源数量 | 2 个资源 | 3 custom resource + 2 Step Functions + 12 Lambda |
| 等待 endpoint `InService` | 无内置等待 | Async waiter，最长 1 小时 |
| 集成成本 | 0（但会炸） | 复制 `sagemaker_autoscaling/constructs/` 目录 |

### 架构/信息流图

```
cdk deploy
   │
   ├─[1] Deregister (sync provider)
   │      deregister_scalable_target(ResourceId, DesiredInstanceCount)
   │      ↳ ObjectNotFoundException → pass（首次部署）
   │
   ├─[2] Endpoint Update (CDK 原生)
   │      add_dependency 保证在 [1] 之后
   │      ↳ endpoint 状态: Updating → InService
   │
   ├─[3] Register Scalable Target (async provider)
   │      on_event → 立即返回
   │      is_complete → 每 30s 查 describe_endpoint
   │                   ≠ InService 则 IsComplete=False
   │                   == Failed 则 raise
   │      total_timeout = 1h
   │
   └─[4] Attach Scaling Policy (async provider)
          is_complete → describe_scalable_targets 非空？
                       → put_scaling_policy(TargetTrackingScaling)
          total_timeout = 15min
```

栈删除时：[3] 与 [4] 的 `on_event` 在 `Delete` 请求下 deregister / delete policy 做清理。

## 实用评估

### 什么场景值得用

- **同一 endpoint 被多套环境复用**：dev/staging/prod 三套配置靠 `config.yaml` 差异驱动，改一处再 `cdk deploy` 即可，不用每次手动 CLI 兜底。
- **实例类型会随模型变更而升级**：从 `ml.m5.large` 升到 `ml.m5.xlarge` 正是这个构造的核心用例（blog 的 walkthrough 就是拿这个举例）。
- **CI/CD 中跑 SageMaker 部署**：静默丢失 autoscaling 的故障在流水线里没人看，这个 construct 把它变成显式 waiter，失败会红。
- **已经把 endpoint 声明在 CDK 里**：直接复制 constructs 目录即可，不用重写整栈。

### 什么场景不值得用

- **只在控制台部署的团队**：完全没有 CloudFormation 状态跟踪问题。
- **Serverless Inference / Provisioned Throughput**：不涉及 `sagemaker:variant:DesiredInstanceCount` 这套 scalable target 语义。
- **强资源洁癖者**：部署产物是 3 个 custom resource + 2 个 Step Functions 状态机 + **12 个 Lambda**，其中 7 个由 CDK `cr.Provider` 框架生成。官方 blog 明确提醒「这些函数你不用维护，但它们存在于栈里，审资源时要算进去」。如果你的组织对 Lambda 数量/IAM 权限有硬性配额审计，需要先评估。
- **单次性实验 endpoint**：为一个跑两天就删的 endpoint 引入三层 custom resource 明显过重。

### 迁移成本

- **从原生 CFN 资源迁移**：删除模板中的 `AWS::ApplicationAutoScaling::ScalableTarget` 与 `ScalingPolicy` 两个资源，`cdk deploy` 一次。⚠️ 这一步之后 CFN 会把原资源标记删除——建议先在非生产栈验证 CloudFormation 是否正确放手（blog 未说明该迁移路径的边界情况，属于 **待确认** 项）。
- **从全新栈开始**：`git clone` 示例仓库 → 改 `config/config.yaml` → `cdk bootstrap` → `cdk deploy InferenceStack`，约 30-60 分钟（含首次 bootstrap）。
- **集成到既有栈**：复制 `sagemaker_autoscaling/constructs/`，构造 `config_hash` JSON，实例化 `SagemakerAutoscalingConstruct`，并把你自己的 `CfnEndpoint` 传进去。代码量约 20 行。
- **依赖**：CDK v2 + Python 3.12+ + `uv`。用 pip/poetry 的团队要额外适配打包流程。

## 对你的意义

这条的价值不在「AWS 又发了一个 sample」，而在于它把 **Agent 时代推理基础设施的一个真实工程边界** 摊开了：LLM/Agent 应用的 endpoint 是**长生命周期 + 高频变更**的混合体，而 IaC 工具（CloudFormation）与扩缩容控制面（Application Auto Scaling）在资源生命周期上并不对齐。任何托管推理平台都会有这个缝隙。

具体到两条追踪线：

- **若你在做 AI 应用的后端**：只要 inference endpoint 进了 IaC，这就是个必然踩的坑。建议做法是**直接抄这个「异步 custom resource + ConfigHash 强制重入」的模式**，不必用它的代码——这个模式对 Bedrock AgentCore Runtime、Vertex AI Endpoint、甚至自建 K8s 上的 vLLM Deployment + HPA 都有迁移价值（后者要特别小心 HPA 与 Deployment 的 update 时序）。
- **若你在做 VLA 侧**：VLA 推理服务常年跑在 GPU endpoint 上，实例类型换型频率高（如换卡型 / 上更大模型），静默丢 autoscaling 的后果是长尾请求直接超时。这类「部署静默降级」比部署失败更难发现，值得纳入自己的部署 checklist。

**建议**：观望但收藏。如果你的 SageMaker endpoint 还没进 CDK，先别为此改架构；一旦进了，直接照抄 `ConfigHash` 那一段——它是整个方案里最便宜也最有效的部分。

## 关键代码/配置片段

配置文件（endpoint 与 autoscaling 放在一起，因为单一 `config_hash` 驱动编排）：

```yaml
endpoint:
  endpoint_name: "my-model-endpoint"
  image: "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-model:latest"
  model_data_url: "s3://my-bucket/models/model.tar.gz"
  instance_type: "ml.m5.large"
  initial_instance_count: 1
  environment: {}
autoscaling:
  min_capacity: 1
  max_capacity: 10
  target_value: 100
  scale_in_cooldown: 600
  scale_out_cooldown: 120
```

Deregister 的首次部署容错：

```python
def handler(event, context):
    resource_id = event["ResourceProperties"]["ResourceId"]
    if event["RequestType"] in ("Create", "Update"):
        try:
            client.deregister_scalable_target(
                ServiceNamespace="sagemaker",
                ResourceId=resource_id,
                ScalableDimension="sagemaker:variant:DesiredInstanceCount",
            )
        except client.exceptions.ObjectNotFoundException:
            pass  # No scalable target on first deploy
    return {"PhysicalResourceId": f"deregister-{resource_id}"}
```

Register 的异步等待（注意 `IsComplete=False` 的轮询语义）：

```python
status = sm_client.describe_endpoint(EndpointName=endpoint_name)["EndpointStatus"]
if status == "Failed":
    raise Exception("Endpoint in Failed state")
if status != "InService":
    return {"IsComplete": False}
as_client.register_scalable_target(
    ServiceNamespace="sagemaker",
    ResourceId=resource_id,
    ScalableDimension="sagemaker:variant:DesiredInstanceCount",
    MinCapacity=int(props["MinCapacity"]),
    MaxCapacity=int(props["MaxCapacity"]),
)
return {"IsComplete": True}
```

集成到既有栈的核心调用：

```python
config_hash = json.dumps({
    "endpoint": {...},
    "autoscaling": {
        "minCapacity": 1, "maxCapacity": 10, "targetValue": 100,
        "scaleInCooldown": 600, "scaleOutCooldown": 120,
    },
})

SagemakerAutoscalingConstruct(
    self, "Autoscaling",
    props=SagemakerAutoscalingProps(
        endpoint=your_endpoint,  # your CfnEndpoint
        autoscaling=AutoscalingConfig(...),
        config_hash=config_hash,
    ),
)
```

验证部署结果：

```bash
aws application-autoscaling describe-scalable-targets \
  --service-namespace sagemaker \
  --resource-ids endpoint/my-model-endpoint/variant/AllTraffic
```

> TODO: 官方 blog 未给出部署耗时、Lambda 调用成本或 concurrent deploy 场景下的表现数据；如需要，可在非生产栈实测登记。

---
[← Back to Deep Dives](./README.md)
