
resource "helm_release" "kong" {
  name             = "kong"
  namespace        = "kong"
  create_namespace = true

  repository = "https://charts.konghq.com"
  chart      = "kong"

  set = [
    {
      name  = "ingressController.installCRDs"
      value = "false"
    },
    {
      name  = "ingressController.gatewayAPI.enabled"
      value = "true"
    },
    {
      name  = "ingressController.enabled"
      value = "true"
    },

    # Kong proxy replicas
    {
      name  = "proxy.replicas"
      value = "3"
    },

    # AWS LoadBalancer
    {
      name  = "proxy.type"
      value = "LoadBalancer"
    },

    # Preserve client IP
    {
      name  = "proxy.externalTrafficPolicy"
      value = "Local"
    },

    # AWS NLB
    {
      name  = "proxy.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
      value = "nlb"
    },
    {
      name  = "proxy.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-scheme"
      value = "internet-facing"
    },
    {
      name  = "proxy.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-nlb-target-type"
      value = "ip"
    }
  ]
}

resource "null_resource" "gateway_api_crds" {
  depends_on = [
    helm_release.kong
  ]
  provisioner "local-exec" {
    command = <<EOT
      echo "Installing Gateway API CRDs v1.3.0..."

      kubectl apply -k "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v1.3.0"
      echo "Waiting for Gateway API CRDs..."

      kubectl wait \
        --for=condition=Established \
        crd/gateways.gateway.networking.k8s.io \
        --timeout=120s

      kubectl wait \
        --for=condition=Established \
        crd/httproutes.gateway.networking.k8s.io \
        --timeout=120s

      echo "Gateway API CRDs are ready"
    EOT
  }

  triggers = {
    gateway_api_version = "v1.3.0"
  }
}
