
resource "kubernetes_namespace" "migration" {
  depends_on = [
    aws_eks_cluster.main,
    aws_eks_node_group.main,
    aws_iam_role_policy_attachment.ebs_csi_irsa_policy,
    aws_eks_addon.ebs_csi
  ]

  metadata {
    name = "migration"
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  lifecycle {
    prevent_destroy = false
    ignore_changes = all
  }
}

