output "eventhub_namespace_id" {
  description = "Resource ID of the Event Hubs namespace."
  value       = azurerm_eventhub_namespace.this.id
}

output "eventhub_namespace_name" {
  description = "Name of the Event Hubs namespace."
  value       = azurerm_eventhub_namespace.this.name
}

output "eventhub_namespace_fqdn" {
  description = "FQDN for clients (AMQP/Kafka) in the form `<namespace>.servicebus.windows.net`."
  value       = "${azurerm_eventhub_namespace.this.name}.servicebus.windows.net"
}

output "eventhub_namespace_principal_id" {
  description = "Principal ID of the namespace managed identity when Azure exposes it (e.g. SystemAssigned)."
  value       = try(azurerm_eventhub_namespace.this.identity[0].principal_id, null)
}

output "eventhub_id" {
  description = "Map of event hub keys to their Azure resource IDs."
  value       = { for k, v in azurerm_eventhub.this : k => v.id }
}

output "eventhub_name" {
  description = "Map of event hub keys to hub names in Azure."
  value       = { for k, v in azurerm_eventhub.this : k => v.name }
}

output "consumer_group_id" {
  description = "Map of consumer group keys (`<eventhub_key>.<consumer_group_name>`) to resource IDs."
  value       = { for k, v in azurerm_eventhub_consumer_group.this : k => v.id }
}

output "authorization_rule_primary_connection_string" {
  description = "Map of authorization rule keys (`<eventhub_key>.<rule_name>`) to primary connection strings."
  value       = { for k, v in azurerm_eventhub_authorization_rule.this : k => v.primary_connection_string }
  sensitive   = true
}

output "eventgrid_system_topic_id" {
  description = "Map of system topic keys (from `system_topic`) to resource IDs."
  value       = { for k, v in azurerm_eventgrid_system_topic.this : k => v.id }
}

output "eventgrid_system_topic_principal_id" {
  description = "Map of system topic keys to the principal ID of the topic system-assigned identity."
  value       = { for k, v in azurerm_eventgrid_system_topic.this : k => try(v.identity[0].principal_id, null) }
}

output "eventgrid_event_subscription_id" {
  description = "Map of event hub keys (where an Event Grid subscription is configured) to subscription resource IDs."
  value       = { for k, v in azurerm_eventgrid_system_topic_event_subscription.this : k => v.id }
}

output "eventgrid_to_eventhub_role_assignment_id" {
  description = "Map of event hub keys to role assignment IDs granting the Event Grid topic identity send access to the hub."
  value       = { for k, v in azurerm_role_assignment.this : k => v.id }
}
