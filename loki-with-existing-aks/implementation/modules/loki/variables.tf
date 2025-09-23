variable "kubernetes_namespace" {
  description = "Kubernetes namespace for Loki application"
  default = "monitoring"
}

variable "storage_account_name" {
  description = "Name of the storage account"
  type        = string
}


variable "chunks_container" {
  description = "Name of the chunks container"
  type        = string
}

variable "ruler_container" {
  description = "Name of the ruler container"
  type        = string
}


variable "service_account_name" {
  description = "Kubernetes service account name for Loki"
  type        = string
}

variable "service_principal_client_id" {
  description = "Service Principal Client ID for accessing storage account"
  type = string
}


variable "username" {
  description = "Username for Loki basic authentication"
  type        = string
  default     = "loki"
}

variable "password" {
  description = "Password for Loki basic authentication"
  type        = string
  sensitive   = true
  default     = ""
}

variable "retention_hours" {
  description = "Log retention in hours"
  type        = number
  default     = 672
}


variable "helm_chart_repository_url"{
  description = "Grafana helm repository"
  type        = string
  default     = "https://grafana.github.io/helm-charts" 
}

# Updated replicas for Simple Scalable architecture
variable "replicas" {
  description = "Number of replicas for Loki Simple Scalable components"
  type = object({
    backend  = number  # compactor, ruler, scheduler, index-gateway
    read     = number  # query-frontend + querier
    write    = number  # distributor + ingester  
    gateway  = number  # gateway
  })
}

variable "memcached_memory" {
  description = "Memory allocation for memcached instances in MB"
  type = object({
    main           = number
    chunks         = number
    frontend       = number
    index_queries  = number
    index_writes   = number
  })
}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
}