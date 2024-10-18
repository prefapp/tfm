# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group
data "azurerm_resource_group" "this" {
    name = var.resource_group_name
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_instance_disk
data "azurerm_managed_disk" "this" {
  for_each            = { for instance in var.backup_instances : instance.disk_name => instance }
  name                = each.value.disk_name
  resource_group_name = each.value.disk_resource_group
}
