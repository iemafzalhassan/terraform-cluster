###############################################
# Security Groups Module
###############################################

###############################################
# Additional Security Group for Worker Nodes
###############################################

resource "aws_security_group" "additional_node_sg" {
  name        = "${var.cluster_name}-additional-node-sg"
  description = "Additional security group for EKS worker nodes"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-additional-node-sg"
    }
  )
}

###############################################
# SSH Access from Your Home IP
###############################################

resource "aws_security_group_rule" "node_ssh_access" {
  count = var.enable_ssh_access ? 1 : 0

  type              = "ingress"
  description       = "SSH access from home IP"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.my_home_ip]
  security_group_id = aws_security_group.additional_node_sg.id
}

###############################################
# Allow All Traffic Between Worker Nodes
###############################################

resource "aws_security_group_rule" "node_to_node" {
  type                     = "ingress"
  description              = "Allow nodes to communicate with each other"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  source_security_group_id = aws_security_group.additional_node_sg.id
  security_group_id        = aws_security_group.additional_node_sg.id
}

###############################################
# Allow Traffic from Control Plane to Nodes
###############################################

resource "aws_security_group_rule" "control_plane_to_node" {
  type                     = "ingress"
  description              = "Allow control plane to communicate with nodes"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = var.cluster_security_group_id
  security_group_id        = aws_security_group.additional_node_sg.id
}

###############################################
# Allow HTTPS for Kubelet API
###############################################

resource "aws_security_group_rule" "node_kubelet_api" {
  type                     = "ingress"
  description              = "Allow control plane to communicate with kubelet"
  from_port                = 10250
  to_port                  = 10250
  protocol                 = "tcp"
  source_security_group_id = var.cluster_security_group_id
  security_group_id        = aws_security_group.additional_node_sg.id
}

###############################################
# Allow All Outbound Traffic
###############################################

resource "aws_security_group_rule" "node_egress_all" {
  type              = "egress"
  description       = "Allow all outbound traffic"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.additional_node_sg.id
}

###############################################
# Security Group for Load Balancers
###############################################

resource "aws_security_group" "load_balancer_sg" {
  name        = "${var.cluster_name}-load-balancer-sg"
  description = "Security group for Application Load Balancers"
  vpc_id      = var.vpc_id

  # Allow HTTP from internet
  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS from internet
  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-load-balancer-sg"
    }
  )
}
