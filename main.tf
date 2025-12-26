###############################################
# AWS Provider Configuration
# This tells Terraform which AWS region to use
###############################################

provider "aws" {
  region = var.region

  # Apply these tags to ALL resources created
  default_tags {
    tags = var.tags
  }
}

# Get current AWS account and region (used for outputs)
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

###############################################
# VPC Module - Creates Network Infrastructure
# This creates: VPC, subnets, NAT gateway, internet gateway
# Must be created FIRST before EKS cluster
###############################################

module "vpc" {
  source = "./modules/vpc"

  cluster_name         = var.cluster_name
  region               = var.region
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  private_subnet_cidrs = var.private_subnet_cidrs # Worker nodes go here
  public_subnet_cidrs  = var.public_subnet_cidrs  # NAT gateway, load balancers
  tags                 = var.tags
}

###############################################
# EKS Module - Creates Kubernetes Cluster
# This is the main Kubernetes control plane
# Requires VPC to exist first (depends_on)
###############################################

module "eks" {
  source = "./modules/eks"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  region          = var.region

  # Network: Use VPC and subnets created above
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids # Nodes go in private subnets

  # Access Control: Who can access the Kubernetes API
  my_home_ip              = var.my_home_ip              # Your IP for API access
  enable_public_endpoint  = var.enable_public_endpoint  # Allow public API access
  enable_private_endpoint = var.enable_private_endpoint # Allow private API access

  # Compute: Node configuration (only used if auto_mode is false)
  enable_auto_mode   = var.enable_auto_mode   # Use Karpenter for auto-scaling
  node_instance_type = var.node_instance_type # EC2 instance type
  node_desired_count = var.node_desired_count # Number of nodes
  node_min_count     = var.node_min_count     # Minimum nodes
  node_max_count     = var.node_max_count     # Maximum nodes
  node_disk_size     = var.node_disk_size     # Disk size in GB

  # Security: Encryption and IAM
  # Note: When auto_mode is true, security groups are managed by Karpenter
  # When auto_mode is false, we use the security group from security_groups module
  additional_node_security_group_id = var.enable_auto_mode ? "" : try(module.security_groups.additional_node_security_group_id, "")
  enable_kms_encryption             = var.enable_kms_encryption # Encrypt secrets
  enable_irsa                       = var.enable_irsa           # IAM roles for pods

  # Logging: What to log to CloudWatch
  cluster_enabled_log_types     = var.cluster_enabled_log_types
  cloudwatch_log_retention_days = var.cloudwatch_log_retention_days

  # Add-ons: Essential Kubernetes components
  enable_ebs_csi_driver               = var.enable_ebs_csi_driver               # Persistent volumes
  enable_aws_load_balancer_controller = var.enable_aws_load_balancer_controller # ALB/NLB support

  tags = var.tags

  # Must wait for VPC to be created first
  depends_on = [module.vpc]
}

###############################################
# Security Groups Module - Firewall Rules
# Creates security groups (firewall rules) for:
# - Worker nodes (SSH access, node-to-node communication)
# - Load balancers (HTTP/HTTPS from internet)
# - Cluster API access (from your IP only)
###############################################

module "security_groups" {
  source = "./modules/security-groups"

  cluster_name = var.cluster_name
  vpc_id       = module.vpc.vpc_id
  # Cluster security group ID - passed after EKS is created
  # Using try() prevents circular dependency during planning
  cluster_security_group_id = try(module.eks.cluster_security_group_id, "")
  my_home_ip                = var.my_home_ip             # Your IP for access
  enable_ssh_access         = var.enable_ssh_access      # Allow SSH to nodes
  enable_public_endpoint    = var.enable_public_endpoint # Allow public API
  tags                      = var.tags

  # Security groups can be created independently
  # The API access rule will be added when cluster_security_group_id is available
  depends_on = [module.vpc]
}

###############################################
# EKS Cluster API Access Rule
# Add API access rule to cluster security group after EKS is created
# This is separate to avoid circular dependency and count prediction issues
###############################################

resource "aws_security_group_rule" "cluster_api_access" {
  count = var.enable_public_endpoint ? 1 : 0

  type              = "ingress"
  description       = "Allow API access from home IP"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [var.my_home_ip]
  security_group_id = module.eks.cluster_security_group_id

  # Must wait for EKS cluster to exist
  depends_on = [module.eks]
}

###############################################
# Kubernetes Provider - Connect to EKS Cluster
# This allows Terraform to manage Kubernetes resources
# Uses AWS CLI to authenticate (no kubeconfig needed)
###############################################

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  # Use AWS CLI to get authentication token
  exec {
    api_version = "client.authentication.k8s.io/v1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      module.eks.cluster_name,
      "--region",
      var.region
    ]
  }
}

###############################################
# Helm Provider Configuration
# This allows Terraform to manage Helm charts
###############################################

provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec = {
      api_version = "client.authentication.k8s.io/v1"
      command     = "aws"
      args = [
        "eks",
        "get-token",
        "--cluster-name",
        module.eks.cluster_name,
        "--region",
        var.region
      ]
    }
  }
}

###############################################
# Helm Repository - NGINX Ingress Controller
# Add the official NGINX Ingress Helm repository
###############################################

resource "helm_release" "ingress_nginx" {
  count = var.enable_ingress_nginx ? 1 : 0

  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = var.ingress_nginx_version
  namespace  = "ingress-nginx"

  create_namespace = true

  # Configure LoadBalancer to be internet-facing
  set = [
    {
      name  = "controller.service.type"
      value = "LoadBalancer"
    },
    {
      name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-scheme"
      value = "internet-facing"
      type  = "string"
    },
    {
      name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
      value = "nlb"
      type  = "string"
    },
    {
      name  = "controller.metrics.enabled"
      value = "true"
    },
    {
      name  = "controller.podAnnotations.prometheus\\.io/scrape"
      value = "true"
      type  = "string"
    },
    {
      name  = "controller.podAnnotations.prometheus\\.io/port"
      value = "10254"
      type  = "string"
    }
  ]

  # Wait for all resources to be ready
  wait    = true
  timeout = 600

  depends_on = [
    module.eks,
    module.vpc
  ]
}

###############################################
# Data Source - NGINX Ingress LoadBalancer
# Get the LoadBalancer hostname after it's created
###############################################

data "kubernetes_service_v1" "ingress_nginx_lb" {
  count = var.enable_ingress_nginx ? 1 : 0

  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }

  depends_on = [helm_release.ingress_nginx]
}
