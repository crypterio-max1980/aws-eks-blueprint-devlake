
variable "name" {
  type    = string
  default = "httpd-server"
}

variable "namespace" {
  type    = string
  default = "default"
}

variable "image" {
  type    = string
  default = "virtapp/apache:7f6c4bf4-3-6"
}

variable "replicas" {
  type    = number
  default = 4
}

variable "container_port" {
  type    = number
  default = 80
}

variable "service_port" {
  type    = number
  default = 8080
}

variable "service_type" {
  type    = string
  default = "ClusterIP"
}
