output "namespace" {
  description = "Namespace where log generator is deployed"
  value       = kubernetes_namespace.log_generator.metadata[0].name
}

output "pod_name" {
  description = "Name of the log generator pod"
  value       = kubernetes_pod.log_generator.metadata[0].name
}