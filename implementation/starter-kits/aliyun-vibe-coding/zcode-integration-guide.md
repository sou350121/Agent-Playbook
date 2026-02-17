# zcode + 阿里云集成配置指南

## 什么是 zcode？

**zcode** 是智谱 AI 推出的 AI 代码编辑器，专为 Vibe Coding 场景设计。核心特性：

- **多模型统一界面**：一个窗口切换 Claude/智谱 GLM/Gemini 等模型
- **MCP 协议支持**：可扩展云端能力（如阿里云 API）
- **内置浏览器**：直接访问阿里云控制台验证部署
- **可视化工作流**：降低 CLI 门槛，让意图描述更直观

---

## 一、安装与基础配置

### 1.1 下载安装

```bash
# 访问智谱官网下载
https://www.zhipuai.cn/download/zcode

# 或使用包管理器（macOS）
brew install --cask zcode

# Windows: 使用安装包
# Linux: 解压后运行 ./zcode
```

### 1.2 配置 AI 模型

**步骤**：
1. 打开 zcode，进入 `Settings` → `Providers`
2. 添加模型提供商：
   - **Claude**：输入 Anthropic API Key
   - **智谱 GLM**：输入智谱 API Key
   - **其他**：根据需要添加

3. 测试连接：发送测试消息验证配置

---

## 二、集成阿里云 CLI

### 2.1 在 zcode 终端中配置

```bash
# 打开 zcode 内置终端（Ctrl + `）

# 配置阿里云 CLI
aliyun configure

# 按提示输入：
# Access Key ID: LTAI5t7xxxxxxxxxx
# Access Key Secret: xxxxxxxxxxxxxxxxxxxx
# Region: cn-hangzhou
# Output Format: json
```

### 2.2 验证配置

```bash
# 测试 CLI 是否正常
aliyun ecs DescribeRegions

# 应返回所有可用区域的列表
```

---

## 三、MCP 扩展：连接阿里云 API

### 3.1 创建 Aliyun MCP Server

**为什么需要 MCP？**
- 让 zcode 内的 Agent 直接调用阿里云 API
- 无需手动执行 CLI 命令
- 实现真正的"意图 → 云端"自动化

**安装 MCP Server**：

```bash
# 使用 npm 安装（Node.js 版本）
npm install -g @aliyun/mcp-server-aliyun

# 或使用 Python 版本
pip install aliyun-mcp-server
```

### 3.2 配置 zcode MCP

**编辑 zcode 配置文件**：

```json
// 在 zcode 设置中添加 MCP 配置
{
  "mcp.servers": {
    "aliyun": {
      "command": "aliyun-mcp-server",
      "args": [
        "--access-key-id", "LTAI5t7xxxxxxxxxx",
        "--access-key-secret", "xxxxxxxxxxxxxxxxxx",
        "--region", "cn-hangzhou"
      ]
    }
  }
}
```

### 3.3 测试 MCP 连接

**在 zcode 中创建测试文件** `test-aliyun-mcp.md`：

````markdown
```mcp
{
  "server": "aliyun",
  "action": "DescribeInstances"
}
```
````

**预期输出**：返回当前账号的所有 ECS 实例列表

---

## 四、典型工作流案例

### 案例 1：意图驱动的 ECS 创建

**步骤 1**：在 zcode 中新建文件 `deploy-intent.md`

**步骤 2**：输入意图描述

````markdown
# 部署意图

我想创建一个 Python Flask 应用：
- 提供 /health 接口
- 使用 Docker 部署
- 部署到阿里云 ECS（2核4G，Ubuntu 20.04）
- 使用 Terraform 管理基础设施

请按照 Vibe Coding 第一定律，使用工业级最佳实践。
````

**步骤 3**：调用 Agent

```bash
# 在 zcode 中按快捷键（Ctrl + Shift + A）
# 选择模型：Claude Sonnet 4.5
# Agent 将自动生成：
# - app.py（Flask 应用）
# - Dockerfile
# - terraform/main.tf
# - deploy.sh（自动部署脚本）
```

**步骤 4**：人类审核（关键！）

```bash
# 查看生成的文件
cat app.py
cat Dockerfile
cat terraform/main.tf

# 确认无误后执行
cd terraform
terraform plan  # 预览变更
terraform apply # 应用配置
```

**步骤 5**：验证部署

```bash
# 使用 zcode 内置浏览器
# 访问 http://$(terraform output public_ip):5000/health

# 或使用终端
curl http://$(terraform output public_ip):5000/health
```

---

### 案例 2：使用 MCP 自动化云操作

**在 zcode 中新建文件 `create-ecs.md`**：

````markdown
# 使用 MCP 创建 ECS

请帮我：
1. 调用阿里云 MCP，创建一台 ECS 实例（2核4G）
2. 等待实例启动完成
3. SSH 到服务器并安装 Docker
4. 返回实例的公网 IP

使用 MCP 协议，而非手动 CLI。
````

**Agent 生成的代码**：

```python
# create_ecs.py
import json
import subprocess
import time

def call_mcp(action, params):
    """调用阿里云 MCP Server"""
    # 这里简化了实际调用逻辑
    result = subprocess.run([
        "aliyun-mcp-server",
        "--action", action,
        "--params", json.dumps(params)
    ], capture_output=True, text=True)

    return json.loads(result.stdout)

# 1. 创建 ECS
instance = call_mcp("CreateInstance", {
    "InstanceType": "ecs.t6-c1m2.large",
    "ImageId": "ubuntu_20_04_x64_20G_alibase_20230908.vhd",
    "SecurityGroupId": "sg-xxxxx"
})

instance_id = instance["InstanceId"]
print(f"✅ ECS 创建成功: {instance_id}")

# 2. 等待启动
time.sleep(60)

# 3. 获取公网 IP
instance_info = call_mcp("DescribeInstanceAttribute", {
    "InstanceId": instance_id
})

public_ip = instance_info["PublicIpAddress"]["IpAddress"][0]
print(f"✅ 公网 IP: {public_ip}")

# 4. SSH 并安装 Docker
# ...（略）
```

---

## 五、zcode 实用技巧

### 5.1 内置浏览器验证部署

**操作步骤**：
1. 部署完成后，Agent 返回应用 URL
2. 在 zcode 中按 `Ctrl + B` 打开内置浏览器
3. 粘贴 URL，直接查看应用运行状态

**优势**：
- 无需切换到外部浏览器
- Agent 可以自动截图并汇报状态

### 5.2 可视化 Git 操作

**典型流程**：
```bash
# Agent 生成代码后
git add .
git commit -m "feat: add Flask application with Terraform config"

# 在 zcode 的 Git 面板中：
# 1. 查看变更差异
# 2. 审核每一行代码
# 3. 确认后推送
git push
```

### 5.3 多模型并行测试

**场景**：对比不同模型的代码质量

````markdown
# 测试 Claude vs 智谱 GLM

意图：创建一个 Python 爬虫

请使用 **Claude Sonnet 4.5** 生成方案 A
请使用 **智谱 GLM-4** 生成方案 B

对比两者：
- 代码质量
- 错误处理
- 性能优化
````

**在 zcode 中**：
1. 切换 Provider，让不同模型生成代码
2. 使用内置 Diff 工具对比
3. 选择最优方案

---

## 六、常见问题

### Q1：MCP Server 连接失败？
**解决方案**：
```bash
# 检查 MCP Server 是否运行
ps aux | grep aliyun-mcp-server

# 查看日志
tail -f ~/.zcode/logs/mcp.log

# 重启 MCP Server
killall aliyun-mcp-server
aliyun-mcp-server --daemon
```

### Q2：阿里云 CLI 未找到？
**解决方案**：
```bash
# 添加到 PATH（macOS/Linux）
echo 'export PATH=$PATH:/usr/local/bin' >> ~/.zshrc
source ~/.zshrc

# Windows: 在系统环境变量中添加
# C:\Program Files\Aliyun\CLI
```

### Q3：Agent 生成的 Terraform 配置有误？
**解决方案**：
1. 使用 `terraform plan` 查看详细错误
2. 让 Agent 解释每一行配置
3. 参考 Terraform 文档手动修正

---

## 七、进阶配置

### 7.1 自定义 MCP 工具

**场景**：封装常用的云操作

**创建自定义 MCP Server**：

```python
# my-aliyun-tools.py
from mcp import Server

server = Server("my-aliyun-tools")

@server.tool("create_web_server")
def create_web_server(app_name: str, port: int = 5000):
    """快速创建 Web 服务器（封装 ECS + Docker）"""
    # 1. 创建 ECS
    # 2. 配置安全组
    # 3. 安装 Docker
    # 4. 返回连接信息
    pass

@server.tool("cleanup_resources")
def cleanup_resources(app_name: str):
    """清理所有相关资源"""
    pass

if __name__ == "__main__":
    server.run()
```

### 7.2 集成 CI/CD

**在 zcode 中配置**：

```json
// .vscode/tasks.json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Deploy to Aliyun",
      "type": "shell",
      "command": "terraform apply -auto-approve",
      "problemMatcher": [],
      "group": {
        "kind": "build",
        "isDefault": true
      }
    }
  ]
}
```

**使用**：按 `Ctrl + Shift + B` 一键部署

---

## 八、最佳实践

### ✅ DO（推荐做法）

1. **人类审核**：Agent 生成的 Terraform/代码必须人工审核
2. **幂等操作**：使用 Terraform 而非手动 CLI（确保可重复执行）
3. **成本控制**：实验完成后立即 `terraform destroy`
4. **版本控制**：所有生成的文件纳入 Git 管理

### ❌ DON'T（避免做法）

1. **直接执行**：不要让 Agent 直接运行 `terraform apply`
2. **硬编码密钥**：使用环境变量，不要将 Access Key 写入代码
3. **忽略日志**：查看 Agent 的思考过程，理解其决策逻辑
4. **过度依赖**：Agent 是助手，人类是架构师和决策者

---

## 九、资源链接

- **zcode 官网**：https://zcode.zhipuai.cn
- **zcode GitHub**：https://github.com/zhipuai/zcode
- **MCP 协议规范**：https://modelcontextprotocol.io
- **阿里云 CLI 文档**：https://help.aliyun.com/document_detail/110627.html

---

## 十、下一步

1. **完成案例 A**：使用 zcode 部署第一个应用到阿里云
2. **开发自定义 MCP Server**：封装你的常用云操作
3. **分享经验**：将你的工作流提交到本仓库

---

> **Vibe Coding 理念**：zcode 是意图输入层，阿里云是执行层。Agent 负责将人类意图转化为可执行计划，人类负责审核和决策。
