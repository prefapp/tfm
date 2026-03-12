## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.51.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.51.0 |


## Resources

| Name | Type |
|------|------|
| [azurerm_eventgrid_system_topic.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventgrid_system_topic) | resource |
| [azurerm_eventgrid_system_topic_event_subscription.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventgrid_system_topic_event_subscription) | resource |
| [azurerm_eventhub.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub) | resource |
| [azurerm_eventhub_authorization_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_authorization_rule) | resource |
| [azurerm_eventhub_consumer_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_consumer_group) | resource |
| [azurerm_eventhub_namespace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_namespace) | resource |
| [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_eventhub"></a> [eventhub](#input\_eventhub) | n/a | <pre>map(object({<br/>    name                = string<br/>    partition_count     = number<br/>    message_retention   = number<br/>    consumer_group_names = list(string)<br/>    auth_rules = list(object({<br/>      name   = string<br/>      listen = bool<br/>      send   = bool<br/>      manage = bool<br/>    }))<br/>    event_subscription = optional(object({<br/>      name                 = string<br/>      included_event_types = list(string)<br/>      retry_ttl            = number<br/>      max_attempts         = number<br/>    }))<br/>    system_topic_name = optional(string)<br/>  }))</pre> | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | n/a | <pre>object({<br/>    name                 = string<br/>    location             = string<br/>    resource_group_name  = string<br/>    sku                  = string<br/>    capacity             = number<br/>    auto_inflate_enabled = bool<br/>    identity_type        = string<br/>    ruleset = object({<br/>      default_action                 = string<br/>      public_network_access_enabled  = bool<br/>      trusted_service_access_enabled = bool<br/>      virtual_network_rules = optional(list(object({<br/>        subnet_id                                       = string<br/>        ignore_missing_virtual_network_service_endpoint = optional(bool)<br/>      })), [])<br/>      ip_rules = optional(list(object({<br/>        ip_mask = string<br/>        action  = string<br/>      })), [])<br/>    })<br/>  })</pre> | n/a | yes |
| <a name="input_system_topic"></a> [system\_topic](#input\_system\_topic) | n/a | <pre>map(object({<br/>    name               = string<br/>    location           = string<br/>    topic_type         = string<br/>    source_resource_id = string<br/>  }))</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_tags_from_rg"></a> [tags\_from\_rg](#input\_tags\_from\_rg) | Use resource group tags as base for module tags | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_eventhub_id"></a> [eventhub\_id](#output\_eventhub\_id) | n/a |
| <a name="output_eventhub_namespace_id"></a> [eventhub\_namespace\_id](#output\_eventhub\_namespace\_id) | Outputs |


## Example of Usage

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
