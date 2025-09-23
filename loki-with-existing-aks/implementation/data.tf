# Data source to reference existing Azure Storage Account
data "azurerm_storage_account" "alloy" {
  name                = var.storage_account_name
  resource_group_name = var.storage_account_rg
}