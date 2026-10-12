
# -----------------------------
# EKS Cluster IAM Role
# -----------------------------
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "ebs_csi" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# -----------------------------
# EKS Cluster
# -----------------------------
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  version  = var.cluster_version  # <-- Kubernetes version
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids              = aws_subnet.private[*].id
    endpoint_public_access  = true
    endpoint_private_access = true
    security_group_ids      = [aws_security_group.eks_nodes_sg.id]
  }

  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator"
  ]

  tags = {
    Name = var.cluster_name
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}

# -----------------------------
# Worker Node Role
# -----------------------------
resource "aws_iam_role" "eks_node_role" {
  name = "${var.cluster_name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "worker_node_policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ])

  role       = aws_iam_role.eks_node_role.name
  policy_arn = each.value
}


# -----------------------------
# Node Node Group
# -----------------------------
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "main-ng"
  node_role_arn  = aws_iam_role.eks_node_role.arn
  subnet_ids     = aws_subnet.private[*].id

  scaling_config {
  desired_size = var.node_group_desired_size
  min_size     = var.node_group_min_size
  max_size     = var.node_group_max_size
  }

  instance_types = var.instance_types

  tags = {
    Name = "${var.cluster_name}-workers"
  }

  depends_on = [
  aws_eks_cluster.main,
  aws_iam_role_policy_attachment.worker_node_policies
  ]
}

# -----------------------------
# Additional Node Group
# -----------------------------
resource "aws_eks_node_group" "app" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "app-ng"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = aws_subnet.private[*].id

  scaling_config {
    desired_size = 0
    max_size     = 1
    min_size     = 0
  }

  # Optional: use different instance types
  instance_types = ["t3.medium"]

  tags = {
    Name = "${var.cluster_name}-additional-workers"
    Purpose = "extra-capacity"
  }

  depends_on = [
    aws_eks_cluster.main,
    aws_iam_role_policy_attachment.worker_node_policies
  ]
}

resource "null_resource" "kubeconfig" {
  depends_on = [aws_eks_cluster.main]

  provisioner "local-exec" {
    command = <<EOT
aws eks update-kubeconfig \
  --region ${var.aws_region} \
  --name ${aws_eks_cluster.main.name}
EOT
  }
}
