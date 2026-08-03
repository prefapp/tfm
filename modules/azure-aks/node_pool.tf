locals {
  default_agent_pool = {
    name = var.aks_agents_pool_name
    vm_size = var.aks_agents_size

    node_count = var.aks_agents_count

    enable_auto_scaling = false

    max_pods = var.aks_agents_max_pods
    os_disk_size_gb = var.aks_os_disk_size_gb

    node_labels = var.aks_default_pool_custom_labels

    orchestrator_version = var.aks_orchestrator_version

    vnet_subnet_id = data.azurerm_subnet.aks_subnet.id

    temporary_name_for_rotation = var.temporary_name_for_rotation

    upgrade_settings = {
      drain_timeout_in_minutes = var.aks_agents_pool_drain_timeout_in_minutes
      max_surge = var.aks_agents_pool_max_surge
      }
    }

    agent_pools = {
      for pool in var.extra_node_pools : pool.name => {
        name = pool.pool_name
        vm_size = pool.vm_size

        enable_auto_scaling = pool.enable_auto_scaling

        node_count = pool.enable_auto_scaling ? null : pool.node_count

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
