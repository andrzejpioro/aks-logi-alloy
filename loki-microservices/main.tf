# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Configure Kubernetes provider to use the AKS cluster
provider "kubernetes" {
  host                   = module.aks.host
  client_certificate     = base64decode(module.aks.client_certificate)
  client_key             = base64decode(module.aks.client_key)
  cluster_ca_certificate = base64decode(module.aks.cluster_ca_certificate)
}

# Configure Helm provider to use the AKS cluster
provider "helm" {
  kubernetes {
    host                   = module.aks.host
    client_certificate     = base64decode(module.aks.client_certificate)
    client_key             = base64decode(module.aks.client_key)
    cluster_ca_certificate = base64decode(module.aks.cluster_ca_certificate)
  }
}

# AKS Module
module "aks" {
  source = "./modules/aks"
  
  # Project configuration
  project_name    = var.project_name
  environment     = var.environment
  location        = var.location
  common_tags     = local.common_tags
  
  # Resource naming
  resource_group_name = local.resource_group_name
  cluster_name        = local.cluster_name
  
  # AKS configuration
  kubernetes_version   = var.kubernetes_version
  node_count          = var.node_count
  node_vm_size        = var.node_vm_size
  ssh_public_key_path = var.ssh_public_key_path
}

# Storage Module
module "storage" {
  source = "./modules/storage"
  
  # Dependencies
  resource_group_name = module.aks.resource_group_name
  location           = module.aks.location
  
  # Storage configuration
  storage_account_base_name = local.storage_account_base_name
  chunk_bucket_name        = local.chunk_bucket_name
  ruler_bucket_name        = local.ruler_bucket_name
  replication_type         = var.storage_replication_type
  common_tags             = local.common_tags
}

# Loki Module
module "loki" {
  source = "./modules/loki"
  
  # Dependencies - no cluster connection variables needed
  oidc_issuer_url = module.aks.oidc_issuer_url
  
  # Storage configuration
  storage_account_name = module.storage.storage_account_name
  storage_account_id   = module.storage.storage_account_id
  chunks_container     = module.storage.chunk_container_name
  ruler_container      = module.storage.ruler_container_name
  
  # Loki configuration
  namespace              = local.loki_namespace
  service_account_name   = local.loki_service_account
  username              = var.loki_username
  password              = var.loki_password
  retention_hours       = local.loki_retention_hours
  replicas              = var.loki_replicas
  memcached_memory      = var.memcached_memory_mb
  
  common_tags = local.common_tags
  
  depends_on = [module.storage]
}

# Alloy Module
module "alloy" {
  source = "./modules/alloy"
  
  # Loki connection - no cluster connection variables needed
  loki_gateway_ip        = module.loki.gateway_external_ip
  loki_username         = var.loki_username
  loki_password         = module.loki.actual_password
  loki_app_client_id    = module.loki.app_client_id
  
  # Configuration
  namespace             = local.loki_namespace
  service_account_name  = local.alloy_service_account
  tenant_configs       = var.tenant_configs
  
  depends_on = [module.loki]
}


# Log Generator Module
module "log_generator" {
  source = "./modules/sample-app-log-generator"
  
  # Configuration
  namespace = "app1"
  app_name  = "log-generator"
  
  depends_on = [module.aks]
}