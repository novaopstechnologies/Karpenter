variable "cluster_endpoint" {
  type = string
}

variable "cluster_ca_certificate" {
  type = string
}

variable "prometheus_chart_version" {
  type    = string
  default = "62.7.0"
}

variable "grafana_chart_version" {
  type    = string
  default = "8.6.4"
}
