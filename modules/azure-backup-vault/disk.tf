# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_vault
resource "azurerm_data_protection_backup_vault" "disk" {
  count               = var.backup_disk != null ? 1 : 0
  name                = var.backup_disk.vault_name
  resource_group_name = data.azurerm_resource_group.name
  location            = data.azurerm_resource_group.resource_group.location
  datastore_type      = var.backup_disk.datastore_type
  redundancy          = var.backup_disk.redundancy
  tags                = local.tags
  identity {
    type = "SystemAssigned"
    }

  lifecycle {
    ignore_changes = [tags]
  }
}

# Disk instance backup
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_instance_disk
resource "azurerm_data_protection_backup_instance_disk" "this" {
  for_each = {
    for instance in var.backup_disk : instance.disk_name => instance
  }

  name                         = each.key
  location                     = data.azurerm_resource_group.this.location
  vault_id                     = azurerm_data_protection_backup_vault.this.id
  disk_id                      = data.azurerm_managed_disk.this[each.key].id
  snapshot_resource_group_name = data.azurerm_resource_group.resource_group.name
  backup_policy_id             = azurerm_data_protection_backup_policy_disk.this[each.value.backup_policy_name].id

  depends_on = [
    azurerm_role_assignment.this_rg,
    azurerm_role_assignment.this_disk
  ]
}

