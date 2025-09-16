# See Modular Terraform Structure artifact for content
data "azurerm_client_config" "current" {}

locals {
  # Resource naming
  resource_group_name = "rg-${var.project_name}-${var.environment}"
  cluster_name        = "${var.project_name}-aks-${var.environment}"
  
  # Kubernetes configuration
  loki_namespace        = "${var.project_name}-${var.environment}"
  loki_service_account  = "${var.project_name}-loki-sa"
  alloy_service_account = "${var.project_name}-alloy-sa"
  
  # Storage configuration
  storage_account_base_name = "${var.project_name}${var.environment}"
  chunk_bucket_name         = "loki-chunks"
  ruler_bucket_name         = "loki-ruler"
  
  # Common tags
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
  
  # Loki retention in hours
  loki_retention_hours = var.loki_retention_days * 24
}