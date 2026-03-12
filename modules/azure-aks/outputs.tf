# Outputs section

# The ID of the AKS cluster.
# Example: `/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/xxxx-common-predev/providers/Microsoft.ContainerService/managedClusters/xxxx-predev-aks`
output "aks_id" {
  value = module.aks.aks_id
}

# The name of the AKS cluster. Example: `xxxx-predev-aks`
output "aks_name" {
  value = module.aks.aks_name
}

# The FQDN of the AKS cluster. Example: `xxxx-predev-xxxxxxxx.hcp.westeurope.azmk8s.io`
output "cluster_fqdn" {
  value = module.aks.cluster_fqdn
}

# The cluster identity of the AKS cluster. See README for structure.
output "cluster_identity" {
  value = module.aks.cluster_identity
}

# The OIDC issuer URL of the AKS cluster.
output "cluster_issuer" {
  value = module.aks.oidc_issuer_url
}

# The kubelet identity of the AKS cluster. See README for structure.
output "kubelet_identity_client_id" {
  value = module.aks.kubelet_identity[0].client_id
}

# The network profile of the AKS cluster. See README for structure.
output "kubelet_identity_object_id" {
  value = module.aks.kubelet_identity[0].object_id
}

# The node resource group of the AKS cluster.
output "network_profile" {
  value = module.aks.network_profile
}

# The OIDC issuer URL of the AKS cluster.
output "node_resource_group" {
  value = module.aks.node_resource_group
}

# The outbound IP address of the AKS cluster.
output "oidc_issuer_url" {
  value = module.aks.oidc_issuer_url
}

# The outbound IP address of the AKS cluster.
output "outbound_ip_address" {
  value = data.azurerm_public_ip.aks_public_ip.id
}

# The subnet ID of the AKS cluster.
output "subnet_id" {
  value = data.azurerm_subnet.aks_subnet.id
}

# The virtual network name of the AKS cluster.
output "vnet" {
  value = data.azurerm_subnet.aks_subnet.virtual_network_name
}
