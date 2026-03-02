# 10x 开发者集成战术链路手册

本手册旨在指导开发者如何将碎片化的 AI 工具串联成一套高效的、具备工业强度的开发流水线。

---

## 🧭 第一阶段：情报与地图 (The Map)
**工具：Qoder / Zread / DeepWiki**
- **动作**：对原始仓库执行全量扫描。
- **输出**：项目结构图、模块依赖 Wiki、Mermaid 流程图。
- **价值**：获取“全景视角”，消除对未知代码的恐惧。

## 🧪 第二阶段：知识蒸馏 (The Manual)
**工具：Skill Seekers**
- **动作**：将第一阶段生成的 Wiki URL 或 Markdown 喂给 Skill Seekers。
- **输出**：一个 `project-master.zip` 的 Claude Skill 技能包。
- **价值**：将数万字的文档浓缩成 Agent 可用的指令集，避免上下文爆炸。

## 📦 第三阶段：环境标准化 (The Container)
**工具：Docker**
- **动作**：编写 `Dockerfile` 锁定 OS、Python/Node 版本及依赖。
- **输出**：一个标准化的镜像（Image）。
- **价值**：确保 Agent 的运行环境与你的逻辑环境 100% 对齐，隔离副作用。

## 🛡️ 第四阶段：会话持久化 (The Fortress)
**工具：Tmux**
- **动作**：在服务器或本地开启 `tmux new -s war-room`。
- **输出**：一个可解绑、可重连的持久化终端。
- **价值**：防止因断网或误操作导致长耗时的 Agent 任务（如全量重构）中断。

## 🚀 第五阶段：作战与编排 (The Command)
**工具：Claude Code / Codex CLI**
- **动作**：在 Tmux 窗口的 Docker 容器内启动 Agent，加载技能包。
- **指令示例**：
  > "根据已加载的 project-master 技能，分析当前容器环境，为我执行 001 号重构 Story。"
- **价值**：实现 Boris Cherny 提到的“离线 200 个 PR”的高级编排。

---

## 总结：10x 战术链的协同效应

| 维度 | 单点工具 | 集成战术链 |
| :--- | :--- | :--- |
| **认知成本** | 逐行读代码 | **查阅 AI 生成的地图** |
| **环境安全** | 宿主机裸奔 | **Docker 隔离保护** |
| **稳定性** | 随断随没 | **Tmux 持久守护** |
| **Agent 效率** | 现场现教 | **Skill 技能直接注入** |

> **关联文档：**
> - [架构治理专项](../../../cognition/architecture/README.md)
> - [Agent 宪法 V2](../../AGENT_CONSTITUTION_UNIVERSAL.md)
