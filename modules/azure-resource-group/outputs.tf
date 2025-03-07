output "resource_group_id" {
  value = azurerm_resource_group.resorce_group.id
}

output "resource_group_name" {
  value = azurerm_resource_group.resorce_group.name
}

output "resource_group_tags" {
  value = azurerm_resource_group.rg.tags
}

output "resource_group_location" {
  value = azurerm_resource_group.rg.location
}
