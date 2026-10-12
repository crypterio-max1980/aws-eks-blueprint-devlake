
resource "kubernetes_deployment" "httpd_server" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels = {
      app = var.name
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = var.name
      }
    }

    template {
      metadata {
        labels = {
          app = var.name
        }
      }

      spec {
        container {
          name  = var.name
          image = var.image

          port {
            container_port = var.container_port
          }

          liveness_probe {
            http_get {
              path = "/"
              port = var.container_port
            }
            initial_delay_seconds = 10
            period_seconds        = 10
          }

          readiness_probe {
            http_get {
              path = "/"
              port = var.container_port
            }
            initial_delay_seconds = 5
            period_seconds        = 5
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "httpd_server" {
  metadata {
    name      = var.name
    namespace = var.namespace
  }

  spec {
    selector = {
      app = kubernetes_deployment.httpd_server.metadata[0].labels.app
    }

    port {
      name        = "http-port"
      port        = var.service_port
      target_port = var.container_port
    }

    type = var.service_type
  }
}
