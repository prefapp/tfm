output "aks_cluster_name_output" {
  value = var.aks_cluster_name
}

output "aks_cluster_location_output" {
  value = var.aks_location
}

output "aks_cluster_resource_group_name_output" {
  value = var.aks_resource_group_name
}

output "aks_cluster_id_output" {
  value = azurerm_kubernetes_cluster.kubernetes.id
}

output "aks_cluster_kubernetes_version_output" {
  value = var.aks_kubernetes_version
}

output "aks_cluster_azure_policy_enabled_output" {
  value = var.aks_azure_policy_enabled
}

output "aks_cluster_automatic_channel_upgrade_output" {
  value = var.aks_automatic_channel_upgrade
}

output "aks_cluster_sku_tier_output" {
  value = var.aks_sku_tier
}

output "aks_cluster_workload_identity_enabled_output" {
  value = var.aks_workload_identity_enabled
}

output "aks_cluster_oidc_issuer_enabled_output" {
  value = var.aks_oidc_issuer_enabled
}

output "aks_cluster_identity_type_output" {
  value = var.aks_identity_type
}

output "aks_cluster_dns_prefix_output" {
  value = var.aks_aks_dns_prefix
}

output "aks_cluster_network_plugin_output" {
  value = var.aks_network_plugin
}

output "aks_cluster_service_cidr_output" {
  value = var.aks_service_cidr
}

output "aks_cluster_dns_service_ip_output" {
  value = var.aks_dns_service_ip
}

output "aks_cluster_default_node_pool_name_output" {
  value = var.aks_default_node_pool_name
}

output "aks_cluster_default_node_pool_node_count_output" {
  value = var.aks_default_node_pool_node_count
}

output "aks_cluster_default_node_pool_vm_size_output" {
  value = var.aks_default_node_pool_vm_size
}

output "aks_cluster_default_node_pool_os_disk_type_output" {
  value = var.aks_default_node_pool_os_disk_type
}

output "aks_cluster_default_node_pool_os_disk_size_gb_output" {
  value = var.aks_default_node_pool_os_disk_size_gb
}

output "aks_cluster_default_node_pool_max_pods_output" {
  value = var.aks_default_node_pool_max_pods
}

output "aks_cluster_key_vault_secrets_provider_enabled_output" {
  value = var.aks_key_vault_secrets_provider_enabled
}

output "aks_cluster_key_vault_secrets_provider_interval_output" {
  value = var.aks_key_vault_secrets_provider_interval
}

output "aks_cluster_tags_output" {
  value = var.aks_tags
}

output "aks_cluster_node_pool_additionals_output" {
  value = var.node_pool_additionals
}

output "aks_cluster_subnet_name_output" {
  value = var.aks_subnet_name
}

output "aks_cluster_vnet_name_output" {
  value = var.aks_vnet_name
}

output "aks_cluster_vnet_name_resource_group_output" {
  value = var.aks_vnet_name_resource_group
}

output "aks_cluster_subnet_id_output" {
  value = data.azurerm_subnet.aks_subnet.id
}
