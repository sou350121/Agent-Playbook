---
auto_generated: true
generated_at: "2026-07-24T12:43:58Z"
source_url: "https://www.36kr.com/p/3902097586800259"
signal_type: "significant_update"
---
# DeepSeek V4 满血版发布：Flash + Pro 双版本，引入峰谷计费 (DeepSeek V4 GA: Flash + Pro Dual Tiers with Peak-Valley Pricing)

> 🔍 本文由 Moltbot 自动生成 | 2026-07-24
>
> **项目/工具**: DeepSeek V4 (GA)
> **链接**: https://api-docs.deepseek.com/quick_start/pricing/
> **核心定位**: DeepSeek 等待三个月的满血版模型正式 GA，提供 Flash（轻量快速）和 Pro（旗舰性能）两个版本，首次引入峰谷计费机制——以 Opus 级性能、七分之一价格继续冲击 AI API 市场。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**：DeepSeek V4 正式版（GA）发布，双版本策略覆盖轻量推理到旗舰编码，API 定价继续碾压同行。
- **现在值得用吗**：是——如果你的场景对 cost/performance 敏感，V4 Flash 是当前性价比最高的选择之一。
- **适合场景**：Agent 后端推理、批量数据处理、编码辅助、长上下文任务（1M context）。
- **不适合场景**：需要极致编码性能的 SWE-bench 场景（仍落后 Claude Opus 4.6）；对并发要求极高的生产系统（Pro 版限 500 QPS）。
- **与前版核心差异**：从单一模型（deepseek-chat/reasoner）拆分为 Flash + Pro 双版本，新增峰谷计费，context 上限提升至 1M。

## 是什么 / 解决什么问题

DeepSeek V4 是 DeepSeek 团队在 V3 之后等待近三个月的正式旗舰版本。此前 V4 预览版（March 2026）已在 SWE-bench Verified 上逼近 Claude Opus 4.6，但价格仅为对方的七分之一。此次 GA 发布带来两个关键变化：

**第一，双版本策略。** 不再用单一模型覆盖所有场景，而是拆分为：
- **deepseek-v4-flash**：面向轻量/高频场景，输出定价 $0.28/M tokens（峰值 $0.56），适合 Agent 日常推理、批量数据处理。
- **deepseek-v4-pro**：面向旗舰场景，输出定价 $0.87/M tokens（峰值 $1.74），编码直追 GPT-5.6 Sol，3D/SVG 生成能力显著增强。

**第二，峰谷计费机制。** DeepSeek 首次给自己的算力装上"计价器"——高峰时段 API 调用价格翻倍。这是对 Agent 场景下持续性高并发需求的直接回应。对将 Agent 挂在工作时间不间断跑的团队，这是一笔需要重新计算的账。

**第三，旧模型下线。** deepseek-chat 和 deepseek-reasoner 于 2026-07-24 正式下线，分别映射为 V4 Flash 的非思考模式和思考模式。这是一个干净的切割，用户需要迁移配置。

## 技术架构拆解

### 核心设计决策

| 决策点 | 选择 | 理由 |
|--------|------|------|
| 双版本拆分 | Flash + Pro | 覆盖不同 cost/performance 权衡，避免"一刀切" |
| 峰谷计费 | 高峰价格 ×2 | 削峰填谷，平衡 GPU 集群负载，给可迁移任务（batch/评测）成本优化空间 |
| 旧模型映射 | chat→Flash 非思考, reasoner→Flash 思考 | 平滑过渡，降低迁移摩擦 |
| 1M context | 统一双版本 | 长文档理解、代码库分析成为标配能力 |
| 384K max output | Pro 和 Flash 共享 | 支持超长代码生成和复杂推理链 |

### 与前版/竞品的关键差异

| 维度 | deepseek-chat (旧) | deepseek-v4-flash | deepseek-v4-pro | Claude Opus 4.6 | GPT-5.6 Sol |
|------|---------------------|--------------------|------------------|-----------------|-------------|
| 输出定价 (`/M tokens) | ~`2.19 (估算) | $0.28 (峰值 $0.56) | $0.87 (峰值 $1.74) | ~$75 | ~$60 |
| 输入定价 (`/M, cache miss) | N/A | `0.14 | $0.435 | ~$15 | ~$10 |
| 输入定价 (`/M, cache hit) | N/A | `0.0028 | $0.003625 | N/A | N/A |
| Context 长度 | 128K | 1M | 1M | 200K | 200K |
| Max Output | 4K | 384K | 384K | ~32K | ~64K |
| 思考模式 | 仅 reasoner | 支持（默认关闭） | 支持（默认开启） | 支持 | 支持 |
| SWE-bench Verified | ~67% (预估) | TODO: 待官方公布 | ~73% (距 Opus 差 0.2pp) | ~73.2% | ~72% |
| 并发上限 | 未公开 | 2500 QPS | 500 QPS | 未公开 | 未公开 |
| Agent 能力 | 基础 | 大幅增强 | 大幅增强 + 3D/SVG | 强 | 强 |

> 注：部分竞品定价为公开数据估算，SWE-bench 数据来自官方 blog 和开发者测试。TODO 标记项需等待 DeepSeek 官方公布。

### 架构/信息流图

```
                    ┌─────────────────────────────────────┐
                    │        DeepSeek API Gateway          │
                    │  (OpenAI/Anthropic Compatible)       │
                    └──────────────┬───────────────────────┘
                                   │
              ┌────────────────────┼────────────────────┐
              │                    │                    │
     ┌────────▼────────┐  ┌───────▼───────┐  ┌────────▼────────┐
     │  deepseek-v4-   │  │ deepseek-v4-  │  │  峰谷计费引擎    │
     │  flash          │  │ pro           │  │  (Peak/Valley)  │
     │                 │  │               │  │                 │
     │ • 非思考/思考   │  │ • 思考优先    │  │ • 平时: 基准价  │
     │ • 2500 QPS      │  │ • 500 QPS     │  │ • 高峰: ×2 价  │
     │ • $0.28/out     │  │ • $0.87/out   │  │ • cache hit:   │
     │ • 1M context    │  │ • 1M context  │  │   $0.0028      │
     └─────────────────┘  └───────────────┘  └────────────────┘
              │                    │
     ┌────────▼────────────────────▼────────┐
     │         Agent / Coding Tool          │
     │  (Claude Code, Copilot, OpenCode...) │
     └──────────────────────────────────────┘
```

### 峰谷计费：对 Agent 工作流的影响

峰谷计费是 DeepSeek 历史上首次引入的定价机制。其核心影响：

```
时间轴 (工作日)
00:00 ─────────────────────────────────── 24:00
  │ 谷         │ 峰 (工作日白天) │ 谷         │
  │ 基准价     │ ×2 价格         │ 基准价     │
  │            │                 │            │
  ├── 适合迁移的任务 ────────────────────────┤
  │  • 批量数据处理  │                               │
  │  • 评测跑分      │                               │
  │  • 数据生成      │                               │
  │  • 离线训练数据  │                               │
  │                  │ 不适合迁移的任务              │
  │                  │  • 实时 Agent 交互             │
  │                  │  • 用户-facing API             │
  └──────────────────┴───────────────────────────────┘
```

**对 Agent 团队的建议**：将可延迟任务（batch inference、evaluation、data generation）调度到谷时段，可将 API 成本降低 30-50%。实时交互场景则无法规避峰价，但即使峰价，V4 Pro 的 $1.74/M output 仍远低于竞品的 $60-75/M。

## 实用评估

### 什么场景值得用

- **Agent 后端推理**：V4 Flash 的 $0.28/M output + 2500 QPS 并发，是当前性价比最高的 Agent 后端之一。思考模式支持让复杂推理链也能胜任。
- **批量数据处理/ETL**：1M context + 极低 cache hit 价格（$0.0028/M），适合长文档解析、数据清洗等批量任务。
- **编码辅助**：V4 Pro 编码直追 GPT-5.6 Sol，SWE-bench 距 Opus 仅差 0.2pp，但价格低两个数量级。Claude Code / Copilot 用户可直接切换后端。
- **3D/SVG 生成**：V4 Pro 在此类多模态输出上显著增强，一次生成可玩 HTML 游戏的能力在竞品中少见。
- **长上下文任务**：1M context 远超竞品（200K），适合代码库全量分析、长文档问答。

### 什么场景不值得用

- **极致编码性能优先**：如果你的核心指标是 SWE-bench 最高分，Claude Opus 4.6 仍有微弱领先，且 V4 Pro 在"专业软件工程"评测中仍落后。
- **超高并发生产系统**：V4 Pro 限 500 QPS，如果需要更高并发，需要用 Flash 版本或做负载均衡。
- **对旧模型有深度依赖**：deepseek-chat/reasoner 已下线，如果你的 pipeline 硬编码了模型名，需要立即迁移。
- **预算不敏感且追求全项第一**：如果价格不是问题，GPT-5.6 Sol 和 Kimi K3 在部分维度上仍有优势。

### 迁移成本

| 迁移路径 | 工作量 | 风险 |
|----------|--------|------|
| deepseek-chat → deepseek-v4-flash (非思考) | 低（改名即可） | 旧模型的 non-thinking 模式直接映射 |
| deepseek-reasoner → deepseek-v4-flash (思考) | 低（改名 + 开启 thinking） | 需确认 thinking mode 参数格式 |
| 任意 → deepseek-v4-pro | 中（需调参） | Pro 版思考模式默认开启，需调整 prompt |
| 其他 API (OpenAI/Anthropic) → DeepSeek | 低（API 兼容） | base_url 切换，无需改代码 |

## 对你的意义

**对 AI 应用开发者**：V4 Flash 的 $0.28/M output 定价让 Agent 后端推理的成本门槛进一步降低。如果你的 Agent 架构中模型调用是主要成本项，切换到 V4 Flash 可能带来 10-50x 的成本节约。1M context 也让"把整个代码库塞进去"成为可行方案。

**对编码工具用户**：V4 Pro 的编码能力直追 GPT-5.6 Sol，而 Claude Code / Copilot 等工具已原生支持 DeepSeek 后端。切换成本几乎为零（改 base_url），但性能/价格比可能显著提升。

**需要关注的风险**：
- 峰谷计费的具体高峰时段定义尚未完全公开——需要观察实际计费行为。
- 首轮测试反馈"褒贬不一"，Pro 版相比 Flash 版领先幅度有限——如果 Flash 已满足需求，Pro 的溢价可能不值得。
- 旧模型已下线，确认你的 pipeline 已更新模型名。

## 关键代码/配置片段

### API 调用示例（OpenAI 格式）

```bash
# V4 Pro（思考模式，高推理力度）
curl https://api.deepseek.com/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${DEEPSEEK_API_KEY}" \
  -d '{
    "model": "deepseek-v4-pro",
    "messages": [
      {"role": "system", "content": "You are a helpful assistant."},
      {"role": "user", "content": "Hello"}
    ],
    "thinking": {"type": "enabled"},
    "reasoning_effort": "high",
    "stream": false
  }'
```

### Claude Code 集成

```json
// .claude/settings.json
{
  "model": "deepseek-v4-pro",
  "apiKey": "${DEEPSEEK_API_KEY}",
  "baseUrl": "https://api.deepseek.com"
}
```

### 峰谷计费成本计算示例

```
场景：Agent 每日 10 万次推理调用，每次平均 500 output tokens

峰时运行 (100% 高峰):
  100,000 × 500 / 1,000,000 × $1.74 = $87/天

谷时运行 (100% 低谷):
  100,000 × 500 / 1,000,000 × $0.87 = $43.5/天

混合策略 (50% 峰 + 50% 谷):
  $65.25/天

对比 Claude Opus ($75/M output):
  100,000 × 500 / 1,000,000 × $75 = $3,750/天

→ 即使峰时运行，V4 Pro 也比 Opus 便宜 43x
```

---
[← Back to Deep Dives](./README.md)
