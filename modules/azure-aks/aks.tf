# AKS section
module "aks" {
  # https://registry.terraform.io/modules/Azure/avm-res-containerservice-managedcluster/azurerm/latest
  source = "github.com/Azure/terraform-azurerm-avm-res-containerservice-managedcluster?ref=v0.7.1"

  location                                             = var.location
  default_agent_pool                                   = local.default_agent_pool
  api_server_authorized_ip_ranges                      = var.api_server_authorized_ip_ranges
  auto_scaler_profile                                  = local.auto_scaler_profile
  key_vault_secrets_provider_enabled                   = var.key_vault_secrets_provider_enabled
  kubernetes_version                                   = var.aks_kubernetes_version
  network_contributor_role_assigned_subnet_ids         = { aks_subnet = data.azurerm_subnet.aks_subnet.id }
  node_os_channel_upgrade                              = var.node_os_channel_upgrade
  agent_pools                                          = local.agent_pools
  oidc_issuer_enabled                                  = var.oidc_issuer_enabled
  orchestrator_version                                 = var.aks_orchestrator_version
  name                                                 = var.aks_prefix

  aad_profile = {
    managed           = true
    enable_azure_rbac = true
    tenant_id         = data.azurerm_client_config.current.tenant_id
  }

  network_profile = {
    network_plugin   = var.aks_network_plugin
    network_policy   = var.aks_network_policy

    load_balancer_sku = var.load_balancer_sku

    outbound_type = var.net_profile_outbound_type

    load_balancer_profile = (
      var.net_profile_outbound_type == "loadBalancer" &&
      var.load_balancer_profile_enabled
    ) ? {
      outbound_ip_address_ids = length(data.azurerm_public_ip.aks_public_ip) > 0 ? [
        data.azurerm_public_ip.aks_public_ip[0].id
      ] : null
    } : null
  }

  key_vault_secrets_provider = {
    secret_rotation_enabled  = var.secret_rotation_enabled
    secret_rotation_interval = var.secret_rotation_interval
  }

  parent_id                                            = data.azurerm_resource_group.this.id
  sku_tier                                             = var.aks_sku_tier
  tags                                                 = local.tags
  upgrade_override                                     = var.upgrade_override
  workload_identity_enabled                            = var.workload_identity_enabled
}
