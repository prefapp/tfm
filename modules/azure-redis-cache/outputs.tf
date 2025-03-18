output "redis_id" {
  value = azurerm_redis_cache.this.id
}

output "private_endpoint_id" {
    value = azurerm_private_endpoint.this.id
}
