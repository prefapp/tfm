module "azure_aks" {
  source = "../../"

  resource_group_name      = "example-rg"
  location                = "westeurope"
  aks_prefix              = "autoscale"
  aks_kubernetes_version  = "1.28.3"
  aks_agents_count        = 1
  aks_agents_size         = "Standard_DS2_v2"
  aks_agents_pool_name    = "default"
  aks_agents_max_pods     = 30
  aks_agents_pool_max_surge = "33%"
  aks_sku_tier              = "Free"
  aks_network_plugin      = "azure"
  aks_network_policy      = "azure"
  aks_orchestrator_version = "1.28.3"
  aks_os_disk_size_gb     = 30
  vnet_name               = "example-vnet"
  vnet_resource_group_name = "example-rg"
  subnet_name             = "example-subnet"
  oidc_issuer_enabled     = true
  workload_identity_enabled = true
  key_vault_secrets_provider_enabled = true
  secret_rotation_enabled = false
  secret_rotation_interval = null
  public_ip_name          = "autoscale-public-ip"
  tags                    = { environment = "autoscale" }

  auto_scaler_profile_enabled = true
  auto_scaler_profile_expander = "random"
  auto_scaler_profile_max_graceful_termination_sec = 600
  auto_scaler_profile_max_node_provisioning_time = "15"
  auto_scaler_profile_max_unready_nodes = 1
  auto_scaler_profile_max_unready_percentage = 45
  auto_scaler_profile_new_pod_scale_up_delay = "0"
  auto_scaler_profile_scale_down_delay_after_add = "10"
  auto_scaler_profile_scale_down_delay_after_delete = "10"
  auto_scaler_profile_scale_down_delay_after_failure = "3"
  auto_scaler_profile_scale_down_unneeded = "10"
  auto_scaler_profile_scale_down_unready = "10"
  auto_scaler_profile_scale_down_utilization_threshold = 0.5
  auto_scaler_profile_scan_interval = "10"
  auto_scaler_profile_skip_nodes_with_local_storage = false
  auto_scaler_profile_skip_nodes_with_system_pods = false
}
