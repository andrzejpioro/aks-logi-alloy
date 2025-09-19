# Project Configuration
variable "project_name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "loki-monitoring"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

# Azure Configuration
variable "location" {
  description = "Azure region"
  type        = string
  default     = "Poland Central"
}

# AKS Configuration
variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.27"
}

variable "node_count" {
  description = "Number of nodes in the default node pool"
  type        = number
  default     = 3
}

variable "node_vm_size" {
  description = "Size of the Virtual Machine"
  type        = string
  default     = "Standard_B2s"
}

# SSH Key Configuration
variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

# Loki Configuration
variable "loki_username" {
  description = "Username for Loki basic authentication"
  type        = string
  default     = "loki"
}

variable "loki_password" {
  description = "Password for Loki basic authentication"
  type        = string
  sensitive   = true
  default     = ""
}

variable "loki_retention_days" {
  description = "Loki log retention in days"
  type        = number
  default     = 28
}

# Updated for Simple Scalable architecture
variable "loki_replicas" {
  description = "Number of replicas for Loki Simple Scalable components"
  type = object({
    backend  = number  # compactor, ruler, scheduler, index-gateway
    read     = number  # query-frontend + querier
    write    = number  # distributor + ingester  
    gateway  = number  # gateway
  })
  default = {
    backend  = 1   # Usually 1 is sufficient for backend components
    read     = 2   # Scale based on query load
    write    = 3   # Scale based on ingestion load
    gateway  = 2   # Frontend load balancer
  }
}

# Storage Configuration
variable "storage_replication_type" {
  description = "Storage account replication type"
  type        = string
  default     = "ZRS"
  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.storage_replication_type)
    error_message = "Storage replication type must be one of: LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS."
  }
}

# Tenant Configuration
variable "tenant_configs" {
  description = "Tenant configuration for multi-tenancy"
  type = map(object({
    namespace = string
    tenant_id = string
  }))
  default = {
    default = {
      namespace = "default"
      tenant_id = "default"
    }
    monitoring = {
      namespace = "monitoring-dev"
      tenant_id = "monitoring-dev"
    }
    app1 = {
      namespace = "app1"
      tenant_id = "app1"
    }
    app2 = {
      namespace = "app2"
      tenant_id = "app2"
    }
  }
}

# Memcached Configuration
variable "memcached_memory_mb" {
  description = "Memory allocation for memcached instances"
  type = object({
    main           = number
    chunks         = number
    frontend       = number
    index_queries  = number
    index_writes   = number
  })
  default = {
    main          = 1024
    chunks        = 1024
    frontend      = 512
    index_queries = 512
    index_writes  = 512
  }
}