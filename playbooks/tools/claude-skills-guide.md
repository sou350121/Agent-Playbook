# Claude Skill 进阶指南：利用 skillsmp 打造全能 Agent

## 1. 什么是 Claude Skill？

Claude Skill 是为 Claude Code 设计的一套**扩展机制**。它通过定义一组工具（Tools）和权限，让 Claude 能够执行原本无法直接完成的任务，如：
- **读取特定格式文件**（如 PDF, Excel）。
- **调用外部 API**（如 YouTube, GitHub, Notion）。
- **执行复杂的工程任务**（如 前端组件库扫描、全量 SEO 检查）。

## 2. 发现最强市场：skillsmp

**skillsmp** 是目前主流的 Claude Skill 社区市场，它解决了开发者“知道要干什么，但不会写 Skill 定义”的痛点。

### 2.1 推荐 Skill 清单
- **YouTube Transcript**：自动抓取视频文案，配合 LLM 进行总结。
- **PDF to Markdown**：将排版复杂的 PDF 转化为整洁的 Markdown 格式。
- **Frontend Beautifier**：针对特定框架的代码美化与重构。
- **Search & Research**：增强型的联网搜索与数据爬取技能。

## 3. 安装与管理流程

### 3.1 极速安装
1. 访问 `skillsmp.com`（或相关社区地址）下载对应的 Skill Zip 包。
2. 启动 Claude Code CLI。
3. 将 Zip 包文件拖入终端，并输入：
   > “Install this skill” 或 “安装这个 skill”
4. 确认权限授权，安装完成。

### 3.2 管理命令
- `skills list`：查看已安装的所有技能。
- `skills remove <name>`：卸载不再需要的技能。

## 4. 安全建议

由于 Skill 拥有执行命令和读取文件的权限，安装前请注意：
- **来源可信**：优先选择 `skillsmp` 等知名社区或经过审计的开源仓库。
- **权限审计**：在安装确认时，留意该 Skill 是否请求了不必要的目录权限。
- **敏感数据隔离**：建议在独立的 Chrome Profile 环境或虚拟机中运行包含高危权限的 Skill。

---

**关联阅读：**
- [CC Switch: AI CLI 配置快速切换工具](./cc-switch-guide.mdx)
- [Mac 多开 Chrome 物理隔离指南](./mac-multi-chrome-isolation-guide.mdx)
