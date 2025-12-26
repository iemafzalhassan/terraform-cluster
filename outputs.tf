###############################################
# Cluster Information Outputs
###############################################

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "region" {
  description = "AWS region"
  value       = var.region
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "cluster_version" {
  description = "Kubernetes version"
  value       = module.eks.cluster_version
}

output "cluster_arn" {
  description = "ARN of the EKS cluster"
  value       = module.eks.cluster_arn
}

###############################################
# Network Outputs
###############################################

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

###############################################
# Access Information
###############################################

output "configure_kubectl" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name} --alias ${var.cluster_name}"
}

output "oidc_provider_arn" {
  description = "ARN of OIDC provider (for IRSA)"
  value       = module.eks.oidc_provider_arn
}

###############################################
# IAM Role ARNs
###############################################

output "ebs_csi_driver_role_arn" {
  description = "IAM role ARN for EBS CSI driver"
  value       = module.eks.ebs_csi_driver_role_arn
}

output "aws_load_balancer_controller_role_arn" {
  description = "IAM role ARN for AWS Load Balancer Controller"
  value       = module.eks.aws_load_balancer_controller_role_arn
}

###############################################
# NGINX Ingress Controller Outputs
###############################################

output "ingress_nginx_loadbalancer_hostname" {
  description = "Hostname of the internet-facing LoadBalancer for NGINX Ingress Controller"
  value       = var.enable_ingress_nginx ? try(data.kubernetes_service_v1.ingress_nginx_lb[0].status[0].load_balancer[0].ingress[0].hostname, "pending") : null
}

output "ingress_nginx_loadbalancer_ip" {
  description = "IP address of the internet-facing LoadBalancer for NGINX Ingress Controller"
  value       = var.enable_ingress_nginx ? try(data.kubernetes_service_v1.ingress_nginx_lb[0].status[0].load_balancer[0].ingress[0].ip, null) : null
}

output "ingress_nginx_status" {
  description = "Status of the NGINX Ingress Controller Helm release"
  value       = var.enable_ingress_nginx ? helm_release.ingress_nginx[0].status : "disabled"
}

output "ingress_nginx_get_lb_command" {
  description = "Command to get the LoadBalancer information"
  value       = var.enable_ingress_nginx ? "kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'" : null
}

###############################################
# Next Steps
###############################################

output "next_steps" {
  description = "Next steps to connect and use the cluster"
  value       = <<-EOT
    
    ========================================
    🎉 EKS Cluster Created Successfully!
    ========================================
    
    Cluster Name: ${module.eks.cluster_name}
    Region: ${var.region}
    Version: ${module.eks.cluster_version}
    
    📋 Next Steps:
    
    1. Configure kubectl:
       aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}
    
    2. Verify cluster access:
       kubectl get nodes
       kubectl get pods -A
    
    3. Check cluster info:
       kubectl cluster-info
    
    4. View nodes (may take 2-3 minutes to appear):
       kubectl get nodes -o wide
    
    5. Deploy a test application:
       kubectl create deployment nginx --image=nginx
       kubectl expose deployment nginx --port=80 --type=LoadBalancer
    
    6. NGINX Ingress Controller:
       ${var.enable_ingress_nginx ? "✓ Installed automatically with internet-facing LoadBalancer" : "Install manually if needed"}
       ${var.enable_ingress_nginx ? "   Get LoadBalancer: kubectl get svc -n ingress-nginx ingress-nginx-controller" : ""}
    
    7. Install Helm charts (if needed):
       See HELM_INSTALLATION.md for instructions to install:
       - AWS Load Balancer Controller
       - Metrics Server
    
    💰 Cost Reminder:
       Don't forget to run 'terraform destroy' when done to avoid charges!
    
    📚 Documentation:
       See README.md for detailed usage instructions
    
    ========================================
  EOT
}
