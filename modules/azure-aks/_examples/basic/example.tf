// Basic example: minimal AKS cluster using the module

module "azure_aks" {
  source = "../../"

  # Core settings (adjust to your environment)
  location                 = "westeurope"
  resource_group_name      = "example-rg"
  vnet_name                = "example-vnet"
  vnet_resource_group_name = "example-rg"
  subnet_name              = "example-subnet"

  # AKS cluster configuration (minimal)
  aks_prefix             = "example"
  aks_kubernetes_version = "1.28.3"

  aks_agents_count         = 2
  aks_agents_size          = "Standard_DS2_v2"
  aks_agents_pool_name     = "default"
  aks_agents_max_pods      = 30
  aks_agents_pool_max_surge = "33%"

  aks_sku_tier        = "Free"
  aks_network_plugin  = "azure"
  aks_network_policy  = "azure"
  aks_orchestrator_version = "1.28.3"
  aks_os_disk_size_gb = 30

  oidc_issuer_enabled        = true
  workload_identity_enabled  = true
  key_vault_secrets_provider_enabled = true
  secret_rotation_enabled    = false

  # Optional: use an existing Public IP for the AKS load balancer
  public_ip_name = "example-public-ip"

  tags = {
    environment = "dev"
    application = "example"
  }
}

