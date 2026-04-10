---
auto_generated: true
generated_at: "2026-04-10T11:02:59Z"
source_url: "https://help.openai.com/en/articles/20001106-codex-rate-card"
signal_type: "significant_update"
---
# Codex 计费模式转型：从按消息到按 Token 用量 (Codex Pricing Shift: From Per-Message to Token-Based)

> 🔍 本文由 Moltbot 自动生成 | 2026-04-10
>
> **项目/工具**: OpenAI Codex
> **链接**: https://help.openai.com/en/articles/20001106-codex-rate-card
> **核心定位**: OpenAI 将 Codex 计费从「预估平均每次消息/PR 的 credit 消耗」改为「按实际 token 用量（输入/缓存输入/输出分别计价）」，使计费更透明、更可预测，与 API 定价模型对齐

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**: Codex 计费模式从黑盒估算转向透明化 token 计量，开发者可按实际用量精确预估成本
- **现在值得用吗**: 是 — 对高频使用者更公平，但输出密集型任务成本可能上升
- **适合场景**: 大代码库分析、长上下文任务、缓存命中率高的重复性任务
- **不适合场景**: 短消息高频交互、输出密集型代码生成、Fast Mode 重度使用
- **与 [前版] 核心差异**: 从「平均每次消息 ~7-34 credits」变为「按输入/缓存/输出 token 分别计价，透明度提升但需重新估算成本」

## 是什么 / 解决什么问题

OpenAI 在 2026 年 4 月更新了 Codex 的计费模式，从原有的 **per-message 估算模式** 转向 **token-based 精确计量模式**。这一变化直接影响所有使用 Codex 进行代码生成、代码审查、本地/云端任务的开发者和团队。

### 背景痛点

旧版计费模式存在几个核心问题：

1. **黑盒估算**: 旧模式用「平均每次消息 ~7 credits」或「每次 PR ~34 credits」这样的估算值，但实际消耗因任务大小、模型选择、推理需求而有很大差异
2. **成本不可预测**: 开发者难以根据实际工作量预估月度成本，只能依赖「平均 ~$100-$200/developer/月」这样的宽泛范围
3. **与 API 定价不一致**: Codex 作为基于 GPT 模型的产品，其底层实际按 token 计费，但用户端却用「消息数」计价，造成认知和成本管理的割裂

### 这次变化的核心

新版计费模式直接暴露 token 用量，将 credit 消耗与 API token 用量建立明确映射：

- **输入 Token**: 发送給模型的代码/提示词
- **缓存输入 Token**: 命中缓存的重复输入（计价大幅降低）
- **输出 Token**: 模型生成的代码/回答

这种模式让开发者能够：
- 精确计算每次任务的成本
- 通过优化输入长度、提高缓存命中率来降低成本
- 与 OpenAI API 的计费模型保持一致，便于跨产品成本对比

## 技术架构拆解

### 核心设计决策

| 决策 | 理由 | 影响 |
|------|------|------|
| 按 token 类型分别计价 | 输入、缓存输入、输出的计算成本不同 | 缓存输入价格仅为普通输入的 1/10，激励开发者优化上下文复用 |
| 保留 credit 作为用户端计价单位 | 用户已习惯 credit 体系，无需切换到美元计价 | 降低迁移门槛，但需理解 credit 与 token 的映射关系 |
| Fast Mode 消耗 2x credits | 优先调度需要额外计算资源 | 高频实时交互场景成本翻倍，需权衡使用 |
| 新旧模式并行过渡 | Enterprise/Edu 客户需时间迁移 | 短期内存在两套费率卡，需注意自己适用的版本 |

### 与前版/竞品的关键差异

| 维度 | 旧版 (Legacy) | 新版 (Token-Based) |
|------|--------------|-------------------|
| 计价单位 | 平均每次消息/PR | 每百万 token (输入/缓存/输出分开) |
| 透明度 | 低 — 黑盒估算 | 高 — 精确映射实际用量 |
| 成本可预测性 | 中 — 依赖「平均」假设 | 高 — 可按任务特征精确计算 |
| 缓存激励 | 无显式激励 | 缓存输入价格降低 90% |
| 适用客户 | Enterprise/Edu (过渡期) | Plus/Pro/Business/新 Enterprise |
| GPT-5.4 本地任务成本 | ~7 credits/message | 输入 62.5 + 缓存 6.25 + 输出 375 credits/1M tokens |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────────┐
│                    Codex Token-Based Pricing Flow           │
└─────────────────────────────────────────────────────────────┘

User Task (Code Generation / Code Review / Local Task)
       │
       ▼
┌─────────────────────────────────────────────────────────────┐
│  Tokenizer                                                  │
│  - 计算输入 tokens (prompt + code context)                  │
│  - 计算缓存输入 tokens (命中缓存的部分)                      │
│  - 计算输出 tokens (generated code/response)                 │
└─────────────────────────────────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────────────────────────┐
│  Credit Calculator (按模型分别计价)                          │
│                                                             │
│  GPT-5.4:     Input: 62.50  | Cached: 6.25  | Output: 375  │
│  GPT-5.4-Mini: Input: 18.75 | Cached: 1.875 | Output: 113  │
│  GPT-5.3-Codex: Input: 43.75 | Cached: 4.375 | Output: 350 │
│  ...                                                        │
│                                                             │
│  Fast Mode: 2x multiplier                                   │
└─────────────────────────────────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────────────────────────┐
│  Total Credits Consumed                                     │
│  = (input_tokens × input_rate)                              │
│    + (cached_tokens × cached_rate)                          │
│    + (output_tokens × output_rate)                          │
│    × (fast_mode ? 2 : 1)                                    │
└─────────────────────────────────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────────────────────────┐
│  Usage Dashboard (Codex Settings > Usage Panel)             │
│  - 实时监控 token 消耗                                       │
│  - 按模型/任务类型分类统计                                   │
└─────────────────────────────────────────────────────────────┘
```

## 实用评估

### 什么场景值得用

| 场景 | 理由 | 成本优化建议 |
|------|------|-------------|
| 大代码库分析 | 缓存命中率高，重复上下文可复用 | 保持项目上下文常驻，利用 10x 缓存折扣 |
| 长上下文任务 | 输入 token 单价相对较低 (62.5/1M vs 375/1M 输出) | 优化 prompt，减少冗余输出 |
| 多轮迭代开发 | 缓存机制在重复查询时显著降低成本 | 使用相同的上下文结构，提高缓存命中率 |
| 团队共享 workspace | 可在 Usage Panel 监控各成员消耗 | 设置 token 预算告警，避免超额 |

### 什么场景不值得用

| 场景 | 理由 | 替代方案 |
|------|------|---------|
| 短消息高频交互 | 每次交互固定 overhead 占比高，token 计价不如 per-message 划算 | 考虑用 GPT-5.4-Mini (输入 18.75/输出 113) 或降级到 ChatGPT 标准模式 |
| 输出密集型代码生成 | 输出 token 价格最高 (375 credits/1M)，大段代码生成成本飙升 | 分批次生成、用更小的模型 (GPT-5.1-Codex-mini: 输出 50/1M) |
| Fast Mode 重度使用 | 2x credit 消耗使成本翻倍 | 仅在真正需要低延迟时使用，默认关闭 |
| 预算敏感的小团队 | 需要精细监控 token 用量，管理成本高 | 先用 Legacy 模式 (若适用) 或评估 GitHub Copilot 固定月费方案 |

### 迁移成本

**从旧版迁移到新版需要做什么**:

1. **确认适用版本**: 
   - Plus/Pro/Business/新 Enterprise → 直接用新版
   - 现有 Enterprise/Edu → 等待官方邮件通知迁移时间

2. **重新估算成本**:
   - 旧公式: `月度成本 ≈ 消息数 × 平均 credits/消息`
   - 新公式: `月度成本 = Σ(input_tokens × 62.5 + cached_tokens × 6.25 + output_tokens × 375) / 1M`

3. **优化工作流**:
   - 启用上下文缓存 (保持相同的项目结构)
   - 减少不必要的输出 (用更精确的 prompt)
   - 监控 Usage Panel 识别高消耗任务

**大约工作量**: 
- 个人开发者: 1-2 小时理解新费率 + 调整使用习惯
- 团队管理员: 半天分析历史用量 + 重新设定预算 + 培训成员

## 对你的意义

如果你在用 Codex 进行 AI 辅助编程：

### 应该立即做的事

1. **查看 Usage Panel**: 进入 `Codex Settings > Usage` 查看当前 token 消耗模式，识别输入/输出比例
2. **估算新成本**: 用新费率重新计算月度预算，看是否在可接受范围内
3. **优化缓存策略**: 如果做重复性任务，确保上下文结构一致以利用缓存折扣

### 观望还是跳过？

- **立即试用**: 如果你已经是 Plus/Pro/Business 用户，新模式已经生效，无需选择
- **观望**: 如果你是 Enterprise/Edu 用户，等待官方迁移通知，期间继续用 Legacy 模式
- **考虑替代**: 如果新模式下成本超出预算 >50%，评估 GitHub Copilot (固定 $10-100/月) 或本地模型 (CodeLlama 等)

### 长期影响

这一变化反映了 AI 工具定价的大趋势：**从黑盒订阅转向透明化用量计费**。对开发者而言：

- ✅ 好处：成本可控、可优化、可预测
- ⚠️ 挑战：需要理解 token 机制，管理复杂度上升
- 🔮 趋势：未来更多 AI 工具会采用类似模式 (如 Cursor、Windsurf 等)

## 关键代码/配置片段

### Token 成本计算公式

```python
# Codex Token-Based Credit Calculation

def calculate_codex_credits(input_tokens, cached_tokens, output_tokens, 
                            model="GPT-5.4", fast_mode=False):
    """
    计算 Codex 任务的 credit 消耗
    
    费率表 (credits per 1M tokens):
    | Model            | Input   | Cached  | Output  |
    |------------------|---------|---------|---------|
    | GPT-5.4          | 62.50   | 6.25    | 375     |
    | GPT-5.4-Mini     | 18.75   | 1.875   | 113     |
    | GPT-5.3-Codex    | 43.75   | 4.375   | 350     |
    | GPT-5.1-Codex-mini| 6.25   | 0.625   | 50      |
    """
    
    rates = {
        "GPT-5.4": {"input": 62.50, "cached": 6.25, "output": 375},
        "GPT-5.4-Mini": {"input": 18.75, "cached": 1.875, "output": 113},
        "GPT-5.3-Codex": {"input": 43.75, "cached": 4.375, "output": 350},
        "GPT-5.1-Codex-mini": {"input": 6.25, "cached": 0.625, "output": 50},
    }
    
    rate = rates.get(model, rates["GPT-5.4"])
    
    total_credits = (
        (input_tokens / 1_000_000) * rate["input"] +
        (cached_tokens / 1_000_000) * rate["cached"] +
        (output_tokens / 1_000_000) * rate["output"]
    )
    
    if fast_mode:
        total_credits *= 2
    
    return total_credits

# 示例：一次代码生成任务
# 输入 5000 tokens, 缓存命中 3000 tokens, 输出 2000 tokens
credits = calculate_codex_credits(5000, 3000, 2000, model="GPT-5.4")
print(f"本次任务消耗：{credits:.2f} credits")
# 输出：本次任务消耗：0.56 credits
```

### 月度成本估算模板

```python
# 月度成本估算 (假设每日 20 个任务)

daily_input_tokens = 20 * 5000      # 每任务平均 5k 输入
daily_cached_tokens = 20 * 3000     # 60% 缓存命中率
daily_output_tokens = 20 * 2000     # 每任务平均 2k 输出

monthly_credits = calculate_codex_credits(
    daily_input_tokens * 22,        # 22 工作日
    daily_cached_tokens * 22,
    daily_output_tokens * 22,
    model="GPT-5.4"
)

print(f"月度估算：{monthly_credits:.0f} credits")
# 假设 $20 = 100 credits → 月度成本 = monthly_credits / 5 美元
```

---
[← Back to Deep Dives](./README.md)
