# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_vault
resource "azurerm_data_protection_backup_vault" "mysql" {
  count               = var.backup_mysql_flexible != null ? 1 : 0
  name                = var.backup_mysql_flexible.vault_name
  resource_group_name = data.azurerm_resource_group.name
  location            = data.azurerm_resource_group.resource_group.location
  datastore_type      = var.backup_mysql_flexible.datastore_type
  redundancy          = var.backup_mysql_flexible.redundancy
  tags                = local.tags

  identity {
    type = "SystemAssigned"
    }

  lifecycle {
    ignore_changes = [tags]
  }
}

# Postgresql flexible server instance backup
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_instance_postgresql_flexible_server
resource "azurerm_data_protection_backup_instance_postgresql_flexible_server" "this" {
  count = var.backup_mysql_flexible.vault_name != null ? 1 : 0
  name = var.backup_mysql_flexible.instance_name
  location = azurerm_resource_group.resource_group.location
  vault_id = azurerm_data_protection_backup_vault.mysql.id
  server_id = var.backup_mysql_flexible.server_id
  backup_policy_id = #Policy module
}


