# Event Hub Namespace
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_namespace
locals {
  virtual_network_rules = var.namespace.ruleset.virtual_network_rules != null ? var.namespace.ruleset.virtual_network_rules : []
  ip_rules              = var.namespace.ruleset.ip_rules != null ? var.namespace.ruleset.ip_rules : []
}

resource "azurerm_eventhub_namespace" "this" {
  name                 = var.namespace.name
  location             = var.namespace.location
  resource_group_name  = var.namespace.resource_group_name
  sku                  = var.namespace.sku
  capacity             = var.namespace.capacity
  auto_inflate_enabled = var.namespace.auto_inflate_enabled
  tags                 = var.tags
  identity {
    type = var.namespace.identity_type
  }
  network_rulesets {
    default_action                 = var.namespace.ruleset.default_action
    public_network_access_enabled  = var.namespace.ruleset.public_network_access_enabled
    trusted_service_access_enabled = var.namespace.ruleset.trusted_service_access_enabled
    virtual_network_rule           = var.namespace.ruleset.virtual_network_rules
    ip_rule                        = var.namespace.ruleset.ip_rules
  }
}

# Event Hub
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub
resource "azurerm_eventhub" "this" {
  for_each          = var.eventhub
  name              = each.value.name
  namespace_id      = azurerm_eventhub_namespace.this.id
  partition_count   = each.value.partition_count
  message_retention = each.value.message_retention
}

# Consumer Group
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_consumer_group
resource "azurerm_eventhub_consumer_group" "this" {
  for_each            = var.eventhub
  name                = each.value.consumer_group_name
  namespace_name      = azurerm_eventhub_namespace.this.name
  eventhub_name       = azurerm_eventhub.this[each.key].name
  resource_group_name = var.namespace.resource_group_name
}

# Event Hub Authorization Rule (SAS)
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_authorization_rule
resource "azurerm_eventhub_authorization_rule" "this" {
  for_each            = var.eventhub.auth_rules
  name                = each.value.name
  namespace_name      = azurerm_eventhub_namespace.this.name
  eventhub_name       = azurerm_eventhub.this[each.key].name
  resource_group_name = var.namespace.resource_group_name
  listen              = each.value.listen
  send                = each.value.send
  manage              = each.value.manage
}

# System Topic
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventgrid_system_topic
resource "azurerm_eventgrid_system_topic" "this" {
  for_each            = var.system_topic
  name                = each.value.name
  location            = each.value.location
  resource_group_name = var.namespace.resource_group_name
  source_resource_id  = each.value.source_resource_id
  topic_type          = each.value.topic_type
  tags                = var.tags
  identity {
    type = "SystemAssigned"
  }
}

# Event Subscription for Event Hub (System Topic)
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventgrid_system_topic_event_subscription
resource "azurerm_eventgrid_system_topic_event_subscription" "this" {
  for_each             = var.eventhub
  name                 = each.value.event_subscription.name
  system_topic         = azurerm_eventgrid_system_topic.this[each.value.system_topic_name].name
  resource_group_name  = azurerm_eventgrid_system_topic.this[each.value.system_topic_name].resource_group_name
  eventhub_endpoint_id = azurerm_eventhub.this[each.key].id
  included_event_types = each.value.event_subscription.included_event_types
  delivery_identity {
    type = "SystemAssigned"
  }
  retry_policy {
    event_time_to_live    = each.value.event_subscription.retry_ttl
    max_delivery_attempts = each.value.event_subscription.max_attempts
  }
  depends_on = [
    azurerm_eventhub.this,
    azurerm_eventgrid_system_topic.this
  ]
}

# Role Assignment for Event Grid -> Event Hub
resource "azurerm_role_assignment" "this" {
  for_each             = var.eventhub
  scope                = azurerm_eventhub.this[each.key].id
  role_definition_name = "Azure Event Hubs Data Sender"
  principal_id         = try(azurerm_eventgrid_system_topic.this[each.value.system_topic_name].identity[0].principal_id, null)
  depends_on = [
    azurerm_eventgrid_system_topic.this
  ]
}
