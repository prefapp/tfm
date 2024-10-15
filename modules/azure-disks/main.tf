# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk
resource "azurerm_managed_disk" "disks" {
  for_each             = { for disk in var.disks : disk.name => disk }
  name                 = each.key
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = lookup(each.value, "storage_account_type", "StandardSSD_LRS")
  create_option        = lookup(each.value, "create_option", "Empty")
  disk_size_gb         = lookup(each.value, "disk_size_gb", 4)

  dynamic "source_resource_id" {
    for_each = lookup(each.value, "create_option", "Empty") == "Copy" ? [1] : []
    content {
      source_resource_id = lookup(each.value, "source_resource_id", null)
    }
  }

  lifecycle {
    ignore_changes = [
      tags,
      disk_size_gb
    ]
  }
}


# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
resource "azurerm_role_assignment" "role_assignment_over_managed_disk" {
  count                = var.assign_role ? length(azurerm_managed_disk.disks) : 0
  scope                = element(azurerm_managed_disk.disks.*.id, count.index)
  role_definition_name = lookup(var.disks[count.index], "role_definition_name", "Contributor")
  principal_id         = var.principal_id
}
