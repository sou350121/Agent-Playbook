---
auto_generated: true
generated_at: "2026-06-24T06:50:05Z"
source_url: "https://github.com/Adam-CAD/CADAM/releases/tag/v0.3.0"
signal_type: "significant_update"
---
# Adam (CADAM)：开源 AI CAD，用 Agent 做机械设计 (Adam CADAM: Open Source AI-Powered CAD)

> 🔍 本文由 Moltbot 自动生成 | 2026-06-24
>
> **项目/工具**: CADAM (by Adam, YC W25)
> **链接**: https://github.com/Adam-CAD/CADAM/releases/tag/v0.3.0
> **核心定位**: 用自然语言描述生成参数化 3D CAD 模型 —— 把 AI Agent 变成机械设计的主要交互媒介

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句話定位**：开源 text-to-CAD 工具，用自然语言 + 图片参考生成可编辑的参数化 3D 模型（OpenSCAD 格式）
- **現在值得用嗎**：看场景 —— 适合快速原型/概念验证/教育演示；不适合精密工程制造
- **適合場景**：3D 打印原型设计、机械设计概念验证、工程教育演示、快速参数化零件生成
- **不適合場景**：需要亚毫米级精度的工业制造、复杂装配体工程级仿真、非 OpenSCAD 生态的 CAD 工作流
- **與傳統 CAD 核心差異**：传统 CAD（Fusion 360/SolidWorks）用 GUI 拖拽建模；CADAM 用自然语言生成完整 OpenSCAD 代码，再通过参数滑块做微调

## 是什么 / 解决什么问题

CAD（计算机辅助设计）一直是工程师最"重"的工具之一 —— Fusion 360、SolidWorks、Onshape 都需要数周的学习曲线才能熟练建模。对于非专业设计师（硬件创业者、研究人员、Maker 社区），一个简单零件可能需要半天才能建出来。

CADAM 的核心假设是：**AI Agent 可以成为 CAD 的主要交互层**。用户用自然语言描述想要的 3D 模型（"设计一个 M12 六角螺栓，45mm 长，带真实螺纹"），AI 自动生成完整的参数化 OpenSCAD 代码，用户再通过交互式滑块调整尺寸。

这个项目来自 **Adam（YC W25）**，2026 年 6 月 17 日发布 v0.3.0，GitHub 上已有 4.6k Star、574 Fork。采用 GPLv3 开源协议。

它的价值主张很明确：**把 CAD 从"画图工具"变成"描述工具"**。你不再需要学习如何拉伸、旋转、布尔运算 —— 你只需要描述你想要的东西。

## 技术架构拆解

### 核心设计决策

| 决策 | 选择 | 理由 |
|------|------|------|
| CAD 引擎 | OpenSCAD WebAssembly | 开源、代码驱动、天然支持参数化；WASM 使其能在浏览器运行 |
| AI 后端 | Anthropic Claude API | 代码生成能力强，适合将自然语言转为 OpenSCAD 脚本 |
| 3D 渲染 | Three.js + React Three Fiber | 浏览器端实时预览，支持交互式旋转/缩放 |
| 参数化机制 | 自动生成可调参数 + 滑块 UI | AI 生成后用户可微调，无需重新调用 LLM |
| 前端框架 | React 19 + TypeScript + TanStack Start + Vite | 现代全栈 React 方案，SSR + API 路由一体 |
| 后端 | Supabase (PostgreSQL/Auth/Storage) | 快速搭建，免运维 |
| 部署 | 浏览器端 WASM | 零安装，打开网页即用 |

### 信息流架构

```
用户自然语言描述
       │
       ▼
┌─────────────────┐
│  Claude API     │  ← AI 将描述转为 OpenSCAD 代码
│  (代码生成)      │
└────────┬────────┘
         │ OpenSCAD 代码 (参数化)
         ▼
┌─────────────────┐
│  OpenSCAD WASM  │  ← 在浏览器中编译/渲染 CAD
│  (CAD 引擎)      │
└────────┬────────┘
         │ 几何数据
         ▼
┌─────────────────┐
│  Three.js / R3F │  ← 交互式 3D 预览
│  (渲染层)        │
└────────┬────────┘
         │
    ┌────┴────┐
    ▼         ▼
 参数滑块   导出 (.STL/.SCAD/.DXF)
 (微调)
```

### 与竞品/传统 CAD 的关键差异

| 维度 | Fusion 360 / SolidWorks | Onshape | CADAM |
|------|------------------------|---------|-------|
| 交互方式 | GUI 拖拽 + 草图 | GUI 拖拽 + 草图 | **自然语言描述** |
| 学习曲线 | 数周至数月 | 数周 | 分钟级（会说话就会用） |
| 参数化 | 原生支持 | 原生支持 | AI 自动生成参数 + 手动微调 |
| 精度 | 工业级 | 工业级 | 概念级（依赖 AI 理解） |
| 部署 | 桌面/云端 | 纯云端 | **浏览器 WASM（零安装）** |
| 开源 | ❌ | ❌ | ✅ GPLv3 |
| 生态 | 封闭 | 封闭 | **OpenSCAD 生态（可导出 .SCAD 源码）** |
| 价格 | 付费 | 付费/免费版 | **免费开源** |

## 实用评估

### 什么场景值得用

- **3D 打印快速原型**：描述一个零件 → 生成 STL → 直接打印。V8 引擎 benchmark 展示了 AI 能理解极复杂的机械描述（90° V 型 8 缸、进排气歧管、曲轴配重、活塞连杆），生成约 460 行 OpenSCAD 代码、22 个可调参数。
- **机械设计概念验证**：在正式投入 CAD 建模前，先用 CADAM 快速验证设计概念是否可行。比如 NACA 2412 翼型机翼、离心泵叶轮、人字齿轮行星减速箱等复杂几何体，都能从一句话生成。
- **工程教育**：学生可以用自然语言描述机械原理（"建一个 24 齿锥齿轮与 16 齿小齿轮 90° 啮合"），即时看到 3D 结果，降低学习门槛。
- **Maker 社区**：不需要专业 CAD 技能的硬件爱好者也能生成可打印的零件。

### 什么场景不值得用

- **工业级精密制造**：AI 生成的几何体精度无法保证亚毫米级。V8 引擎 benchmark 虽然视觉效果好，但螺纹、齿轮模数等关键尺寸可能不完全符合工程标准。
- **大型装配体管理**：CADAM 目前面向单零件/简单装配体，没有 BOM 管理、装配约束、运动仿真等工程功能。
- **已有 CAD 工作流的团队**：如果团队已经在用 Fusion 360 或 SolidWorks 做协作设计，CADAM 无法替代其工程管理能力。
- **非 OpenSCAD 生态**：导出格式限于 STL/SCAD/DXF。如果需要 STEP/IGES 等工业交换格式，需额外转换。

### 迁移成本

- **从 Fusion 360/SolidWorks 迁移**：不是替代关系，而是互补。建议作为"概念生成层"使用 —— 用 CADAM 快速出概念，再导入传统 CAD 做精细化。迁移成本：低（不替换现有工具）。
- **从零开始使用**：打开 adam.new/cadam 即可，零安装。本地开发需 Node.js 20.19+、Supabase CLI。部署成本：极低。

## 对你的意义

这个项目跟 AI Agent 追踪线高度相关 —— 它是** Agent 作为专业领域交互层**的典型案例。CADAM 的核心洞察是：AI Agent 不一定要替代专业软件，而是可以成为专业软件的"自然语言前端"。

对 Ken 的启示：
- **Agent + 专业工具** 是一个值得关注的模式：Agent 负责理解意图、生成初始方案，专业工具负责精调和验证
- **OpenSCAD 代码生成** 是一个聪明的选择 —— 代码是可版本控制的、可参数化的、可审查的，比直接生成二进制 CAD 文件更灵活
- **YC W25 背景** 说明这个方向有资本认可，值得持续关注其演进

建议：**试用**。打开 adam.new/cadam 试几个简单零件，感受自然语言建模的体验。如果 3D 打印是你的兴趣领域，这个工具可能改变你的工作流。

## 关键代码/配置片段

V8 引擎 benchmark 展示了 AI 生成的 OpenSCAD 代码质量。以下是参数定义和核心运动学计算部分（来自官方 benchmark 源码）：

```openscad
// V8 Engine Model — 由 CADAM 从自然语言生成
/* [Visibility] */
cutaway = true;

/* [Animation] */
crank_angle = 45; // [0:1:360] — 旋转曲轴观察活塞运动

/* [Colors] */
block_color = "Silver";
head_color = "DarkGray";
valve_cover_color = "FireBrick";
intake_color = "DimGray";
exhaust_color = "Peru";
pulley_color = "Black";
oil_pan_color = "DarkSlateGray";
internals_color = "LightSteelBlue";

/* [Hidden] */
$fn = 32;
bore = 10;
stroke = 15;
crank_r = stroke / 2;
conrod_len = 35;
cyl_spacing = 28;
deck_height = 50;
bank_angle = 45;
pin_angles = [0, 90, 270, 180];
main_y = [0, 28, 56, 84, 112];
pin_y_start = [8, 36, 64, 92];

// 核心运动学：活塞位置计算
function get_D(crank_ang, bank_ang) =
 let(Px = crank_r * sin(crank_ang),
     Pz = crank_r * cos(crank_ang),
     Wx = conrod_len * sin(bank_ang),
     Wz = conrod_len * cos(bank_ang))
   sqrt(pow(Wx - Px, 2) + pow(Wz - Pz, 2));
```

这段代码的关键观察：
- AI 正确理解了 V8 发动机的 90° 夹角、 firing order（曲轴销角度 [0, 90, 270, 180]）
- 运动学公式 `get_D` 正确计算了活塞-连杆-曲轴的几何关系
- 22 个可调参数覆盖了所有关键尺寸
- 代码约 460 行，结构清晰，模块化良好

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-003: 多 Agent 协作框架从实验走向工程实践 | 支持 | CADAM 展示了 Agent 在专业领域（CAD/机械设计）的工程化落地，Agent 作为交互层替代传统 GUI 的模式正在验证 |

---
[← Back to Deep Dives](./README.md)
