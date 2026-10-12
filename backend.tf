
terraform {
  backend "s3" {
    bucket = "apps-terraform-clusters"
    key    = "eks-LLM-Platform/terraform.tfstate"
    region = "eu-central-1"
  }
}
