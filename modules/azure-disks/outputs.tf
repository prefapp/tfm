# Output section
output "disk_names" {
  value = [for disk in azurerm_managed_disk.disks : disk.name]
}

output "disk_ids" {
  value = [for disk in azurerm_managed_disk.disks : disk.id]
}
