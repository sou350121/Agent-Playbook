#!/bin/bash
# 阿里云 CLI 自动安装脚本
# 适用于 macOS 和 Linux
# 由 Agent 生成，人类审核后执行

set -e  # 遇到错误立即退出

echo "========================================="
echo "阿里云 CLI 自动安装脚本"
echo "========================================="
echo ""

# 检测操作系统
OS="$(uname -s)"
case "${OS}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac;;
    *)          echo "不支持的操作系统: ${OS}"; exit 1;;
esac

echo "检测到操作系统: ${MACHINE}"
echo ""

# 下载最新版本
echo "正在下载阿里云 CLI..."
CLI_VERSION="3.0.0"
BASE_URL="https://aliyuncli.alicdn.com/aliyun-cli-${MACHINE}-latest"

if [ "${MACHINE}" = "Mac" ]; then
    curl -s -o aliyun.zip "${BASE_URL}.zip"
    unzip -o aliyun.zip
    sudo mv aliyun /usr/local/bin/
else
    curl -s -o aliyun.tgz "${BASE_URL}.tgz"
    tar -xzf aliyun.tgz
    sudo mv aliyun /usr/local/bin/
fi

echo "✅ 阿里云 CLI 已安装"
echo ""

# 清理下载文件
echo "清理临时文件..."
rm -f aliyun.zip aliyun.tgz

echo "✅ 清理完成"
echo ""

# 验证安装
echo "验证安装..."
aliyun version

echo ""
echo "========================================="
echo "安装完成！"
echo "========================================="
echo ""
echo "下一步：配置 Access Key"
echo "运行命令: aliyun configure"
echo ""
echo "获取 Access Key:"
echo "1. 访问 https://ram.console.aliyun.com/manage/ak"
echo "2. 创建 Access Key"
echo "3. 复制 Access Key ID 和 Secret"
echo ""
