# Ensures local kubectl is pointed at the right cluster before the
# local-exec provisioners below run kubectl apply.
resource "null_resource" "kubeconfig" {
  triggers = {
    cluster_name = var.cluster_name
  }

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --region ${var.aws_region} --name ${var.cluster_name}"
  }
}

resource "helm_release" "karpenter" {
  name             = "karpenter"
  namespace        = "karpenter"
  create_namespace = true

  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = var.karpenter_version

  values = [
    templatefile("${path.module}/../../../helm-values/karpenter-values.yaml", {
      cluster_name                   = var.cluster_name
      cluster_endpoint                = var.cluster_endpoint
      karpenter_controller_role_arn  = var.karpenter_controller_role_arn
      interruption_queue_name         = var.interruption_queue_name
    })
  ]

  depends_on = [null_resource.kubeconfig]
}

# EC2NodeClass and NodePool are Karpenter CRDs installed by the helm chart
# above, so they're applied afterwards via kubectl rather than as native
# Terraform resources (kubernetes_manifest has known issues with CRDs that
# don't exist yet at plan time).
resource "null_resource" "ec2nodeclass" {
  triggers = {
    node_role_name = var.node_iam_role_name
    cluster_name    = var.cluster_name
  }

  provisioner "local-exec" {
    command = <<-EOT
      sed -e 's|__NODE_ROLE_NAME__|${var.node_iam_role_name}|g' \
          -e 's|__CLUSTER_NAME__|${var.cluster_name}|g' \
          ${path.module}/../../../kubernetes/ec2nodeclass.yaml | kubectl apply -f -
    EOT
  }

  depends_on = [helm_release.karpenter]
}

resource "null_resource" "nodepool" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/../../../kubernetes/nodepool.yaml"
  }

  depends_on = [null_resource.ec2nodeclass]
}
