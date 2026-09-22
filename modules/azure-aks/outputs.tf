# Outputs section

# The ID of the AKS cluster.
# Example: `/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/xxxx-common-predev/providers/Microsoft.ContainerService/managedClusters/xxxx-predev-aks`
output "aks_id" {
  value = module.aks.resource_id
}

# The name of the AKS cluster. Example: `xxxx-predev-aks`
output "aks_name" {
  value = module.aks.name
}

# The FQDN of the AKS cluster. Example: `xxxx-predev-xxxxxxxx.hcp.westeurope.azmk8s.io`
output "cluster_fqdn" {
  value = module.aks.fqdn
}

# The cluster identity of the AKS cluster. See README for structure.
output "cluster_identity" {
  value = {
    principal_id = module.aks.identity_principal_id
    tenant_id    = module.aks.identity_tenant_id
  }
}

# The OIDC issuer URL of the AKS cluster.
output "cluster_issuer" {
  value = module.aks.oidc_issuer_profile_issuer_url
}

# The kubelet identity client ID of the AKS cluster.
output "kubelet_identity_client_id" {
  value = module.aks.kubelet_identity.clientId
}

# The kubelet identity object ID of the AKS cluster.
output "kubelet_identity_object_id" {
  value = module.aks.kubelet_identity.objectId
}

# The network profile of the AKS cluster. See README for structure.
output "network_profile" {
  value = {
    outbound_type                        = var.net_profile_outbound_type
    load_balancer_effective_outbound_ips = module.aks.network_profile_load_balancer_profile_effective_outbound_ips
    nat_gateway_effective_outbound_ips   = module.aks.network_profile_nat_gateway_profile_effective_outbound_ips
  }
}

# The node resource group of the AKS cluster.
output "node_resource_group" {
  value = module.aks.node_resource_group_name
}

# The OIDC issuer URL of the AKS cluster.
output "oidc_issuer_url" {
  value = module.aks.oidc_issuer_profile_issuer_url
}

# The outbound IP address of the AKS cluster.
output "outbound_ip_address" {
  value = try(data.azurerm_public_ip.aks_public_ip[0].ip_address, null)
}

# The outbound public IP resource ID of the AKS cluster.
output "outbound_public_ip_id" {
  value = try(data.azurerm_public_ip.aks_public_ip[0].id, null)
}

# The subnet ID of the AKS cluster.
output "subnet_id" {
  value = data.azurerm_subnet.aks_subnet.id
}

# The virtual network name of the AKS cluster.
output "vnet" {
  value = data.azurerm_subnet.aks_subnet.virtual_network_name
}

