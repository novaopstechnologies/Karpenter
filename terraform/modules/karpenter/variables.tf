variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "cluster_name" {
  type = string
}

variable "cluster_endpoint" {
  type = string
}

variable "cluster_ca_certificate" {
  type = string
}

variable "oidc_provider_arn" {
  type = string
}

variable "karpenter_controller_role_arn" {
  type = string
}

variable "node_iam_role_name" {
  type = string
}

variable "karpenter_version" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "cluster_security_group_id" {
  type = string
}

variable "interruption_queue_name" {
  type    = string
  default = ""
}
