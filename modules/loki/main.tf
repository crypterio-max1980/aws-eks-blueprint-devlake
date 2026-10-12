
resource "helm_release" "loki" {
  name             = "loki"
  namespace        = "loki"

  repository       = "https://grafana-community.github.io/helm-charts"
  chart            = "loki"
  version          = "18.5.0"

  create_namespace = true

  wait             = true
  timeout          = 900
  atomic           = true
  cleanup_on_fail  = true

  values = [
    file("${path.module}/values.yaml")
  ]
}
