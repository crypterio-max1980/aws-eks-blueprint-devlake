
resource "helm_release" "prometheus" {
  name             = "prometheus"
  namespace        = "default"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = "77.10.0"

  create_namespace = true

  wait             = true
  timeout          = 600
  atomic           = true

  values = [
    file("${path.module}/prometheus-values.yaml")
  ]
}
