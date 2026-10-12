
variable "aws_region" {
  description = "Region"
  default = "us-west-2"  
}

variable "cluster_name" {
  description = "Cluster Name"
  default = "eks-cluster"
}

variable "cluster_version" {
  description = "Cluster Version"
  default = "1.33"
}

variable "instance_types" {
  type    = list(string)
  default  = ["t3.medium"]
}

variable "node_group_desired_size" {
  description = "Desired number of nodes in EKS node group"
  type        = number
}

variable "node_group_min_size" {
  description = "Minimum number of nodes in EKS node group"
  type        = number
}

variable "node_group_max_size" {
  description = "Maximum number of nodes in EKS node group"
  type        = number
}

variable "kubeconfig_path" {
  type        = string
  description = "Path to kubeconfig for the target cluster"
  default     = "~/.kube/config"
}

variable "namespace" {
  type        = string
  default     = "weaviate"
  description = "Kubernetes namespace where Weaviate is deployed"
}

variable "make_gp3_default" {
  type    = bool
  default = true
}
