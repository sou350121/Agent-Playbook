---
auto_generated: true
generated_at: "2026-04-03T12:41:17Z"
source_url: "https://simonwillison.net/2026/Mar/29/pretext/"
signal_type: "significant_update"
---
# Pretext: 高性能文本布局浏览器库 (Pretext: High-Performance Text Layout Library for Browsers)

> 🔍 本文由 Moltbot 自动生成 | 2026-04-03
>
> **项目/工具**: Pretext (@chenglou/pretext)
> **链接**: https://github.com/chenglou/pretext
> **核心定位**: 无需触碰 DOM 即可计算文本布局的纯 JS/TS 库，通过预计算 + 缓存机制将布局 reflow 开销降低 200 倍以上

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**: React 前核心开发者 Cheng Lou 新作，用 off-screen canvas 预测量 + 纯算术布局，避免 DOM reflow
- **現在值得用嗎**: 是 — 如果你需要动态文本布局、虚拟滚动、或 Canvas/SVG 文本渲染
- **適合場景**: 消息气泡自适应高度、masonry 布局、Canvas 文本渲染、防止 layout shift、AI 生成内容的浏览器外验证
- **不適合場景**: 简单静态文本、已有 CSS 布局能满足的场景、需要完整 CSS 排版功能的场景
- **與 [傳統方案] 核心差異**: 传统方案需 render → measure → reflow（昂贵），Pretext 只需一次 prepare + 多次廉价 layout（纯算术）

## 是什么 / 解决什么问题

Web 开发中一个长期存在的痛点是：**计算一段换行文本的高度必须实际渲染到 DOM 并测量**。这个流程会触发浏览器的 layout reflow，是浏览器最昂贵的操作之一。当你需要动态计算大量文本元素的高度（如消息列表、动态内容流、虚拟滚动）时，这种开销会迅速累积成性能瓶颈。

Pretext 由前 React 核心开发者、react-motion 原作者 Cheng Lou 创建，它绕过了 DOM 测量的需求。核心思路是：
1. 使用 off-screen canvas 的 `measureText` API 预先测量文本片段的宽度
2. 缓存这些测量结果
3. 通过纯算术模拟浏览器的换行逻辑，计算给定宽度下的文本高度

根据官方 benchmark 数据：
- `prepare()` 一次性开销：约 19ms（500 条文本批次）
- `layout()` 热路径开销：约 0.09ms（同样批次）

**性能提升约 200 倍**，且 `layout()` 可以无限次重复调用而无需重新测量。

## 技术架构拆解

### 核心设计决策

| 决策 | 理由 | 权衡 |
|------|------|------|
| **prepare/layout 分离** | 将昂贵的一次性分析（分词、测量、缓存）与廉价的重复计算（纯算术布局）分离 | 调用者需要理解两者的生命周期，不能对同一文本重复调用 prepare() |
| **使用 canvas measureText** | 直接调用浏览器的字体引擎，保证测量准确性 | 依赖浏览器实现，不同浏览器可能有细微差异 |
| **图粒度分段 (grapheme-level segmentation)** | 支持 emoji、混合双向文本（如韩文 + RTL 阿拉伯文）、非拉丁字符 | 增加了分段逻辑的复杂度 |
| **缓存共享** | 所有 prepare() 调用共享内部缓存，避免重复测量相同字体/文本 | 长时间运行的应用需手动调用 clearCache() 释放内存 |
| **不追求完整 CSS 排版** | 专注最常见的文本布局场景（white-space: normal, word-break: normal 等） | 不支持复杂的 CSS 排版功能（如 nested markup、pre-wrap 需显式开启） |

### 与前版/竞品的关键差异

| 维度 | 传统 DOM 测量方案 | Pretext |
|------|------------------|---------|
| **测量方式** | 实际渲染到 DOM → getBoundingClientRect/offsetHeight | off-screen canvas measureText + 缓存 |
| **性能** | 每次测量都触发 reflow（昂贵） | prepare 一次 + layout 无限次（纯算术） |
| **准确性** | 100% 准确（就是浏览器自己算的） | 接近 100%（用浏览器字体引擎做 ground truth） |
| **多语言支持** | 依赖浏览器原生支持 | 显式支持 emoji、混合双向文本、非拉丁字符 |
| **输出目标** | 只能用于 DOM | DOM、Canvas、SVG、未来支持服务端 |
| **包大小** | N/A（原生 API） | 几 KB |
| **测试方法** | 手动测试 | 用《了不起的盖茨比》全文 + 多语言语料库自动验证 |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────────┐
│                    Pretext 架构流程                          │
└─────────────────────────────────────────────────────────────┘

输入文本 + 字体声明
       │
       ▼
┌──────────────────┐
│   prepare()      │  ← 一次性开销 (~19ms/500 条)
│  - 空白规范化     │
│  - 文本分段       │  (词、软连字符、emoji、非拉丁字符)
│  - canvas 测量    │  (off-screen, 不触发 reflow)
│  - 缓存结果       │
└──────────────────┘
       │
       ▼
  PreparedText (不透明句柄)
       │
       ├─────────────────┬─────────────────┬─────────────────┐
       ▼                 ▼                 ▼                 ▼
┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│  layout()   │  │layoutWith   │  │walkLine     │  │layoutNext   │
│  (纯算术)    │  │Lines()      │  │Ranges()     │  │Line()       │
│  ~0.09ms    │  │(获取行列表)  │  │( speculative│  │(逐行迭代)   │
│             │  │             │  │ 测试宽度)    │  │             │
└─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘
       │
       ▼
{ height, lineCount } 或 { lines } 或 无返回值
```

## 实用评估

### 什么场景值得用

1. **虚拟滚动/列表优化**: 需要预先知道每个文本项的高度以计算滚动条位置和可视区域。Pretext 可以在数据加载时就计算高度，无需实际渲染。

2. **动态布局系统**: 如 masonry 布局、JS 驱动的 flexbox 实现。Pretext 允许你在 CSS 之外精确控制布局，实现 CSS 无法完成的复杂效果。

3. **Canvas/SVG 文本渲染**: 游戏、数据可视化、自定义 UI 组件需要在非 DOM 环境中渲染文本。Pretext 可以直接输出每行的位置和文本内容。

4. **防止 Layout Shift**: 在异步加载文本内容时，预先计算高度并预留空间，避免页面跳动影响用户体验。

5. **AI 生成内容的浏览器外验证**: 在 CI/CD 或开发阶段，无需启动浏览器就能验证按钮标签是否溢出、文本布局是否符合预期。

6. **多语言/混合文本场景**: 需要处理 emoji、RTL 文本、东亚字符混合的场景，Pretext 的图粒度分段提供了更好的支持。

### 什么场景不值得用

1. **简单静态文本**: 如果文本内容固定且布局简单，直接用 CSS 更简单可靠。

2. **需要完整 CSS 排版功能**: Pretext 不支持 nested markup、复杂的 CSS inline formatting、或自定义的 text-decoration。

3. **system-ui 字体场景**: 官方明确指出 system-ui 在 macOS 上布局准确性不安全，需使用命名字体。

4. **极度狭窄的容器**: 虽然支持 overflow-wrap: break-word，但极窄宽度下仍只在 grapheme 边界断行，可能导致意外效果。

5. **已有成熟布局方案**: 如果你的项目已经用 CSS Grid/Flexbox 满足了所有需求，引入 Pretext 只会增加复杂度。

### 迁移成本

**从传统 DOM 测量迁移到 Pretext**:

```javascript
// 旧方案
function measureTextHeight(text, font, maxWidth) {
  const span = document.createElement('span')
  span.style.font = font
  span.style.width = maxWidth + 'px'
  span.style.display = 'block'
  span.textContent = text
  document.body.appendChild(span)
  const height = span.offsetHeight
  document.body.removeChild(span)
  return height
}

// 新方案 (Pretext)
import { prepare, layout } from '@chenglou/pretext'

function measureTextHeight(text, font, maxWidth, lineHeight) {
  const prepared = prepare(text, font)
  const { height } = layout(prepared, maxWidth, lineHeight)
  return height
}
```

**工作量评估**:
- 基础替换：1-2 小时（理解 prepare/layout 分离模式）
- 复杂场景（如动态宽度、多字体）：半天到一天
- 测试验证：需在不同浏览器、不同文本内容下验证准确性

**注意事项**:
- 确保 font 字符串格式与 canvas.font 一致（如 `16px Inter`）
- lineHeight 需与 CSS line-height 声明同步
- 不要在 resize 等场景重复调用 prepare()，只调用 layout()

## 对你的意义

如果你在开发以下类型的项目，Pretext 值得立即试用：

1. **聊天/消息应用**: 消息气泡高度动态计算、虚拟滚动优化
2. **内容流/信息流产品**: 动态内容高度预计算、防止 layout shift
3. **数据可视化工具**: Canvas/SVG 文本标注、自定义布局
4. **设计系统/组件库**: 提供不依赖 DOM 的文本测量工具

**建议行动**:
1. 用 `bun install @chenglou/pretext` 快速试用
2. 访问 [chenglou.me/pretext](https://chenglou.me/pretext/) 查看官方 demo
3. 在你的项目中最耗时的文本测量场景做 A/B 测试

**观望理由**:
- 项目较新（2026 年 3 月底发布），生产环境案例有限
- 文档虽详细但缺少中文资源
- 社区生态尚未形成（插件、扩展、最佳实践）

## 关键代码/配置片段

### 基础用法

```javascript
import { prepare, layout } from '@chenglou/pretext'

// 一次性准备（昂贵，但只做一次）
const prepared = prepare('AGI 春天到了. بدأت الرحلة 🚀', '16px Inter')

// 多次布局计算（廉价，纯算术）
const { height, lineCount } = layout(prepared, 320, 20)
// height: 文本总高度
// lineCount: 行数
```

### 支持 textarea 风格的文本（保留空格/制表符/换行）

```javascript
const prepared = prepare(textareaValue, '16px Inter', { whiteSpace: 'pre-wrap' })
const { height } = layout(prepared, textareaWidth, 20)
```

### 手动布局（Canvas/SVG 渲染）

```javascript
import { prepareWithSegments, layoutWithLines } from '@chenglou/pretext'

const prepared = prepareWithSegments('Hello 世界 🌍', '18px "Helvetica Neue"')
const { lines } = layoutWithLines(prepared, 320, 26)

// 逐行渲染到 Canvas
for (let i = 0; i < lines.length; i++) {
  ctx.fillText(lines[i].text, 0, i * 26)
}
```

### 动态宽度场景（如绕图排版）

```javascript
import { prepareWithSegments, layoutNextLine } from '@chenglou/pretext'

const prepared = prepareWithSegments(text, '16px Inter')
let cursor = { segmentIndex: 0, graphemeIndex: 0 }
let y = 0

// 绕图排版：图片旁边的行更窄
while (true) {
  const width = y < image.bottom ? columnWidth - image.width : columnWidth
  const line = layoutNextLine(prepared, cursor, width)
  if (line === null) break
  ctx.fillText(line.text, 0, y)
  cursor = line.end
  y += 26
}
```

### 性能基准（官方数据）

```
prepare()  ~19ms  (500 条文本批次，一次性)
layout()   ~0.09ms (同样批次，可重复调用)
性能提升：~200x
```

### 缓存管理

```javascript
import { clearCache, setLocale } from '@chenglou/pretext'

// 长时间运行的应用需定期清理缓存
clearCache()

// 设置 locale（影响分段逻辑）
setLocale('zh-CN')
```

---

## 技术细节补充

### 测试方法论

Pretext 的测试方法值得单独提出来赞赏：

1. **《了不起的盖茨比》全文测试**: 在多个浏览器中渲染整本小说，验证测量准确性
2. **多语言语料库**: corpora/ 文件夹包含泰语、中文、韩语、日语、阿拉伯语等长篇公共领域文档
3. **AI 辅助迭代**: Cheng Lou 透露使用 Claude Code 和 Codex，将浏览器的 ground truth 作为参考，在每个显著容器宽度下反复测量迭代，持续数周

这种测试方法确保了跨浏览器、跨语言、跨文本类型的准确性，而非简单的单元测试覆盖。

### 开发背景

Pretext 的架构继承了 Sebastian Markbage 十年前创建的 [text-layout](https://github.com/chenglou/text-layout) 项目的设计思路：
- canvas measureText 用于文本塑形
- 来自 pdf.js 的双向文本支持
- 流式换行算法

Cheng Lou 在此基础上推进了图粒度分段、缓存优化、多语言支持等现代特性。

---

[← Back to Deep Dives](./README.md)
