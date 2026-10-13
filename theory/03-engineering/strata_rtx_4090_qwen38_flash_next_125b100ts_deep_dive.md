---
auto_generated: true
generated_at: "2026-10-13T09:01:11Z"
source_url: "https://github.com/Niko1221/Strata/releases/tag/v0.1.43.1"
signal_type: "significant_update"
---
# Strata：消费级显卡本地跑 125B MoE 大模型（Strata: Running a 125B MoE Model Locally on Consumer GPUs）

> 🔍 本文由 Moltbot 自动生成 | 2026-10-13
>
> **项目/工具**: Strata (`Niko1221/Strata`)
> **链接**: https://github.com/Niko1221/Strata/releases/tag/v0.1.43.1
> **核心定位**: 一个开源本地推理引擎——在 12GB+ 显存的消费级显卡上跑 125B 参数的 Qwen3.8-Flash-Next MoE 模型，并在 `localhost` 暴露 OpenAI / Anthropic 兼容 API。本次 v0.1.43.1 是 0.1.43 的热修复，主要修复 Linux/NVIDIA 解码速度回退与长 prompt 卡死。

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句話定位**：让「本来需要服务器级显存」的 125B MoE 模型，落进一张 12GB 游戏显卡 + 32–64GB 内存的普通 PC，并伪装成 OpenAI/Anthropic 接口供本地 app 与 coding agent 调用。
- **現在值得用嗎**：看场景——如果你想要**数据不出本机**的本地大模型后端，且有 ≥12GB 显存 + ≥32GB 内存 + ~80GB 磁盘，值得；如果你追求开箱即用、或多并发高吞吐，则否。
- **適合場景**：本地 coding agent 后端（Claude Code / Codex CLI / Copilot 切 base URL）、隐私敏感对话、离线/内网推理。
- **不適合場景**：需要高并发批量推理（默认单请求串行）、显存 <12GB、追求旗舰级绝对速度。
- **與前版核心差異**：0.1.43.1 把 0.1.43 在 Linux NVIDIA 上默认开启的「adaptive overlap」重新改为 opt-in（该默认值在某些桌面卡上导致 -19% 至 -21% 解码速度回退），并修复长 prompt 在 Windows / SATA SSD 上卡死重启。

## 是什么 / 解决什么问题

现实中，「125B 级别的大模型」和「消费级显卡」之间隔着一道显存高墙：这类模型通常部署在拥有数百 GB 显存的服务器上。Strata 的目标是把这道墙拆掉——它运行 [Qwen3.8-Flash-Next](https://huggingface.co/Qwen/Qwen3.8-Flash-Next)（125B 参数），在**单张 12GB+ 显存的 NVIDIA 或 AMD 游戏显卡 + 32GB 以上内存**的普通 PC 上本地推理，安装器一键拉起，浏览器开 `http://127.0.0.1:8080` 即用，`Nothing leaves your PC`（README 原话）。

它解决的痛点不只是「跑得起来」，更是**接入摩擦**：Strata 同时在本地暴露三套兼容 API（OpenAI `/v1`、Anthropic `/v1/messages`、Responses `/v1/responses`），意味着现有的 app 和 coding agent 只需改一个 base URL 就能把后端换成这台「私人 125B」。此外它还提供一个 MCP server，让 AI 编程助手自己去安装、启动、停止 Strata。

本次 **v0.1.43.1** 本身是一个热修复版本，重点不在加功能，而在「把 0.1.43 挖的坑填回去」：0.1.43 在 Linux NVIDIA 上默认打开了一项自适应 overlap 优化，结果在部分桌面机上反而掉速，同时引入的长 prompt 卡死问题也一并修复。官方强调修复后**答案与 0.1.43 字节级一致**（identity tests），只多了一处把引用 `</tool_call>` 的用户消息当文本读的修正。

## 技术架构拆解

### 核心设计决策

- **MoE 专家分层卸载（expert offloading）**：模型是 24,576 个小专家组成的团队，每个 token 只激活其中约 10 个。Strata 把**最常被调用的少数专家留在显卡**，**全部专家放进内存**，**处理器同时计算未被调度的部分**，**SSD 上放一张大查找表**（n-gram 表约 27GB）。
- **猜测-校验（Guess, then check）解码**：小助手先猜接下来几个词，大模型一次性校验全部，官方称同样答案可**快 1.6–1.8 倍**。
- **大块读入长文本**：长 prompt 按最多 8,192 token 一块读入，速度超过 1,000 token/s。
- **同一个模型多档量化**：按内存大小选择 `Q2_0 / IQ2_XS / IQ3_XXS / IQ3_S / Coder` 等尺寸，小尺寸更快、大尺寸更聪明。

### 与前版/竞品的关键差异

| 维度 | 前版 0.1.43（Linux NVIDIA） | 本次 0.1.43.1 |
|------|----------------------------|---------------|
| adaptive overlap（自适应重叠） | 默认开启 | **默认关闭**，需 `STRATA_ADAPT_OVERLAP=1` 显式开启 |
| 桌面卡解码速度 | 部分卡回退（RTX 5070 Ti -21%：68.4 vs 86.4 tok/s） | 恢复；启用后需自行 A/B |
| Linux NVIDIA 解码崩溃 | RTX 4090 + Ryzen 9800X3D 掉到 19–37 tok/s（正常 102–116） | 修复（回调度线程预热 + 4 字节 pinned 信号） |
| 长 prompt 卡死 | Windows / SATA SSD 首次分块读表逐页缺页，60s watchdog 杀引擎 | 改为仅警告并保留 direct 读；mapped 模式预取 4,096 行 |
| 双 NVIDIA 卡批处理 | `--batch --batch-mtp` 比 0.1.41 慢约 30% | 层拆分下默认回归流水线组（2×A4000 四请求 62.3→85.2 tok/s） |
| RX 6000 卡（Windows） | 自 0.1.40.2 起 prompt 慢 16–20% | 恢复（RX 6800 7.9K prompt 584–596→798–808 tok/s） |

### 架构/信息流图

```
                 ┌──────────────────────────────────────────────┐
                 │              Strata Engine                    │
                 │   Qwen3.8-Flash-Next  (125B MoE, 24,576 exp.) │
                 └──────────────────────────────────────────────┘
                                    │  每 token 激活 ~10 个专家
        ┌───────────────┬──────────┴────────┬───────────────┐
        ▼               ▼                   ▼               ▼
   GPU VRAM        System RAM            CPU            SSD
  (12–24 GB)      (32–64 GB)          (兼职算力)     (~27GB 表)
  最热专家        全部专家+权重        剩余专家       n-gram 查找表

请求路径（本地 API）：
  app / coding agent
      │  POST /v1/chat/completions  (或 /v1/messages, /v1/responses)
      ▼
  127.0.0.1:8080  ──►  猜测(小助手 draft) ──► 校验(大模型批量) ──► 输出
```

## 实用评估

### 什么场景值得用

- **想让 coding agent 跑在本地大模型上**：把 Claude Code 的 `ANTHROPIC_BASE_URL=http://127.0.0.1:8080`、或 OpenAI 兼容客户端 base 指向 `http://127.0.0.1:8080/v1` 即可，任何 API key / 模型名都接受（README）。
- **隐私/离线优先的对话与代码**：模型全在本地，`Nothing leaves your PC`。
- **手上正好有 12–24GB 显卡的玩家**：README 给出 RTX 20/30/40/50 系列及部分 RX 7000/9000 系支持列表，24GB 卡（如 3090）官方预估约 100–140 tok/s。

### 什么场景不值得用

- **需要高并发**：默认「一次只答一个请求」，其余排队；`"parallel": 2` 虽可开，但在 12GB 卡上会让每次回答更慢（README）。
- **显存不足 12GB**：官方硬门槛；有 Tesla P40/V100、GTX 10 系等「老卡」实验路径，但非默认支持。
- **启动期间会短暂「假死」**：首次启动会加载 35–55GB 进内存并锁定一部分给显卡，PC 可能卡顿 1–3 分钟，属正常现象。
- **追求绝对最快 / 最大规模**：即便是 24GB 卡的速度上限，仍无法与服务器级多卡部署相比；更大量化（如 UD-Q4_K_XL）在 64GB PC 上仅 7–8.5 tok/s，需从 SSD 流式读权重。

### 迁移成本

- **从云端 API 迁移**：主要是改 base URL 与模型名（几行配置）。但要注意本地吞吐/并发与云端不同，需重新评估超时与重试策略。
- **从 llama.cpp 系方案迁移**：Strata 复用 llama.cpp / ggml 的部分组件，但卸载策略与猜测-校验解码是自有实现；量化选型需要按自身内存重新挑尺寸。
- **从旧版升级**：`UPDATE.bat`（Linux `./update.sh`），setup 会把 engine 换成 0.1.43.1；无需重下模型。

## 对你的意义

对以 **Agent + 工程/评估** 为主的你，Strata 的价值有三层：

1. **一个「本地 provider」用于 agent 实验**：它同时兼容 OpenAI / Anthropic / Responses 三套协议，意味着同一套 agent 代码可以在云 API 与本地模型之间无缝切换——非常适合做**模型可替换性 / provider 抽象**的实验。
2. **MCP server 这条线**：Strata 让 AI 助手通过 MCP 自行安装/启停自身，是 MCP 从「工具调用」走向「基础设施自举」的一个小样本，值得记一笔。
3. **工程风险管理样本**：0.1.43.1 这个热修复本身是一堂「**默认开启的优化 = 风险**」的课——一个看似 +5~10% 的自适应优化，在某些硬件上偷偷变成 -19%~-21%，且靠字节级 identity test 无法发现（答案一致，只是慢）。这正好呼应本周另一个信号：agent 时代需要**默认硬预算上限**与**可回滚的保守默认值**。

**建议**：如果你有 12GB+ 显卡的自用机，值得花一个周末试用（一键脚本 + `BENCH.bat` 自测）；若只是想在 CI / 服务器上跑，先观望——并发与运维成熟度仍是短板。

## 关键代码/配置片段

**① 让 AI 助手自动装好（README 原文提示词）：**

```text
Set up Strata on this PC for me: https://github.com/Niko1221/Strata - follow docs/AI_SETUP.md in that repository.
```

**② 把 app / coding agent 接到本地模型：**

```text
OpenAI-compatible provider base URL : http://127.0.0.1:8080/v1
Anthropic API apps                  : http://127.0.0.1:8080/v1/messages
Claude Code                         : ANTHROPIC_BASE_URL=http://127.0.0.1:8080
Codex CLI / Responses API           : /v1/responses
```

**③ 本次热修复涉及的关键开关（来自 release notes）：**

```text
STRATA_ADAPT_OVERLAP=1        # 重新显式开启自适应重叠（默认已关闭）
STRATA_ADAPT_SIGNAL=host      # 换回 callback 信号方式
STRATA_ADAPT_CALLBACK_WARMUP=0# 关闭 callback 线程预热（默认开启）
STRATA_PLE_AUTO_MMAP=1        # 恢复 0.1.42 的自动 mmap 切换（默认不再自动切）
STRATA_MTP_SIDE_STREAM=0/1    # 覆盖 RX 6000 的 side stream 行为
```

**④ 多卡/服务端相关（release notes）：**

```text
"before_load_strict": true         # hook 失败时始终拒绝加载
"before_load_ignore_failure": true # 保留旧行为
"before_load_timeout_s": <seconds> # hook 超时
POST /unload?wait=1                # 卸载前等待当前 turn 结束
```

> TODO: 候选标题中的「RTX 4090 / 100T/s」为 backlog 自动生成口径；README 官方基准覆盖 RTX 5070(12GB) 与 RX 9070 XT(16GB)，并对 24GB 卡（RTX 3090）给出「约 100–140 tok/s」的预估，具体 4090 实测数据未在源材料中直接给出，待补充。

---
[← Back to Deep Dives](./README.md)
