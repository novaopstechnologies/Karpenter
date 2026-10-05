output "helm_release_name" {
  value = helm_release.karpenter.name
}

output "helm_release_status" {
  value = helm_release.karpenter.status
}
