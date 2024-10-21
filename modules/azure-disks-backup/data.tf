# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group
data "azurerm_resource_group" "this" {
    name = var.resource_group_name
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/managed_disk
data "azurerm_managed_disk" "this" {
  for_each            = { for instance in var.backup_instances : instance.disk_name => instance }
  name                = each.value.disk_name
  resource_group_name = each.value.disk_resource_group
}

# Ensure none of the disks have the same resource group as the value of var.resource_group_name
resource "null_resource" "validate_disks" {
  count = length([for instance in var.backup_instances : instance if instance.disk_resource_group == var.resource_group_name])

  provisioner "local-exec" {
    command = "echo 'Validation failed: One or more disks have the same resource group as resource group vault'"
    when    = "create"
  }

  lifecycle {
    create_before_destroy = true
  }
}
