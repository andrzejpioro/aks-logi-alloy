# See Loki Identity Module artifact for content
variable "oidc_issuer_url" {
  description = "OIDC issuer URL for workload identity"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for Loki"
  type        = string
}

variable "service_account_name" {
  description = "Kubernetes service account name for Loki"
  type        = string
}

variable "storage_account_id" {
  description = "ID of the storage account"
  type        = string
}
