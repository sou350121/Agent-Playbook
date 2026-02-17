# 阿里云 + Vibe Coding 启动脚本

> **目标**：30 分钟完成从"零"到"云端应用部署"的全流程

---

## 📦 目录结构

```
aliyun-vibe-coding/
├── install-aliyun-cli.sh          # macOS/Linux 自动安装脚本
├── install-aliyun-cli.ps1         # Windows 自动安装脚本
├── docker-templates/              # Docker 模板
│   ├── Python.Dockerfile         # Python 应用模板
│   ├── Node.Dockerfile           # Node.js 应用模板
│   └── docker-compose.yml        # 多容器编排模板
├── terraform-examples/           # Terraform 基础设施示例
│   └── ecs-docker/               # ECS + Docker 部署
│       ├── main.tf               # 主配置文件
│       ├── variables.tf          # 变量定义
│       ├── user-data.sh          # ECS 初始化脚本
│       └── README.md             # 使用说明
└── zcode-integration-guide.md    # zcode 集成配置指南
```

---

## 🚀 快速开始

### 步骤 1：安装阿里云 CLI（5 分钟）

**macOS/Linux**：

```bash
# 运行自动安装脚本
chmod +x install-aliyun-cli.sh
./install-aliyun-cli.sh

# 验证安装
aliyun version
```

**Windows**：

```powershell
# 以管理员身份运行 PowerShell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\install-aliyun-cli.ps1

# 验证安装
aliyun version
```

### 步骤 2：配置 Access Key（2 分钟）

```bash
aliyun configure

# 按提示输入：
# Access Key ID: LTAI5t7xxxxxxxxxx
# Access Key Secret: xxxxxxxxxxxxxxxxxxxx
# Region: cn-hangzhou
# Output Format: json
```

**获取 Access Key**：
1. 访问 https://ram.console.aliyun.com/manage/ak
2. 创建 Access Key
3. 复制并妥善保管

### 步骤 3：使用 Docker 模板（10 分钟）

**Python 应用示例**：

```bash
# 1. 复制模板
cp docker-templates/Python.Dockerfile ./Dockerfile

# 2. 创建 app.py
cat > app.py << 'EOF'
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello():
    return "Hello from Aliyun + Vibe Coding!"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
EOF

# 3. 创建 requirements.txt
echo "Flask==3.0.0\ngunicorn==21.2.0" > requirements.txt

# 4. 构建并运行（本地测试）
docker build -t my-app .
docker run -p 5000:5000 my-app

# 5. 测试
curl http://localhost:5000/
```

### 步骤 4：部署到阿里云（15 分钟）

```bash
# 1. 进入 Terraform 示例目录
cd terraform-examples/ecs-docker

# 2. 初始化 Terraform
terraform init

# 3. 预览变更（重要！）
terraform plan

# 4. 应用配置
terraform apply

# 5. 获取访问地址
terraform output app_url
# 输出示例：http://47.96.xxx.xxx:5000

# 6. 访问应用
curl $(terraform output app_url)
```

### 步骤 5：清理资源（重要！）

```bash
# 实验完成后立即释放资源
cd terraform-examples/ecs-docker
terraform destroy
```

---

## 📚 详细文档

### 核心指南

- **[阿里云 + Vibe Coding 实战指南](../../stack/tools/aliyun-vibe-coding-practical-guide.mdx)**
  - 核心服务速览
  - Docker 化部署完整流程
  - 成本优化策略
  - 常见问题与调试

### 实战案例

- **[三个渐进式部署案例](../../use-cases/case-studies/aliyun-vibe-coding-deployment.mdx)**
  - 案例 A：Flask + ECS（入门，30 分钟）
  - 案例 B：定时爬虫 + 函数计算（进阶，1 小时）
  - 案例 C：多 Agent + ACK（高级，3 小时）

### zcode 集成

- **[zcode + 阿里云配置指南](./zcode-integration-guide.md)**
  - 安装与配置
  - MCP 扩展开发
  - 典型工作流案例

---

## 🎯 学习路径

### 阶段 1：基础准备（第 1 周）

**目标**：搭建环境，理解核心概念

**任务清单**：
- [ ] 安装 Docker 和阿里云 CLI
- [ ] 阅读 [Vibe Coding 范式](../../stack/methodology/planning/vibe-coding-paradigm.mdx)
- [ ] 本地运行一个 Docker 容器

**验证标准**：
```bash
# 能成功运行
docker run hello-world
aliyun ecs DescribeRegions
```

---

### 阶段 2：首个云端部署（第 2-3 周）

**目标**：完成"意图 → 代码 → 云端"全流程

**任务清单**：
- [ ] 阅读实战指南
- [ ] 在 zcode 中输入部署意图
- [ ] 审核 Agent 生成的代码
- [ ] 使用 Terraform 部署到 ECS

**验证标准**：
- 应用成功在云端运行
- 能通过公网 IP 访问
- 实验完成后正确释放资源

---

### 阶段 3：进阶自动化（第 4-6 周）

**目标**：掌握 Serverless 和多 Agent 编排

**任务清单**：
- [ ] 完成案例 B（函数计算 + OSS）
- [ ] 尝试案例 C（ACK + Kubernetes）
- [ ] 开发自定义 MCP Server

**验证标准**：
- 能独立选择合适的云服务
- 理解成本优化策略
- 掌握幂等安全墙原则

---

## 💡 最佳实践

### ✅ DO（推荐做法）

1. **人类审核**：Agent 生成的 Terraform/代码必须人工审核
2. **幂等操作**：使用 Terraform 而非手动 CLI（确保可重复执行）
3. **成本控制**：实验完成后立即 `terraform destroy`
4. **版本控制**：所有生成的文件纳入 Git 管理
5. **最小权限**：使用 RAM 子账号，只授予必要权限

### ❌ DON'T（避免做法）

1. **直接执行**：不要让 Agent 直接运行 `terraform apply`
2. **硬编码密钥**：使用环境变量，不要将 Access Key 写入代码
3. **忽略日志**：查看 Agent 的思考过程，理解其决策逻辑
4. **过度依赖**：Agent 是助手，人类是架构师和决策者
5. **忘记清理**：实验后必须释放资源，避免持续计费

---

## 💰 成本参考

| 资源 | 配置 | 按量付费 | 包年包月 |
|------|------|---------|---------|
| ECS | 2核4G | 0.35 元/小时 | 145 元/月 |
| 函数计算 | 内存 512MB | 0.000031 元/调用 | - |
| OSS | 标准存储 | 0.12 元/GB/月 | - |

**成本控制技巧**：
- 使用按量付费进行实验
- 设置费用告警（>100 元通知）
- 实验完成后立即释放资源
- 使用函数计算代替 ECS（几乎免费）

---

## 🛠️ 故障排查

### 问题 1：阿里云 CLI 配置失败

**错误**：`configure: command not found`

**解决方案**：
```bash
# 检查 CLI 是否正确安装
which aliyun

# 检查 PATH 环境变量
echo $PATH

# macOS/Linux: 添加到 PATH
export PATH=$PATH:/usr/local/bin

# Windows: 在系统环境变量中添加
# C:\Program Files\Aliyun\CLI
```

### 问题 2：Docker 构建失败

**错误**：`Cannot connect to the Docker daemon`

**解决方案**：
```bash
# 启动 Docker 服务
sudo service docker start  # Linux
open -a Docker            # macOS

# 验证
docker ps
```

### 问题 3：Terraform 执行超时

**错误**：`Timeout waiting for instance to become running`

**解决方案**：
```bash
# 查看实例状态
aliyun ecs DescribeInstanceAttribute --InstanceId i-xxxxx

# 延长超时时间（在 main.tf 中）
resource "time_sleep" "wait_for_instance" {
  depends_on = [alicloud_instance.default]
  create_duration = "5m"  # 延长到 5 分钟
}
```

### 问题 4：成本超预算

**原因**：忘记释放资源

**解决方案**：
```bash
# 立即释放所有 ECS 实例
aliyun ecs DescribeInstances --output json | \
  jq '.Instances.Instance[].InstanceId' | \
  xargs -I {} aliyun ecs DeleteInstance --InstanceId {} --Force true

# 设置定时任务（每天 22:00 提醒）
# 使用 crontab 或 Windows 任务计划程序
```

---

## 📖 扩展阅读

### Vibe Coding 理念

- [Vibe Coding 第一定律](../../blog/2026-01-02-vibe-coding-first-law.md)
- [Vibe Coding 范式](../../stack/methodology/planning/vibe-coding-paradigm.mdx)
- [Agent 编排架构](../../stack/frameworks/ai-coding-agent-architecture.mdx)

### 云服务对比

- [云端 vs 本地执行](../../stack/frameworks/agent-execution-environment-cloud-vs-local.mdx)
- [Docker Mastery for Agents](../../stack/tools/docker-mastery-for-agents.mdx)

### 初学者指南

- [小白通关手册](../../implementation/getting-started/README.md)
- [工具栈入门](../../implementation/getting-started/02-tool-stack.md)

---

## 🤝 贡献指南

欢迎提交你的实战案例和经验分享！

**如何贡献**：
1. Fork 本仓库
2. 创建分支：`git checkout -b feature/your-case`
3. 提交变更：`git commit -m "feat: add xxx case"`
4. 推送分支：`git push origin feature/your-case`
5. 创建 Pull Request

**贡献类型**：
- 实战案例（case-studies/）
- Docker 模板（docker-templates/）
- Terraform 示例（terraform-examples/）
- 文档改进（docs/）

---

## 📄 许可证

本仓库内容采用 CC BY-SA 4.0 许可证。

---

> **Vibe Coding 第一定律实践**：所有脚本和模板都追求"工业级、标准、鲁棒"，而非"最快速完成"。让 AI 承担繁琐的配置工作，人类专注业务意图和架构决策。
