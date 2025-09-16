variable "namespace" {
  description = "Kubernetes namespace for the log generator"
  type        = string
  default     = "app1"
}

variable "app_name" {
  description = "Name of the log generator application"
  type        = string
  default     = "log-generator"
}