# AKS section
module "aks" {
  # https://registry.terraform.io/modules/Azure/aks/azurerm/latest
  source = "github.com/Azure/terraform-azurerm-aks?ref=9.1.0"

  prefix                                               = var.aks_prefix
  resource_group_name                                  = var.resource_group_name
  kubernetes_version                                   = var.aks_kubernetes_version
  orchestrator_version                                 = var.aks_orchestrator_version
  agents_max_pods                                      = var.aks_agents_max_pods
  agents_count                                         = var.aks_agents_count
  agents_size                                          = var.aks_agents_size
  agents_pool_name                                     = var.aks_agents_pool_name
  agents_labels                                        = var.aks_default_pool_custom_labels
  node_os_channel_upgrade                              = var.node_os_channel_upgrade
  temporary_name_for_rotation                          = var.temporary_name_for_rotation
  attached_acr_id_map                                  = var.acr_map
  network_plugin                                       = var.aks_network_plugin
  network_policy                                       = var.aks_network_policy
  load_balancer_profile_enabled                        = var.load_balancer_profile_enabled
  load_balancer_sku                                    = var.load_balancer_sku
  load_balancer_profile_outbound_ip_address_ids        = [data.azurerm_public_ip.aks_public_ip.id]
  os_disk_size_gb                                      = var.aks_os_disk_size_gb
  agents_pool_max_surge                                = var.aks_agents_pool_max_surge
  agents_pool_drain_timeout_in_minutes                 = var.aks_agents_pool_drain_timeout_in_minutes
  sku_tier                                             = var.aks_sku_tier
  rbac_aad_azure_rbac_enabled                          = true
  rbac_aad_managed                                     = true
  role_based_access_control_enabled                    = true
  api_server_authorized_ip_ranges                      = var.api_server_authorized_ip_ranges
  vnet_subnet_id                                       = data.azurerm_subnet.aks_subnet.id
  oidc_issuer_enabled                                  = var.oidc_issuer_enabled
  workload_identity_enabled                            = var.workload_identity_enabled
  key_vault_secrets_provider_enabled                   = var.key_vault_secrets_provider_enabled
  secret_rotation_enabled                              = var.secret_rotation_enabled
  secret_rotation_interval                             = var.secret_rotation_interval
  network_contributor_role_assigned_subnet_ids         = { aks_subnet = data.azurerm_subnet.aks_subnet.id }
  log_analytics_workspace_enabled                      = false
  node_pools                                           = local.extra_pools
  auto_scaler_profile_enabled                          = var.auto_scaler_profile_enabled
  auto_scaler_profile_expander                         = var.auto_scaler_profile_expander
  auto_scaler_profile_max_graceful_termination_sec     = var.auto_scaler_profile_max_graceful_termination_sec
  auto_scaler_profile_max_node_provisioning_time       = var.auto_scaler_profile_max_node_provisioning_time
  auto_scaler_profile_max_unready_nodes                = var.auto_scaler_profile_max_unready_nodes
  auto_scaler_profile_max_unready_percentage           = var.auto_scaler_profile_max_unready_percentage
  auto_scaler_profile_new_pod_scale_up_delay           = var.auto_scaler_profile_new_pod_scale_up_delay
  auto_scaler_profile_scale_down_delay_after_add       = var.auto_scaler_profile_scale_down_delay_after_add
  auto_scaler_profile_scale_down_delay_after_delete    = var.auto_scaler_profile_scale_down_delay_after_delete
  auto_scaler_profile_scale_down_delay_after_failure   = var.auto_scaler_profile_scale_down_delay_after_failure
  auto_scaler_profile_scale_down_unneeded              = var.auto_scaler_profile_scale_down_unneeded
  auto_scaler_profile_scale_down_unready               = var.auto_scaler_profile_scale_down_unready
  auto_scaler_profile_scale_down_utilization_threshold = var.auto_scaler_profile_scale_down_utilization_threshold
  auto_scaler_profile_scan_interval                    = var.auto_scaler_profile_scan_interval
  auto_scaler_profile_skip_nodes_with_local_storage    = var.auto_scaler_profile_skip_nodes_with_local_storage
  auto_scaler_profile_skip_nodes_with_system_pods      = var.auto_scaler_profile_skip_nodes_with_system_pods
  tags                                                 = var.tags
}
