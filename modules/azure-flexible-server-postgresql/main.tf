# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server
resource "azurerm_postgresql_flexible_server" "this" {
  name                              = var.postgresql_flexible_server.name
  resource_group_name               = data.azurerm_resource_group.resource_group.name
  location                          = var.postgresql_flexible_server.location
  version                           = var.postgresql_flexible_server.version
  public_network_access_enabled     = var.postgresql_flexible_server.public_network_access_enabled
  delegated_subnet_id               = var.postgresql_flexible_server.public_network_access_enabled == false ? try(data.azurerm_subnet.subnet[0].id, null) : null
  private_dns_zone_id               = var.postgresql_flexible_server.public_network_access_enabled == false ? try(data.azurerm_private_dns_zone.dns_private_zone[0].id, null) : null
  administrator_login               = var.postgresql_flexible_server.administrator_login
  administrator_password            = coalesce(var.administrator_password_key_vault_secret_name, data.azurerm_key_vault_secret.administrator_password[0].value)
  zone                              = var.postgresql_flexible_server.zone
  storage_tier                      = var.postgresql_flexible_server.storage_tier
  storage_mb                        = var.postgresql_flexible_server.storage_mb
  sku_name                          = var.postgresql_flexible_server.sku_name
  replication_role                  = var.postgresql_flexible_server.replication_role
  create_mode                       = var.postgresql_flexible_server.create_mode
  source_server_id                  = var.postgresql_flexible_server.source_server_id
  point_in_time_restore_time_in_utc = var.postgresql_flexible_server.point_in_time_restore_time_in_utc
  tags                              = local.tags
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
  lifecycle {
    ignore_changes = [
      version,
      create_mode,
      point_in_time_restore_time_in_utc,
      source_server_id,
      zone
    ]
  }
}

resource "azurerm_postgresql_flexible_server_configuration" "this" {
  for_each  = var.postgresql_flexible_server_configuration
  name      = each.value.name
  server_id = azurerm_postgresql_flexible_server.this.id
  value     = each.value.value
}

resource "random_password" "password" {
  length  = 20
  special = true
}

# Create the Key Vault secret
resource "azurerm_key_vault_secret" "password_create" {
  key_vault_id = data.azurerm_resources.key_vault_from_name.resources.id
  name         = var.administrator_password_key_vault_secret_name
  value        = random_password.password.result
  depends_on = [ random_password.password ]
  lifecycle {
    # Ignore changes to the secret's value to prevent overwriting it after the initial creation
    ignore_changes = [value]
  }
}

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_firewall_rule
resource "azurerm_postgresql_flexible_server_firewall_rule" "this" {
  for_each = { for idx, rule in var.azurerm_postgresql_flexible_server_firewall_rule : idx => rule if rule.name != null }
  server_id        = azurerm_postgresql_flexible_server.this.id
  name             = each.value.name
  start_ip_address = each.value.start_ip_address
  end_ip_address   = each.value.end_ip_address

 }

