# Outputs section
# Data section
output "vnet" {
  value = data.azurerm_subnet.aks_subnet.virtual_network_name
}

output "subnet_id" {
  value = data.azurerm_subnet.aks_subnet.id
}

# AKS section
output "aks_id" {
  value = module.aks.aks_id
}

output "aks_name" {
  value = module.aks.aks_name
}

output "outbound_ip_address" {
  value = data.azurerm_public_ip.aks_public_ip.id
}

output "cluster_issuer" {
  value = module.aks.oidc_issuer_url
}

output "oidc_issuer_url" {
  value = module.aks.oidc_issuer_url
}

output "node_resource_group" {
  value = module.aks.node_resource_group
}

output "network_profile" {
  value = module.aks.network_profile
}

output "kubelet_identity" {
  value = module.aks.kubelet_identity
}

output "host" {
  value = module.aks.host
}

output "cluster_identity" {
  value = module.aks.cluster_identity
}

output "cluster_fqdn" {
  value = module.aks.cluster_fqdn
}
