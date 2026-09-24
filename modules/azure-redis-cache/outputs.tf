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

output "port" {
  description = "Non-SSL port of the Redis cache."
  value       = azurerm_redis_cache.this.port
}

output "redis_connection" {
  description = "Connection information for Redis."
  value = {
    hostname = azurerm_redis_cache.this.hostname
    ssl_port = azurerm_redis_cache.this.ssl_port
    port     = azurerm_redis_cache.this.port
  }
}

output "primary_access_key" {
  description = "Primary access key for the Redis cache."
  value       = azurerm_redis_cache.this.primary_access_key
  sensitive   = true
}

output "secondary_access_key" {
  description = "Secondary access key for the Redis cache."
  value       = azurerm_redis_cache.this.secondary_access_key
  sensitive   = true
}

output "private_endpoint_ids" {
  description = "Map of private endpoint resource IDs, keyed by the private_endpoints map key. Empty when no private endpoints were requested."
  value       = { for k, v in azurerm_private_endpoint.this : k => v.id }
}

output "private_endpoint_private_ips" {
  description = "Map of private IP addresses assigned to each private endpoint NIC, keyed by the private_endpoints map key. Empty when no private endpoints were requested."
  value       = { for k, v in azurerm_private_endpoint.this : k => v.private_service_connection[0].private_ip_address }
}
