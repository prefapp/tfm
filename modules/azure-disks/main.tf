# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk
resource "azurerm_managed_disk" "disks" {
  for_each             = var.disks
  name                 = each.key
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = each.value.storage_account_type
  create_option        = lookup(each.value, "create_option", "Empty")
  disk_size_gb         = 4
  lifecycle {
    ignore_changes = [
      tags,
      disk_size_gb
    ]
  }
}
