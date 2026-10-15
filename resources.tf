
###  ---  Application  ---  ###
module "httpd" {
  source = "./modules/httpd"
  depends_on = [kubernetes_namespace.migration]

  name   = "httpd-server"
  image = "virtapp/apache:7f6c4bf4-3-6"
  service_port = 8080
  service_type = "ClusterIP"
}

module "kong" {
  source = "./modules/kong"
  depends_on = [module.httpd]
}

module "keda" {
  source = "./modules/keda"
  depends_on = [module.kong]
}

module "prometheus" {
  source = "./modules/prometheus"
  depends_on = [module.keda]
}

module "grafana" {
  source = "./modules/grafana"
  depends_on = [module.prometheus]
}

module "ingress" {
  source = "./modules/ingress"
  depends_on = [module.grafana]
}

module "metabase" {
  source = "./modules/metabase"
  depends_on = [module.ingress]
}
