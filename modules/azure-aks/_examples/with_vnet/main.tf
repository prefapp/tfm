module "azure_aks" {
  source = "../../"

  resource_group_name     = "example-rg"
  location                = "westeurope"
  aks_prefix              = "vnet"
  aks_kubernetes_version  = "1.28.3"
  aks_sku_tier            = "Free"
  aks_sku_name            = "Base"
  aks_network_dataplane   = "azure"
  aks_network_plugin      = "azure"
  aks_network_policy      = "azure"
  aks_orchestrator_version = "1.28.3"
  vnet_name               = "custom-vnet"
  vnet_resource_group_name = "network-rg"
  subnet_name             = "custom-subnet"
  oidc_issuer_enabled     = true
  workload_identity_enabled = true
  key_vault_secrets_provider_enabled = true
  secret_rotation_enabled = false
  secret_rotation_interval = null
  public_ip_name          = "vnet-public-ip"
  auto_upgrade_profile = {
    node_os_upgrade_channel = "None"
    upgrade_channel         = "none"
  }
  aks_upgrade_settings = {
		override_settings = {
      force_upgrade = false
      until		      = "2026-09-18T14:30:00Z"
		}
  }
    auto_scaler_profile       = null
  tags                    = { environment = "vnet" }

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
}
