#!/bin/bash
# ECS 实例启动脚本（User Data）
# 由 Agent 生成，在实例首次启动时自动执行

set -e

echo "========================================="
echo "Vibe Coding: ECS 初始化脚本"
echo "========================================="
echo ""

# 更新系统
echo "[1/6] 更新系统..."
apt-get update
apt-get upgrade -y

# 安装 Docker
echo "[2/6] 安装 Docker..."
curl -fsSL https://get.docker.com | sh
systemctl enable docker
systemctl start docker

# 安装 Docker Compose
echo "[3/6] 安装 Docker Compose..."
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# 配置防火墙
echo "[4/6] 配置防火墙..."
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow ${app_port}/tcp
ufw --force enable

# 创建应用目录
echo "[5/6] 创建应用目录..."
mkdir -p /opt/${app_name}
cd /opt/${app_name}

# （可选）从 OSS 拉取应用代码
# echo "[6/6] 从 OSS 拉取应用代码..."
# aliyun oss cp oss://my-bucket/app.tar.gz .
# tar -xzf app.tar.gz
# docker-compose up -d

echo ""
echo "✅ ECS 初始化完成！"
echo "========================================="
echo ""
echo "下一步："
echo "1. SSH 到服务器: ssh root@$(curl -s http://100.100.100.200/latest/meta-data/public-ipv4)"
echo "2. 部署应用: cd /opt/${app_name} && docker-compose up -d"
echo ""
