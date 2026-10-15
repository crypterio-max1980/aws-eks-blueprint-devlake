
terraform {
  backend "s3" {
    bucket = "apps-terraform-clusters"
    key    = "eks-cluster-metabase/terraform.tfstate"
    region = "eu-central-1"
  }
}
