
###  ---  Default Template  ---  ###
aws_region      = "eu-central-1" # \\\ eu-central-1
cluster_name    = "eks-cluster-vector"
cluster_version = "1.35"
instance_types  = ["t3.large"] # \\\ 4CPU-16RAM t3.xlarge
node_group_desired_size = 3
node_group_min_size     = 3
node_group_max_size     = 7

