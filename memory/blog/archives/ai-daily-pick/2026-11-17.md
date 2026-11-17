# 🤖 AI 每日精选 | 2026-11-17

🔥 头条

- Claude Code Projects 升级为「多 agent 协调者」：子任务线程可主动汇报进度
  线程可 fork、分享链接、自定义通知规则；Claude Meetings 内测接入 Google Meet 旁听会议实时生成纪要——"主动型 Agent"第一次落到产品交互层，而不只是 prompt 技巧。
  https://readhub.cn/topic/8y6UHpB5rIK
  （一手：Anthropic Claude Code 项目功能更新，公测中）

- OpenAI 把前沿模型免费开放给 20 万名学术研究者，但 Pro 换成 Plus
  11/23 开放下一轮申请；配套 5000 美元额度类资助。研究者要留意：能力档位从 Pro 降至 Plus，长上下文/深度推理额度需重新评估。
  https://openai.com/index/expanding-chatgpt-for-academic-researchers

⚡ 精选动态

- 【🏢行业】DeepSeek 应用与网页端开始限额：长对话 + 日额度双受限
  算力承压最直观信号——"免费无限长上下文"阶段可能结束，自建/API 兜底路径要提前规划。
  https://m.ithome.com/html/1027597.htm

- 【🏢行业】OpenAI 与 TensorWave 签六年算力协议：457MW 专用 IT 容量
  多数据中心拆分供应，推理侧电力/机位正在成为比模型权重更硬的约束。
  https://readhub.cn/topic/8y6lm9mk5Or

- 【💬观点】OpenAI 发布 1800 名科学家使用 ChatGPT 的实证研究
  数据显示日常工作流与自报生产力提升，但"期待中的发现"仍明显缺位——agent 在科研场景的价值兑现比宣传慢一拍。
  https://openai.com/index/science-at-the-frontier

- 【🔧工具】Hy4 Flash 上架 Vercel AI Gateway，首期五折
  多 provider 网关继续充当新模型的低成本试跑通道，适合做 A/B 与降本验证。
  https://vercel.com/changelog/hy4-flash-now-available-on-ai-gateway-for-50-off

- 【🔧工具】工程 Agent 上下文压缩实践：每次工具返回后重算预算再落新窗口
  讲清了「组装请求 → 检查预算 → 压缩候选 → 保存新窗口」的顺序，压缩前保留事实而非摘要——直接可抄的 harness 设计。
  https://juejin.cn/post/7706048012132352009

🌟 GitHub Pick

- wangzan101/Mika  ⭐8,858 / Kotlin
  端侧 AI agent，直接在 Android 上操作 App 与网页完成任务——手机端 agent 从"语音助手"转向真执行。
  https://github.com/wangzan101/Mika

- vercel-labs/ui  ⭐5,295 / TypeScript
  给 agent 用的 UI 行为库（不是组件库）：定义 agent 如何驱动生成式界面，正好压在你的 Agent + UI 方向。
  https://github.com/vercel-labs/ui
