# See Modular Terraform Structure artifact for content
data "azurerm_client_config" "current" {}

locals {
  # Resource naming

  
  # Kubernetes configuration
  loki_namespace        = var.kubernetes_namespace
  loki_service_account  = var.kubernetes_service_account
  alloy_service_account = var.kubernetes_service_account
  
  # Storage configuration
  chunk_bucket_name         = "loki-chunks"
  ruler_bucket_name         = "loki-ruler"
  
  # Common tags
  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
  
  # Loki retention in hours
  loki_retention_hours = var.loki_retention_days * 24
}