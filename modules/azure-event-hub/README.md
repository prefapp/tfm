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

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_eventhub"></a> [eventhub](#input\_eventhub) | n/a | <pre>map(object({<br/>    name                = string<br/>    partition_count     = number<br/>    message_retention   = number<br/>    auth_rule_name      = string<br/>    consumer_group_name = string<br/>    auth_rule = object({<br/>      listen = bool<br/>      send   = bool<br/>      manage = bool<br/>    })<br/>    event_subscription = object({<br/>      name                 = string<br/>      included_event_types = list(string)<br/>      retry_ttl            = number<br/>      max_attempts         = number<br/>    })<br/>    system_topic_name = string<br/>  }))</pre> | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | n/a | <pre>object({<br/>    name                 = string<br/>    location             = string<br/>    resource_group_name  = string<br/>    sku                  = string<br/>    capacity             = number<br/>    auto_inflate_enabled = bool<br/>    identity_type        = string<br/>    ruleset = object({<br/>      default_action                 = string<br/>      public_network_access_enabled  = bool<br/>      trusted_service_access_enabled = bool<br/>      virtual_network_rules = optional(list(object({<br/>        subnet_id                                       = string<br/>        ignore_missing_virtual_network_service_endpoint = optional(bool)<br/>      })), [])<br/>      ip_rules = optional(list(object({<br/>        ip_mask = string<br/>        action  = string<br/>      })), [])<br/>    })<br/>  })</pre> | n/a | yes |
| <a name="input_system_topic"></a> [system\_topic](#input\_system\_topic) | n/a | <pre>map(object({<br/>    name               = string<br/>    location           = string<br/>    topic_type         = string<br/>    source_resource_id = string<br/>  }))</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Variables | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_eventhub_id"></a> [eventhub\_id](#output\_eventhub\_id) | n/a |
| <a name="output_eventhub_namespace_id"></a> [eventhub\_namespace\_id](#output\_eventhub\_namespace\_id) | Outputs |


## Example of Usage

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
