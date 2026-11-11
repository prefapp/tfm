output "managed_redis_id" {
  description = "Resource ID of the Azure Managed Redis instance."
  value       = azurerm_managed_redis.this.id
}

output "hostname" {
  description = "DNS hostname of the Managed Redis cluster endpoint."
  value       = azurerm_managed_redis.this.hostname
}

output "default_database_id" {
  description = "Resource ID of the default Managed Redis database."
  value       = azurerm_managed_redis.this.default_database[0].id
}

output "default_database_port" {
  description = "TCP port of the default Managed Redis database endpoint."
  value       = azurerm_managed_redis.this.default_database[0].port
}

output "primary_access_key" {
  description = "Primary access key for the Managed Redis default database. Only populated when access_keys_authentication_enabled = true."
  value       = azurerm_managed_redis.this.default_database[0].primary_access_key
  sensitive   = true
}

output "secondary_access_key" {
  description = "Secondary access key for the Managed Redis default database. Only populated when access_keys_authentication_enabled = true."
  value       = azurerm_managed_redis.this.default_database[0].secondary_access_key
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

output "access_policy_assignment_ids" {
  description = "Map of access policy assignment IDs keyed by the index of the input list."
  value       = { for k, v in azurerm_managed_redis_access_policy_assignment.this : k => v.id }
}
