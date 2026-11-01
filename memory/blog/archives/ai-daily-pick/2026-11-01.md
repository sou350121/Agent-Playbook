# 🤖 AI 每日精选 | 2026-11-01

🔥 头条（1-2 条）

- 【🏢行业】OpenAI 本轮融资目标下调 100 亿美元，缩至约 200 亿、估值 1.25 万亿
  公开市场 AI 板块抛售叠加 Anthropic 即将上市，投资者缩量认购，周五前须完成出资承诺
  https://www.cnbc.com/amp/2026/10/31/openai-funding-target-cut-10-billion.html

- 【🆕新发布】DeepSeek Harness 发布《Super-agent 设计探索》：Router/Worker 双层 + 事件驱动 + Watchdog
  把 agent 从"单 session 工具"改成"常驻多任务协作者"：Router 统一对外，Worker 隔离并发；合成负载下任务完成 p95 15.7 分钟 vs 单 session 29.5 分钟
  https://m.ithome.com/html/1020615.htm
  （一手：DeepSeek Harness 官方文章 https://github.com/deepseek-ai/dsh-superagent-prototype）

⚡ 精选动态（3-5 条）

- 【🔧工具】Parameter Labs 披露 ChatGPT 账户接管链：HTML Preview 沙箱 + MathLive postMessage 越界
  iframe 打 postMessage 触发父页 MathLive 虚拟键盘，其 innerHTML 渲染未校验来源 → 注入无 sandbox iframe → 借 YouTube oEmbed 反射执行 JS；$5000 赏金被认为偏低
  https://www.parameter.ai/labs/we-found-a-gap-at-openai

- 【📊趋势】Claude 订阅档位改名：Max 5x→Max、Max 20x→Ultra，验证账户取消 5 小时窗口限制
  $200 档限制不再按 5 小时重置，长跑 agent 批处理任务少了一个硬中断点（二手 36氪转述，一手为 claude.com/pricing）
  https://www.36kr.com/p/4049021975886084

- 【🧪实验】Anthropic 公开 Claude 后台"自评"机制：多生成约 10 token 自审，算力开销 <2%
  默认全开、不当场拦截只记风险等级，每日高危汇总交人工；企业零保留协议可豁免 —— 事后审计型安全的新范式
  https://readhub.cn/topic/8xgJk95Q2I6

- 【📊趋势】RSI 热潮下，国产 Agentic Infra 把自迭代基础设施压到英伟达 GPU 物理极限
  同期 DeepSeek 生态在 B 站一周内被大量 agent 化内容侵入，开发者社区的自举式实验明显加速
  https://readhub.cn/topic/8xfiaJhBds7

🌟 GitHub Pick（1-2 个）

- deepseek-ai/dsh-superagent-prototype · 官方原型 · 开源
  Super-agent 双层架构参考实现：Router 全局上下文 + 隔离 Worker + Thread 订阅事件直通 + Watchdog 外部控制回路
  https://github.com/deepseek-ai/dsh-superagent-prototype

- agent-labs-dev/fastbrowse
  用"页面控件索引 + 小选择模型点选"替代截图式浏览器 agent，不依赖 selector，附 CLI/Py/Node/Go SDK 与 MCP server
  https://github.com/agent-labs-dev/fastbrowse

💬 社区热议（0-2 条）

- HN：ChatGPT 分享链接可被用来接管账户（item 50314699）
  争论点在"沙箱内不可信 HTML 与父页 postMessage 边界"——平台级应用普遍没做 source 校验
  https://news.ycombinator.com/item?id=50314699

---
