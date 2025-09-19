variable "loki_gateway_ip" {
  description = "IP address of the Loki gateway"
  type        = string
}

variable "loki_username" {
  description = "Username for Loki authentication"
  type        = string
}

variable "loki_password" {
  description = "Password for Loki authentication"
  type        = string
  sensitive   = true
}

variable "loki_app_client_id" {
  description = "Azure AD Application client ID for Loki"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for Alloy"
  type        = string
}

variable "service_account_name" {
  description = "Kubernetes service account name for Alloy"
  type        = string
}

variable "tenant_configs" {
  description = "Tenant configuration for multi-tenancy"
  type = map(object({
    namespace = string
    tenant_id = string
  }))
}