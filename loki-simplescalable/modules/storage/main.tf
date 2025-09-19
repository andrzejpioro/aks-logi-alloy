# See Storage Module artifact for content

# Generate a random suffix for globally unique storage account name
resource "random_string" "storage_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Create the storage account
resource "azurerm_storage_account" "loki" {
  name                     = "${var.storage_account_base_name}${random_string.storage_suffix.result}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = var.replication_type

  # Additional security settings
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false

  tags = merge(var.common_tags, {
    Purpose = "Loki Storage"
  })
}

# Create storage container for chunks
resource "azurerm_storage_container" "chunks" {
  name                  = var.chunk_bucket_name
  storage_account_name  = azurerm_storage_account.loki.name
  container_access_type = "private"
}

# Create storage container for ruler
resource "azurerm_storage_container" "ruler" {
  name                  = var.ruler_bucket_name
  storage_account_name  = azurerm_storage_account.loki.name
  container_access_type = "private"
}