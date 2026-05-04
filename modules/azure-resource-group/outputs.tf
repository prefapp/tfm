output "resource_group_id" {
  description = "Resource ID of the created resource group."
  value       = azurerm_resource_group.this.id
}

output "resource_group_name" {
  description = "Name of the created resource group."
  value       = azurerm_resource_group.this.name
}

output "resource_group_location" {
  description = "Azure region of the resource group."
  value       = azurerm_resource_group.this.location
}

output "resource_group_tags" {
  description = "Tags applied to the resource group."
  value       = azurerm_resource_group.this.tags
}
