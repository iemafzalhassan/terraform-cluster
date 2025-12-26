###############################################
# General Configuration Variables
# These are the main settings for your cluster
###############################################

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "afzal-demo-eks"
}

variable "region" {
  description = "AWS region for the EKS cluster"
  type        = string
  default     = "eu-west-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "demo"
}

###############################################
# Network Configuration Variables
# VPC and subnet settings - usually don't need to change
###############################################

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (worker nodes)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (NAT Gateway, Load Balancers)"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

###############################################
# Security Configuration Variables
# IMPORTANT: Update my_home_ip in terraform.tfvars!
###############################################

variable "my_home_ip" {
  description = "Your home IP address for SSH and API access (CIDR format: x.x.x.x/32)"
  type        = string

  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.my_home_ip))
    error_message = "IP must be in CIDR format (e.g., 182.48.223.179/32)."
  }
}

variable "enable_ssh_access" {
  description = "Enable SSH access to worker nodes from your IP"
  type        = bool
  default     = true
}

variable "enable_private_endpoint" {
  description = "Enable private API endpoint"
  type        = bool
  default     = true
}

variable "enable_public_endpoint" {
  description = "Enable public API endpoint"
  type        = bool
  default     = true
}

###############################################
# EKS Cluster Configuration Variables
# Kubernetes version and node settings
###############################################

variable "cluster_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.31"
}

variable "enable_auto_mode" {
  description = "Enable EKS Auto Mode with Karpenter"
  type        = bool
  default     = true
}

variable "node_instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "node_desired_count" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "node_min_count" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "node_max_count" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 5
}

variable "node_disk_size" {
  description = "Disk size (GB) for worker nodes"
  type        = number
  default     = 20
}

###############################################
# EKS Add-ons Configuration Variables
# Enable/disable optional Kubernetes components
###############################################

variable "enable_ebs_csi_driver" {
  description = "Enable AWS EBS CSI driver for persistent volumes"
  type        = bool
  default     = true
}

variable "enable_aws_load_balancer_controller" {
  description = "Enable AWS Load Balancer Controller for ALB/NLB"
  type        = bool
  default     = true
}

variable "enable_metrics_server" {
  description = "Enable Kubernetes Metrics Server"
  type        = bool
  default     = true
}

variable "enable_cluster_autoscaler" {
  description = "Enable Cluster Autoscaler (not needed with Karpenter)"
  type        = bool
  default     = false
}

variable "enable_ingress_nginx" {
  description = "Enable NGINX Ingress Controller with internet-facing LoadBalancer"
  type        = bool
  default     = true
}

variable "ingress_nginx_version" {
  description = "Version of the NGINX Ingress Controller Helm chart"
  type        = string
  default     = "4.14.1"
}

###############################################
# Logging & Monitoring Variables
# CloudWatch log settings
###############################################

variable "cluster_enabled_log_types" {
  description = "List of control plane logs to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "cloudwatch_log_retention_days" {
  description = "Days to retain CloudWatch logs"
  type        = number
  default     = 7
}

###############################################
# Encryption & Security Variables
# KMS encryption and IAM roles for service accounts
###############################################

variable "enable_kms_encryption" {
  description = "Enable KMS encryption for EKS secrets"
  type        = bool
  default     = true
}

variable "enable_irsa" {
  description = "Enable IAM Roles for Service Accounts"
  type        = bool
  default     = true
}

###############################################
# Tags Variables
# Tags applied to all AWS resources for organization
###############################################

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Project     = "EKS-Demo"
    ManagedBy   = "Terraform"
    Owner       = "Afzal-Hassan"
    Environment = "Demo"
  }
}
