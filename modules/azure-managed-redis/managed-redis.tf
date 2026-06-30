# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_redis
resource "azurerm_managed_redis" "this" {
  name                      = var.managed_redis.name
  resource_group_name       = data.azurerm_resource_group.resource_group.name
  location                  = var.managed_redis.location
  sku_name                  = var.managed_redis.sku_name
  high_availability_enabled = var.managed_redis.high_availability_enabled
  public_network_access     = var.managed_redis.public_network_access
  tags                      = local.tags

  dynamic "identity" {
    for_each = var.managed_redis.identity != null ? [var.managed_redis.identity] : []
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  dynamic "customer_managed_key" {
    for_each = var.managed_redis.customer_managed_key != null ? [var.managed_redis.customer_managed_key] : []
    content {
      key_vault_key_id          = customer_managed_key.value.key_vault_key_id
      user_assigned_identity_id = customer_managed_key.value.user_assigned_identity_id
    }
  }

  default_database {
    access_keys_authentication_enabled            = var.managed_redis.default_database.access_keys_authentication_enabled
    client_protocol                               = var.managed_redis.default_database.client_protocol
    clustering_policy                             = var.managed_redis.default_database.clustering_policy
    eviction_policy                               = var.managed_redis.default_database.eviction_policy
    geo_replication_group_name                    = var.managed_redis.default_database.geo_replication_group_name
    persistence_append_only_file_backup_frequency = var.managed_redis.default_database.persistence_append_only_file_backup_frequency
    persistence_redis_database_backup_frequency   = var.managed_redis.default_database.persistence_redis_database_backup_frequency

    dynamic "module" {
      for_each = var.managed_redis.default_database.modules
      iterator = redis_module
      content {
        name = redis_module.value.name
        args = redis_module.value.args
      }
    }
  }
}
