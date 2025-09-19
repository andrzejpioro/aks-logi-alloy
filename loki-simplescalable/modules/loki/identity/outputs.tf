# See Loki Identity Module artifact for content
output "app_client_id" {
  description = "Azure AD Application client ID for Loki"
  value       = azuread_application.loki.client_id
}

output "service_principal_object_id" {
  description = "Service Principal Object ID for Loki"
  value       = azuread_service_principal.loki.object_id
}

output "federated_credential_subject" {
  description = "Subject for federated identity credential"
  value       = "system:serviceaccount:${var.namespace}:${var.service_account_name}"
}
