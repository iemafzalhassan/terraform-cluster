###############################################
# 👇 UPDATE YOUR IP HERE WHEN IT CHANGES 👇
###############################################

# Your current home IP (run: curl -4 ifconfig.me)
my_home_ip = "" # 👈 CHANGE THIS!

###############################################
# Cluster Configuration
###############################################

cluster_name    = "afzal-demo-eks"
region          = "eu-west-1"
cluster_version = "1.31"
environment     = "demo"

###############################################
# Network Configuration
###############################################

vpc_cidr             = "10.0.0.0/16"
availability_zones   = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

###############################################
# Node Configuration
###############################################

node_instance_type = "t3.medium"
node_desired_count = 2
node_min_count     = 1
node_max_count     = 5
node_disk_size     = 20

###############################################
# Features
###############################################

enable_auto_mode                    = true
enable_ebs_csi_driver               = true
enable_aws_load_balancer_controller = true
enable_metrics_server               = true
enable_cluster_autoscaler           = false # Not needed with Karpenter
enable_ingress_nginx                = true  # NGINX Ingress with internet-facing LoadBalancer
ingress_nginx_version               = "4.14.1"
enable_kms_encryption               = true
enable_irsa                         = true

###############################################
# Access Configuration
###############################################

enable_ssh_access       = true # Allow SSH from your IP
enable_private_endpoint = true
enable_public_endpoint  = true

###############################################
# Logging
###############################################

cluster_enabled_log_types     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
cloudwatch_log_retention_days = 7 # Reduce to save costs for demos

###############################################
# Tags (Optional - customize as needed)
###############################################

tags = {
  Project     = "EKS-Demo"
  ManagedBy   = "Terraform"
  Owner       = "Afzal-Hassan"
  Environment = "Demo"
  Purpose     = "Learning-K8s"
}
