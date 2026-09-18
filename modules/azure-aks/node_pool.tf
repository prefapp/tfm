locals {
  default_agent_pool = {
    name = var.default_node_pool.name
    vm_size = var.default_node_pool.vm_size
    count_of = var.default_node_pool.count_of
    enable_auto_scaling = false
    max_pods = var.default_node_pool.max_pods
    os_disk_size_gb = var.default_node_pool.os_disk_size_gb
    node_labels = var.default_node_pool.node_labels
    orchestrator_version = var.aks_kubernetes_version
    vnet_subnet_id = data.azurerm_subnet.aks_subnet.id
    upgrade_settings = {
      drain_timeout_in_minutes = var.default_node_pool.upgrade_settings.drain_timeout_in_minutes
      node_soak_duration_in_minutes = var.default_node_pool.upgrade_settings.node_soak_duration_in_minutes
      max_surge = var.default_node_pool.upgrade_settings.max_surge
    }
  }

  agent_pools = {
    for pool in var.extra_node_pools : pool.name => {
      name = pool.pool_name
      vm_size = pool.vm_size
      enable_auto_scaling = pool.enable_auto_scaling
      count_of = pool.enable_auto_scaling ? null : pool.node_count
      min_count = pool.min_count
      max_count = pool.max_count
      max_pods = pool.max_pod_per_node
      mode = pool.mode
      os_disk_type = pool.os_disk_type
      node_labels = pool.custom_labels
      orchestrator_version = (
        pool.orchestrator_version != "" ? pool.orchestrator_version : var.aks_orchestrator_version
      )
      vnet_subnet_id = data.azurerm_subnet.aks_subnet.id
      create_nodepool_before_destroy = pool.create_before_destroy
      upgrade_settings = pool.upgrade_settings
      }
    }
  }
