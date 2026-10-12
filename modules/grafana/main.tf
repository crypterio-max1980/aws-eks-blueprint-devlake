
resource "helm_release" "grafana" {
  name       = "grafana"
  namespace  = "default"

  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = "9.3.2"

  create_namespace = true

  wait    = true
  timeout = 600
  atomic  = true

  values = [
    file("${path.module}/grafana-values.yaml")
  ]
}
