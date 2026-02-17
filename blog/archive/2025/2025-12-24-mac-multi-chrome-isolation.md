---
slug: mac-multi-chrome-isolation
title: Mac 低成本多开隔离方案：手搓指纹浏览器的平替
authors: [sou350121]
tags: [tools, workflow, chrome, mac, isolation]
---

来自 墨染 (@moranweb3) 的实操分享：如何利用 Chrome 原生参数实现低成本、物理级的多开隔离。这不仅适用于 Web3 撸毛，也同样适用于需要独立环境的 Multi-Agent 测试。

### 核心痛点
- **Chrome 个人资料模式**：IP 共用，缓存隔离不彻底，容易被识别为关联账号。
- **指纹浏览器 (ADS Power)**：成本高，且个人散户对安全性有顾虑。

### 解决方案：命令行参数隔离
利用 Chrome 的 `--user-data-dir` 和 `--proxy-server` 参数，实现：
1. **数据隔离**：每个窗口拥有独立的存储目录。
2. **网络隔离**：每个窗口分配独立的代理 IP。

<!-- truncate -->

> 详细配置命令与自动化脚本见：[Mac 多开 Chrome 物理隔离指南](../stack/tools/mac-multi-chrome-isolation-guide.mdx)
