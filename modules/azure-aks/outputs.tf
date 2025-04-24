# Outputs section

# AKS section
output "aks_id" {
  value = module.aks.aks_id
}

output "aks_name" {
  value = module.aks.aks_name
}

output "cluster_fqdn" {
  value = module.aks.cluster_fqdn
}

output "cluster_identity" {
  value = module.aks.cluster_identity
}

output "cluster_issuer" {
  value = module.aks.oidc_issuer_url
}

output "kubelet_identity_client_id" {
  value = module.aks.kubelet_identity[0].client_id
}

output "network_profile" {
  value = module.aks.network_profile
}

output "node_resource_group" {
  value = module.aks.node_resource_group
}

output "oidc_issuer_url" {
  value = module.aks.oidc_issuer_url
}

output "outbound_ip_address" {
  value = data.azurerm_public_ip.aks_public_ip.id
}

# Data section
output "subnet_id" {
  value = data.azurerm_subnet.aks_subnet.id
}

output "vnet" {
  value = data.azurerm_subnet.aks_subnet.virtual_network_name
}
