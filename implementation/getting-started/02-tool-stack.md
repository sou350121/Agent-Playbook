# 02 工具：Cursor / Claude Code / MCP / Skills 入门

你可以把 Coding Agent 想象成一个“超级工厂”。要开动这个工厂，你需要认识这三个核心组件。

```text
       [ 你 (指挥官) ]
             |
             v
    +-----------------------+
    |   Cursor / Claude     | <--- [ 底座 ] (环境与编辑器)
    +-----------+-----------+
                |
        +-------+-------+
        |               |
  v-----+-----v   v-----+-----v
  |    MCP    |   |   Skills  |
  +-----------+   +-----------+
    [ 触角 ]        [ 说明书 ]
 (连接真实世界)    (专业工作流)
```

## 1. 核心底座：Cursor / Claude Code
这是你工作的“桌面”。

- **Cursor**：像是一个带了 AI 助手的 IDE（开发工具）。它能看到你所有的代码，帮你写、帮你改。
- **Claude Code (CLI)**：像是一个“住在你电脑里的幽灵”。它在终端运行，执行力极强，能跨越很多文件完成复杂任务。

**小白建议**：先从 **Cursor** 开始。它的可视化界面更友好，报错时 AI 会直接在旁边给你建议。

## 2. 工具插头：MCP (Model Context Protocol)
- **大白话**：它是 AI 的“插头”或“感官”。
- **干什么用**：AI 默认只知道它训练过的数据。MCP 能让 AI 连接上你的**真实世界**。

```text
      [ AI 大脑 ]
          |
    +-----+-----+
    |  MCP 接口  | <--- 各种插头 (Plugs)
    +-----+-----+
          |
    +-----+-----------------------+
    | [搜索] [文件] [数据库] [网络] |
    +-----------------------------+
```

  - **Google Search MCP**：让 AI 能上网搜最新的技术文档。
  - **FileSystem MCP**：让 AI 读写你电脑上的文件（安全受控）。
  - **Memory/Context MCP**：让 AI 记住你的偏好。

**一句话总结**：有了 MCP，AI 就不再是“纸上谈兵”，而是能干活的老师傅。

## 3. 幂等安全墙：Skills (技能与工作流)

- **大白话**：它是 AI 的“稳定执行插件”。
- **痛点**：AI 的对话是“不确定”的，同样的指令，它今天可能写得很好，明天可能就偷懒了（这就是“非幂等性”）。
- **解决办法**：我们将复杂的、需要 100% 正确的逻辑，写成代码脚本（Skill/Script），然后让 AI 去调用。

> **Rust 哲学**：就像在建筑周围筑起高墙。
> - **墙内（Skill）**：是 100% 安全、确定的（Safe）。
> - **墙外（Prompt）**：是随机、不可控的（Unsafe）。
> 我们的目标是：让这堵“确定性”的墙越来越厚，让 AI 在既定的轨道上干活，而不是乱跑。

- **怎么用**：在本仓库的 `docs/prompt-library/` 中有很多类似的逻辑，你可以直接复制这些 Skill 的“内核”给 AI。

## 4. 为什么你需要这套“组合拳”？
如果没有这套组合，你只是在用网页版 ChatGPT：
- **手动搬运工**：你得不停地复制粘贴代码，累且容易出错。
- **信息孤岛**：AI 只有“记忆”，没有“眼睛”。它看不到你的项目结构，给出的建议往往牛头不对马嘴。
- **刻舟求剑**：它只知道训练时的数据，不知道你 5 分钟前改了什么。

有了这套组合：
- **Cursor (视力)**：提供了实时全量的项目上下文。
- **MCP (触角)**：让 AI 能连接最新的互联网文档和本地文件系统。
- **Skills (准则)**：让 AI 按照专业的工作流，而不是“拍脑袋”写代码。

## 5. 最小练习（10 分钟）
1. **安装 Cursor**（如果还没装）：去官网下载并打开。
2. **体验 .cursorrules**：
   - 在你的项目根目录新建一个 `.cursorrules` 文件。
   - 随便写一行规则，比如：“所有的代码注释必须用中文”。
   - 然后在对话框里让 AI 帮你写一小段代码，看看它是不是乖乖听话。
3. **理解“规则”的威力**：
   - 这里的规则就是你给 AI 定义的“轨道”。

更多黑话解释见：
- [小白版黑话词典：单行道与围栏](../architecture-governance/00-glossary-for-beginners.mdx)

---

## 6. 模型服务：vLLM（本地推理引擎，可选但强烈推荐）

当你开始把 Agent 用在“真实开发”里，你会很快遇到一个问题：
- 你不想每次都调用云端 API（成本/延迟/合规）。
- 你希望在本地或内网部署一个稳定的模型服务。

**vLLM** 是目前最主流的开源推理服务引擎之一，适合用作你本地/内网的“模型服务层”。

### 6.1 从官网开始（新手最省心）
- vLLM 官网：`https://vllm.ai/`
- 官网提供更友好的安装/硬件选择路径（CPU/GPU 等），建议新手从这里进入。
- 快速理解：[`vLLM 是什么？为什么叫 vLLM？`](../tools/vllm-basics-and-naming.mdx)

### 6.2 语义路由（进阶）
当你有多个模型并存时，引入“语义路由”能把模型选择、安全过滤（脱狱/PII）、语义缓存、幻觉门控统一到同一层决策。
- 深度文档：[`vLLM 语义路由深度解析`](../capabilities/vllm-semantic-routing-deep-dive.mdx)

---

## 7. 云基础设施：阿里云 (Aliyun) - 进阶工具链

当你掌握了本地开发后，下一步就是把 Agent 部署到云端。阿里云提供了完整的云基础设施，让 Vibe Coding 的"短暂性"理念真正落地。

### 7.1 核心服务速览

| 服务 | 作用 | 新手友好度 | 典型场景 |
|------|------|-----------|----------|
| **ECS** (云服务器) | 远程电脑，可以跑 Docker | ⭐⭐⭐⭐ | 部署 Web 应用、Agent 服务 |
| **OSS** (对象存储) | 云端硬盘 | ⭐⭐⭐⭐⭐ | 存文件、托管静态网站 |
| **FC** (函数计算) | 无服务器函数 | ⭐⭐⭐⭐ | 定时任务、事件驱动 |
| **ACK** (容器服务) | Kubernetes 集群 | ⭐⭐ | 多 Agent 并行处理 |

### 7.2 阿里云 CLI：云端的"遥控器"

**为什么需要 CLI？**
- 网页控制台操作慢，无法自动化
- CLI 可以被 Agent 调用，实现真正的"意图 → 云端"
- 所有操作可追溯、可重复

**快速安装**：

```bash
# macOS/Linux
curl -s https://aliyuncli.alicdn.com/aliyun-cli-install-latest.sh | bash

# 配置 Access Key
aliyun configure

# 测试
aliyun ecs DescribeRegions
```

### 7.3 zcode + 阿里云：完整工作流

```
[你在 zcode 中输入意图]
        ↓
[Agent 生成代码 + Terraform 配置]
        ↓
[人类审核] ← 关键步骤！
        ↓
[terraform apply] → 自动创建 ECS
        ↓
[SSH 部署 Docker 容器]
        ↓
[zcode 内置浏览器验证]
        ↓
[实验完成后 terraform destroy]
```

### 7.4 学习路径

1. **第 1-2 周**：本地 Docker 化应用
   - 阅读：[Docker Mastery for Agents](../tools/docker-mastery-for-agents.mdx)
   - 实践：在本地跑一个 Python Flask 容器

2. **第 3-4 周**：部署到阿里云 ECS
   - 阅读：[阿里云 + Vibe Coding 实战指南](../tools/aliyun-vibe-coding-practical-guide.mdx)
   - 实践：完成案例 A（Flask + ECS）

3. **第 5-6 周**：Serverless 进阶
   - 实践：完成案例 B（函数计算 + OSS）

### 7.5 成本提示

- **学习实验**：使用按量付费，约 0.35 元/小时
- **关键原则**：实验完成后立即释放资源（`terraform destroy`）
- **成本控制**：设置费用告警（>100 元通知）

### 7.6 快速上手（30 分钟）

```bash
# 1. 安装阿里云 CLI（见上方）
# 2. 使用本仓库的启动脚本
cd starter-kits/aliyun-vibe-coding
./install-aliyun-cli.sh  # 或 Windows PowerShell 版本

# 3. 部署第一个应用
cd terraform-examples/ecs-docker
terraform init
terraform plan  # 预览
terraform apply # 应用

# 4. 访问应用
curl http://$(terraform output app_url)

# 5. 清理资源（重要！）
terraform destroy
```

### 7.7 推荐资源

- **完整指南**：[阿里云 + Vibe Coding 实战指南](../tools/aliyun-vibe-coding-practical-guide.mdx)
- **实战案例**：[三个渐进式部署案例](../case-studies/aliyun-vibe-coding-deployment.mdx)
- **启动脚本**：[starter-kits/aliyun-vibe-coding](../../starter-kits/aliyun-vibe-coding/)
- **zcode 集成**：[zcode + 阿里云配置指南](../../starter-kits/aliyun-vibe-coding/zcode-integration-guide.md)

> **Vibe Coding 第一定律实践**：所有云部署都追求"工业级、标准、鲁棒"，而非"最快速完成"。让 AI 承担繁琐的云配置工作，人类专注业务意图。
