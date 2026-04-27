# 📡 订阅 Pulsar 照見 · AI Agent 频道

> AI Agent 生态每天 50+ 信号，自动过滤为 5-10 条工程关键精选 · RSS 推送到你的阅读器
> 🔗 配套：[VLA-Handbook 同款订阅页](https://github.com/sou350121/VLA-Handbook/blob/main/docs/SUBSCRIBE.md)

---

## 🎁 一键订阅（最快）

到 **[订阅页](https://sou350121.github.io/pulsar-web/subscribe/)** 点对应按钮：

- **[Feedly]** 一键跳转 Feedly 订阅对话框
- **[Inoreader]** 同上
- **[复制 URL]** 给其他阅读器

**一键全订阅**：下载 [OPML 文件](https://sou350121.github.io/pulsar-web/rss/opml.xml) 导入任何支持 OPML 的阅读器（Feedly/Inoreader/NetNewsWire 都支持）。

---

## 🛰️ 关于 AI Agent 的 Feed

### 📘 AI 每日（重点订阅）
**URL**：`https://sou350121.github.io/pulsar-web/rss/ai-daily.xml`

- AI Agent 生态每日精选（每天 5-10 条）
- 含 AI 深度解读文章
- 来源：Hacker News / 36kr / Simon Willison / GitHub Trending / OpenAI / Anthropic / Readhub 等
- 经 qwen3.5-plus 评级筛选（⚡🔧📖❌）

### 📚 周/双周深度报告
**URL**：`https://sou350121.github.io/pulsar-web/rss/weekly.xml`

- 周报 = 前瞻侦察（意外信号 / 可证伪命题 / 观察清单）
- 双周报 = 回顾分析（趋势识别 / 交叉洞察 / 预测验证）
- 含 AI App 域 + VLA 域两个版本（按订阅源区分）

### 🤖 VLA 配套频道（如果你也关注机器人）

- 🧠 **VLA 新文章**：`/rss/vla-theory.xml`
- ⚡ **VLA 每日信号**：`/rss/vla-daily.xml`

---

## 怎么开始订阅

### 桌面浏览器

- **Feedly / Inoreader**：到 [订阅页](https://sou350121.github.io/pulsar-web/subscribe/) 点对应按钮
- **NetNewsWire**（macOS 原生，免费）：File → Import Feeds → 选 opml.xml
- **其他**：复制 URL 后在阅读器 Add Subscription

**最懒方式**：Feedly/Inoreader 直接贴**网站首页** `https://sou350121.github.io/pulsar-web/`，阅读器自动发现 4 个 feed。

### 手机

- iOS：Reeder 5 / NetNewsWire / Feedly
- Android：FeedMe / Readably / Feedly
- 都支持 OPML 一键导入

### 命令行 / 自动化

```bash
# curl 测试
curl https://sou350121.github.io/pulsar-web/rss/ai-daily.xml | head -50

# Zapier / n8n 接 Slack / Discord / Telegram
# rss2email 转邮件
# Buttondown / Feedburner 做广播邮件
```

---

## 内容许可

所有订阅内容以 **[CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)** 授权：

- ✅ 自由转载 / AI 训练 / 商用
- ✅ 只需署名：`sou350121 · Pulsar 照見 · https://sou350121.github.io/pulsar-web/`

每个 feed XML 都自带 `<copyright>` 标记，聚合器会自动保留。

---

## FAQ

### Q: 为什么 feed 不放全文？
**A**: 故意的。标题+摘要+链接 → 你点进去看全文 → 我们能知道哪些受欢迎，帮助优化筛选。

### Q: AI 每日 feed 频率？
**A**: 每天 1 次（北京时间约 12:00 部署），通常含 5-10 条精选。

### Q: 链接里 `?utm_source=rss&...` 是什么？
**A**: UTM 追踪参数。如果接入 Umami/Plausible 等可分析"读者从 RSS 来" vs "直接访问"。不收集任何个人信息。

### Q: feed 会消失吗？
**A**: 只要 pulsar-web 站点还在。`/rss/*` 路径在 CI smoke test 保护下，pipeline 架构变动不会让 feed 静默失效。

---

## 反馈

- **Bug / 错误**：[提 Issue](https://github.com/sou350121/Agent-Playbook/issues)
- **想加新 feed**：同上
- **VLA 版本**：参考 [VLA-Handbook SUBSCRIBE.md](https://github.com/sou350121/VLA-Handbook/blob/main/docs/SUBSCRIBE.md)
