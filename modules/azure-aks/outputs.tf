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

output "foo" {
  value = azurerm_kubernetes_cluster.main.network_profile
}
