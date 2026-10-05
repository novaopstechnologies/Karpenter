resource "helm_release" "prometheus" {
  name             = "prometheus"
  namespace        = "monitoring"
  create_namespace = true

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = var.prometheus_chart_version

  values = [
    file("${path.module}/../../../helm-values/prometheus-values.yaml")
  ]
}

resource "helm_release" "grafana" {
  name      = "grafana"
  namespace = "monitoring"

  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = var.grafana_chart_version

  values = [
    file("${path.module}/../../../helm-values/grafana-values.yaml")
  ]

  depends_on = [helm_release.prometheus]
}
