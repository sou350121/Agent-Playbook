---
auto_generated: true
generated_at: "2026-06-15T08:04:16Z"
source_url: "https://kyushu.dev/"
signal_type: "significant_update"
---
# Kyushu：自托管 WASM 沙箱，零依赖运行 JS/TS Worker (Kyushu: A Self-Hostable Wasm Sandbox for JavaScript Workers)

> 🔍 本文由 Moltbot 自动生成 | 2026-06-15
>
> **项目/工具**: Kyushu
> **链接**: https://github.com/peterpeterparker/kyushu
> **核心定位**: 一个开源 CLI 工具，让你将 JavaScript/TypeScript handler 编译为 WebAssembly 二进制，无需 Node.js/Bun/Docker 即可在任何 VPS 上运行——类 Cloudflare Workers 体验的自托管替代方案。

## 快速判断（30 秒讀完這段就夠了）

- **一句話定位**：Kyushu 让你用 Cloudflare Workers 风格的 API 写 JS/TS 函数，编译成 `.wasm` 后通过单个二进制 `kyu` 在任何 VPS 上运行，完全不依赖 Node.js 运行时。
- **現在值得用嗎**：看场景。适合需要轻量沙箱隔离执行不可信代码的场景（如 AI Agent 代码执行、用户自定义逻辑）；**不适合生产环境**——项目明确标注为早期实验阶段。
- **適合場景**：AI Agent 安全执行沙箱、VPS 上的边缘风格 handler 部署、不想管理 Node.js/Docker 的轻量场景
- **不適合場景**：生产级多租户隔离（沙箱安全性未经审计）、需要完整 npm 生态的动态 import 场景、需要顶层 console.log 调试的场景
- **與 Cloudflare Workers 核心差異**：Workers 是托管 PaaS（受限平台），Kyushu 是自托管方案（完全控制基础设施），但牺牲了成熟度和安全审计。

## 是什么 / 解决什么问题

Kyushu 的诞生源于作者构建 [Juno](https://github.com/junobuild/juno) 平台时的经验——一个让应用运行在容器中的平台。当他尝试 Cloudflare Workers 后，发现其"单个函数、沙箱化、处理 HTTP"的模型非常优雅，但希望把它带到自己的 VPS 上，而不是依赖 Cloudflare 的托管平台。

核心痛点很明确：在 AI Agent 需要安全执行不可信代码的时代，现有的方案要么太重（Docker 容器），要么受限于平台（Cloudflare Workers），要么依赖庞大的运行时（Node.js/Bun）。Kyushu 试图用 WebAssembly 填补这个空白——一个单个二进制、零依赖、强隔离的 JS/TS 执行环境。

项目的定位非常诚实：**早期实验阶段**。README 明确警告"expect breaking changes, missing features, and rough edges"，不建议生产使用。但这恰恰是它值得深度分析的原因——它代表了一种新的思路：用 WASM 替代容器作为轻量沙箱。

## 技术架构拆解

### 核心设计决策

Kyushu 的架构由两个核心组件构成：

1. **Worker（构建阶段）**：一个 `wasm32-wasip2` 组件，内部嵌入了 QuickJS JavaScript 运行时。当你运行 `kyu build` 时，TypeScript/JavaScript 入口文件通过 [Rolldown](https://rolldown.rs) 打包，然后用 [Wizer](https://github.com/bytecodealliance/wizer) 进行预初始化——将代码冻结在内存快照中。输出的 `.wasm` 文件包含了你的代码和运行时，随时准备处理请求。

2. **Runner（运行阶段）**：`kyu run` 是一个用 Rust 编写的二进制工具，底层由 [Wasmtime](https://wasmtime.io) 驱动。它加载你构建好的 worker，启动 HTTP 服务器，将传入的请求分发到 WASM 沙箱中执行。JavaScript 在沙箱内运行，与宿主文件系统和社会环境完全隔离——除非你通过配置显式允许。

### 关键设计选择

| 维度 | 设计选择 | 理由 |
|------|---------|------|
| JS 运行时 | QuickJS（嵌入 WASM） | 轻量、WASM 友好，比 V8 小得多 |
| 打包工具 | Rolldown | Rust 编写的极速 bundler，替代 Webpack/esbuild |
| 预初始化 | Wizer (Bytecode Alliance) | 将模块初始化阶段"冻结"为快照，启动即热 |
| WASM 执行引擎 | Wasmtime | 成熟、符合 WASIP2 标准、强安全隔离 |
| API 风格 | Cloudflare Workers ExportedHandler | 降低学习曲线，代码可移植 |
| 语言 | Rust（runner）+ TS/JS（worker） | runner 追求性能和安全性，worker 保持开发者友好 |

### 架构/信息流图

```
构建阶段 (kyu build)                    运行阶段 (kyu run)
┌──────────────────────┐               ┌─────────────────────────────┐
│ src/index.ts         │               │ HTTP Request                │
│   (Your Handler)     │               │      │                      │
└──────┬───────────────┘               │      ▼                      │
       │                               │  ┌─────────────────────┐    │
       ▼                               │  │    Wasmtime (host)  │    │
┌──────────────────────┐               │  │                     │    │
│ Rolldown (bundler)   │               │  │  ┌───────────────┐  │    │
│  + Wizer (snapshot)  │               │  │  │ worker.wasm   │  │    │
└──────┬───────────────┘               │  │  │ (sandbox)     │  │    │
       │                               │  │  │               │  │    │
       ▼                               │  │  │ QuickJS + JS  │  │    │
┌──────────────────────┐               │  │  │   your code   │  │    │
│ worker/              │               │  │  └───────────────┘  │    │
│   __kyushu_worker.   │──────────────►│  │                     │    │
│   wasm               │               │  └─────────────────────┘    │
└──────────────────────┘               │      │                      │
                                       │      ▼                      │
                                       │  HTTP Response              │
                                       └─────────────────────────────┘
```

### 与竞品的关键差异

| 维度 | Cloudflare Workers | Docker 容器 | Node.js 直接运行 | Kyushu |
|------|-------------------|-------------|-----------------|--------|
| 部署位置 | Cloudflare 平台 | 任意（需 Docker） | 任意（需 Node） | 任意（单二进制） |
| 启动延迟 | ~ms 级 | ~秒级 | ~百ms 级 | ~ms 级（Wizer 快照） |
| 资源占用 | 极低（托管） | 高（完整 OS 层） | 中（V8 引擎 ~50MB） | 极低（Wasmtime ~数MB） |
| 隔离强度 | 平台级 | OS 级（cgroups/namespaces） | 无隔离 | WASM 沙箱级 |
| npm 兼容性 | 有限 | 完整 | 完整 | 有限（无动态 import） |
| 多租户安全 | 生产级 | 生产级 | 不适用 | 实验阶段（未审计） |
| 自托管 | ❌ | ✅ | ✅ | ✅ |
| 依赖管理 | 零 | Docker 引擎 | Node.js + npm | 单个 `kyu` 二进制 |

## 实用评估

### 什么场景值得用

**1. AI Agent 代码执行沙箱**
这是 Kyushu 最自然的使用场景。当 AI Agent 需要执行用户提交的代码片段时，Kyushu 提供了一个轻量、隔离的执行环境。相比 Docker 容器（启动慢、资源重）或直接 Node.js 执行（无隔离），WASM 沙箱在启动速度和资源占用上有明显优势。QuickJS 运行时嵌入在 `.wasm` 文件内，每个请求在独立沙箱中运行，模块级变量不会跨请求持久化——这天然适合无状态的代码执行任务。

**2. VPS 上的边缘风格 handler 部署**
如果你有自己的 VPS 但不想依赖 Cloudflare/AWS Lambda 等托管平台，Kyushu 让你用熟悉的 Workers API 编写 handler，然后部署在自己的服务器上。配置简单——一个 `kyu run` 命令即可启动 HTTP 服务，默认监听 5987 端口。

**3. 需要文件系统隔离的场景**
Kyushu 支持通过 `worker.mounts` 配置显式挂载宿主文件系统到沙箱内，并可控制读写权限。这对于需要限制 worker 访问特定目录的场景很有用——默认情况下 worker 对文件系统完全不可见。

### 什么场景不值得用

**1. 生产环境多租户隔离**
项目明确声明沙箱安全性未经独立审计。QuickJS 的 Node.js 兼容 polyfill（来自 wasm-rquickjs 项目）的安全性未知。在未经彻底安全审查前，不应将 Kyushu 暴露给不可信输入。

**2. 依赖动态 import() 的 npm 包**
许多 npm 包使用动态 `import()` 作为逃避打包的手段。Kyushu 的 WASM 沙箱没有 Node.js 模块解析能力，这些动态导入会在运行时抛出 `ReferenceError`。例如 `file-type` 包的 `fromFile` 方法动态导入 `strtok3`，必须改用 `fromBuffer` 等浏览器/边缘 API 变体。

**3. 需要顶层 console.log 调试的场景**
由于 Wizer 预初始化机制，模块顶层的 `console.log` 调用会被静默吞掉——因为在快照化过程中写入 stdout 会破坏运行时的内部 stdio 状态。只能在 fetch handler 内部使用 console.log。

### 迁移成本

从 Cloudflare Workers 迁移到 Kyushu：
- **API 层**：高度兼容。Workers 的 `ExportedHandler` 接口基本一致，`fetch(request)` handler 可直接复用。
- **依赖层**：需检查所有 npm 依赖是否使用动态 import()，如有需替换为静态导入或边缘兼容 API。
- **基础设施层**：需安装 `kyu` 二进制（`curl -fsSL https://kyushu.dev/install | bash`），配置 Nginx/Caddy 反向代理到 5987 端口。
- **估计工作量**：简单 handler 1-2 小时；复杂应用需逐个检查依赖兼容性，可能 1-2 天。

从 Docker 容器迁移：
- 架构范式不同（容器 → WASM 函数），需重写部署逻辑。
- 优势：启动速度从秒级降到毫秒级，资源占用从百 MB 降到 MB 级。
- 估计工作量：取决于应用复杂度，通常半天到数天。

## 对你的意义

对于 Ken 的 AI 应用开发方向，Kyushu 最值得关注的是它的 **Agent 沙箱潜力**。

在 Agent 框架中，执行不可信代码（用户提交的工具函数、第三方插件、动态生成的逻辑）是一个持续存在的安全挑战。当前的主流方案是 Docker 容器隔离——但它太重了。Kyushu 代表的 WASM 沙箱方案提供了一个更轻量的替代路径：

- 单个二进制部署，无需 Docker 守护进程
- 毫秒级启动，适合高频短任务
- 强隔离：默认无文件系统/网络访问

但需要注意，这个项目仍处于实验阶段。建议：
- **短期**：在本地开发环境中试用，验证 Agent 代码执行场景的可行性
- **中期**：关注 Wasmtime 和 QuickJS WASM 集成的安全审计进展
- **长期**：如果 WASM 沙箱安全性得到验证，可能成为 Agent 执行层的标准选项之一

## 关键代码/配置片段

### Worker 入口（TypeScript）

```typescript
// src/index.ts
import type { ExportedHandler } from "kyushu-types";

export default {
  async fetch(request) {
    return {
      status: 200,
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ hello: "world" }),
    };
  },
} satisfies ExportedHandler;
```

### 配置文件示例（挂载文件系统 + 环境变量）

```toml
# kyu.toml
[run]
wasm = "worker/__kyushu_worker.wasm"
port = 5987

[[worker.mounts]]
host = "./data"
guest = "/data"
writable = false

[[worker.env]]
key = "API_KEY"
value = "${SECRET_API_KEY}"
```

### 构建与运行

```bash
# 1. 编写 worker
# 2. 构建为 WASM
kyu build
# → 输出 worker/__kyushu_worker.wasm

# 3. 运行
kyu run
# → Listening on http://0.0.0.0:5987

# 4. 开发模式（热重载）
kyu dev
```

### WorkerRequest / WorkerResponse 接口

```typescript
interface WorkerRequest {
  method: WorkerMethod;      // GET, POST, etc.
  url: string;               // Full request URL
  headers?: Record<string, string>;
  body?: string | ArrayBuffer | Uint8Array;
}

interface WorkerResponse {
  status?: number;           // Default: 200
  body?: string | ArrayBuffer | Uint8Array;
  headers?: Record<string, string>;
}
```

---
[← Back to Deep Dives](./README.md)
