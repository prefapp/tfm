module "azure_aks" {
  source = "../../"

  resource_group_name     = "example-rg"
  location                = "westeurope"
  aks_prefix              = "extra"
  aks_kubernetes_version  = "1.28.3"
  aks_sku_tier            = "Free"
  aks_sku_name            = "Base"
  aks_network_dataplane   = "azure
  aks_network_plugin      = "azure"
  aks_network_policy      = "azure"
  aks_orchestrator_version = "1.28.3"
  vnet_name               = "example-vnet"
  vnet_resource_group_name = "example-rg"
  subnet_name             = "example-subnet"
  oidc_issuer_enabled     = true
  workload_identity_enabled = true
  key_vault_secrets_provider_enabled = true
  secret_rotation_enabled = false
  secret_rotation_interval = null
  public_ip_name          = "extra-public-ip"
  auto_upgrade_profile {
    node_os_upgrade_channel = "None"
    upgrade_channel         = "none"
  }
	upgrade_settings {
		override_settings {
      force_upgrade = false
      until		      = "2026-09-18T14:30:00Z"
		}
	}
  tags                    = { environment = "extra" }

  default_node_pool {
    name = "default"
    vm_size = "Standard_D8as_v5"
    count_of = 1
    enable_auto_scaling = false
    max_pods = 30
    os_disk_size_gb = 128
    node_labels {
      pool = "default"
    }
    upgrade_settings {
      drain_timeout_in_minutes = 30
      node_soak_duration_in_minutes = 0
      max_surge = "10%"
    }
  }

  extra_node_pools = [
    {
      name                  = "np1"
      pool_name             = "np1"
      vm_size               = "Standard_DS2_v2"
      count_of              = 1
      enable_auto_scaling   = false
      custom_labels         = { role = "worker" }
    },
    {
      name                  = "np2"
      pool_name             = "np2"
      vm_size               = "Standard_DS3_v2"
      enable_auto_scaling   = true
      custom_labels         = { role = "batch" }
    }
  ]
}
