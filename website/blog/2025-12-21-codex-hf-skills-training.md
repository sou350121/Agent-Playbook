---
slug: codex-hf-skills-training
title: Codex + HF Skills：开启“自动驾驶”级别的模型训练时代
authors: [sou350121]
tags: [codex, huggingface, training, automation, mlops]
---

继 Claude Code 之后，我们迎来了更强大的工程闭环：**OpenAI Codex + Hugging Face Skills**。这不仅仅是让 AI 写代码，而是让 AI 担任你的“全职机器学习工程师”。

### 核心能力
- **全流程自动化**：从微调 (SFT)、偏好优化 (DPO) 到强化学习 (RL)，Codex 都能自动处理。
- **智能决策**：根据 Trackio 实时指标自动评估模型检查点，决定是否继续训练或调整参数。
- **一键生产化**：自动验证数据集、选型 GPU 硬件、生成报告、导出 GGUF 并发布到 Hub。

<!-- truncate -->

### 为什么这是游戏规则改变者？
传统的模型训练需要频繁地在终端、监控页面和代码之间切换。现在，你只需要一句话：
> "Fine-tune Qwen3-0.6B on the dataset open-r1/codeforces-cots"

Codex 会帮你选好硬件（如 t4-small）、监控损失、运行评估，并最终给你一份精美的 Markdown 实验报告。这种“智力套利”让我们可以把精力集中在实验设计上，而非繁琐的操作环节。

[原文参考：Hugging Face Blog]

