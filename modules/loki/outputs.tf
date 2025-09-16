# See Loki Module artifact for content
output "namespace" {
  description = "Loki namespace name"
  value       = kubernetes_namespace.loki.metadata[0].name
}

output "actual_password" {
  description = "Generated or provided Loki password"
  value       = local.actual_password
  sensitive   = true
}

output "gateway_external_ip" {
  description = "External IP of the Loki gateway LoadBalancer"
  value       = try(data.kubernetes_service.loki_gateway.status[0].load_balancer[0].ingress[0].ip, "Pending")
}

output "gateway_url" {
  description = "URL to access Loki gateway"
  value       = try("http://${data.kubernetes_service.loki_gateway.status[0].load_balancer[0].ingress[0].ip}:3100", "Pending")
}

output "app_client_id" {
  description = "Azure AD Application client ID for Loki"
  value       = module.identity.app_client_id
}

output "helm_status" {
  description = "Status of the Loki Helm release"
  value       = helm_release.loki.status
}