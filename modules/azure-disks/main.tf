resource "azurerm_managed_disk" "disks" {
  for_each             = { for disk in var.disks : disk.name => disk }
  name                 = each.key
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = lookup(each.value, "storage_account_type", "Standard_LRS")
  create_option        = lookup(each.value, "create_option", "Empty")
  disk_size_gb         = lookup(each.value, "disk_size_gb", 4)

  lifecycle {
    ignore_changes = [
      tags,
      disk_size_gb
    ]
  }
}
