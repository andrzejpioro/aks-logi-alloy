# Configure Kubernetes provider

# Create ClusterRole for Alloy to read pods/logs across namespaces
resource "kubernetes_cluster_role" "alloy" {
  metadata {
    name = "alloy-logs-reader"
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "pods/log", "services", "endpoints"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["deployments", "replicasets", "daemonsets", "statefulsets"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["nodes", "nodes/metrics", "nodes/proxy"]
    verbs      = ["get", "list", "watch"]
  }
}

# Create ClusterRoleBinding
resource "kubernetes_cluster_role_binding" "alloy" {
  metadata {
    name = "alloy-logs-reader"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.alloy.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = var.service_account_name
    namespace = var.namespace
  }
}

# Create ServiceAccount for Alloy
resource "kubernetes_service_account" "alloy" {
  metadata {
    name      = var.service_account_name
    namespace = var.namespace

    annotations = {
      "azure.workload.identity/client-id" = var.loki_app_client_id
    }

    labels = {
      "azure.workload.identity/use" = "true"
    }
  }
}

# Generate Alloy configuration using template
resource "kubernetes_config_map" "alloy_config" {
  metadata {
    name      = "alloy-config"
    namespace = var.namespace
  }

  data = {
    "config.river" = templatefile("${path.module}/config.river.tpl", {
      tenant_configs   = var.tenant_configs
      loki_gateway_ip  = var.loki_gateway_ip
      loki_username    = var.loki_username
      loki_password    = var.loki_password
    })
  }
}

# Deploy Alloy using Helm chart
resource "helm_release" "alloy" {
  name       = "alloy"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "alloy"
  namespace  = var.namespace

  depends_on = [
    kubernetes_config_map.alloy_config,
    kubernetes_service_account.alloy,
    kubernetes_cluster_role_binding.alloy
  ]

  values = [
    yamlencode({
      serviceAccount = {
        create = false
        name   = kubernetes_service_account.alloy.metadata[0].name
      }

      alloy = {
        configMap = {
          create = false
          name   = kubernetes_config_map.alloy_config.metadata[0].name
          key    = "config.river"
        }

        resources = {
          limits = {
            cpu    = "200m"
            memory = "256Mi"
          }
          requests = {
            cpu    = "100m"
            memory = "128Mi"
          }
        }
      }

      controller = {
        type = "daemonset"
      }

      service = {
        enabled = true
      }
    })
  ]

  timeout         = 300
  wait           = true
  cleanup_on_fail = true
}