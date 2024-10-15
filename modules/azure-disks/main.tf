# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk
resource "azurerm_managed_disk" "disks" {
  for_each             = { for disk in var.disks : disk.name => disk }
  name                 = each.key
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = lookup(each.value, "storage_account_type", "StandardSSD_LRS")
  create_option        = lookup(each.value, "create_option", "Empty")
  source_resource_id   = lookup(each.value, "source_resource_id", null)
  disk_size_gb         = lookup(each.value, "disk_size_gb", 4)

  lifecycle {
    ignore_changes = [
      tags,
      disk_size_gb
    ]
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
resource "azurerm_role_assignment" "role_assignment_over_managed_disk" {
  for_each             = var.assign_role ? azurerm_managed_disk.disks : {}
  scope                = each.value.id
  role_definition_name = lookup(each.value, "role_definition_name", "Contributor")
  principal_id         = var.principal_id
}
