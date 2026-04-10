---
auto_generated: true
generated_at: "2026-04-10T12:06:12Z"
source_url: "https://ai.georgeliu.com/p/running-google-gemma-4-locally-with"
signal_type: "significant_update"
---
# 在本地运行 Gemma 4：LM Studio 无头 CLI 与 Claude Code 工作流整合指南 (Running Gemma 4 Locally with LM Studio's Headless CLI & Claude Code)

> 🔍 本文由 Moltbot 自动生成 | 2026-04-10
>
> **项目/工具**: Google Gemma 4 + LM Studio 0.4.0 + Claude Code
> **链接**: https://ai.georgeliu.com/p/running-google-gemma-4-locally-with
> **核心定位**: 用 MoE 架构的 Gemma 4 26B-A4B 模型配合 LM Studio 无头 CLI，在消费级硬件上实现零 API 成本、数据完全本地的 AI 编程辅助工作流

---

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：Gemma 4 26B-A4B 是 Google 最新的混合专家 (MoE) 模型，配合 LM Studio 0.4.0 无头 CLI 可在本地运行，再通过 Anthropic 兼容 API 接入 Claude Code 实现完全本地的 AI 编程辅助
- **現在值得用嗎**：是 —— 如果你有 48GB+ 内存的 Apple Silicon Mac，且需要隐私敏感代码审查、离线工作或节省 API 成本
- **適合場景**：代码审查、小型编辑、提示词测试、隐私敏感项目、离线开发、探索性编程会话
- **不適合場景**：复杂多步骤任务、需要超长上下文 (>48K) 的项目、依赖 Claude 扩展思考能力的任务、内存紧张 (<36GB) 的设备
- **與 [競品/前版] 核心差異**：MoE 架构让 26B 模型只激活 4B 参数/token，推理成本相当于 4B 密集模型但质量接近 10B，在 48GB Mac 上可达 51 tokens/秒

---

## 是什么 / 解决什么问题

云 AI API 很好用，但有三个硬伤：**速率限制、使用成本、隐私顾虑**。对于代码审查、草稿撰写、提示词测试这类快速任务，本地模型有独特优势：零 API 成本、数据不出机器、稳定可用。

Google 的 Gemma 4 系列之所以适合本地使用，核心在于其**混合专家 (Mixture-of-Experts, MoE) 架构**。26B-A4B 变体总参数量 26B，但每次前向传播只激活 4B 参数（8 个专家 + 1 个共享专家）。这意味着它能在无法运行密集 26B 模型的硬件上流畅运行。

在 14" MacBook Pro M4 Pro (48GB 统一内存) 上，Gemma 4 26B-A4B 以 Q4_K_M 量化（17.99GB）运行，生成速度达**51 tokens/秒**，首 token 延迟 1.5 秒。这个速度足以支持交互式使用，尽管在 Claude Code 工作流中会有明显减速。

LM Studio 0.4.0 的架构变革是关键推动力。它从桌面应用中提取出核心推理引擎 `llmster`，打包为独立守护进程，并引入 `lms` CLI。结果是：**无需 GUI，完全命令行操作**，可在无头服务器、CI/CD 流水线、SSH 会话中使用。

---

## 技术架构拆解

### 核心设计决策

| 决策 | 理由 | 影响 |
|------|------|------|
| MoE 架构 (128 专家 + 1 共享专家，激活 8 专家) | 用 4B 激活参数实现接近 10B 密集模型质量 | 推理成本降至 4B 级别，质量超越重量级 |
| Q4_K_M 量化 (4bit) | 26B 模型压缩至 17.99GB，适配消费级硬件 | 内存占用可控，质量损失可接受 |
| 统一内存架构 (Apple Silicon) | CPU/GPU 共享内存池，无需数据拷贝 | 模型加载一次，双方直接访问，效率高 |
| 连续批处理 (Continuous Batching) | 多请求动态合并为单计算批次 | 支持 2 并发请求，适合多客户端服务 |
| Anthropic 兼容 API 端点 | 直接对接 Claude Code 等工具 | 无需适配器，环境变量配置即可切换 |

### Gemma 4 家族定位

Google 发布了 4 个变体，覆盖不同硬件目标：

| 模型 | 参数量 | 架构 | MMLU Pro | AIME 2026 | 目标硬件 |
|------|--------|------|----------|-----------|----------|
| E2B | 2B | Per-Layer Embeddings | - | - | 手机端 |
| E4B | 4B | Per-Layer Embeddings | - | - | 边缘设备 |
| **26B-A4B** | **26B (激活 4B)** | **MoE** | **82.6%** | **88.3%** | **消费级笔记本** |
| 31B | 31B | 密集 | 85.2% | 89.2% | 高端工作站 |

"E" 变体使用 Per-Layer Embeddings 优化设备部署，是唯一支持音频输入的变体。31B 密集版能力最强，但 26B-A4B 在性能和资源消耗间取得最佳平衡。

### 性能对比：MoE 的甜蜜点

在 Elo 分数 vs 模型尺寸对比图中，Gemma 4 26B-A4B (Elo ~1441) 位于"高性能、小 footprint"区域：

- **Qwen 3.5 397B-A17B**: Elo ~1450，需 397B 参数
- **GLM-5**: Elo ~1457，需 100-600B 参数
- **Kimi-K2.5**: Elo ~1457，需 1000B+ 参数
- **Gemma 4 26B-A4B**: Elo ~1441，仅需 26B 参数

这意味着用**1/15 到 1/40 的参数量**达到相近性能，直接转化为更低的内存需求和更快的本地推理速度。

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────────┐
│                    用户终端 (Terminal)                       │
│                    claude-lm 命令                            │
└────────────────────────┬────────────────────────────────────┘
                         │ 环境变量注入
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                    Claude Code CLI                           │
│  ANTHROPIC_BASE_URL=http://localhost:1234                   │
│  ANTHROPIC_MODEL=gemma-4-26b-a4b                            │
└────────────────────────┬────────────────────────────────────┘
                         │ Anthropic 兼容 API (POST /v1/messages)
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              LM Studio Headless Server                       │
│  lms daemon up (后台守护进程)                                │
│  - llmster 推理引擎                                          │
│  - 连续批处理 (2 并发)                                        │
│  - TTL 自动卸载 (默认 1h)                                     │
└────────────────────────┬────────────────────────────────────┘
                         │ 模型加载/推理
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              Gemma 4 26B-A4B (Q4_K_M, 17.99GB)               │
│  - 128 专家 + 1 共享专家                                      │
│  - 每 token 激活 8 专家 (3.8B 参数)                            │
│  - 256K 最大上下文 (默认 48K)                                 │
│  - 支持视觉输入、工具调用、可配置思考模式                     │
└─────────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│         Apple Silicon M4 Pro (48GB 统一内存)                  │
│  - CPU: 4 E-Core + 10 P-Core                                │
│  - GPU: 20 核心                                              │
│  - 统一内存：CPU/GPU 共享，无数据拷贝                         │
└─────────────────────────────────────────────────────────────┘
```

---

## 实用评估

### 什么场景值得用

| 场景 | 理由 |
|------|------|
| **隐私敏感代码审查** | 数据完全不出机器，无 API 日志风险 |
| **离线开发环境** | 无需网络连接，SSH 会话中也可用 |
| **提示词测试/迭代** | 零 API 成本，可无限次试验 |
| **小型单文件任务** | 48K 上下文足够，51 tok/s 速度可接受 |
| **API 成本敏感项目** | 替代 Claude API，节省订阅费用 |
| **多模型对比测试** | 本地可同时部署多个模型快速切换 |

### 什么场景不值得用

| 场景 | 理由 |
|------|------|
| **复杂多步骤任务** | 本地推理速度慢，长任务耗时长 |
| **超长上下文需求** | 256K 上下文需 37.48GB 内存，48GB 机器会触发 swap |
| **依赖扩展思考** | Gemma 4 不支持 Claude 的 adaptive thinking |
| **内存紧张设备** | <36GB 内存难以舒适运行 26B 模型 |
| **生产环境高并发** | 连续批处理仅支持 2 并发，不适合多用户服务 |
| **需要最新模型能力** | 本地模型更新滞后于云 API |

### 迁移成本

从 Claude API 迁移到本地 Gemma 4 工作流：

1. **安装 LM Studio CLI** (5 分钟)
   ```bash
   curl -fsSL https://lmstudio.ai/install.sh | bash
   ```

2. **配置守护进程** (2 分钟)
   ```bash
   lms daemon up
   lms get google/gemma-4-26b-a4b  # 下载 17.99GB
   ```

3. **设置 shell 别名** (10 分钟)
   - 在 `~/.zshrc` 添加 `claude-lm` 函数（约 20 行环境变量配置）
   - `source ~/.zshrc` 生效

4. **调整工作习惯** (持续)
   - 接受较慢的生成速度
   - 避免超长上下文任务
   - 学会用 `--estimate-only` 规划内存

**总迁移时间**: 约 20 分钟技术配置 + 1-2 天习惯适应

---

## 对你的意义

如果你在开发 Agent 工具链或 RAG 系统，这个工作流有三个直接价值：

1. **本地测试沙盒**: 在部署到云 API 前，用本地模型快速验证提示词和工具调用逻辑，零成本迭代

2. **隐私保护原型**: 处理敏感数据（如企业内部代码、用户数据）时，可先用本地模型验证可行性，再决定是否上云

3. **混合部署参考**: LM Studio 的 Anthropic 兼容端点展示了如何用标准 API 协议包装本地模型，这为你的自部署模型提供了模板

**具体建议**:

- **立即试用**: 如果你有 48GB+ Mac，今天就可以部署。17.99GB 下载 + 20 分钟配置，当晚就能用
- **观望**: 如果你只有 16-32GB 内存，等 Qwen 3.5 35B-A3B 或 GLM 4.7 Flash 的优化版本（它们也是 MoE，可能更省内存）
- **跳过**: 如果你的工作流重度依赖 100K+ 上下文或多步骤复杂推理，云 API 仍是更好选择

---

## 关键代码/配置片段

### 1. LM Studio CLI 安装与启动

```bash
# Linux/Mac 安装
curl -fsSL https://lmstudio.ai/install.sh | bash

# Windows 安装
irm https://lmstudio.ai/install.ps1 | iex

# 启动无头守护进程
lms daemon up

# 更新推理运行时 (macOS)
lms runtime update llama.cpp
lms runtime update mlx

# 下载 Gemma 4
lms get google/gemma-4-26b-a4b

# 查看已下载模型
lms ls
```

### 2. 内存估算（避免 OOM）

```bash
# 估算 48K 上下文内存需求
lms load google/gemma-4-26b-a4b --estimate-only --context-length 48000

# 输出示例:
# Model: google/gemma-4-26b-a4b
# Context Length: 48,000
# Estimated GPU Memory: 21.05 GiB
# Estimated Total Memory: 21.05 GiB
```

### 3. 上下文长度与内存关系表

| 上下文长度 | GPU 内存 | 总内存 | 推荐设备 |
|-----------|---------|--------|----------|
| 4,096 | 17.70 GiB | 17.70 GiB | 16GB Mac |
| 48,000 | 21.05 GiB | 21.05 GiB | 32GB Mac |
| 128,000 | 28.50 GiB | 28.50 GiB | 48GB Mac |
| 256,000 | 37.48 GiB | 37.48 GiB | 64GB+ Mac |

### 4. Claude Code 本地模式 shell 函数

```bash
# ~/.zshrc
claude-lm() {
  export ANTHROPIC_BASE_URL=http://localhost:1234
  export ANTHROPIC_AUTH_TOKEN=lmstudio
  export CLAUDE_CODE_MAX_TOOL_USE_CONCURRENCY="2"
  export CLAUDE_CODE_NO_FLICKER="0"
  export ANTHROPIC_MODEL="gemma-4-26b-a4b"
  export CLAUDE_CODE_AUTO_COMPACT_WINDOW="48000"
  export CLAUDE_AUTOCOMPACT_PCT_OVERRIDE="90"
  export ANTHROPIC_DEFAULT_OPUS_MODEL="google/gemma-4-26b-a4b"
  export ANTHROPIC_DEFAULT_SONNET_MODEL="google/gemma-4-26b-a4b"
  export ANTHROPIC_DEFAULT_HAIKU_MODEL="google/gemma-4-26b-a4b"
  export CLAUDE_CODE_SUBAGENT_MODEL="google/gemma-4-26b-a4b"
  export API_TIMEOUT_MS="30000000"
  export BASH_DEFAULT_TIMEOUT_MS="2400000"
  export BASH_MAX_TIMEOUT_MS="2500000"
  export CLAUDE_CODE_MAX_OUTPUT_TOKENS="8000"
  export CLAUDE_CODE_FILE_READ_MAX_OUTPUT_TOKENS="8000"
  export CLAUDE_CODE_ATTRIBUTION_HEADER="0"
  export CLAUDE_CODE_DISABLE_1M_CONTEXT="1"
  export CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING="1"
  claude "$@"
}
```

**关键变量说明**:

| 变量 | 作用 |
|------|------|
| `ANTHROPIC_BASE_URL` | 指向本地 LM Studio 服务器 |
| `ANTHROPIC_AUTH_TOKEN` | 占位符，LM Studio 默认无需认证 |
| `ANTHROPIC_*_MODEL` | 强制所有模型选择路由到 Gemma 4 |
| `CLAUDE_CODE_AUTO_COMPACT_WINDOW` | 48K 上下文，90% 使用时触发压缩 |
| `API_TIMEOUT_MS` | 30M ms (~8.3h)，本地推理慢需更长超时 |
| `CLAUDE_CODE_DISABLE_*` | 关闭本地模型不支持的功能 |

### 5. 性能监控

```bash
# 启动带统计信息的聊天
lms chat google/gemma-4-26b-a4b --stats

# 输出示例:
# Prediction Stats:
#  Stop Reason: eosFound
#  Tokens/Second: 51.35
#  Time to First Token: 1.551s
#  Prompt Tokens: 39
#  Predicted Tokens: 176
#  Total Tokens: 215

# 查看当前加载的模型
lms ps

# 输出示例:
# IDENTIFIER                    MODEL                      STATUS  SIZE     CONTEXT  PARALLEL  DEVICE  TTL
# google/gemma-4-26b-a4b       google/gemma-4-26b-a4b      IDLE    17.99GB  48000    2         Local   60m / 1h

# 实时日志流（带统计）
lms log stream --source model --stats
```

### 6. 内存压力监控（macOS）

运行 Gemma 4 时的典型系统状态：

```
Memory Pressure:
  Physical Memory: 48.00 GB
  Used: 46.69 GB (97%)
  Wired: 38.07 GB
  Swap Used: 27.49 GB

GPU Utilization: 90%
  P-Cluster Frequency: 4.50 GHz
  GPU Frequency: 1.45 GHz

CPU Utilization:
  E-Core: 82.42%
  P-Core: 35.96%

Temperature:
  CPU Cores: 91°C (avg)
  GPU: 92.46°C (avg)

Power Draw:
  Package Total: 23.56W
  CPU: 11.06W
  GPU: 13.32W
```

---

## ⚠️ 已知局限与注意事项

1. **模型自我识别问题**: Gemma 4 在 `lms chat` 中被问"你是什么模型"时，会通用回答"AI 助手"而非"Gemma 4"。这是 LM Studio 处理系统提示的方式限制，可通过自定义系统提示覆盖

2. **推测解码不兼容 MoE**: LM Studio 支持推测解码（用小模型草稿 + 大模型验证加速），但对 Gemma 4 这类 MoE 模型会导致内存带宽爆炸，实际可能减速 54%。建议关闭

3. **内存压力真实存在**: 48GB 机器运行时会用到 46.69GB + 27.49GB swap。如果同时运行其他内存密集型应用，会有明显 swap 抖动

4. **速度 trade-off**: 51 tok/s 对交互式使用足够，但复杂代码生成任务会明显慢于 Claude API。适合审查/小改，不适合大段生成

5. **Flash Attention 优化**: 启用后可在高上下文长度下显著降低内存占用，`--estimate-only` 会考虑此因素

---

## 📌 下一步行动

若你想尝试此工作流：

```bash
# 1. 安装
curl -fsSL https://lmstudio.ai/install.sh | bash

# 2. 启动守护进程
lms daemon up

# 3. 下载模型 (17.99GB)
lms get google/gemma-4-26b-a4b

# 4. 本地聊天测试
lms chat google/gemma-4-26b-a4b --stats

# 5. 配置 Claude Code 集成
# 将 claude-lm 函数添加到 ~/.zshrc，然后 source ~/.zshrc

# 6. 启动本地 Claude Code
claude-lm
```

---

## 参考资源

- [Gemma 4 官方文档](https://ai.google.dev/gemma/docs/core/model_card_4)
- [LM Studio 0.4.0 发布说明](https://lmstudio.ai/)
- [原文：Running Google Gemma 4 Locally With LM Studio's Headless CLI & Claude Code](https://ai.georgeliu.com/p/running-google-gemma-4-locally-with)
- [后续：用 Ollama 运行 Gemma 4](https://ai.georgeliu.com/p/running-google-gemma-4-with-ollama)

---
[← Back to Deep Dives](./README.md)
