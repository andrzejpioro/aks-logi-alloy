# Note: Provider configurations are handled at the root level

# Create the loki namespace
resource "kubernetes_namespace" "loki" {
  metadata {
    name = var.namespace
    labels = {
      "azure.workload.identity/use" = "true"
    }
  }
}

# Generate password if not provided
resource "random_password" "loki_password" {
  count   = var.password == "" ? 1 : 0
  length  = 16
  special = true
}

locals {
  actual_password = var.password != "" ? var.password : random_password.loki_password[0].result
  htpasswd_content = "${var.username}:${bcrypt(local.actual_password)}"
}

# Include the identity configuration
module "identity" {
  source = "./identity"
  
  oidc_issuer_url      = var.oidc_issuer_url
  namespace            = var.namespace
  service_account_name = var.service_account_name
  storage_account_id   = var.storage_account_id
}

# Create basic auth secret for Loki gateway
resource "kubernetes_secret" "loki_basic_auth" {
  metadata {
    name      = "loki-basic-auth"
    namespace = kubernetes_namespace.loki.metadata[0].name
  }

  data = {
    ".htpasswd" = local.htpasswd_content
  }

  type = "Opaque"
}

# Create canary basic auth secret
resource "kubernetes_secret" "canary_basic_auth" {
  metadata {
    name      = "canary-basic-auth"
    namespace = kubernetes_namespace.loki.metadata[0].name
  }

  data = {
    username = var.username
    password = local.actual_password
  }

  type = "Opaque"
}

# Deploy Loki using Helm chart with template
resource "helm_release" "loki" {
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  namespace  = kubernetes_namespace.loki.metadata[0].name

  depends_on = [
    kubernetes_namespace.loki,
    kubernetes_secret.loki_basic_auth,
    kubernetes_secret.canary_basic_auth,
    module.identity
  ]

  values = [
    templatefile("${path.module}/helm-values.yaml.tpl", {
      storage_account_name    = var.storage_account_name
      chunks_container       = var.chunks_container
      ruler_container        = var.ruler_container
      service_account_name   = var.service_account_name
      app_client_id         = module.identity.app_client_id
      retention_hours       = var.retention_hours
      replicas              = var.replicas
      memcached_memory      = var.memcached_memory
      basic_auth_secret     = kubernetes_secret.loki_basic_auth.metadata[0].name
      canary_auth_secret    = kubernetes_secret.canary_basic_auth.metadata[0].name
    })
  ]

  timeout         = 600
  wait           = true
  cleanup_on_fail = true
}

# Get Loki gateway service information
data "kubernetes_service" "loki_gateway" {
  metadata {
    name      = "loki-gateway"
    namespace = kubernetes_namespace.loki.metadata[0].name
  }
  depends_on = [helm_release.loki]
}