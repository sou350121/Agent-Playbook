# 🤖 AI 每日精选 | 2026-11-15

🔥 头条

- llama.cpp / ggml 同时发布 v1.0.0：本地推理终于有稳定 API 契约
  3.5 年来首个 major 版本：删掉 35 个废弃函数、NextN 投机解码 API 进 llama.h、OCP FP8 KV cache、MoE 专家缓存可调 CPU 分摊、新增 Kimi-K3.1-Pro / Ripple-65B / drama-3 TTS 等架构；llama-server 补 SSRF / CORS / DNS rebinding / MCP tool 取消
  https://github.com/ggml-org/llama.cpp/releases/tag/v1.0.0

- OpenAI 上线 ChatGPT Wallet：agent 拿支付 token，永远看不到你的卡号
  与 Amex / Mastercard / Visa 共建，每笔由 Face ID 等生物验证授权、生成替代卡号；首发接入 dots（ChatGPT Pro，美国）——"agent 代付"第一次有了可审计的链路
  https://openai.com/index/introducing-chatgpt-wallet

⚡ 精选动态

- 【🆕新发布】Amazon Bedrock AgentCore runtime V2：预热快照把 agent 冷启动压到 ~2 秒
  不再逐 session 拉镜像初始化，而是启动一次 → 冻结 microVM 内存与磁盘做快照 → 新 session 直接 restore；官方给了 4 种模式（build hook 预加载、用户进场即预热）
  https://aws.amazon.com/blogs/machine-learning/architecture-patterns-for-fast-session-startup-on-amazon-bedrock-agentcore-runtime/

- 【🔧工具】AWS 用 NVIDIA NeMo Switchyard 给 coding agent 做模型路由，验收指标是「cost per solved task」
  指出 token 单价没意义——要看总成本 / 测试通过的 run 数；给了 LiteLLM + Switchyard 插件 + CDK 部署和 A/B 基准脚本（示例代码，非生产）
  https://aws.amazon.com/blogs/machine-learning/route-coding-agent-requests-to-the-right-model-on-amazon-bedrock-with-nvidia-nemo-switchyard/

- 【🆕新发布】Claude Meetings 进入 beta：Claude 作为可见参会者加入 Google Meet
  实时记笔记、答疑，并在通话中直接产出文档 / 白板 / 幻灯片；Team 与 Enterprise 计划先开（11/12 起 rollout）
  https://support.claude.com/en/articles/12138966-release-notes

- 【🔧工具】pydantic-ai v2.68.0：审批与反问回到 run 内（RequestInput），子 agent 事件标准化
  新增 OutputTokenLimitExceeded + ModelFallback 自动降级、ConversationStore 持久化 UI adapter 会话、PromptInjectionDefender 可作为 Temporal durable operation 跑
  https://github.com/pydantic/pydantic-ai/releases/tag/v2.68.0

- 【🔧工具】AWS 开源 aws-emulator：不用真云账号也能本地跑集成测试
  Rust 写的本地服务克隆，要求 Docker；项目本身由"agent 集群"写出来——前三周 29,684 次 commit
  https://github.com/aws/aws-emulator

- 【📊趋势】Anthropic IPO 路演启动，路演视频首次披露算力与商业模型细节
  与「Claude 攻势太猛、OpenAI 有点收缩」的同周舆论互文——两家在定价与算力上的分化，会直接传导到你下一季的模型选型成本
  https://simonwillison.net/2026/Nov/11/anthropic-ipo-roadshow/

🌟 GitHub Pick

- ggml-org/llama.cpp  ·  Trending（v1.0.0 发布日）  ·  C/C++
  LLM 推理的 C/C++ 基石，稳定 ABI 后下游绑定和私有化部署可以放心 pin 版本
  https://github.com/ggml-org/llama.cpp

- aws/aws-emulator  ·  新库首周冲榜  ·  Rust
  由 agent 海量提交催生的官方云服务本地模拟器，测试不再烧真实 API 额度
  https://github.com/aws/aws-emulator

（今日数据源以一手发布为主；新闻源为二手转述的条目已交叉核验官方 Release / 博客后才收录）
