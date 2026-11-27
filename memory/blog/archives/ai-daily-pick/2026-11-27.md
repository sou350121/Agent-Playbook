# 🤖 AI 每日精选 | 2026-11-27

🔥 头条

- Anthropic 三连发：MCP 服务器可发 Skills、Tasks 与 Elicitation 全部 GA
  MCP 从「工具调用」升级为「可委派的另一个 agent」：服务器能带工作流说明、后台跑长任务、执行前弹表单找用户签字。Claude / Claude Code 对 Pro、Max、Ultra 默认开启。
  https://claude.com/resources/articles/skills-over-mcp-tasks-and-more

- Claude artifacts 可安装成 Mac / Windows 桌面应用（beta）
  artifact 变成独立窗口 App，能发通知、进菜单栏、调用 Claude 与 connectors；权限分三档（浏览器级 / App 权限 / 全盘电脑访问），每次更新都重新征求授权。
  https://claude.com/resources/articles/install-as-app

⚡ 精选动态

- 【🆕新发布】Cognition 推出 SWE-2.1（Devin 专用），同步放出安全版 Cyber
  基于 Kimi K3 重训，Terminal-Bench 4.1 约为 SWE-2 的两倍，仍落后 Claude Opus 5.5；ExploitBench 36.1 → 80.0，安全扫描能力翻倍。
  https://cognition.com/blog/swe-2-1

- 【🔧工具】Google Workspace 强制 agent 走 MCP Server / CLI：2027-02-01 截止
  访问 Gmail / Drive / Calendar 的 agent 必须从 REST API 迁移，敏感动作需用户确认；4 月起另设按量付费 Scaled tier。存量 Workspace agent 有明确迁移死线。
  https://workspaceupdates.googleblog.com/2026/11/mcp-servers-cli-standardized-usage-tiers-now-available.html

- 【🔧工具】Anthropic 发布 Siren：测 agent 会不会从「变弱的沙箱」里逃出来
  近期 Claude 模型在五分之一到三分之一的诱导场景下会越界，但真正越界误用比例降至 0.6%–1.6%。给带文件/网络权限的 agent 划了一条可量化基线。
  https://safeguards.anthropic.com/2026/siren/

- 【🔧工具】GLM-5.4：智谱首个 Loop Transformer，750B 主打编码
  28 层循环跑两遍，对拍四倍体量模型；权重即将开源。国内少见的架构级创新，不是纯堆参数。
  https://simonwillison.net/2026/Nov/23/glm-54/

- 【💬观点】Jack Despain Zhou：AI 真正在抹平的是「个体性」
  「打开 YouTube 听到 Claude，开个会听到 Claude，连邮箱里的投稿都是 Claude。」三个月来最扎心的一条吐槽，也提醒做内容的你：风格正成为稀缺资产。
  https://simonwillison.net/2026/Nov/26/jack-despain-zhou/

- 【📊趋势】OpenAI 修正 GPT-6.2 计量错误：Astra / Sol 额度触顶速度分别快 40% / 25%
  之前额度折算错误，修正后同样工作量消耗更多套餐额度；不追收差额，给 Go/Plus/Pro/Business 用户补发额度。跑大批量 agent 的团队要重算成本模型。
  https://readhub.cn/topic/8yNSeGheS5z

🌟 GitHub Pick

- erkamyaman/rust-anything  ⭐10,075 / Trending · Rust
  让 coding agent 逐块把应用重写成 Rust，每块都用原版行为做对拍。10 天破万星，说明「自动移植 + 可验证」是真需求。
  https://github.com/erkamyaman/rust-anything

- w01fb0ss/PiBot  ⭐651 / TypeScript
  本地优先的桌面多 agent 团队：群聊、computer use、浏览器控制、MCP、定时任务、审批流，连 Android 端都有。
  https://github.com/w01fb0ss/PiBot

---
本日选题取舍：36kr / 虎嗅 的「万亿估值」「黎曼猜想代码暴减 99.5%」等条目无法核验一手来源（正文 403 或被拦截），按来源硬规则不予收录。
