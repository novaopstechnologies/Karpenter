variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "ap-south-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "karpenter-demo-cluster"
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.30"
}

variable "environment" {
  description = "Environment name (dev/staging/prod)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability zones to use"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (nodes/pods live here)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (NAT gateways, public LBs)"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "node_instance_types" {
  description = "Instance types for the small managed 'system' node group. Karpenter handles everything else."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "system_node_desired_size" {
  type    = number
  default = 2
}

variable "system_node_min_size" {
  type    = number
  default = 1
}

variable "system_node_max_size" {
  type    = number
  default = 3
}

variable "karpenter_version" {
  description = "Helm chart version for Karpenter"
  type        = string
  default     = "1.0.6"
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default = {
    Project   = "karpenter-terraform-project"
    ManagedBy = "terraform"
  }
}
