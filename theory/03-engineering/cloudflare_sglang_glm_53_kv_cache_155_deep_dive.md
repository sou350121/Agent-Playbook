---
auto_generated: true
generated_at: "2026-10-31T08:00:48Z"
source_url: "https://blog.cloudflare.com/kv-cache-exposure-remediation/"
signal_type: "significant_update"
---
# 当 KV Cache 串了别人的上下文：Cloudflare 披露 GLM-5.3 跨租户泄漏与 SGLang 修复 (Cross-Request KV Cache Exposure in GLM-5.3: The Pool-Size Mismatch and SGLang's Fix)

> 🔍 本文由 Moltbot 自动生成 | 2026-10-31
>
> **项目/工具**: Cloudflare Workers AI + SGLang（disaggregated prefill/decode）+ GLM-5.3
> **链接**: https://blog.cloudflare.com/kv-cache-exposure-remediation/
> **核心定位**: 一次由「推理引擎 KV 池容量小于模型上下文长度」引发的跨租户数据泄漏事件，以及 SGLang 在上游做出的一整类 KV cache 生命周期修复——对任何自托管大模型推理的人都算强制阅读

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句話定位**：GLM-5.3 在 Workers AI 上从 2026-08-27 起，对超过 681,280 token 的 prompt 返回了其他用户残留的 KV 上下文；根因是「KV 池容量 681,280 tokens < 上下文长度 1,048,576 tokens」，叠加 SGLang 分片模式下的 rejection 路径 bug，共影响 155 条响应。
- **現在值得用嗎**：如果你跑 SGLang disaggregated（PD 分离），**立刻升级到 v0.5.22 或以上**；如果只是单机 SGLang 或走商业 API，这不是紧急项，但值得抄一份检查清单。
- **適合場景**：自托管推理运维、多租户 SaaS 的模型后端、agent 长上下文工作负载（agentic coding 一类动辄几十万 token 的会话）。
- **不適合場景**：只调用托管 API 的应用开发者——底层由厂商负责；以及从不触发长上下文的轻量场景，风险面很小。
- **與前版核心差異**：v0.5.22 之前，超长请求被 prefill 拒绝后仍会走完 handoff，decode 会读到本请求从未写过的页面；v0.5.22 之后，被拒请求在 admission 队列就被退役，并加了逐次传输校验和、abort-ACK 保留、默认 deferred KV release。

## 是什么 / 解决什么问题

KV cache 是推理引擎为了加速自回归生成而保留在 GPU 显存里的中间状态。为了省显存和延迟，几乎所有引擎都不会在请求结束后把页面清零，下一个拿到页面的请求直接覆盖——这是业界通行做法，代价是「页面所有权追踪」成了引擎自己的责任，而不是硬件的保证。

Cloudflare 的这次事故正是所有权追踪在「分片式 PD 分离」部署下断掉了一环。他们在 prefill 集群上给 GLM-5.3 配了 1,048,576 token 的上下文窗口，但 KV 池实际只能装 681,280 token。Cloudflare 在发版前就知道这个不匹配，但根据「引擎应该会报错」和「长上下文压测返回了成功的 HTTP 状态码」判断问题不大——这个假设正是事件的第一层。

第二层是 SGLang 在 v0.5.21 之前对超长请求的处理缺陷：请求被拒绝后，prompt 被替换成一个 token 的占位符，但请求本身在 admission 队列里仍被判定为「存活」，于是它走完了 bootstrap、分配、KV 传输的整个流程。decode 节点收到「传输完成」，然后对这 8 个预留页面全部做 attention——其中只有 1 页是本次请求写入的，其余 7 页是别的用户会话的残留。响应是 HTTP 200，`prompt_tokens` 对得上，内容还很通顺，只是里面夹了别人的上下文。

## 技术架构拆解

### 核心设计决策

- **PD 分离（disaggregated prefill/decode）**：prefill 池负责算 prompt 的 KV，通过 RDMA（Mooncake）把 cache 交给 decode 池生成。这是高吞吐推理的主流形态，但也把「页面所有权」从单机问题变成了跨机问题。
- **KV 池大小不是配置项**：SGLang 在启动时按「模型权重加载后剩余的显存」自动确定池大小，与模型声明的上下文长度是两个独立值，没有任何机制强制两者一致。Cloudflare 明确指出「check that they do」是部署方的责任。
- **不清零页面以保性能**：这是刻意选择。零填充会吃掉吞吐，所以安全必须由引擎的页面生命周期管理来兜底。
- **双保险修复**：Cloudflare 同时修了配置（把池扩到约 2.04M tokens，约为上下文长度的两倍）和引擎（被拒请求在 admission 阶段带着原始错误退役，发生在任何 bootstrap/分配/传输之前，对应上游 PR #38704 / #38935）。
- **不依赖配置的长期方向**：给每个物理 KV 页面打 tag，页面被重新分配时 tag 变化，请求记录自己期望的 tag，decode 读 cache 前校验。Cloudflare 的原型测试吞吐与尾延迟损耗低于 1%，但因可靠性问题暂时撤下，正在与 SGLang 一起产品化。

### 与前版/竞品的关键差异

| 维度 | v0.5.20 之前 | v0.5.22 |
|------|------------|------------|
| 超长请求处理 | 被拒后仍走完 handoff，decode 读到他人页面 | 在 admission 队列退役，任何分配/传输前返回原始错误 |
| 传输完整性 | 无校验 | `--disaggregation-enable-kv-checksum`：decode 生成前校验传输 KV 的 checksum |
| 页面释放 | 只覆盖部分失败类型 | deferred KV release 默认开启，覆盖 transfer 失败、abort、超时等多种路径 |
| 客户端断连 | 可能导致请求中途 abort，产生跨节点竞态 | `sgl-router` 在断连/预填失败时同时取消两半 |
| 传输批大小 | 无上限，超时可能留下无界尾巴 | 可选 cap 的 Mooncake 传输批次（#32758） |
| 可观测性 | KV canary 覆盖不全 | canary 修复 + deferred release 指标（次数、时长、是否靠 drain 确认结束） |

### 架构/信息流图

```
Router ──告知 prompt 长度(8 页)──> Decode 节点  (预留 8 页 KV)
   │
   └──> Prefill admission (旧逻辑: req.finished() == False → 放行)
          │  被拒请求把 rejection 存在 to_finish，finished() 仍为 False
          ▼
        Prefill forward (prompt 已被换成 1-token 占位符 → 平凡前向)
          │
          ▼
        RDMA/Mooncake 传输: 只写 1 页 (P0) + 发送 "transfer complete"
          │
          ▼
        Decode attention: 读 P0..P7
          P1..P7 = 上一次请求残留（其他用户 prompt / 部分生成）
          │
          ▼
        返回 HTTP 200 + 连贯但混入他人数据的响应
```

## 实用评估

### 什么场景值得用

- **多租户自托管推理**：一旦同一组 GPU 上服务多个租户，KV 页面残留就是合规级问题，不是性能问题。这次事件证明「没有错误码」不等于「没有越界」。
- **超长上下文 agent 工作负载**：agentic coding 类会话动辄几十万 token，恰好踩在阈值附近。Cloudflare 明确表示受影响请求「在时间与体量上与普通长上下文使用一致，不像有人刻意利用」——说明这类 bug 在正常使用中就会被触发。
- **正在做 PD 分离部署调优的团队**：v0.5.22 里那批竞态修复（#43719、#37077、#40645）就是一份现成的「分布式 KV 安全 checklist」。

### 什么场景不值得用

- **只走商业 API 的应用层**：这部分由厂商负责，你真正该做的是确认供应商的版本与披露节奏。
- **单机 SGLang 部署**：单机路径上占位符逻辑「能正常工作」——拒绝后批处理走完，客户端收到错误。风险主要落在 PD 分离模式。
- **把 checksum 当万能药**：`--disaggregation-enable-kv-checksum` 与 `--kv-canary` 尚未覆盖所有模型架构（GLM 5.3、GLM 5.3 Flash、DeepSeek V4 仍在推进），需要看日志确认请求真的在做校验。

### 迁移成本

- 升级到 v0.5.22：包管理与镜像层面基本是版本号替换，但需要重启推理进程；PD 分离集群要确认 prefill/decode 两侧同步升级。
- 配置核对：从引擎启动日志读出 KV 池大小，和上下文长度逐一比对，每个 prefill/decode 节点都要查，且在权重、量化、并行度、显存比例每次变动后重查。
- 加校验开关与指标：需要评估 checksum/canary 的吞吐代价（Cloudflare 的页面 tag 原型约 <1%，checksum 开销未在该文中给出数字），并接入 deferred release 指标。
- 负载均衡器调整：让请求撑到 first token 再断开，避免制造不必要的 abort。

## 对你的意义

如果手头有自托管推理，或者在看「agent 长上下文」的系统设计，这次披露的价值不在于单个 CVE 式的补丁，而在于它暴露了一类被普遍忽略的假设：**「引擎会拒绝它处理不了的请求」是错的**。

具体建议：

1. **立即**：任何 disaggregated SGLang 部署升级到 v0.5.22+；在部署检查里加一条「KV 池 ≥ 上下文长度」的硬门禁。
2. **本周**：把「只校验 HTTP 状态码」的压测改成同时校验输出内容一致性——Cloudflare 的教训就是状态码 200 但输出是别人的。
3. **持续关注**：页面级 tag 的完整性方案（integrity by construction）和形式化验证 RDMA KV 传输协议这两条线，是对 Agent 基础设施长期更有价值的成果。

## 关键代码/配置片段

以下是源材料中出现的真实命令与 API（未做改写）：

```
# 分片模式下的传输完整性校验：decode 在生成前校验 KV checksum
--disaggregation-enable-kv-checksum

# KV canary：检测并记录可能的 cache 损坏
--kv-canary
```

排障时关注的关键状态字段（来自 Cloudflare 对 bug 机制的描述）：

```
req.finished()        # 旧 admission 判断依据；被拒请求仍返回 False
req.to_finish         # 被拒请求的错误存在这里，而非 finished_reason
prompt_tokens         # 返回 200 时与长 prompt 对得上，掩盖了问题
```

> TODO: Cloudflare 原文未公布 checksum / canary 的具体吞吐与延迟开销百分比，只有页面 tag 原型的「< 1%」，此处不做外推。

## 📌 关联背景

本文不对应「AI Agent 假设追踪」清单中的具体假设（候选 JSON 的 `assumption_matches` 为空）。但它与 A-005（AI 工作流自动化成为企业最快增长场景）间接相关：agent 工作流的负载特征正是超长上下文与多租户并发，这类 KV 内存安全问题会随 agent 落地规模同步放大。

---
[← Back to Deep Dives](./README.md)
