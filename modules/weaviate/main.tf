resource "helm_release" "weaviate" {
  name             = "weaviate"
  namespace        = "weaviate"
  create_namespace = true

  repository = "https://weaviate.github.io/weaviate-helm"
  chart      = "weaviate"
  version    = "17.5.1"

  timeout         = 1200
  atomic          = true
  cleanup_on_fail = true
  wait            = true

  values = [
    yamlencode({
      replicas            = 3
      podManagementPolicy  = "Parallel"

      service = {
        type = "ClusterIP"
      }

      grpcService = {
        type = "ClusterIP"
      }

      storage = {
        size             = "10Gi"
        storageClassName = "gp3"
      }

      authentication = {
        anonymous_access = {
          enabled = true
        }
      }

      logLevel = "info"

      serviceMonitor = {
        enabled = true
      }

      resources = {
        requests = {
          cpu    = "500m"
          memory = "2Gi"
        }

        limits = {
          cpu    = "2"
          memory = "4Gi"
        }
      }
    })
  ]
}
