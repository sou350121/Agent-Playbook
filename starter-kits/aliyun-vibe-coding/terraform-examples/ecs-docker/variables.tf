# Terraform 变量配置
# 由 Agent 根据人类意图生成，人类审核后应用

variable "region" {
  description = "阿里云区域"
  type        = string
  default     = "cn-hangzhou"
}

variable "availability_zone" {
  description = "可用区"
  type        = string
  default     = "cn-hangzhou-i"
}

variable "app_name" {
  description = "应用名称"
  type        = string
  default     = "vibe-coding-app"
}

variable "environment" {
  description = "环境（dev/staging/production）"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be dev, staging, or production."
  }
}

variable "app_port" {
  description = "应用监听端口"
  type        = number
  default     = 5000
}

variable "bandwidth" {
  description = "公网带宽（Mbps）"
  type        = number
  default     = 5
}

variable "system_disk_size" {
  description = "系统盘大小（GB）"
  type        = number
  default     = 40
}

variable "data_disk_size" {
  description = "数据盘大小（GB）"
  type        = number
  default     = 100
}

variable "allocate_eip" {
  description = "是否分配弹性 IP"
  type        = bool
  default     = true
}
