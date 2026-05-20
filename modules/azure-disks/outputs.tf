output "disk_names" {
  description = "Names of created managed disks."
  value       = [for disk in azurerm_managed_disk.disks : disk.name]
}

output "disk_ids" {
  description = "Resource IDs of created managed disks."
  value       = [for disk in azurerm_managed_disk.disks : disk.id]
}
