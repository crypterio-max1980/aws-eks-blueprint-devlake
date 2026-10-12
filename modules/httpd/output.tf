
output "deployment_name" {
  value = kubernetes_deployment.httpd_server.metadata[0].name
}

output "service_name" {
  value = kubernetes_service.httpd_server.metadata[0].name
}

output "service_cluster_ip" {
  value = kubernetes_service.httpd_server.spec[0].cluster_ip
}
