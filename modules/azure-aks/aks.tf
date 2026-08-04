# AKS section
module "aks" {
  # https://registry.terraform.io/modules/Azure/avm-res-containerservice-managedcluster/azurerm/latest
  source = "github.com/Azure/terraform-azurerm-avm-res-containerservice-managedcluster?ref=v0.7.1"

  location                                             = var.location

  default_agent_pool                                   = local.default_agent_pool

  api_server_access_profile = var.api_server_authorized_ip_ranges == null ? null : {
  authorized_ip_ranges = var.api_server_authorized_ip_ranges
  }

  auto_scaler_profile                                  = local.auto_scaler_profile

  addon_profile_key_vault_secrets_provider = var.key_vault_secrets_provider_enabled ? {
    enabled = true

    config = {
      enable_secret_rotation = var.secret_rotation_enabled
      rotation_poll_interval = var.secret_rotation_interval
    }
  } : null

  kubernetes_version                                   = var.aks_kubernetes_version

  auto_upgrade_profile = {
    node_os_upgrade_channel = var.auto_upgrade_profile.node_os_channel_upgrade
    upgrade_channel         = var.auto_upgrade_profile.upgrade_channel
  }

  agent_pools                                          = local.agent_pools

  oidc_issuer_profile = {
    enabled = var.oidc_issuer_enabled
  }

  security_profile = {
    workload_identity = {
      enabled = var.workload_identity_enabled
    }
  }

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

  sku = {
    tier = var.aks_sku_tier
  }

  tags                                                 = local.tags
}
