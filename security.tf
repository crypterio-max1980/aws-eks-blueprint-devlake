
# -----------------------------
# ALB Security Group (Public)
# -----------------------------
resource "aws_security_group" "alb_sg" {
  name        = "${var.cluster_name}-alb-sg"
  description = "Allow internet traffic to ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Uncomment if enabling HTTPS
  # ingress {
  #   description = "HTTPS from Internet"
  #   from_port   = 443
  #   to_port     = 443
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-alb-sg"
  }
}

# -----------------------------
# Worker Nodes Security Group
# -----------------------------
resource "aws_security_group" "eks_nodes_sg" {
  name        = "${var.cluster_name}-nodes-sg"
  description = "EKS worker nodes"
  vpc_id      = aws_vpc.main.id

  # Node-to-node communication
  ingress {
    description = "Node to node communication"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  # Traffic from ALB to Pods (IP mode)
  ingress {
    description     = "Traffic from ALB"
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Optional: SSH access (lock down or remove in prod)
  # ingress {
  #   description = "SSH access"
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "tcp"
  #   cidr_blocks = ["YOUR_IP/32"]
  # }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-nodes-sg"
  }
}
