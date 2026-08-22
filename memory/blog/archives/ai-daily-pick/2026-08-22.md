# 🤖 AI 每日精选 | 2026-08-22

🔥 头条
- OpenAI 全面开源 Codex Harness：Agent 循环引擎 Apache 2.0 许可
  OpenAI 将驱动 Codex 的核心 Harness 框架全面开源，含 CLI/SDK/app-server 三大组件。Greg Brockman 称「远不止编程工具」，首批案例已落地税务/云平台。
  https://github.com/openai/codex

- 博通谈判 700 亿美元债务融资，为 Anthropic 等 AI 企业提供基础设施
  博通联合黑石/阿波罗洽谈史上最大 AI 基础设施债务融资，优先档 450 亿 + 次级档 350 亿美元。AI 基建军备竞赛进入「千亿美元级」阶段。
  https://readhub.cn/topic/8vmW6XLNHQX

⚡ 精选动态
- 【🔧工具】AWS Bedrock 查询感知压缩：RAG 输入 Token 成本优化模式
  AWS 官方博客发布 RAG 后检索压缩模式：用小模型过滤 retrieved chunks 再喂给主模型，同时降低幻觉面积。兼容 Bedrock Knowledge Bases + Prompt Caching + Rerank API。
  https://aws.amazon.com/blogs/machine-learning/reduce-rag-costs-on-amazon-bedrock-with-query-aware-compression/

- 【💬观点】Google Research：将移动模式注入 LLM，让模型「理解」物理空间
  提出 ME-POIs 框架，将匿名移动数据（到达时间/停留时长/周边活动）与文本描述融合，构建同时编码 POI 身份和功能节奏的向量表示。访问意图预测提升 81.9%。
  https://research.google/blog/how-mobility-gives-language-models-a-deeper-understanding-of-place/

- 【🧪实验】HumeAI：语音识别基准优化（benchmaxxing）首次量化，多个开源 ASR 模型「背答案」
  评估 11 个开源 ASR 模型发现，多个高分模型在音频与参考答案矛盾时仍复述基准答案，甚至能识别「你在参加哪个基准测试」。
  https://huggingface.co/blog/asr-benchmark-optimization/
