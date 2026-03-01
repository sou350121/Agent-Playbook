# Mac 多开 Chrome 物理隔离指南

> 适用场景：Web3 多账号操作、多 Agent 环境隔离、跨境电商多店铺管理。本方案利用 Chrome 原生参数实现数据与网络的双重隔离。

## 1. 核心原理

通过命令行启动 Chrome，并强制指定不同的**数据目录**和**代理服务器**：

- `--user-data-dir`：指定一个全新的文件夹存放该窗口的所有 Cookie、插件和缓存。
- `--proxy-server`：指定该窗口流量经过的代理 IP。

## 2. 实操步骤

### 2.1 准备脚本

1. 在 Mac 上新建一个文件夹（例如 `ChromeProfiles`）。
2. 在该文件夹内创建一个 `.command` 后缀的文件（例如 `Profile001.command`）。
3. 填入以下代码模板：

```bash
#!/bin/bash
# 注意：修改 --user-data-dir 路径为你本地的路径
# 修改 --proxy-server 为你的代理 IP:端口
open -n -a "Google Chrome" --args \
  --user-data-dir="$HOME/Documents/ChromeProfiles/001" \
  --proxy-server="http://your_proxy_ip:port" \
  --no-first-run
```

### 2.2 赋予执行权限

打开终端，输入以下命令（只需操作一次）：
```bash
chmod +x $HOME/Documents/ChromeProfiles/Profile001.command
```

### 2.3 批量化

通过复制多个 `.command` 文件并修改数字编号，即可实现瞬间启动几十个相互独立的 Chrome 窗口。

## 3. 进阶管理建议

- **窗口布局**：推荐配合 **Rectangle** 或 **Magnet** 软件，将屏幕切分为 4 或 6 块，实现高效监控。
- **代理安全**：
    - 代理验证（账号密码）建议在窗口弹出时**手动输入并保存**。
    - **警惕**：避免使用第三方的代理自动填充插件，已有爆雷案例（窃取钱包数据）。
- **指纹伪装**：虽然数据隔离了，但浏览器指纹（如 Canvas, WebGL）仍具相似性。对于极高安全要求的场景，建议配合 `Canvas Defender` 插件手动微调。

## 4. 与 Agent 的结合

在 **Agentic Workflow** 中，如果你需要让不同的 Agent 模拟真实用户行为（如在不同账号下操作），这套方案是目前最经济、最透明的底层架构。

---

**关联阅读：**
- [智力套利策略：利用平权智力寻找利基机会](../methodology/planning/intelligence-arbitrage-strategy.mdx)
- [CC Switch: AI CLI 配置快速切换工具](./cc-switch-guide.mdx)
