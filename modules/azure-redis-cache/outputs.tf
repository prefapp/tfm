output "redis_basic_id" {
  value = azurerm_redis_cache.basic_config.id
}

output "redis_premium_id" {
  value = azurerm_redis_cache.premium_config[0].id
}

output "private_endpoint_id" {
    value = azurerm_private_endpoint.this.id
}
