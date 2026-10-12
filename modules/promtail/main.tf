
resource "helm_release" "promtail" {
  name             = "promtail"
  namespace        = "default"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "promtail"
  version          = "6.16.6"

  create_namespace = true

  wait             = true
  timeout          = 600
  atomic           = true

  values = [
    file("${path.module}/promtail-values.yaml")
  ]
}
