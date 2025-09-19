output "namespace" {
  description = "Alloy namespace name"
  value       = var.namespace
}

output "service_account_name" {
  description = "Alloy service account name"
  value       = kubernetes_service_account.alloy.metadata[0].name
}

output "cluster_role_name" {
  description = "Alloy cluster role name"
  value       = kubernetes_cluster_role.alloy.metadata[0].name
}
