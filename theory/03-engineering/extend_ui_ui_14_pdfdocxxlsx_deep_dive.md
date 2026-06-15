---
auto_generated: true
generated_at: "2026-06-15T05:48:53Z"
source_url: "https://www.extend.ai/ui"
signal_type: "significant_update"
---
# Extend UI：面向文档 Agent 的开源 React 组件库 (Extend UI — Open Source Document UI Kit for AI Agents)

> 🔍 本文由 Moltbot 自动生成 | 2026-06-15
>
> **项目/工具**: Extend UI (@extend/*)
> **链接**: https://github.com/extend-hq/ui
> **核心定位**: 一套 14 个 React 组件，让开发者无需从零搭建即可拥有 PDF/DOCX/XLSX 查看器、边界框引用、电子签名和文件管理系统——专为文档 Agent 和人机协作审阅流程设计

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：Extend UI 是一套 MIT 开源的 React 组件库，由文档处理公司 Extend 内部打磨后开源，覆盖 PDF/DOCX/XLSX/CSV 查看、OCR 布局块高亮、边界框引用审阅、电子签名、文件浏览等 14 个组件。
- **現在值得用嗎**：是——如果你的产品涉及文档处理（Agent 输出审阅、合同审核、发票提取结果确认等），它比从零集成 pdf.js 或 Docx.js 高效得多。
- **適合場景**：AI Agent 输出文档的可视化审阅界面；文档密集型 SaaS 的内部工具；需要"提取结果 ↔ 原文对照"的人机协作流程。
- **不適合場景**：纯文本聊天界面；不需要文档查看/编辑的轻量 Agent；非 React 技术栈（目前仅 React）。
- **與競品核心差異**：相比 react-pdf / Docx.js 等单一格式查看器，Extend UI 提供的是**多格式 + 审阅工作流**的完整组件集（尤其是 bounding box citations 和 OCR layout blocks），且以 shadcn registry 方式安装为源码，可深度定制。

## 是什么 / 解决什么问题

文档处理是 AI Agent 最核心的工作流之一——从合同审查到发票提取，从研究报告摘要到法律文件审阅。但问题在于：**提取只是第一步，展示和确认才是用户真正交互的界面**。

现有的开源方案存在明显断层：
- **react-pdf** 只做 PDF 渲染，不支持 DOCX/XLSX，没有审阅交互
- **Docx.js** 侧重 DOCX 生成而非查看
- **Spreadsheet 组件**（如 x-spreadsheet）功能单一，无文档关联
- 如果要实现"AI 提取结果 ↔ 原文高亮对照"的边界框引用（bounding box citations），基本需要从零开发

Extend UI 填补了这个断层。它由 Extend AI（一家文档自动化公司）内部组件层开源而来，在生产环境中处理了数百万页文档，稳定性和抛光度经过验证。

**关键设计选择**：组件通过 shadcn CLI 安装为**源码**（而非 npm 包），意味着每个组件都完全可定制——你可以直接修改 Tailwind 样式、调整交互逻辑、注入自定义业务逻辑。这与设计系统 Agent（如 v0、lovable）的 prototyping 需求天然契合。

## 技术架构拆解

### 核心设计决策

| 决策 | 理由 |
|------|------|
| **shadcn registry 分发**（`npx shadcn@latest add @extend/pdf-viewer`） | 组件以源码形式复制到项目，用户可自由修改，不依赖黑盒依赖 |
| **基于 EmbedPDF / PDFium 渲染** | 利用成熟的 PDF 渲染引擎，而非自研；支持长文档懒加载 |
| **组件与 Block 两层抽象** | 原子组件（PDFViewer/DOCXViewer）负责单一功能；Block（OcrBlocksBlock/HumanReviewBlock）组合多个组件形成完整工作流 |
| **依赖宿主项目的 shadcn primitives** | 不捆绑 Button/Dialog/Select，复用宿主设计系统，减少冲突 |
| **MIT 开源** | 消除企业采用顾虑，与商业 SaaS 形成差异化 |

### 组件全景

| 组件 | 状态 | 核心能力 |
|------|------|----------|
| PDF Viewer | 稳定 | 页面导航、缩放、搜索、文本选择、缩略图、上传、OCR 叠加层 |
| DOCX Viewer | 稳定 | DOCX 文档渲染与浏览 |
| DOCX Editor | 实验性 | DOCX 在线编辑 |
| Excel Viewer | 稳定 | XLSX 表格渲染 |
| Excel Editor | 实验性 | XLSX 在线编辑 |
| CSV/TSV Viewer | 稳定 | 表格数据查看 |
| File Upload | 稳定 | 文件拖拽上传 |
| File System (Finder) | 稳定 | 类 Finder 文件浏览器，支持图标/列表/列/画廊视图 |
| Bounding Box Citations | 稳定 | AI 提取结果与原文 PDF 的边界框对照审阅 |
| Schema Builder | 稳定 | 结构化 Schema 构建器 |
| File Thumbnail | 稳定 | 文件缩略图生成 |
| Layout Blocks | 稳定 | OCR 布局块高亮（标题/段落/表格等），置信度展示 |
| E-Signature | 稳定 | 电子签名工作流 |
| Document Splits | 稳定 | 文档分页/分段处理 |
| Document Viewer Sidebar | 稳定 | 文档侧边栏导航 |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────┐
│                    Your Application                      │
│  ┌───────────────────────────────────────────────────┐  │
│  │              Block Layer (工作流层)                 │  │
│  │  ┌─────────────────┐  ┌───────────────────────┐  │  │
│  │  │ OcrBlocksBlock  │  │ HumanReviewBlock      │  │  │
│  │  │ (OCR 布局审阅)   │  │ (边界框引用确认)       │  │  │
│  │  └────────┬────────┘  └──────────┬────────────┘  │  │
│  │           │                      │               │  │
│  │  ┌────────┴──────────────────────┴────────────┐  │  │
│  │  │         Component Layer (原子组件层)         │  │  │
│  │  │  PDFViewer │ DOCXViewer │ XLSXViewer │ ...  │  │  │
│  │  └────────┬───────────────────────────────────┘  │  │
│  │           │                                      │  │
│  │  ┌────────┴───────────────────────────────────┐  │  │
│  │  │    Rendering Engine (渲染引擎层)             │  │  │
│  │  │  EmbedPDF / PDFium  │  Docx.js  │  SheetJS  │  │  │
│  │  └───────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────┘  │
│                                                          │
│  依赖宿主: shadcn primitives (Button/Dialog/Select/...)  │
└─────────────────────────────────────────────────────────┘
```

### 与竞品的关键差异

| 维度 | react-pdf | Docx.js | Extend UI |
|------|-----------|---------|-----------|
| 支持格式 | PDF only | DOCX 生成 | PDF + DOCX + XLSX + CSV |
| 查看能力 | ✅ | ❌ (侧重生成) | ✅ |
| 编辑能力 | ❌ | ✅ (生成) | ⚠️ (实验性编辑) |
| AI 审阅工作流 | ❌ | ❌ | ✅ (bounding box + OCR blocks) |
| 电子签名 | ❌ | ❌ | ✅ |
| 文件管理 | ❌ | ❌ | ✅ (Finder 风格) |
| 安装方式 | npm 包 | npm 包 | shadcn 源码 |
| 定制深度 | 有限（黑盒） | 有限（黑盒） | 完全可改（源码） |
| 许可证 | MIT | Apache 2.0 | MIT |

## 实用评估

### 什么场景值得用

- **AI Agent 文档输出审阅界面**：当 Agent 从 PDF 中提取了结构化数据（如发票金额、合同条款），Bounding Box Citations 组件可以直接在 PDF 原文上高亮对应区域，让用户一键确认或修正。这是目前开源生态中最完整的实现。
- **OCR 结果质量检查**：Layout Blocks 组件支持展示 OCR 输出的每个块（标题/段落/表格）及其置信度，适合需要人工复核 OCR 质量的场景。
- **文档密集型内部工具**：合同管理、发票处理、合规审查等场景，需要同时查看多种格式文档并支持批注/签名。
- **Agent Builder 平台的文档预览**：如果你的平台让用户构建文档处理 Agent，Extend UI 可以作为输出预览层直接嵌入。

### 什么场景不值得用

- **非 React 项目**：目前仅支持 React。Vue/Svelte/Angular 项目无法直接使用。
- **纯文本 Agent 界面**：如果你的 Agent 只输出文本/代码，不需要文档查看，这套组件库是过度工程。
- **需要服务端文档处理**：Extend UI 是纯前端组件库，不涉及服务端文档解析/转换。如需服务端 PDF 解析，需搭配其他工具（如 pdf-parse、LibreOffice）。
- **实验性编辑功能不可用于生产**：DOCX Editor 和 Excel Editor 标记为 Experimental，稳定性和功能完整性未经验证。

### 迁移成本

从 react-pdf 迁移：
- **安装**：`npx shadcn@latest add @extend/pdf-viewer` 替代 `npm install react-pdf`
- **API 差异**：Extend UI 的 PDFViewer 接受 `src` 和 `className` 等简洁 props，比 react-pdf 的 `file` + ` onLoadSuccess` 模式更直观
- **工作量估算**：简单查看场景约 1-2 小时（替换组件 + 调整样式）；如果涉及自定义交互（如页面事件回调），约 4-8 小时
- **注意事项**：需确保项目已有 shadcn primitives（Button/Dialog/Select），否则需先安装 shadcn

从零开始搭建文档审阅界面：
- 使用 Extend UI：1-2 天可完成基础文档查看 + 审阅工作流
- 不使用 Extend UI：react-pdf (2-3 天) + 自研边界框高亮 (3-5 天) + DOCX 查看器 (2-3 天) = 7-11 天

## 对你的意义

如果你正在构建 AI Agent 的文档输出界面（特别是涉及提取结果确认、OCR 复核、合同审阅等场景），Extend UI 是目前开源生态中最完整的选择。它的 Bounding Box Citations 和 Layout Blocks 组件直接对应 AI 提取 → 人工确认的核心工作流，省去了大量自研工作。

**建议**：如果你的技术栈是 React + Tailwind，立即试用。先用 `npx shadcn@latest add @extend/pdf-viewer` 验证 PDF 查看效果，再按需添加 Bounding Box Citations 组件。

**观望点**：编辑功能（DOCX Editor / Excel Editor）仍为实验性，如果编辑是核心需求，需评估成熟度。

## 关键代码/配置片段

### 安装与基础使用

```bash
npx shadcn@latest add @extend/pdf-viewer
npx shadcn@latest add @extend/bounding-box-citations-block
```

### PDF 查看器

```tsx
import { PDFViewer } from "@/components/ui/pdf-viewer"

export default function Page() {
  return <PDFViewer file="/sample.pdf" className="h-[720px]" />
}
```

### 边界框引用审阅（AI 提取结果确认）

```tsx
import type { ReviewField } from "@/components/ui/bounding-box-citations"
import { HumanReviewBlock } from "@/components/blocks/bounding-box-citations-block"

const fields: ReviewField[] = [
  {
    key: "invoice_total",
    schema: {
      type: "number",
      title: "Invoice total",
      description: "Total amount due on the invoice.",
    },
    actual: 1280.5,
    expected: 1280.5,
    location: {
      page: 1,
      area: { left: 62, top: 82, width: 22, height: 4 },
    },
  },
]

export default function Page() {
  return (
    <HumanReviewBlock
      file="/documents/invoice.pdf"
      fields={fields}
      className="h-[720px]"
    />
  )
}
```

### OCR 布局块审阅

```tsx
import type { ParsedOcrOutput } from "@/components/ui/layout-blocks"
import { OcrBlocksBlock } from "@/components/blocks/layout-blocks-block"

const output: ParsedOcrOutput = {
  chunks: [
    {
      blocks: [
        {
          id: "title",
          type: "heading",
          content: "Statement of Work",
          metadata: {
            page: { number: 1, width: 612, height: 792 },
            avgOcrConfidence: 0.99,
          },
          boundingBox: { left: 72, top: 96, right: 360, bottom: 124 },
        },
      ],
    },
  ],
}

export default function Page() {
  return <OcrBlocksBlock file="/documents/statement.pdf" output={output} />
}
```

### Finder 风格文件浏览

```tsx
import type { FileSystemItem } from "@/components/ui/file-system"
import { FileSystemBlock } from "@/components/blocks/file-system-block"

const items: FileSystemItem[] = [
  { kind: "folder", path: "reports/", hasChildren: true },
  {
    kind: "file",
    path: "bank-statement.pdf",
    contentType: "application/pdf",
    url: "/documents/bank-statement.pdf",
    previewImageUrl: "/documents/bank-statement-preview.png",
  },
]

export default function Page() {
  return (
    <FileSystemBlock
      items={items}
      title="Documents"
      defaultView="icons"
      className="h-[720px]"
      getFileUrl={(file) =>
        `/api/files/sign?path=${encodeURIComponent(file.path)}`
      }
      loadChildren={async ({ path }) => {
        const response = await fetch(
          `/api/files?prefix=${encodeURIComponent(path)}`
        )
        return response.json()
      }}
    />
  )
}
```

---
[← Back to Deep Dives](./README.md)
