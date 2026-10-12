
resource "kubernetes_ingress_v1" "grafana" {
  metadata {
    name      = "ingress-route-grafana"
    namespace = "default"
    annotations = {
      "konghq.com/strip-path" = "true"
      # Optional:
      # "konghq.com/protocols"                 = "https"
      # "konghq.com/https-redirect-status-code" = "301"
      # "cert-manager.io/cluster-issuer"      = "letsencrypt-prod"
    }
  }

  spec {
    ingress_class_name = "kong"

    tls {
      hosts       = ["monitor.crypterio.co"]
      secret_name = "loki-tls"
    }

    rule {
      host = "monitor.appflex.io"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "grafana"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

