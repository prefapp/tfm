# Output section
output "name" {
  value = azurerm_managed_disk.disks[*].name
}

output "id" {
  value = azurerm_managed_disk.disks[*].id
}
