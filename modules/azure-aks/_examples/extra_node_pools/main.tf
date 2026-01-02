module "azure_aks" {
  source = "../../"

  resource_group_name      = "example-rg"
  location                = "westeurope"
  aks_prefix              = "extra"
  aks_kubernetes_version  = "1.28.3"
  aks_agents_count        = 2
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
  public_ip_name          = "extra-public-ip"
  tags                    = { environment = "extra" }

  extra_node_pools = [
    {
      name                  = "np1"
      pool_name             = "np1"
      vm_size               = "Standard_DS2_v2"
      node_count            = 1
      enable_auto_scaling   = false
      custom_labels         = { role = "worker" }
    },
    {
      name                  = "np2"
      pool_name             = "np2"
      vm_size               = "Standard_DS3_v2"
      node_count            = 2
      enable_auto_scaling   = false
      custom_labels         = { role = "batch" }
    }
  ]
}
