# See Storage Module artifact for content
output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.loki.name
}

output "storage_account_id" {
  description = "ID of the storage account"
  value       = azurerm_storage_account.loki.id
}

output "primary_blob_endpoint" {
  description = "Primary blob endpoint URL"
  value       = azurerm_storage_account.loki.primary_blob_endpoint
}

output "primary_access_key" {
  description = "Primary access key for the storage account"
  value       = azurerm_storage_account.loki.primary_access_key
  sensitive   = true
}

output "connection_string" {
  description = "Connection string for the storage account"
  value       = azurerm_storage_account.loki.primary_connection_string
  sensitive   = true
}

output "chunk_container_name" {
  description = "Name of the chunks container"
  value       = azurerm_storage_container.chunks.name
}

output "ruler_container_name" {
  description = "Name of the ruler container"
  value       = azurerm_storage_container.ruler.name
}