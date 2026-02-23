# Yandex Cloud Credentials
variable "yc_cloud_id" {
  description = "Yandex Cloud Cloud ID"
  type        = string
  sensitive   = true
}

variable "yc_folder_id" {
  description = "Yandex Cloud Folder ID"
  type        = string
  sensitive   = true
}

# Выберите ОДИН способ аутентификации:
variable "service_account_key_file" {
  description = "Path to service account key file (JSON)"
  type        = string
  default     = null
  sensitive   = true
}

# Zone Configuration
variable "yc_zone" {
  description = "Default zone for resources"
  type        = string
  default     = "ru-central1-a"
}

# SSH Configuration
variable "vm_user" {
  description = "Default SSH user for VMs"
  type        = string
  default     = "safalkon"
}

variable "ssh_public_key" {
  description = "SSH public key content"
  type        = string
  sensitive   = true
}

# Environment
variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "diplom"
}

# VM Configuration
variable "vm_preemptible" {
  description = "Use preemptible VMs for cost saving"
  type        = bool
  default     = true
}

variable "web_server_count" {
  description = "Number of web server instances"
  type        = number
  default     = 2
}

# CIDR Blocks
variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Public subnet CIDR block"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_app_subnet_cidr" {
  description = "Private app subnet CIDR block"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_data_subnet_cidr" {
  description = "Private data subnet CIDR block"
  type        = string
  default     = "10.0.3.0/24"
}
/*
# Service Account Configuration
variable "service_account_id" {
  description = "Service Account ID for Instance Group"
  type        = string
  sensitive   = true
}
*/