output "additional_node_security_group_id" {
  description = "Additional security group ID for worker nodes"
  value       = aws_security_group.additional_node_sg.id
}

output "load_balancer_security_group_id" {
  description = "Security group ID for load balancers"
  value       = aws_security_group.load_balancer_sg.id
}
