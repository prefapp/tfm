data "azurerm_postgresql_flexible_server" "postgresql_restore_original_server" {
  count               = local.data.server_creation.mode == "PointInTimeRestore" ? 1 : 0
  name                = local.data.server_creation.from_pitr.source_server_name
  resource_group_name = local.data.server_creation.from_pitr.source_server_resource_group
}

resource "azurerm_postgresql_flexible_server" "postgresql_flexible_server" {
  name                              = local.data.server.name
  resource_group_name               = local.data.resource_group.name
  location                          = var.location
  version                           = local.data.server.version
  delegated_subnet_id               = local.subnet_id
  private_dns_zone_id               = data.azurerm_private_dns_zone.private_dns_zone.id
  backup_retention_days             = local.data.backup_retention_days
  create_mode                       = lookup(local.data.server_creation, "mode", null)
  point_in_time_restore_time_in_utc = local.data.server_creation.mode == "PointInTimeRestore" ? local.data.server_creation.from_pitr.pitr : null
  source_server_id                  = local.data.server_creation.mode == "PointInTimeRestore" ? data.azurerm_postgresql_flexible_server.postgresql_restore_original_server[0].id : null
  authentication {
    active_directory_auth_enabled = local.data.authentication.active_directory_auth_enabled
    password_auth_enabled         = local.data.authentication.password_auth_enabled
  }
  maintenance_window {
    day_of_week  = local.data.maintainance_window.day_of_week
    start_hour   = local.data.maintainance_window.start_hour
    start_minute = local.data.maintainance_window.start_minute
  }
  administrator_login    = local.data.administrator_login
  administrator_password = data.azurerm_key_vault_secret.password.value
  zone                   = lookup(local.data.server, "zone", null)
  storage_mb             = local.data.server.disk_size
  sku_name               = local.data.server.sku_name
  replication_role       = lookup(local.data.server, "replication_role", "None")
  tags                   = local.data.server.tags
  depends_on = [
    azurerm_key_vault_secret.password_create
  ]
  lifecycle {
    ignore_changes = [
      version
    ]
  }
}

resource "azurerm_postgresql_flexible_server_configuration" "postgresql_flexible_server_conf" {
  count     = length(local.data.server_parameters.azure_extensions) > 0 ? 1 : 0
  name      = "azure.extensions"
  server_id = azurerm_postgresql_flexible_server.postgresql_flexible_server.id
  value     = join(",", local.data.server_parameters.azure_extensions)
}