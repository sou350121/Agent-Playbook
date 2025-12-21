# 工具工作流：Codex + HF Skills 自动化训练指南

> **核心目标**：配置 Codex 接入 Hugging Face Skills 仓库，实现机器学习实验的全流程自动化。

## 1. 环境准备

在开始之前，请确保你拥有：
- **Hugging Face 账户**：建议开通 Pro/Team 计划（Jobs 需付费）。
- **HF 写权限 Token**：在 [huggingface.co/settings/tokens](https://huggingface.co/settings/tokens) 生成。
- **OpenAI Codex**：安装并配置好 Codex CLI。

## 2. 安装与配置

### 2.1 加载技能仓库
Codex 会自动识别 `AGENTS.md` 文件。克隆 HF Skills 仓库到本地：

```bash
git clone https://github.com/huggingface/skills.git
cd skills
```

### 2.2 连接 Hugging Face
登录 HF 账号：
```bash
hf auth login
```

### 2.3 配置 MCP (模型上下文协议)
将以下内容添加到 `~/.codex/config.toml`，提升 Codex 与 Hub 的集成体验：

```toml
[mcp_servers.huggingface]
command = "npx"
args = ["-y", "mcp-remote", "https://huggingface.co/mcp?login"]
```

## 3. 常用指令范式

### 数据集验证
```bash
codex "Check if open-r1/codeforces-cots works for SFT training."
```

### 启动微调实验
```bash
codex "Start a new fine-tuning experiment to improve code solving abilities on using SFT. 
- Maintain a report for the experiment. 
- Evaluate models with the openai_humaneval benchmark
- Use the open-r1/codeforces-cots dataset"
```

### 模型导出 (GGUF)
```bash
codex "Convert my fine-tuned model to GGUF with Q4_K_M quantization. Push to username/my-model-gguf."
```

## 4. 关键文件说明
- **`training_reports/`**：Codex 自动生成的实验报告，包含训练参数、运行日志链接和评估得分。
- **`Trackio Logs`**：实时监控训练损失和性能指标。

---
> 💡 **总结**：通过 HF Skills，Codex 已经进化为一个具备端到端决策能力的 MLOps 代理。

