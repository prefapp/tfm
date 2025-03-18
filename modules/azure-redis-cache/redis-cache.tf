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
  subnet_id                     = var.redis.family == "P" ? try(data.azurerm_subnet.subnet[0].id, null) : null
  tags                          = local.tags
  zones                         = var.redis.zones
  patch_schedule {
    day_of_week     = var.redis.patch_schedule.day_of_week
    start_hour_utc  = var.redis.patch_schedule.start_hour_utc
  }
  dynamic "redis_configuration" {
    for_each = var.redis.family == "P" ? [1] : []

    content {
      aof_backup_enabled              = var.redis.redis_configuration.aof_backup_enabled
      aof_storage_connection_string_0 = var.redis.redis_configuration.aof_storage_connection_string_0
      aof_storage_connection_string_1 = var.redis.redis_configuration.aof_storage_connection_string_1
      authentication_enabled          = var.redis.redis_configuration.authentication_enabled
      active_directory_authentication_enabled = var.redis.redis_configuration.active_directory_authentication_enabled
      maxmemory_reserved = var.redis.redis_configuration.maxmemory_reserved
      maxmemory_delta = var.redis.redis_configuration.maxmemory_delta
      maxmemory_policy = var.redis.redis_configuration.maxmemory_policy
      maxfragmentationmemory_reserved = var.redis.redis_configuration.maxfragmentationmemory_reserved
      rdb_backup_frequency = var.redis.redis_configuration.rdb_backup_frequency
      rdb_backup_max_snapshot_count = var.redis.redis_configuration.rdb_backup_max_snapshot_count
      rdb_storage_connection_string = var.redis.redis_configuration.rdb_storage_connection_string
    }
  }
}
