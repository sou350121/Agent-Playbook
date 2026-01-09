# Terraform 配置：阿里云 ECS + Docker 部署
# 遵循 Vibe Coding 第一定律：基础设施即代码，幂等且可追溯

terraform {
  required_version = ">= 1.0"

  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = "~> 1.200"
    }
  }
}

# 配置阿里云 Provider
provider "alicloud" {
  region = var.region
}

# ============================================
# 数据源：查询现有资源
# ============================================

# 查询可用镜像（Ubuntu 20.04）
data "alicloud_images" "ubuntu" {
  name_regex  = "ubuntu_20_04_x64_20G_alibase_*"
  most_recent = true
  owners      = "system"
}

# 查询可用实例类型
data "alicloud_instance_types" "default" {
  cpu_core_count = 2
  memory_size   = 4

  availability_zone = var.availability_zone
}

# 查询默认 VPC 和 VSwitch
data "alicloud_vpcs" "default" {
  is_default = true
}

data "alicloud_vswitches" "default" {
  is_default = true
  vpc_id     = data.alicloud_vpcs.default.vpcs.0.id
}

# ============================================
# 安全组配置
# ============================================

resource "alicloud_security_group" "default" {
  name   = "${var.app_name}-security-group"
  vpc_id = data.alicloud_vpcs.default.vpcs.0.id

  tags = {
    Name = "${var.app_name}-sg"
    Env  = var.environment
  }
}

# 允许 SSH 访问
resource "alicloud_security_group_rule" "allow_ssh" {
  type              = "ingress"
  ip_protocol       = "tcp"
  port_range        = "22/22"
  security_group_id = alicloud_security_group.default.id
  cidr_ip           = "0.0.0.0/0"
}

# 允许 HTTP 访问
resource "alicloud_security_group_rule" "allow_http" {
  type              = "ingress"
  ip_protocol       = "tcp"
  port_range        = "80/80"
  security_group_id = alicloud_security_group.default.id
  cidr_ip           = "0.0.0.0/0"
}

# 允许应用端口访问
resource "alicloud_security_group_rule" "allow_app" {
  type              = "ingress"
  ip_protocol       = "tcp"
  port_range        = "${var.app_port}/${var.app_port}"
  security_group_id = alicloud_security_group.default.id
  cidr_ip           = "0.0.0.0/0"
}

# ============================================
# ECS 实例配置
# ============================================

resource "alicloud_instance" "default" {
  # 实例配置
  instance_name        = "${var.app_name}-${var.environment}"
  image_id             = data.alicloud_images.ubuntu.images.0.id
  instance_type        = data.alicloud_instance_types.default.instance_types.0.id
  availability_zone    = var.availability_zone

  # 网络配置
  vswitch_id           = data.alicloud_vswitches.default.vswitches.0.id
  security_groups      = [alicloud_security_group.default.id]

  # 带宽配置
  internet_max_bandwidth_out = var.bandwidth

  # 认证配置（使用 SSH 密钥对）
  password_length = 0  # 不使用密码登录

  # 系统盘配置
  system_disk_category = "cloud_essd"
  system_disk_size     = var.system_disk_size

  # 数据盘配置（可选）
  data_disks {
    category = "cloud_essd"
    size     = var.data_disk_size
    encrypted = false
  }

  # 实例启动时自动运行的脚本
  user_data = base64encode(templatefile("${path.module}/user-data.sh", {
    app_port = var.app_port
    app_name = var.app_name
  }))

  # 标签
  tags = {
    Name        = "${var.app_name}-${var.environment}"
    Environment = var.environment
    ManagedBy   = "terraform"
    Purpose     = "vibe-coding-demo"
  }

  # 实例释放时是否删除数据盘
  deletion_protection = false
}

# ============================================
# 弹性 IP（可选）
# ============================================

resource "alicloud_eip" "default" {
  count = var.allocate_eip ? 1 : 0

  bandwidth            = var.bandwidth
  internet_charge_type = "PayByTraffic"
}

resource "alicloud_eip_association" "default" {
  count = var.allocate_eip ? 1 : 0

  allocation_id = alicloud_eip.default[0].id
  instance_id   = alicloud_instance.default.id
}

# ============================================
# 输出信息
# ============================================

output "instance_id" {
  description = "ECS 实例 ID"
  value       = alicloud_instance.default.id
}

output "public_ip" {
  description = "ECS 公网 IP"
  value       = var.allocate_eip ? alicloud_eip.default[0].ip_address : alicloud_instance.default.public_ip
}

output "ssh_command" {
  description = "SSH 连接命令"
  value       = "ssh root@${var.allocate_eip ? alicloud_eip.default[0].ip_address : alicloud_instance.default.public_ip}"
}

output "app_url" {
  description = "应用访问地址"
  value       = "http://${var.allocate_eip ? alicloud_eip.default[0].ip_address : alicloud_instance.default.public_ip}:${var.app_port}"
}
