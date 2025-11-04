## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.51.0 |

```yaml
values:
  namespace:
    name: "namespace-name"
    location: "westeurope"
    resource_group_name: "resource-group-name"
    sku: "Standard"
    capacity: 1
    auto_inflate_enabled: false
    maximum_throughput_units: 1
    identity_type: "SystemAssigned"
    ruleset:
      default_action: "Deny"
      public_network_access_enabled: false
      trusted_service_access_enabled: false
      ip_rules:
        - ip_mask: "10.0.0.0"
          action: "Allow"
        # ...more rules...
      virtual_network_rules:
        - subnet_id: "subnet-resource-id"
          ignore_missing_virtual_network_service_endpoint: true|false
        # ...more rules...

  system_topic:
    topic1:
      name: "system-topic-name"
      location: "global"
      topic_type: "Microsoft.Resources.Subscriptions"
      source_resource_id: "resource-id"
    # topic2:
    #   name: "system-topic-name"
    #   ...

  eventhub:
    hub1:
      name: "eventhub-name"
      partition_count: 1
      message_retention: 1
      consumer_group_name: "consumer-group-name"
      auth_rule_name: "auth-rule-name"
      auth_rule:
        listen: true
        send: false
        manage: false
      event_subscription:
        name: "subscription-name"
        included_event_types:
          - "Microsoft.Resources.ResourceWriteSuccess"
          - "Microsoft.Resources.ResourceWriteFailure"
          - "Microsoft.Resources.ResourceWriteCancel"
          # ...more types...
        retry_ttl: 1440
        max_attempts: 30
      system_topic_name: "topic1"
    # hub2:
    #   name: "eventhub-name"
    #   ...

  tags:
    env: "environment"
    product: "product"
    client: "client"
    application: "application"
    tenant: "tenant"
```
