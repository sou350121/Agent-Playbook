---
auto_generated: true
generated_at: "2026-11-04T03:30:34Z"
source_url: "https://vercel.com/changelog/data-cache-is-moving-to-runtime-cache"
signal_type: "significant_update"
---
# Vercel Data Cache 并入 Runtime Cache：Next.js 缓存从「免费」走向按读写计费 (Vercel Merges Data Cache into Runtime Cache: Next.js Caching Becomes Metered)

> 🔍 本文由 Moltbot 自动生成 | 2026-11-04
>
> **项目/工具**: Vercel Runtime Cache（原 Data Cache）
> **链接**: https://vercel.com/changelog/data-cache-is-moving-to-runtime-cache
> **核心定位**: Next.js 的 `fetch` 缓存与 `unstable_cache` 底层从 Data Cache 迁到 Runtime Cache——代码不用改，但原本不计费的读写开始按区域单价收费。

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句話定位**：Vercel 把散落的四个缓存 API（`fetch` 缓存、`unstable_cache`、`getCache`、`'use cache: remote'`）统一到 Runtime Cache 之下，同时把此前免费的读取/写入变成计费项。
- **現在值得用嗎**：是，但前提是你先把项目的缓存读写量看清楚——否则迁移后你的 $20 Pro 基础设施额度可能被吃掉一大块。
- **適合場景**：Next.js App Router 项目、SvelteKit/Nuxt 上跑在 Vercel、以及需要跨请求复用数据但不想自建 Redis 的团队。
- **不適合場景**：缓存命中率极低却写入量巨大的项目（写入单价 $4.00/百万，比读取贵 10 倍）；以及必须跨区域强一致读取的场景——Runtime Cache 每个区域独立，miss 时不会去别的区域找。
- **與 Data Cache 的核心差异**：存储配额按项目/环境独立分配（Pro 8 倍、Enterprise 10 倍），但读写从免费变计费。

## 是什么 / 解决什么问题

Vercel 的 Data Cache 自 App Router 时代就存在，专门存「应用用来生成响应的那部分数据」——它和 CDN 缓存不同，CDN 存的是完整 HTTP 响应，Data Cache 存的是数据本身。所以一个商品页可以复用缓存的目录数据，同时为每个访客渲染个性化响应。

问题是这套服务此前只服务 Next.js。为了让其他框架也能用，Vercel 在一年前推出了带直连 API 的 Runtime Cache（`getCache` from `@vercel/functions`），可以用于 Routing Middleware 里的 feature flag 查询、构建期缓存 CMS 内容、以及 SvelteKit 和 Nuxt 的数据缓存。Next.js 自己的 `'use cache: remote'` 也跑在 Runtime Cache API 上。

于是系统里同时存在两套存储、两套预算、两套观测工具。这次合并的目的是收口：所有四个 API 走同一套存储预算和用量工具，方便人（和 coding agent）统一优化。代价是此前不计费的 Data Cache 读写从此按 Runtime Cache 的区域价格计费。

## 技术架构拆解

### 核心设计决策

- **统一存储层而非统一 API 层**：Next.js 的 `fetch` 缓存和 `unstable_cache` 用户代码零改动，变化发生在底层存储与计费。这是典型的「无感迁移 + 有感账单」。
- **按项目/环境分配存储，而非团队池**：Pro 上每个项目每个环境拿到独立配额，容量是原先团队共享池的 8 倍；Enterprise 项目拿到原 Data Cache 存储的 10 倍。这直接降低了因配额紧张触发的 eviction。
- **区域独立缓存，miss 不跨区域查找**：一次 cache hit 只需要在代码运行的区域内做一次往返。代价是冷区域必然 miss，需要自己回源。
- **标签失效（tag invalidation）用时间戳而非批量删除**：每个条目存自己的标签和写入时间，读取时去同区域的 tag store 查这些标签的失效时间戳；只要任一标签在条目写入后被失效，条目即视为 stale。失效百万条目只需写一个时间戳。
- **全局管道分发失效**：失效立即更新接收请求区域的 tag store，再通过全球 push 管道分发，通常几百毫秒内到达其他区域。
- **熔断器换延迟、放弃瞬时强一致**：判断条目是否新鲜本身依赖 tag store，流量尖峰时慢分片会拖累 hit。Vercel 加了熔断，允许读取用内存中的 tag 时间戳做判断——**这个 fallback 期间，刚被失效的数据可能被短暂当作新鲜**。

### 与前版/竞品的关键差异

| 维度 | 之前（Data Cache） | 现在（Runtime Cache） |
|------|------------|------------|
| 适用框架 | 仅 Next.js（`fetch` 缓存 / `unstable_cache`） | Next.js 四种 API + SvelteKit / Nuxt / 直接 `getCache` |
| 存储配额（Pro） | 团队级共享池 | 每项目每环境独立，容量 8 倍 |
| 存储配额（Enterprise） | 原配额 | 原配额的 10 倍 |
| 读写计费 | 不计费 | 读取 $0.40/百万起，写入 $4.00/百万起，按区域浮动 |
| 免费额度（Hobby） | — | 每月 100 万读 + 20 万写，全项目合计 |
| 跨区域行为 | 同上 | 每区域独立，miss 不跨区域回查 |
| 观测能力 | 基础 | 增加 deployment marker、revalidation 原因、写入利用率 |

### 架构/信息流图

```
请求 → 代码/框架 (fetch cache | unstable_cache | getCache | 'use cache: remote')
                │
                ▼
        Runtime Cache 区域实例  ←── Go API
                │
        ┌───────┴────────┐
        ▼                ▼
   value store       tag store (失效时间戳)
        │                │
        │        ┌───────┴────────┐
        │        │ 熔断时：读内存快照 │  ← 可能短暂读到已失效数据
        │        └───────┘
        ▼
    HIT → 一次区域内往返返回
    MISS → 应用回源取数/计算 → 写回本区域
                                    │
        tag 失效 ──► 写时间戳 ──► 全球 push 管道（数百 ms 内到其他区域）
```

## 实用评估

### 什么场景值得用

- **Next.js App Router 项目**：代码零改动，Pro 下存储直接变 8 倍，eviction 减少往往意味着命中率上升。Vercel 官方数据：在 eviction 频繁的 Enterprise 项目中，缓存 miss 率约在一天内减半。
- **多框架混用 Vercel 的团队**：SvelteKit / Nuxt 终于能吃到和 Next.js 同级的缓存服务，不用另起 Redis。
- **流量尖峰敏感的应用**：Vercel 称八月全区域启用熔断后，最大区域在同等流量下的 p99 cache-service 读取延迟降到原来的约五分之一，相关 on-call 告警消失。

### 什么场景不值得用

- **写多读少的缓存模式**：写入 $4.00/百万 是读取的 10 倍。把「每次请求都 set 一遍」当幂等保护用的代码，迁移后会立刻变成账单事故。官方也承认提供「写入利用率」指标就是为了找「写了但很少被读」的数据。
- **要求跨区域强一致的读取**：区域缓存互不可见，冷区域首次请求必然回源。如果业务假设缓存全局一致，需要重新设计。
- **失效后必须绝对立刻不可见的场景**（合规、价格、权限类数据）：熔断 fallback 期间可能把刚失效的条目当新鲜返回。这是官方明写的权衡。
- **重度依赖 CDN 层缓存的静态内容**：Runtime Cache 存的是数据不是响应，放错层会白白付读写费。

### 迁移成本

- **代码改动**：Next.js 用户为 0。其他框架若未接入，需要改用 `getCache` API。
- **时间线**：2026-10-30 之后新建的团队默认走 Runtime Cache；已有 Hobby 团队在 2026-11-29 被自动迁移；Pro 会收到具体迁移日期与计费生效时间通知；Enterprise 由客户团队单独联系。10-30 起 Hobby/Pro 可从团队的 CDN 设置中提前 opt-in，opt-in 即刻按新价计费。
- **必做的功课**：迁移前用 Observability 的 Runtime Cache 视图核对读写量，再按官方优化指南（或把官方提供的 agent prompt 丢给 coding agent，或在 dashboard 用 "Optimize with Vercel Agent"）压掉不必要的读写。这部分工作量取决于项目缓存策略的混乱程度，无法给统一数字。
- **可选的退路**：在 CDN 设置里禁用 `fetch` / `unstable_cache` 缓存——更多请求打回数据源，但不会阻止迁移。

## 对你的意义

对 Agent / RAG 类应用，这事比看起来重要。典型 RAG 前端会把检索结果、embedding 查表、工具调用结果塞进 `unstable_cache`，而这类缓存经常是「写一次读一次」——正好踩中最坏的价格结构。如果你的 Agent 工作流里有工具结果的缓存层，**迁移前先看写入利用率**，很可能有一半写入是纯浪费。

对用 Vercel 孵化的 Agent UI 项目：建议是「提前 opt-in + 立刻做一轮读写优化」。理由不是省钱，而是提前暴露缓存策略问题——真正痛的是自动迁移当天账单突增，却不知道是哪段代码在写。

`getCache` 的存在也提示一个架构机会：SvelteKit / Nuxt 上的 Agent 前端不必再自建 Redis 做会话级数据缓存。但同样先算写入量。

> TODO: 本文未核实各区域具体单价差异（官方称 $0.40/百万读、$4.00/百万写「起」，按区域浮动），如需预算建议直接查区域定价页。

## 关键代码/配置片段

从 Next.js 现有代码迁移：不需要改代码，`fetch` 缓存与 `unstable_cache` 会自动切换到 Runtime Cache。

若要在 Next.js 之外直接使用缓存服务（源材料中给出的 API 名称）：

```
import { getCache } from '@vercel/functions'

const cache = getCache()
```

标签失效模型（源材料描述的语义，非可直接复制代码）：给同一类数据打同一个 tag，比如所有商品数据都打 `catalog`；目录变更时只需失效 `catalog` 这个 tag，写一个时间戳即可让百万条条目同时变 stale。

框架侧接入示例：Next.js 的 `'use cache: remote'` 本身就用 Runtime Cache API 缓存函数与组件输出。

---
[← Back to Deep Dives](./README.md)
