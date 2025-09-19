// Discover all pods
discovery.kubernetes "pods" {
  role = "pod"
}

%{~ for tenant_key, tenant in tenant_configs }
// Create discovery for ${tenant.namespace} namespace (${tenant.tenant_id})
discovery.relabel "${replace(tenant.namespace, "-", "_")}_pods" {
  targets = discovery.kubernetes.pods.targets

  // Only keep pods from ${tenant.namespace} namespace
  rule {
    source_labels = ["__meta_kubernetes_namespace"]
    regex         = "${tenant.namespace}"
    action        = "keep"
  }

  // Add standard labels
  rule {
    source_labels = ["__meta_kubernetes_namespace"]
    target_label  = "namespace"
  }
  
  rule {
    source_labels = ["__meta_kubernetes_pod_name"]
    target_label  = "pod"
  }
  
  rule {
    source_labels = ["__meta_kubernetes_pod_container_name"]
    target_label  = "container"
  }

  // Add node information
  rule {
    source_labels = ["__meta_kubernetes_pod_node_name"]
    target_label  = "node"
  }

  // Add app labels if available
  rule {
    source_labels = ["__meta_kubernetes_pod_label_app"]
    target_label  = "app"
  }

  rule {
    source_labels = ["__meta_kubernetes_pod_label_app_kubernetes_io_name"]
    target_label  = "app_name"
  }
}

// Scrape logs for ${tenant.namespace}
loki.source.kubernetes "${replace(tenant.namespace, "-", "_")}_logs" {
  targets    = discovery.relabel.${replace(tenant.namespace, "-", "_")}_pods.output
  forward_to = [loki.write.${replace(tenant.namespace, "-", "_")}_loki.receiver]
}

// Write to Loki with ${tenant.tenant_id} tenant ID
loki.write "${replace(tenant.namespace, "-", "_")}_loki" {
  endpoint {
    url = "http://${loki_gateway_ip != "Pending" ? loki_gateway_ip : "loki-gateway.${tenant.namespace}.svc.cluster.local"}:3100/loki/api/v1/push"
    
    basic_auth {
      username = "${loki_username}"
      password = "${loki_password}"
    }

    headers = {
      "X-Scope-OrgID" = "${tenant.tenant_id}",
    }
  }

  external_labels = {
    cluster = "aks-cluster",
    tenant  = "${tenant.tenant_id}",
  }
}

%{~ endfor }