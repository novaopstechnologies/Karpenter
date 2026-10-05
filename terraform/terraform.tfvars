aws_region      = "ap-south-1"
cluster_name    = "karpenter-demo-cluster"
cluster_version = "1.31"
environment     = "dev"

vpc_cidr             = "10.0.0.0/16"
azs                  = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

node_instance_types      = ["t3.small"]
system_node_desired_size = 2
system_node_min_size     = 1
system_node_max_size     = 3

karpenter_version = "1.0.6"

tags = {
  Project   = "karpenter-terraform-project"
  ManagedBy = "terraform"
  Owner     = "karthick"
}
