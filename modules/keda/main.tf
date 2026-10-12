
resource "helm_release" "keda" {
  name             = "keda"
  repository       = "https://kedacore.github.io/charts"
  chart            = "keda"
  version          = "2.17.0"

  namespace        = "keda"
  create_namespace = true

  wait            = true
  wait_for_jobs   = true
  timeout         = 600
  atomic          = true
  cleanup_on_fail = true

  values = [
    yamlencode({
      crds = {
        install = true
      }
    })
  ]
}
