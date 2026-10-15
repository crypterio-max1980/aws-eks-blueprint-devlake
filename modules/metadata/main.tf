
resource "kubernetes_namespace_v1" "metabase" {
  metadata {
    name = "metabase"
  }
}

resource "helm_release" "metabase" {
  name       = "metabase"
  namespace  = kubernetes_namespace_v1.metabase.metadata[0].name
  repository = "https://pmint93.github.io/helm-charts"
  chart      = "metabase"

  # Pin a chart version for reproducible deployments
  # version = "YOUR_TESTED_CHART_VERSION"

  wait    = true
  timeout = 600
}

output "metabase_namespace" {
  value = kubernetes_namespace_v1.metabase.metadata[0].name
}

output "metabase_release" {
  value = helm_release.metabase.name
}
