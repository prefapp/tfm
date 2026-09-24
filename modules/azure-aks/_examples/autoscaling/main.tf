module "azure_aks" {
  source = "../../"

  resource_group_name     = "example-rg"
  location                = "westeurope"
  aks_prefix              = "autoscale"
  aks_kubernetes_version  = "1.28.3"
  aks_sku_tier            = "Free"
  aks_sku_name            = "Base"
  aks_network_plugin      = "azure"
  aks_network_policy      = "azure"
  aks_network_dataplane   = "azure"
  aks_orchestrator_version = "1.28.3"
  vnet_name               = "example-vnet"
  vnet_resource_group_name = "example-rg"
  subnet_name             = "example-subnet"
  oidc_issuer_enabled     = true
  workload_identity_enabled = true
  key_vault_secrets_provider_enabled = true
  secret_rotation_enabled = false
  secret_rotation_interval = null
  public_ip_name          = "autoscale-public-ip"
  auto_upgrade_profile = {
    node_os_upgrade_channel = "None"
    upgrade_channel         = "none"
  }
	upgrade_settings = {
		override_settings = {
      force_upgrade = false
      until		      = "2026-09-18T14:30:00Z"
		}
	}
  tags                    = { environment = "autoscale" }

  default_node_pool = {
    name = "default"
    vm_size = "Standard_D8as_v5"
    count_of = 1
    enable_auto_scaling = false
    max_pods = 30
    os_disk_size_gb = 128
    node_labels = {
      pool = "default"
    }
    upgrade_settings = {
      drain_timeout_in_minutes = 30
      node_soak_duration_in_minutes = 0
      max_surge = "10%"
    }
  }

  auto_scaler_profile = {
    balance_similar_node_groups = false
    daemonset_eviction_for_empty_nodes = false
    daemonset_eviction_for_occupied_nodes = true
    ignore_daemonsets_utilization = false
    max_empty_bulk_delete = 10
    expander = "random"
    max_graceful_termination_sec = 600
    max_node_provision_time = "15"
    ok_total_unready_count = 1
    max_total_unready_percentage = 45
    new_pod_scale_up_delay = "0"
    scale_down_delay_after_add = "10"
    scale_down_delay_after_delete = "10"
    scale_down_delay_after_failure = "3"
    scale_down_unneeded_time = "10"
    scale_down_unready_time = "10"
    scale_down_utilization_threshold = 0.5
    scan_interval = "10"
    skip_nodes_with_local_storage = false
    skip_nodes_with_system_pods = false
  }
}
