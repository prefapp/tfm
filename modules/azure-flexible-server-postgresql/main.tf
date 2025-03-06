locals {
  tags = var.tags_from_rg ? data.azurerm_resource_group.resource_group.tags : var.tags
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server
resource "azurerm_postgresql_flexible_server" "this" {
  name                   = var.postgresql_flexible_server.name
  resource_group_name    = data.azurerm_resource_group.name
  location               = var.postgresql_flexible_server.location
  version                = var.postgresql_flexible_server.version
  delegated_subnet_id    = data.azurerm_subnet.subnet.id
  private_dns_zone_id    = data.azurerm_private_dns_zone.dns_private_zone.id
  administrator_login    = var.postgresql_flexible_server.administrator_login
  administrator_password = coalesce(var.admin_password, data.azurerm_key_vault_secret.administrator_password.value)
  zone                   = var.postgresql_flexible_server.zone
  storage_tier           = var.postgresql_flexible_server.storage_tier
  storage_mb             = var.postgresql_flexible_server.storage_mb
  sku_name               = var.postgresql_flexible_server.sku_name
  replication_role       = var.postgresql_flexible_server.replication_role
  create_mode            = var.postgresql_flexible_server.create_mode
  tags                   = local.tags
  maintenance_window {
    day_of_week  = var.postgresql_flexible_server.maintenance_window.day_of_week
    start_hour   = var.postgresql_flexible_server.maintenance_window.start_hour
    start_minute = var.postgresql_flexible_server.maintenance_window.start_minute
  }
  authentication {
    active_directory_auth_enabled = var.postgresql_flexible_server.authentication.active_directory_auth_enabled
    password_auth_enabled         = var.postgresql_flexible_server.authentication.password_auth_enabled
    tenant_id                     = var.postgresql_flexible_server.authentication.tenant_id
  }
}

resource "azurerm_postgresql_flexible_server_configuration" "this" {
  for_each  = var.postgresql_flexible_server_configuration
  name      = each.value.name
  server_id = azurerm_postgresql_flexible_server.this.id
  value     = each.value.value
}
