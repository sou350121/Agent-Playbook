---
auto_generated: true
generated_at: "2026-07-24T11:03:10Z"
source_url: "https://simonwillison.net/2026/Jul/19/claude-code-in-bun-in-rust/"
signal_type: "significant_update"
---
# Claude Code 底层运行时迁移至 Rust 版 Bun (Claude Code Ships Bun Written in Rust)

> 🔍 本文由 Moltbot 自动生成 | 2026-07-24
>
> **项目/工具**: Claude Code (内嵌 Bun 运行时)
> **链接**: https://simonwillison.net/2026/Jul/19/claude-code-in-bun-in-rust/
> **核心定位**: Anthropic 将 Claude Code 的底层 JavaScript 运行时从 Zig 版 Bun 迁移至 Rust 版 Bun，以系统性消除内存安全缺陷，百万级设备已静默升级。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**: Claude Code v2.1.181+ 内嵌了用 Rust 重写的 Bun v1.4.0 运行时，这是 Bun 从 Zig 到 Rust 的完整语言迁移在 prod 的首次大规模部署。
- **现在值得用吗**: 是——如果你在用 Claude Code，你已经在使用了（无需额外操作）。
- **适合场景**: AI 编码助手终端体验、Node.js 兼容的本地工具链、追求启动速度的 CLI 场景
- **不适合场景**: 需要自行管理 Bun 版本的生产服务器（Rust 版 Bun 目前仅通过 canary 渠道发布，尚未正式 GA）
- **与之前版本核心差异**: 底层语言从 Zig → Rust，编译器在编译期消除了 use-after-free / double-free / 内存泄漏等整类 bug，而非依赖运行时 sanitizer 或代码规范

## 是什么 / 解决什么问题

Bun 是一个高性能 JavaScript 运行时 + 打包工具 + 包管理器，由 Jarred Sumner 于 2021 年用 Zig 语言从零构建。截至 2026 年中，Bun CLI 月下载量超过 2200 万次，Claude Code、OpenCode 等知名 AI 编码工具均以其为底层运行时。

然而，Bun 的 Zig 实现长期面临一个根本性难题：**JavaScript 是垃圾回收语言，而 Zig 是手动内存管理语言**。当 GC 管理的 JS 值与手动管理的 Zig 内存交错时，生命周期管理变得极其脆弱。Bun v1.3.14 的 bug 列表揭示了问题的严重性：

- `node:zlib` 中的 heap-use-after-free（异步 write 期间调用 reset 触发崩溃）
- `node:http2` 中可重入 JS 回调导致 hashmap rehash、内部流指针失效
- `UDPSocket.sendMany()` 中用户代码在 `valueOf()` 回调中 detach ArrayBuffer 导致堆越界写
- `crypto.scrypt` 内存泄漏（回调和保护缓冲区在输出分配失败时从未释放）
- `tlsSocket.setSession()` 每次调用泄漏约 6.5 KB 的 SSL_SESSION
- `fs.watch()` watcher 因引用计数下溢永久钉死为 GC root，永不回收

这些不是边缘情况——它们是 Bun 在复杂 Node.js API 兼容性场景下的系统性风险。Jarred Sumner 在博客中坦言："I was tired of going to sleep worrying about crashes in Bun."

**解决方案**: 将 Bun 的 535,496 行 Zig 代码（不含注释）整体迁移至 Rust。Rust 的所有权系统在编译期就能阻止 use-after-free、double-free 和大部分内存泄漏，将运行时崩溃变为编译期错误。

## 技术架构拆解

### 核心设计决策

| 决策点 | 选择 | 理由 |
|--------|------|------|
| 迁移策略 | 机械式逐行移植（minimal behavioral changes） | 保持现有测试套件不变，降低行为回归风险 |
| 目标语言 | Rust（而非 C++） | C++ 仍有内存安全问题且依赖 style guide；Rust 编译器提供硬性保证 |
| 迁移方式 | LLM 辅助（Claude Fable 5） | 传统手动重写需小团队一年；LLM 加速了机械性翻译 |
| 测试策略 | 复用 Bun 现有的 TypeScript 测试套件 | 测试代码不依赖运行时编程语言，可直接复用 |
| 部署策略 | 先通过 Claude Code 静默部署，再发布 canary | 百万级真实设备作为金丝雀，验证稳定性 |

### 与前版（Zig Bun）的关键差异

| 维度 | Zig 版 Bun | Rust 版 Bun |
|------|-----------|-------------|
| 内存安全 | 手动管理 + defer；依赖 ASAN + fuzzing + 代码审查 | 编译器保证（所有权系统）；use-after-free/double-free 是编译错误 |
| 清理机制 | 显式 `defer` / `errdefer` 在每个调用点 | 隐式 `Drop`（RAII-like 自动清理） |
| GC 交互 | 手动管理 GC 可见性；保守栈扫描易出错 | 类型系统提供更强约束 |
| 稳定性反馈 | 运行时崩溃 / ASAN 报错 / fuzzing 发现 | 编译期错误（更早、更确定） |
| 代码量 | 535,496 行 Zig | 等量 Rust（机械移植） |
| 性能 | 基准 | Linux 启动提速 ~10% |
| 发布状态 | GA（v1.3.x） | canary（v1.4.0），尚未正式 GA |

### 架构/信息流图

```
                    ┌─────────────────────────────────────┐
                    │         Claude Code CLI              │
                    │         (v2.1.181+)                  │
                    └──────────────┬──────────────────────┘
                                   │
                    ┌──────────────▼──────────────────────┐
                    │      内嵌 Bun 运行时                 │
                    │      v1.4.0 (Rust)                  │
                    │                                     │
                    │  ┌─────────────┐  ┌──────────────┐ │
                    │  │ JavaScript  │  │  Node.js API  │ │
                    │  │ Core (JSC)  │  │  兼容层       │ │
                    │  └──────┬──────┘  └──────┬───────┘ │
                    │         │                │         │
                    │  ┌──────▼────────────────▼───────┐ │
                    │  │   Rust 重写的核心运行时        │ │
                    │  │   (535K+ 行, 编译期内存安全)   │ │
                    │  └──────────────┬────────────────┘ │
                    └─────────────────┼──────────────────┘
                                      │
                    ┌─────────────────▼──────────────────┐
                    │    部署渠道                         │
                    │                                    │
                    │  [1] Claude Code 内嵌 (prod, 百万) │
                    │  [2] Bun canary (公开测试)         │
                    │  [3] Bun GA (尚未发布)             │
                    └────────────────────────────────────┘
```

### 为什么不是 C++？

Jarred 在博客中明确分析了 C++ 选项：Bun 已有约 20% 代码是 C++（嵌入 JavaScriptCore、uWebSockets、BoringSSL 等）。C++ 会提供构造函数/析构函数，减少 `extern "C"` 包装代码。但关键问题是：

> "We would still be reliant on style guides enforced through code review, and even with ASAN, memory corruption and memory leaks would still happen."

C++ 的内存安全依赖 style guide + code review + ASAN（运行时检测），而 Rust 的所有权系统在**编译期**就阻止了这些问题。对于 53 万行代码的迁移来说，编译器保证比风格指南可靠得多。

### LLM 在重写中的角色

这是一个值得关注的元叙事：Jarred Sumner 使用 Anthropic 的 Claude Fable 5（预发布版本）辅助完成了大部分机械性翻译工作。他在博客中说：

> "What if, instead, I spend a week testing if Anthropic's new model can rewrite Bun in Rust?"

> "At first, I didn't expect it to work. A few days in, a high % of the test suite started passing..."

这暗示了 LLM 在**系统级语言迁移**中的可行性——不是写新功能，而是将已有的、经过充分测试的代码从一种语言翻译到另一种语言。测试套件作为行为正确性的锚点，LLM 负责机械翻译，人类负责编译期错误修复和边界情况调整。

## 实用评估

### 什么场景值得用

- **AI 编码助手用户**: 如果你用 Claude Code，你已经在受益——Linux 上启动速度提升 10%，且内存安全缺陷系统性减少
- **关注运行时稳定性的团队**: Rust 版 Bun 的编译期保证意味着更少的生产崩溃，这对长时间运行的服务很重要
- **对 LLM 辅助工程感兴趣的开发者**: 这是 LLM 辅助大规模代码迁移的公开案例（535K 行 Zig → Rust），值得研究其方法论

### 什么场景不值得用

- **需要自行管理 Bun 版本的生产环境**: Rust 版 Bun 目前仅通过 canary 渠道发布（`bun upgrade --canary`），尚未正式 GA。生产环境建议等待 GA 版本
- **对 Zig 生态有依赖的项目**: 如果你的工具链深度依赖 Bun 的 Zig 实现细节（如特定的 C FFI 行为），迁移可能有兼容性风险
- **追求最新 Bun 功能的用户**: Rust 重写是机械移植，可能暂不包含 Zig 版后期的新特性

### 迁移成本

- **对 Claude Code 用户**: 零成本——升级 Claude Code 到 v2.1.181+ 即可
- **对独立 Bun 用户**: 等待 GA 发布；canary 版本可用于测试，但不建议生产使用
- **对 Bun 贡献者**: 需要学习 Rust；但测试套件不变（TypeScript），行为预期不变

## 对你的意义

这个迁移对 AI 应用开发生态有几个信号：

1. **Anthropic 对底层基础设施的垂直整合**: 2025 年 12 月收购 Bun，2026 年 6 月完成 Rust 重写并部署到 Claude Code——6 个月内的整合速度令人印象深刻。这意味着 Anthropic 不再只是模型提供商，而是在控制从模型到运行时的全栈。

2. **LLM 辅助系统编程的里程碑**: 535K 行 Zig → Rust 的迁移由 LLM 主导完成，这是 AI 辅助工程在系统编程领域的第一个大规模公开案例。如果这个模式可复制，未来语言迁移的成本将大幅下降。

3. **"Boring is good" 的工程哲学**: Jarred 的原话是 "Startup got 10% faster on Linux but otherwise, barely anyone noticed. Boring is good." 底层运行时迁移的最高境界是用户毫无感知——这正是成功的标志。

**建议**: 如果你在用 Claude Code，确保已升级到最新版本。如果你关注 Bun 生态，可以试用 canary 版本但生产环境等待 GA。对 LLM 辅助代码迁移感兴趣的团队，这个案例值得深入研究。

## 关键代码/配置片段

### 验证 Claude Code 使用的 Bun 版本（Simon Willison）

```bash
# 方法 1: 从二进制文件中提取版本字符串
strings ~/.local/bin/claude | grep -m1 'Bun v1'
# 输出: Bun v1.4.0 (macOS arm64)

# 方法 2: 确认 Rust 源码文件存在
strings ~/.local/bin/claude | grep -Eo 'src/[[:alnum:]_./-]+\.rs'
# 输出 563 个 .rs 文件名，例如:
# src/runtime/bake/dev_server/mod.rs
# src/runtime/bake/production.rs
# src/bundler/bundle_v2.rs

# 方法 3: 运行时版本检查（Ajan Raj 提供）
cat > /tmp/bun-version.ts <<'EOF'
console.log("embedded bun:", Bun.version);
process.exit(0);
EOF
BUN_OPTIONS="--preload=/tmp/bun-version.ts" claude --version
# 输出: 1.4.0
```

### Bun 官方 Rust 迁移的 commit（May 17, 2026）

```
# 版本更新 commit（Bun v1.4.0）
# https://github.com/oven-sh/bun/commit/b18bf6d1d0a92238f240bfd125f0e3b3461b9243
# package.json 中版本更新为 1.4.0，此后未变
```

### Zig vs Rust 清理机制对比（来自官方博客）

```
语言        清理机制
----        --------
Zig         defer, errdefer（显式，每个调用点）
C++         ~Destructor, &&Move（隐式，基于作用域）
Rust        Drop（隐式，编译器保证执行）
```

---
[← Back to Deep Dives](./README.md)
