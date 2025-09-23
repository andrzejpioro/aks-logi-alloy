# See Loki Module artifact for content

output "actual_password" {
  description = "Generated or provided Loki password"
  value       = local.actual_password
  sensitive   = true
}

output "namespace" {
  description = "Kubernetes namespace where Loki is deployed"
  value       = var.kubernetes_namespace
  
}
# output "gateway_external_ip" {
#   description = "External IP of the Loki gateway LoadBalancer"
#   value       = try(data.kubernetes_service.loki_gateway.status[0].load_balancer[0].ingress[0].ip, "Pending")
# }

 output "gateway_url" {
   description = "URL to access Loki gateway"
  #  value       = try("http://${data.kubernetes_service.loki_gateway.status[0].load_balancer[0].ingress[0].ip}:3100", "Pending")
   value      =  "http://${data.kubernetes_service.loki_gateway.metadata[0].name}.${data.kubernetes_service.loki_gateway.metadata[0].namespace}.svc.cluster.local:3100"
 }

 output "app_client_id" {
   description = "Azure AD Application client ID for Loki"
   value       = var.service_principal_client_id
 }

output "helm_status" {
  description = "Status of the Loki Helm release"
  value       = helm_release.loki.status
}