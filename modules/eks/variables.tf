variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for worker nodes"
  type        = list(string)
}

variable "my_home_ip" {
  description = "Your home IP for API access"
  type        = string
}

variable "enable_public_endpoint" {
  description = "Enable public API endpoint"
  type        = bool
}

variable "enable_private_endpoint" {
  description = "Enable private API endpoint"
  type        = bool
}

variable "enable_irsa" {
  description = "Enable IAM Roles for Service Accounts"
  type        = bool
}

variable "enable_kms_encryption" {
  description = "Enable KMS encryption for secrets"
  type        = bool
}

variable "enable_auto_mode" {
  description = "Enable EKS Auto Mode with Karpenter"
  type        = bool
}

variable "node_instance_type" {
  description = "Instance type for worker nodes"
  type        = string
}

variable "node_desired_count" {
  description = "Desired number of worker nodes"
  type        = number
}

variable "node_min_count" {
  description = "Minimum number of worker nodes"
  type        = number
}

variable "node_max_count" {
  description = "Maximum number of worker nodes"
  type        = number
}

variable "node_disk_size" {
  description = "Disk size for worker nodes"
  type        = number
}

variable "additional_node_security_group_id" {
  description = "Additional security group for nodes (only used when auto_mode is false)"
  type        = string
  default     = ""
}

variable "cluster_enabled_log_types" {
  description = "List of control plane logs to enable"
  type        = list(string)
}

variable "cloudwatch_log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
}

variable "enable_ebs_csi_driver" {
  description = "Enable EBS CSI driver"
  type        = bool
}

variable "enable_aws_load_balancer_controller" {
  description = "Enable AWS Load Balancer Controller"
  type        = bool
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
}
