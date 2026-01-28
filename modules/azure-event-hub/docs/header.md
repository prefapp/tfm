# Azure Event Hub Terraform Module

## Overview

This Terraform module allows you to create and manage a complete Azure Event Hub environment, including:
- Namespace, Event Hubs, authorization rules, and consumer groups.
- Integration with Event Grid System Topics and subscriptions.
- Advanced network, security, and scalability configuration.
- Flexible tagging and tag inheritance from the Resource Group.

## Main features
- Create namespaces and multiple Event Hubs with custom configuration.
- Support for authorization rules, consumer groups, and event subscriptions.
- Integration with Event Grid System Topics.
- Network rules configuration (IP, VNet, public access, etc).

## Complete usage example

```yaml
values:
  tags_from_rg: true
  tags:
    extra_tag: "example"
  namespace:
    name: "example-namespace"
    location: "westeurope"
    resource_group_name: "example-resource-group"
    sku: "Standard"
    capacity: 1
    auto_inflate_enabled: false
    identity_type: "SystemAssigned"
    ruleset:
      default_action: "Deny"
      public_network_access_enabled: true
      trusted_service_access_enabled: true
      ip_rules:
        - ip_mask: "10.0.0.1"
          action: "Allow"
        - ip_mask: "10.0.0.2"
          action: "Allow"
  system_topic:
    topic-events:
      name: "topic-events"
      location: "global"
      topic_type: "Microsoft.Resources.Subscriptions"
      source_resource_id: "/subscriptions/00000000-0000-0000-0000-000000000000"
  eventhub:
    events-hub:
      name: "events-hub"
      partition_count: 1
      message_retention: 1
      consumer_group_names:
        - "events-subscription"
        - "external-processor"
      auth_rules:
        - name: "external-listen"
          listen: true
          send: false
          manage: false
      event_subscription:
        name: "events-subscription"
        included_event_types:
          - "Microsoft.Resources.ResourceWriteSuccess"
          - "Microsoft.Resources.ResourceWriteFailure"
          - "Microsoft.Resources.ResourceWriteCancel"
          - "Microsoft.Resources.ResourceDeleteSuccess"
          - "Microsoft.Resources.ResourceDeleteFailure"
          - "Microsoft.Resources.ResourceDeleteCancel"
          - "Microsoft.Resources.ResourceActionSuccess"
          - "Microsoft.Resources.ResourceActionFailure"
          - "Microsoft.Resources.ResourceActionCancel"
        retry_ttl: 1440
        max_attempts: 30
      system_topic_name: "topic-events"
    logs-hub:
      name: "logs-hub"
      partition_count: 1
      message_retention: 1
      consumer_group_names:
        - "app-logs"
        - "infra-logs"
      auth_rules:
        - name: "app-fluentbit-agent"
          listen: false
          send: true
          manage: false
```

## File structure

```
.
├── main.tf
├── variables.tf
├── outputs.tf
├── README.md
├── CHANGELOG.md
└── docs/
    ├── header.md
    └── footer.md
```
