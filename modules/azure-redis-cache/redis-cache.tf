#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/redis_cache
resource "azurerm_redis_cache" "this" {
  name                          = var.redis.name
  location                      = var.redis.location
  resource_group_name           = data.azurerm_resource_group.resource_group.name
  capacity                      = var.redis.capacity
  family                        = var.redis.family
  sku_name                      = var.redis.sku_name
  non_ssl_port_enabled          = var.redis.non_ssl_port_enabled
  minimum_tls_version           = var.redis.minimum_tls_version
  redis_version                 = var.redis.redis_version
  public_network_access_enabled = var.redis.public_network_access_enabled
  tags                          = local.tags
  zones                         = var.redis.zones
  subnet_id                     = var.redis.family == "P" ? try(data.azurerm_subnet.subnet[0].id, null) : null
  patch_schedule {
    day_of_week     = var.redis.patch_schedule.day_of_week
    start_hour_utc  = var.redis.patch_schedule.start_hour_utc
  }
  redis_configuration {
    aof_backup_enabled              = var.redis.family == "P" ? var.redis.redis_configuration.aof_backup_enabled : false
    aof_storage_connection_string_0 = var.redis.family == "P" ? var.redis.redis_configuration.aof_storage_connection_string_0 : null
    aof_storage_connection_string_1 = var.redis.family == "P" ? var.redis.redis_configuration.aof_storage_connection_string_1 : null
    authentication_enabled          = var.redis.family == "P" ? var.redis.redis_configuration.authentication_enabled : false
  }
}

