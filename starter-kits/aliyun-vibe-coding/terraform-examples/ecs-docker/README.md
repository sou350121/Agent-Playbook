# Terraform 使用指南

## 快速开始

### 1. 配置 Access Key

```bash
export ALICLOUD_ACCESS_KEY="your-access-key-id"
export ALICLOUD_SECRET_KEY="your-access-key-secret"
export ALICLOUD_REGION="cn-hangzhou"
```

### 2. 初始化 Terraform

```bash
terraform init
```

### 3. 预览变更

```bash
terraform plan
```

### 4. 应用配置

```bash
terraform apply
```

### 5. 查看输出

```bash
terraform output
```

输出示例：
```
instance_id = i-xxxxxxxxx
public_ip = 47.96.xxx.xxx
ssh_command = ssh root@47.96.xxx.xxx
app_url = http://47.96.xxx.xxx:5000
```

### 6. 销毁资源

```bash
terraform destroy
```

## Vibe Coding 最佳实践

1. **人类审核**：运行 `terraform plan` 后，人类必须审核变更
2. **幂等性**：Terraform 确保多次执行结果一致
3. **版本控制**：所有 `.tf` 文件纳入 Git 管理
4. **状态文件**：使用阿里云 OSS 存储 Terraform 状态（生产环境）

## 成本提示

- 默认配置使用按量付费 ECS（约 0.35 元/小时）
- 实验完成后立即运行 `terraform destroy` 释放资源
- 可通过 `var.environment` 切换环境（dev/staging/production）

## 故障排查

### 问题 1：SSH 连接失败
```bash
# 检查安全组规则
terraform show | grep security_group

# 在阿里云控制台确认安全组已开放 22 端口
```

### 问题 2：Docker 未安装
```bash
# SSH 到服务器，手动执行安装脚本
ssh root@$(terraform output public_ip)
curl -fsSL https://get.docker.com | sh
```

### 问题 3：实例启动超时
```bash
# 查看实例状态
aliyun ecs DescribeInstanceAttribute --InstanceId $(terraform output instance_id)

# 查看用户数据执行日志
cat /var/log/cloud-init-output.log
```
