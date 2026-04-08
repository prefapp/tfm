output "redis_id" {
  description = "Resource ID of the Azure Cache for Redis instance."
  value       = azurerm_redis_cache.this.id
}

output "private_endpoint_id" {
  description = "Resource ID of the private endpoint for the Redis cache."
  value       = azurerm_private_endpoint.this.id
}
