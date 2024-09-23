locals {
  extra_pools = {
    for pool in var.extra_node_pools :
    pool.name => {
      name                  = pool.pool_name
      vm_size               = pool.vm_size
      node_count            = pool.enable_auto_scaling ? null : pool.node_count
      vnet_subnet_id        = data.azurerm_subnet.aks_subnet.id
      create_before_destroy = pool.create_before_destroy
      enable_auto_scaling   = pool.enable_auto_scaling
      max_count             = pool.max_count
      min_count             = pool.min_count
      max_pods              = pool.max_pod_per_node
      os_disk_type          = pool.os_disk_type
      mode                  = pool.mode
      node_labels           = pool.custom_labels
      orchestrator_version  = pool.orchestrator_version == "" ? var.aks_orchestrator_version : pool.orchestrator_version
      upgrade_settings      = pool.upgrade_settings
    }
  }
}
