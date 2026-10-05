module "vpc" {
  source = "./modules/vpc"

  cluster_name         = var.cluster_name
  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
  tags                 = var.tags
}

module "eks" {
  source = "./modules/eks"

  cluster_name             = var.cluster_name
  cluster_version          = var.cluster_version
  vpc_id                   = module.vpc.vpc_id
  private_subnet_ids       = module.vpc.private_subnet_ids
  public_subnet_ids        = module.vpc.public_subnet_ids
  node_instance_types      = var.node_instance_types
  system_node_desired_size = var.system_node_desired_size
  system_node_min_size     = var.system_node_min_size
  system_node_max_size     = var.system_node_max_size
  tags                     = var.tags
}

# Karpenter-specific IAM: controller IRSA role, node role/instance profile,
# and the SQS queue + EventBridge rules used for interruption handling.
# Depends on the EKS module's OIDC provider, so it comes after module.eks.
module "iam" {
  source = "./modules/iam"

  cluster_name      = var.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
  tags              = var.tags
}

module "karpenter" {
  source = "./modules/karpenter"

  aws_region                    = var.aws_region
  cluster_name                  = module.eks.cluster_name
  cluster_endpoint               = module.eks.cluster_endpoint
  cluster_ca_certificate         = module.eks.cluster_certificate_authority_data
  oidc_provider_arn              = module.eks.oidc_provider_arn
  karpenter_controller_role_arn = module.iam.karpenter_controller_role_arn
  node_iam_role_name             = module.iam.karpenter_node_role_name
  karpenter_version              = var.karpenter_version
  private_subnet_ids             = module.vpc.private_subnet_ids
  cluster_security_group_id      = module.eks.cluster_security_group_id
  interruption_queue_name        = module.iam.karpenter_interruption_queue_name

  depends_on = [module.eks, module.iam]
}

module "monitoring" {
  source = "./modules/monitoring"

  cluster_endpoint       = module.eks.cluster_endpoint
  cluster_ca_certificate = module.eks.cluster_certificate_authority_data

  depends_on = [module.eks, module.storage]
}

module "applications" {
  source = "./modules/applications"

  cluster_name = module.eks.cluster_name

  depends_on = [module.karpenter]
}

module "storage" {
  source = "./modules/storage"

  cluster_name = module.eks.cluster_name

  depends_on = [module.eks]
}
