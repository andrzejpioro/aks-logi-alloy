# See Loki Identity Module artifact for conte# See Loki Identity Module artifaty/outputs.tf << 'EOF'
# See Loki Identity # dule artifact for content
# Create Azure AD application
resource "azuread_application" "loki" {
  display_name = "loki-${var.namespace}"
}

# Create service principal for the application
resource "azuread_service_principal" "loki" {
  client_id = azuread_application.loki.client_id
}

# Create federated identity credential
resource "azuread_application_federated_identity_credential" "loki" {
  application_id = azuread_application.loki.id
  display_name   = "LokiFederatedIdentity"
  description    = "Federated identity for Loki accessing Azure resources"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = var.oidc_issuer_url
  subject        = "system:serviceaccount:${var.namespace}:${var.service_account_name}"
}

# Assign Storage Blob Data Contributor role to the service principal
resource "azurerm_role_assignment" "loki_storage" {
  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.loki.object_id
  
  depends_on = [azuread_application_federated_identity_credential.loki]
}