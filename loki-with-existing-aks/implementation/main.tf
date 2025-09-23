# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Configure Kubernetes provider to use the AKS cluster
data "azurerm_kubernetes_cluster" "existing" {
  name                = var.aks_cluster_name
  resource_group_name = var.aks_rg_name
}

provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.existing.kube_config.0.host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.existing.kube_config.0.client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.existing.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.existing.kube_config.0.cluster_ca_certificate)
}

# Configure Helm provider to use the AKS cluster
provider "helm" {
  kubernetes {
     host                   = data.azurerm_kubernetes_cluster.existing.kube_config.0.host
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.existing.kube_config.0.client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.existing.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.existing.kube_config.0.cluster_ca_certificate)
  }
}


# Loki Module
module "loki" {
  source = "./modules/loki"
  

  # Kubernetest configuration
  kubernetes_namespace = var.kubernetes_namespace
  
  helm_chart_repository_url = var.grafana_helm_chart_repo

  # Storage configuration
  service_principal_client_id = var.service_principal_client_id
  storage_account_name = var.storage_account_name
  chunks_container     = var.storage_container_chunks_name
  ruler_container      = var.storage_container_ruller_name
  
  # Loki configuration
  service_account_name   = local.loki_service_account
  username              = var.loki_username
  password              = var.loki_password
  retention_hours       = local.loki_retention_hours
  replicas              = var.loki_replicas
  memcached_memory      = var.memcached_memory_mb
  
  common_tags = local.common_tags
  
}

# # # Alloy Module
# module "alloy" {
#   source = "./modules/alloy"
  
#   # Loki connection - no cluster connection variables needed
#   loki_gateway_ip        = module.loki.gateway_external_ip
#   loki_username         = var.loki_username
#   loki_password         = module.loki.actual_password
#   loki_app_client_id    = module.loki.app_client_id
  
#   # Configuration
#   kubernetes_namespace  = local.loki_namespace
#   service_account_name  = local.alloy_service_account
#   tenant_configs       = var.tenant_configs
  
#   helm_chart_repository_url = var.grafana_helm_chart_repo


#   #depends_on = [module.loki]
# }


# # Log Generator Module
# module "log_generator" {
#   source = "./modules/sample-app-log-generator"
  
#   # Configuration
#   namespace = "app1"
#   app_name  = "log-generator"
  
#   depends_on = [module.loki]
# }