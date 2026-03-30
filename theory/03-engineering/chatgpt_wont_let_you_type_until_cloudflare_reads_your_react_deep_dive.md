---
auto_generated: true
generated_at: "2026-03-30T03:31:54Z"
source_url: "https://www.buchodi.com/chatgpt-wont-let-you-type-until-cloudflare-reads-your-react-state-i-decrypted-the-program-that-does-it/"
signal_type: "blog_post"
---
# ChatGPT 的隐形守门员：Cloudflare 如何读取你的 React 状态 (ChatGPT's Invisible Gatekeeper: How Cloudflare Reads Your React State)

> 🔍 本文由 Moltbot 自动生成 | 2026-03-30
>
> **项目/工具**: Cloudflare Turnstile + OpenAI Sentinel
> **链接**: https://www.buchodi.com/chatgpt-wont-let-you-type-until-cloudflare-reads-your-react-state-i-decrypted-the-program-that-does-it/
> **核心定位**: 解密 ChatGPT 网页中 Cloudflare Turnstile 的 bot 检测机制——不仅验证浏览器真实性，还验证 React 应用是否完全渲染

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：Cloudflare Turnstile 在 ChatGPT 中运行的 bot 检测程序，通过解密 377 个样本发现其检查 55 个属性，包括 React 应用内部状态
- **現在值得用嗎**：不适用（这是分析文章，不是工具推荐）
- **適合場景**：AI 应用开发者需要理解 bot 检测边界；安全研究人员关注指纹收集范围
- **不適合場景**：普通用户无需关心（透明运行）
- **與傳統 bot 檢測核心差異**：从浏览器层指纹升级到应用层验证——必须真正渲染 React SPA 才能通过

## 是什么 / 解决什么问题

ChatGPT 的每个消息请求都会触发一个 Cloudflare Turnstile 程序在浏览器中静默运行。安全研究员 Buchodi 通过解密 377 个网络流量中的 Turnstile 字节码，发现了一套远超传统浏览器指纹收集的检测机制。

传统 bot 检测停留在浏览器层：检查 User-Agent、Canvas 指纹、WebGL 渲染器等。但 Turnstile 在 ChatGPT 中的实现增加了一个关键维度：**应用层验证**。它检查 `__reactRouterContext`、`loaderData`、`clientBootstrap` 等 React 内部数据结构——这些属性只有在 ChatGPT 的 React 单页应用完全渲染和水合（hydration）后才会存在。

这意味着什么？一个能伪造浏览器指纹的 bot，如果没有真正渲染 ChatGPT 的 React 应用，就会失败。这是 bot 检测从「验证你是真实浏览器」升级到「验证你是真实用户在使用真实应用」的标志性案例。

## 技术架构拆解

### 核心设计决策

**双层加密设计**：
- 外层：Turnstile 字节码用 `p` token XOR 加密（`p` 在同一 HTTP 请求中传输，可轻松解密）
- 内层：19KB 的指纹程序用另一个 XOR 密钥加密
- 关键发现：内层密钥是一个浮点数字面量（如 `97.35`），直接嵌入在字节码指令中

**55 属性三层架构**：
```
Layer 1: Browser Fingerprint (浏览器指纹)
├── WebGL (8 properties): UNMASKED_VENDOR_WEBGL, GPU 型号等
├── Screen (8): colorDepth, pixelDepth, 分辨率等
├── Hardware (5): hardwareConcurrency, deviceMemory, maxTouchPoints
├── Font measurement (4): 隐藏 div 测量字体渲染尺寸
├── DOM probing (8): createElement, 样式探测
└── Storage (5): localStorage 读写，指纹持久化

Layer 2: Cloudflare Network (Cloudflare 网络层)
├── cfIpCity, cfIpLatitude, cfIpLongitude
├── cfConnectingIp, userRegion
└── 仅当请求经过 Cloudflare 边缘节点才存在

Layer 3: Application State (应用状态) ← 关键创新
├── __reactRouterContext (React Router v6+ 内部结构)
├── loaderData (路由加载器结果)
└── clientBootstrap (ChatGPT 专属 SSR 水合标记)
```

**VM 执行模型**：
- 28 个操作码（ADD, XOR, CALL, BTOA, RESOLVE, BIND_METHOD, JSON_STRINGIFY 等）
- 每程序 417-580 条指令（平均 480 条）
- 随机化的浮点寄存器地址（每请求变化）

### 与前版/竞品的关键差异

| 维度 | 传统 bot 检测 (reCAPTCHA v2) | Cloudflare Turnstile (ChatGPT 实现) |
|------|----------------------------|----------------------------------|
| 检测层级 | 浏览器指纹 + 行为挑战 | 浏览器 + 网络 + 应用状态三层 |
| 用户交互 | 需要点击「我不是机器人」 | 完全静默，无感知 |
| React 感知 | 无 | 检查 `__reactRouterContext` 等内部状态 |
| 加密强度 | 固定密钥或无加密 | 每请求动态密钥（但嵌入在载荷中） |
| 可解密性 | 低 | 高（密钥在字节码中明文存在） |
| 持久化 | Session/Cookie | localStorage + 每请求动态生成 |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────────┐
│                    ChatGPT User Action                       │
│                    (type message, send)                      │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│              Cloudflare Turnstile Prepare Request            │
│  Client → Cloudflare: request turnstile challenge            │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│              Encrypted Bytecode Response                     │
│  turnstile.dx: 28,000 chars base64 (XOR'd with p token)     │
│  p token: sent in same HTTP exchange                         │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│              Client-Side Decryption Chain                    │
│  1. XOR(base64decode(dx), p) → outer bytecode (89 instr)    │
│  2. Find 5-arg instruction → extract float key (e.g. 97.35) │
│  3. XOR(19KB blob, key) → inner program (417-580 instr)     │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│              VM Execution: 55 Properties Collection          │
│  Layer 1: Browser (WebGL, Screen, Hardware, Font, DOM)      │
│  Layer 2: Cloudflare Edge Headers (city, IP, region)        │
│  Layer 3: React State (__reactRouterContext, loaderData)    │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│              Token Generation                                │
│  JSON.stringify(fingerprint) → XOR → RESOLVE               │
│  Result: OpenAI-Sentinel-Turnstile-Token header             │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│              ChatGPT Conversation Request                    │
│  POST /conversation with Turnstile token attached           │
└─────────────────────────────────────────────────────────────┘
```

## 实用评估

### 什么场景值得研究

- **AI 应用开发者**：如果你正在构建需要 bot 保护的 AI 应用，这是当前最前沿的实现参考。Turnstile 的应用层验证思路值得借鉴。
- **安全研究人员**：加密密钥嵌入在字节码中的设计值得深入分析——这是「足够隐藏」而非「真正加密」的典型案例。
- **隐私倡导者**：55 个属性的收集范围（包括 GPU 型号、字体渲染、localStorage 持久化）引发了数据最小化原则的讨论。

### 什么场景不值得过度解读

- **普通用户**：这是透明运行的机制，不影响正常使用。无需采取任何行动。
- **bot 开发者**：不要试图绕过——这个分析展示了防御方的深度，但攻防是动态的。Buchodi 强调所有流量来自授权参与者，未未经授权访问任何系统。
- **竞品分析**：Turnstile 的具体实现细节可能随时变化，不应作为长期依赖的设计依据。

### 迁移成本

这不是一个可「迁移」的工具，而是 Cloudflare 服务的一部分。如果你正在使用 reCAPTCHA 或其他 bot 检测方案并考虑切换到 Turnstile：

- **集成成本**：低（Cloudflare 提供 SDK）
- **定制成本**：高（应用层验证逻辑需要自行设计）
- **隐私合规成本**：中（需评估 55 属性收集是否符合 GDPR/CCPA）

## 对你的意义

**对 Ken 的 AI 应用开发工作的启示**：

1. **Agent Playbook 应增加 bot 检测模式条目**：当前 `theory/03-engineering` 主要关注工程实践，但 AI 应用的 bot 保护是一个快速增长的需求领域。建议添加：
   - `03-engineering/bot-detection-patterns.md`
   - 对比 Turnstile / reCAPTCHA / hCaptcha / 自建方案

2. **隐私边界设计值得提前思考**：如果你在构建 AI 应用并考虑集成 bot 检测，Turnstile 的案例提醒我们：
   - 收集哪些数据是必要的？
   - 哪些数据应该本地处理而非上传？
   - 如何向用户透明披露？

3. **应用层验证是趋势**：随着 bot 工具越来越成熟（能伪造浏览器指纹），仅靠浏览器层检测已经不够。考虑在你的 Agent 框架中加入「应用完整性验证」的设计模式。

**建议**：观望为主。Turnstile 的具体实现细节可能变化，但其设计思路（应用层验证 + 静默运行 + 动态加密）值得记录到 Agent Playbook 中。

## 关键代码/配置片段

### 外层解密（Python）

```python
# XOR decrypt outer layer using p token from same HTTP exchange
outer = json.loads(bytes(
    base64decode(dx)[i] ^ p_token[i % len(p_token)]
    for i in range(len(base64decode(dx)))
))
# → 89 VM instructions
```

### 内层密钥提取

```python
# Key is embedded in bytecode as a float literal in a 5-arg instruction
# Example instruction: [41.02, 0.3, 22.58, 12.96, 97.35]
# The last argument (97.35) is the XOR key for the 19KB inner blob

# Verified across 50 requests: 50/50 success rate
inner_blob = base64decode(encrypted_blob)
xor_key = str(instruction[4])  # 5th argument
decrypted = bytes(b ^ ord(xor_key[i % len(xor_key)]) for i, b in enumerate(inner_blob))
```

### Token 生成（最终 4 条指令）

```python
# After collecting 55 properties, the program executes:
[
    [96.05, 3.99, 3.99],      # JSON.stringify(fingerprint)
    [22.58, 46.15, 57.34],    # store
    [33.34, 3.99, 74.43],     # XOR(json, key)
    [1.51, 56.88, 3.99]       # RESOLVE → becomes the token
]
# Result sent as: OpenAI-Sentinel-Turnstile-Token header
```

### 55 属性完整列表（摘要）

```
Layer 1 - Browser (38 properties):
- WebGL: UNMASKED_VENDOR_WEBGL, UNMASKED_RENDERER_WEBGL, getParameter, getContext
- Screen: colorDepth, pixelDepth, width, height, availWidth, availHeight, availLeft, availTop
- Hardware: hardwareConcurrency, deviceMemory, maxTouchPoints, platform, vendor
- Font: fontFamily, fontSize, getBoundingClientRect, innerText (via hidden div)
- DOM: createElement, appendChild, removeChild, style, position, visibility, ariaHidden
- Storage: storage, quota, estimate, setItem, usage + localStorage key 6f376b6560133c2c

Layer 2 - Cloudflare Network (5 properties):
- cfIpCity, cfIpLatitude, cfIpLongitude, cfConnectingIp, userRegion

Layer 3 - Application State (3 properties):
- __reactRouterContext, loaderData, clientBootstrap

Plus: Signal Orchestrator (36 behavioral properties) + PoW (25 fingerprint fields)
```

## 数据摘要

| 指标 | 数值 |
|------|------|
| 解密程序数量 | 377/377 (100%) |
| 观察到的独立用户 | 32 |
| 每程序属性数 | 55 (所有样本一致) |
| 每程序指令数 | 417-580 (平均 480) |
| 50 样本中的唯一 XOR 密钥 | 41 |
| Signal Orchestrator 行为属性 | 36 |
| PoW 指纹字段 | 25 |
| PoW 求解时间 | 72% 在 5ms 内 |

---

**方法论说明**：所有流量来自授权参与者，未未经授权访问任何系统。Turnstile SDK 经过美化手动反混淆。所有解密离线使用 Python 执行。不披露任何个人用户数据。

---
[← Back to Deep Dives](./README.md)
