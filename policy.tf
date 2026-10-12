
data "aws_caller_identity" "current" {}

locals {
  oidc_sub = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
}

resource "aws_iam_openid_connect_provider" "eks" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer

  client_id_list = ["sts.amazonaws.com"]

  # 🔥 safer than tls_certificate in EKS
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

resource "aws_iam_role" "ebs_csi_irsa" {
  name = "${var.cluster_name}-ebs-csi-irsa"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.eks.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          (local.oidc_sub) = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ebs_csi_irsa_policy" {
  role       = aws_iam_role.ebs_csi_irsa.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_eks_addon" "ebs_csi" {
  cluster_name             = aws_eks_cluster.main.name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.62.0-eksbuild.1"
  service_account_role_arn = aws_iam_role.ebs_csi_irsa.arn

  depends_on = [
    aws_eks_cluster.main,
    aws_eks_node_group.main,
    aws_iam_role_policy_attachment.ebs_csi_irsa_policy
  ]
}

resource "kubernetes_storage_class_v1" "gp3" {
  depends_on = [aws_eks_addon.ebs_csi]

  metadata {
    name = "gp3"

    annotations = {
      "storageclass.kubernetes.io/is-default-class" = var.make_gp3_default ? "true" : "false"
    }
  }

  storage_provisioner = "ebs.csi.aws.com"

  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion  = true

  parameters = {
    type   = "gp3"
    fsType = "ext4"
  }
}
