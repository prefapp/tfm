# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster
resource "azurerm_kubernetes_cluster" "kubernetes" {
  name                      = var.aks_cluster_name
  location                  = var.aks_location
  resource_group_name       = var.aks_resource_group_name
  dns_prefix                = var.aks_aks_dns_prefix
  kubernetes_version        = var.aks_kubernetes_version
  azure_policy_enabled      = var.aks_azure_policy_enabled
  automatic_channel_upgrade = var.aks_automatic_channel_upgrade
  sku_tier                  = var.aks_sku_tier
  workload_identity_enabled = var.aks_workload_identity_enabled
  oidc_issuer_enabled       = var.aks_oidc_issuer_enabled
  identity {
    type = var.aks_identity_type
  }
  default_node_pool {
    name                = var.aks_default_node_pool_name
    enable_auto_scaling = var.aks_default_node_pool_enable_auto_scaling
    # `max_count` and `min_count` must be set to `null` when enable_auto_scaling is set to `false`
    min_count           = var.aks_default_node_pool_enable_auto_scaling ? var.aks_default_node_pool_min_count : null
    max_count           = var.aks_default_node_pool_enable_auto_scaling ? var.aks_default_node_pool_max_count : null
    node_count          = var.aks_default_node_pool_node_count
    vm_size             = var.aks_default_node_pool_vm_size
    os_disk_type        = var.aks_default_node_pool_os_disk_type
    os_disk_size_gb     = var.aks_default_node_pool_os_disk_size_gb
    max_pods            = var.aks_default_node_pool_max_pods
    vnet_subnet_id      = data.azurerm_subnet.aks_subnet.id
  }
  key_vault_secrets_provider {
    secret_rotation_enabled  = var.aks_key_vault_secrets_provider_enabled
    secret_rotation_interval = var.aks_key_vault_secrets_provider_interval
  }
  network_profile {
    network_plugin = var.aks_network_plugin
    service_cidr   = var.aks_service_cidr
    dns_service_ip = var.aks_dns_service_ip
  }
  tags = var.aks_tags
  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count,
      for tag in var.ignored_tags : "tags.${tag}"
    ]
  }
}
