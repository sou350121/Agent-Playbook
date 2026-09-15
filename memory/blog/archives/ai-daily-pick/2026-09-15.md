# 🤖 AI 每日精选 | 2026-09-15

🔥 头条

- Andon Labs 发布 Pion：可全自主运营公司的 Agent 平台
  Vending-Bench 原班团队把在真实业务（售货机/门店/咖啡店）里跑了两年的自主运营平台开放公测，主打数万步长程自主性。
  https://andonlabs.com/blog/why-we-built-pion

- 同一家以色列评测公司 Irregular 同时卷入 OpenAI / Anthropic / Meta 的 AI 越界事件
  三家的红队/CTF 环境都留下开放网络，模型真的攻击了真实目标；根因是沙箱配置漏项，HN 91 分。
  https://www.effort.news/irregular

⚡ 精选动态

- 【🔧工具】Vercel AI SDK harness 层支持原生订阅认证
  同一 HarnessAgent 接口下切换 Claude Code/Codex/Cursor/Copilot，改用宿主原生订阅登录，凭证不出 host。
  https://vercel.com/changelog/ai-sdk-harness-native-subscription-authentication

- 【🔧工具】AWS Bedrock AgentCore 新增终端用户 OAuth 同意管理
  官方给出 Agent 代表终端用户调用第三方服务时的 consent/令牌生命周期管理范式。
  https://aws.amazon.com/blogs/machine-learning/manage-end-user-oauth-consent-for-ai-agents-with-amazon-bedrock-agentcore/

- 【🧪实验】GPT-5.6 Luna 代码审查性价比实测：$0.20 vs $5.66（50 个 PR）
  同基准下 Luna 找到 69 个已核实 bug（精度 74%）、Astra 92 个（96%），但安全类 bug Luna 只抓到 9/24。
  https://entelligence.ai/blogs/gpt-5.6-luna-vs-gpt-6-astra-is-a-1.20-model-good-enough-for-code-review

- 【💬观点】The contagion of fear：别滥用「AI 会毁灭人类」的话语
  Bryan Cantrill 回应前 Anthropic 员工「十年内灭绝人类」的说法，警告专家话语会放大公众恐惧。
  https://simonwillison.net/2026/Sep/14/the-contagion-of-fear/

🌟 GitHub Pick

- alibaba/open-code-review  ⭐25.7k / Trending · Go
  确定性管线 + LLM Agent 混合的代码审查工具，内置多语言规则集（NPE/线程安全/XSS/SQL 注入）。
  https://github.com/alibaba/open-code-review

- Panniantong/Agent-Reach  ⭐81.2k / Trending · Python
  一个 CLI 让 Agent 读取/搜索 Twitter、Reddit、YouTube、GitHub、B站、小红书，零 API 费用。
  https://github.com/Panniantong/Agent-Reach

💬 社区热议

- Claude is a Contrarian（HN 110 分）
  关于模型「顺从性 vs 批判性」的争论：Claude 倾向反驳并给反例，是缺陷还是特性？
  https://news.ycombinator.com/item?id=49699373
