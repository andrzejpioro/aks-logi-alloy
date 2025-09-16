# See AKS Module artifact for content
# Create Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.common_tags
}

# Create the AKS cluster
resource "azurerm_kubernetes_cluster" "main" {
  name                = var.cluster_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "${var.cluster_name}-dns"
  kubernetes_version  = var.kubernetes_version

  # Default node pool configuration
  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = var.node_vm_size

    upgrade_settings {
      drain_timeout_in_minutes      = 0
      max_surge                     = "10%"
      node_soak_duration_in_minutes = 0
    }
  }

  # Service principal or managed identity
  identity {
    type = "SystemAssigned"
  }

  # Enable workload identity and OIDC issuer
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  # SSH key configuration
  linux_profile {
    admin_username = "adminuser"

    ssh_key {
      key_data = file(var.ssh_public_key_path)
    }
  }

  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count
    ]
  }

  tags = var.common_tags
}