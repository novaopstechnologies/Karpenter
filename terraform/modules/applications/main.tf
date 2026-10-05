# Applies the sample deployment/service/ingress from the kubernetes/ folder.
# In a real setup you'd likely swap this for an ArgoCD Application instead
# of a local-exec kubectl apply.
resource "null_resource" "app_manifests" {
  triggers = {
    deployment = filemd5("${path.module}/../../../kubernetes/deployment.yaml")
    service    = filemd5("${path.module}/../../../kubernetes/service.yaml")
    ingress    = filemd5("${path.module}/../../../kubernetes/ingress.yaml")
  }

  provisioner "local-exec" {
    command = <<-EOT
      kubectl apply -f ${path.module}/../../../kubernetes/deployment.yaml
      kubectl apply -f ${path.module}/../../../kubernetes/service.yaml
      kubectl apply -f ${path.module}/../../../kubernetes/ingress.yaml
    EOT
  }
}
