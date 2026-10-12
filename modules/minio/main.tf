
resource "helm_release" "minio" {
  name             = "minio"
  namespace        = "default"
  repository       = "https://charts.min.io/"
  chart            = "minio"
  create_namespace = true

  values = [
    yamlencode({
      mode         = "standalone"
      replicas     = 1

      # Root credentials (use variable for security)
      rootUser     = "root"
      rootPassword = var.minio_root_password

      # Buckets to create automatically
      buckets = [
        { name = "events" },
        { name = "data" },
        { name = "loki" }

      ]

      # Enable persistent storage
      persistence = {
        enabled = true
        size    = "10Gi"
      }

      # Service configuration
      service = {
        type = "ClusterIP"  # use NodePort or LoadBalancer if needed
        port = 9000         # default S3 API port
      }

      # Console UI service
      console = {
        enabled = true
        port    = 9001
      }

      # Resource requests & limits
      resources = {
        requests = {
          memory = "512Mi"
          cpu    = "250m"
        }
        limits = {
          memory = "1Gi"
          cpu    = "1000m"
        }
      }
    })
  ]
}
