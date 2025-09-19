# See Storage Module artifact for content
variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "storage_account_base_name" {
  description = "Base name of the storage account (will have random suffix added)"
  type        = string
}

variable "chunk_bucket_name" {
  description = "Name of the chunks storage container"
  type        = string
  default     = "loki-chunks"
}

variable "ruler_bucket_name" {
  description = "Name of the ruler storage container"
  type        = string
  default     = "loki-ruler"
}

variable "replication_type" {
  description = "Storage account replication type"
  type        = string
  default     = "ZRS"
}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
}