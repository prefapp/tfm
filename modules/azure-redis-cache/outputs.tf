output "redis_id" {
  description = "Resource ID of the Azure Cache for Redis instance."
  value       = azurerm_redis_cache.this.id
}

output "hostname" {
  description = "Redis hostname for TLS client connections."
  value       = azurerm_redis_cache.this.hostname
}

output "ssl_port" {
  description = "TLS port exposed by the Redis cache."
  value       = azurerm_redis_cache.this.ssl_port
}

output "private_endpoint_id" {
  description = "Resource ID of the private endpoint for the Redis cache."
  value       = azurerm_private_endpoint.this.id
}
