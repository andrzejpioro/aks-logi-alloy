# See Modular Terraform Structure artifact for content
# AKS Outputs
output "cluster_info" {
  description = "AKS cluster information"
  value = {
    name                = module.aks.cluster_name
    resource_group      = module.aks.resource_group_name
    location            = module.aks.location
    kubernetes_version  = module.aks.kubernetes_version
    oidc_issuer_url    = module.aks.oidc_issuer_url
  }
}

# Storage Outputs
output "storage_info" {
  description = "Storage account information"
  value = {
    account_name          = module.storage.storage_account_name
    primary_blob_endpoint = module.storage.primary_blob_endpoint
    chunks_container      = module.storage.chunk_container_name
    ruler_container       = module.storage.ruler_container_name
  }
}

# Loki Outputs
output "loki_info" {
  description = "Loki deployment information"
  value = {
    namespace          = module.loki.namespace
    gateway_url        = module.loki.gateway_url
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
  value       = "az aks get-credentials --resource-group ${module.aks.resource_group_name} --name ${module.aks.cluster_name}"
}

# Connection Commands
output "connection_info" {
  description = "Connection information and useful commands"
  value = {
    kubectl_config    = "az aks get-credentials --resource-group ${module.aks.resource_group_name} --name ${module.aks.cluster_name}"
    loki_port_forward = "kubectl port-forward -n ${module.loki.namespace} service/loki-gateway 3100:80"
    view_pods        = "kubectl get pods -n ${module.loki.namespace}"
    view_logs        = "kubectl logs -n ${module.loki.namespace} -l app.kubernetes.io/name=loki"
  }
}