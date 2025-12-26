variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "cluster_security_group_id" {
  description = "EKS cluster security group ID (optional, for API access rule)"
  type        = string
  default     = ""
}

variable "my_home_ip" {
  description = "Your home IP for SSH and API access"
  type        = string
}

variable "enable_ssh_access" {
  description = "Enable SSH access from your IP"
  type        = bool
  default     = true
}

variable "enable_public_endpoint" {
  description = "Enable public API endpoint"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
