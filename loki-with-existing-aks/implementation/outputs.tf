# See Modular Terraform Structure artifact for content

# Loki Outputs
output "loki_info" {
  description = "Loki deployment information"
  value = {
    namespace          = module.loki.namespace
    #gateway_url        = module.loki.gateway_url
    username          = var.loki_username
    app_id            = module.loki.app_client_id
  }
}

# Sensitive Outputs
output "loki_password" {
  description = "Loki authentication password"
  value       = module.loki.actual_password
  sensitive   = true
}

output "kubectl_config_command" {
  description = "Command to configure kubectl"
  value       = "az aks get-credentials --resource-group ${var.aks_rg_name} --name ${var.aks_cluster_name}"
}

# Connection Commands
output "connection_info" {
  description = "Connection information and useful commands"
  value = {
    kubectl_config    = "az aks get-credentials --resource-group ${var.aks_rg_name} --name ${var.aks_cluster_name}"
    loki_port_forward = "kubectl port-forward -n ${module.loki.namespace} service/loki-gateway 3100:80"
    view_pods        = "kubectl get pods -n ${module.loki.namespace}"
    view_logs        = "kubectl logs -n ${module.loki.namespace} -l app.kubernetes.io/name=loki"
  }
}