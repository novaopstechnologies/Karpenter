output "gp3_storage_class_name" {
  value = kubernetes_storage_class.gp3.metadata[0].name
}
