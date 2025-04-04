output "resource_group_id" {
  value       = azurerm_resource_group.this.id
}

output "resource_group_name" {
  value       = azurerm_resource_group.this.name
}

output "resource_group_location" {
  value       = azurerm_resource_group.this.location
}

output "resource_group_tags" {
  value       = azurerm_resource_group.this.tags
}
