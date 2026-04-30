<!-- BEGIN_TF_DOCS -->
# `azure-event-hub`

## Overview

Terraform module that creates an **Event Hubs namespace**, one or more **event hubs**, optional **consumer groups** and **authorization rules**, and optionally **Event Grid system topics**, **event subscriptions** (delivering to an event hub endpoint), and a **role assignment** so Event Grid can send data to the hub.

**Prerequisites**

- An existing **resource group** (`namespace.resource_group_name`).
- Appropriate **Azure RBAC** / identity permissions for Event Hubs and Event Grid resources.

**Behaviour notes (as implemented)**

- **`eventhub`** is a map: each key is used internally to tie consumer groups, auth rules, and (when configured) Event Grid resources to a specific hub. Consumer group and auth rule entries are built from `consumer_group_names` and `auth_rules` lists per hub.
- **Event Grid path**: for an `eventhub` entry, if `event_subscription` and `system_topic_name` are both set, the module creates an `azurerm_eventgrid_system_topic_event_subscription` targeting that hub. `system_topic_name` must match a **key** in the `system_topic` map. The module also creates `azurerm_role_assignment` (`Azure Event Hubs Data Sender`) scoped to the hub when `system_topic_name` is set; `principal_id` comes from the system topic’s managed identity (`try(..., null)` in code—ensure the topic exists so assignment is valid).
- **`system_topic`**: pass **`system_topic = {}`** when you do not use Event Grid; the variable is required by the module interface but an empty map disables those resources (`for_each` over `{}`).
- **Tags**: `tags_from_rg` merges resource group tags with `tags` (module tags override on duplicate keys).
- **`locals.virtual_network_rules` / `locals.ip_rules`**: defined from `namespace.ruleset` but **not referenced** elsewhere in this module; network rules are passed directly via `var.namespace.ruleset` into `azurerm_eventhub_namespace`. These locals are redundant implementation leftovers and do not affect the module interface.

## Basic usage

```hcl
module "event_hub" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-event-hub?ref=<version>"

  tags_from_rg = false
  tags         = { example = "basic" }

  namespace = {
    name                 = "ehns-example"
    location             = "westeurope"
    resource_group_name  = "example-rg"
    sku                  = "Standard"
    capacity             = 1
    auto_inflate_enabled = false
    identity_type        = "SystemAssigned"
    ruleset = {
      default_action                 = "Allow"
      public_network_access_enabled  = true
      trusted_service_access_enabled = true
      virtual_network_rules          = []
      ip_rules                       = []
    }
  }

  system_topic = {}

  eventhub = {
    hub1 = {
      name                 = "events"
      partition_count      = 2
      message_retention    = 1
      consumer_group_names = ["cg1"]
      auth_rules = [
        { name = "listen", listen = true, send = false, manage = false }
      ]
      event_subscription  = null
      system_topic_name   = null
    }
  }
}
```

## Module layout

| Path | Purpose |
|------|---------|
| `main.tf` | Namespace, hubs, consumer groups, auth rules, Event Grid, role assignment |
| `locals.tf` | Tags, flattened consumer groups and auth rules |
| `variables.tf` | Inputs |
| `outputs.tf` | Exported IDs |
| `versions.tf` | Terraform and provider constraints |
| `CHANGELOG.md` | Release history |
| `docs/header.md` | Overview (this file) |
| `docs/footer.md` | Examples and provider links |
| `_examples/basic` | Minimal validate-oriented example |
| `_examples/comprehensive` | Reference YAML |
| `README.md` | Generated content (terraform-docs) |
| `.terraform-docs.yml` | terraform-docs configuration |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.51.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.51.0 |

## Modules

No modules.

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
| <a name="input_eventhub"></a> [eventhub](#input\_eventhub) | Map of event hubs to create inside the namespace. Map keys are internal identifiers used for consumer groups,<br/>authorization rules, and Event Grid wiring. To enable Event Grid delivery for a hub, set both `event_subscription`<br/>and `system_topic_name` (matching a key in `system_topic`). | <pre>map(object({<br/>    name                 = string<br/>    partition_count      = number<br/>    message_retention    = number<br/>    consumer_group_names = list(string)<br/>    auth_rules = list(object({<br/>      name   = string<br/>      listen = bool<br/>      send   = bool<br/>      manage = bool<br/>    }))<br/>    event_subscription = optional(object({<br/>      name                 = string<br/>      included_event_types = list(string)<br/>      retry_ttl            = number<br/>      max_attempts         = number<br/>    }))<br/>    system_topic_name = optional(string)<br/>  }))</pre> | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Event Hubs namespace configuration (SKU, capacity, managed identity type). Use nested `ruleset` for network rules; it maps to the `network_rulesets` block on `azurerm_eventhub_namespace`. | <pre>object({<br/>    name                 = string<br/>    location             = string<br/>    resource_group_name  = string<br/>    sku                  = string<br/>    capacity             = number<br/>    auto_inflate_enabled = bool<br/>    identity_type        = string<br/>    ruleset = object({<br/>      default_action                 = string<br/>      public_network_access_enabled  = bool<br/>      trusted_service_access_enabled = bool<br/>      virtual_network_rules = optional(list(object({<br/>        subnet_id                                       = string<br/>        ignore_missing_virtual_network_service_endpoint = optional(bool)<br/>      })), [])<br/>      ip_rules = optional(list(object({<br/>        ip_mask = string<br/>        action  = string<br/>      })), [])<br/>    })<br/>  })</pre> | n/a | yes |
| <a name="input_system_topic"></a> [system\_topic](#input\_system\_topic) | Event Grid system topics keyed by name referenced from `eventhub.*.system_topic_name`. Use an empty map `{}` when Event Grid is not used. | <pre>map(object({<br/>    name               = string<br/>    location           = string<br/>    topic_type         = string<br/>    source_resource_id = string<br/>  }))</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_tags_from_rg"></a> [tags\_from\_rg](#input\_tags\_from\_rg) | Use resource group tags as base for module tags | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_authorization_rule_primary_connection_string"></a> [authorization\_rule\_primary\_connection\_string](#output\_authorization\_rule\_primary\_connection\_string) | Map of authorization rule keys (`<eventhub_key>.<rule_name>`) to primary connection strings. |
| <a name="output_authorization_rules"></a> [authorization\_rules](#output\_authorization\_rules) | Map of authorization rules with connection strings. |
| <a name="output_consumer_group_id"></a> [consumer\_group\_id](#output\_consumer\_group\_id) | Map of consumer group keys (`<eventhub_key>.<consumer_group_name>`) to resource IDs. |
| <a name="output_eventgrid_event_subscription_id"></a> [eventgrid\_event\_subscription\_id](#output\_eventgrid\_event\_subscription\_id) | Map of event hub keys (where an Event Grid subscription is configured) to subscription resource IDs. |
| <a name="output_eventgrid_system_topic_id"></a> [eventgrid\_system\_topic\_id](#output\_eventgrid\_system\_topic\_id) | Map of system topic keys (from `system_topic`) to resource IDs. |
| <a name="output_eventgrid_system_topic_principal_id"></a> [eventgrid\_system\_topic\_principal\_id](#output\_eventgrid\_system\_topic\_principal\_id) | Map of system topic keys to the principal ID of the topic system-assigned identity. |
| <a name="output_eventgrid_to_eventhub_role_assignment_id"></a> [eventgrid\_to\_eventhub\_role\_assignment\_id](#output\_eventgrid\_to\_eventhub\_role\_assignment\_id) | Map of event hub keys to role assignment IDs granting the Event Grid topic identity send access to the hub. |
| <a name="output_eventhub_id"></a> [eventhub\_id](#output\_eventhub\_id) | Map of event hub keys to their Azure resource IDs. |
| <a name="output_eventhub_name"></a> [eventhub\_name](#output\_eventhub\_name) | Map of event hub keys to hub names in Azure. |
| <a name="output_eventhub_namespace_fqdn"></a> [eventhub\_namespace\_fqdn](#output\_eventhub\_namespace\_fqdn) | FQDN for clients (AMQP/Kafka) in the form `<namespace>.servicebus.windows.net`. |
| <a name="output_eventhub_namespace_id"></a> [eventhub\_namespace\_id](#output\_eventhub\_namespace\_id) | Resource ID of the Event Hubs namespace. |
| <a name="output_eventhub_namespace_name"></a> [eventhub\_namespace\_name](#output\_eventhub\_namespace\_name) | Name of the Event Hubs namespace. |
| <a name="output_eventhub_namespace_principal_id"></a> [eventhub\_namespace\_principal\_id](#output\_eventhub\_namespace\_principal\_id) | Principal ID of the namespace managed identity when Azure exposes it (e.g. SystemAssigned). |
| <a name="output_eventhubs"></a> [eventhubs](#output\_eventhubs) | Map of event hubs with their attributes. |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | Event Hub namespace details. |
| <a name="output_system_topics"></a> [system\_topics](#output\_system\_topics) | Map of Event Grid system topics. |

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-event-hub/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-event-hub/_examples/basic) — Namespace, one hub, consumer group, and auth rule; empty `system_topic` so no Event Grid (see folder README).
- [comprehensive](https://github.com/prefapp/tfm/tree/main/modules/azure-event-hub/_examples/comprehensive) — Illustrative `values.reference.yaml` including network rules and Event Grid-style configuration (see folder README).

## Resources

Terraform resource docs use **4.51.0** as a baseline aligned with the `azurerm` constraint in `versions.tf` (`>= 4.51.0`).

- **Azure Event Hubs**: [https://learn.microsoft.com/azure/event-hubs/event-hubs-about](https://learn.microsoft.com/azure/event-hubs/event-hubs-about)
- **azurerm\_eventhub\_namespace**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.51.0/docs/resources/eventhub_namespace](https://registry.terraform.io/providers/hashicorp/azurerm/4.51.0/docs/resources/eventhub_namespace)
- **azurerm\_eventhub**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.51.0/docs/resources/eventhub](https://registry.terraform.io/providers/hashicorp/azurerm/4.51.0/docs/resources/eventhub)
- **azurerm\_eventhub\_consumer\_group**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.51.0/docs/resources/eventhub_consumer_group](https://registry.terraform.io/providers/hashicorp/azurerm/4.51.0/docs/resources/eventhub_consumer_group)
- **azurerm\_eventhub\_authorization\_rule**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.51.0/docs/resources/eventhub_authorization_rule](https://registry.terraform.io/providers/hashicorp/azurerm/4.51.0/docs/resources/eventhub_authorization_rule)
- **azurerm\_eventgrid\_system\_topic**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.51.0/docs/resources/eventgrid_system_topic](https://registry.terraform.io/providers/hashicorp/azurerm/4.51.0/docs/resources/eventgrid_system_topic)
- **azurerm\_eventgrid\_system\_topic\_event\_subscription**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.51.0/docs/resources/eventgrid_system_topic\_event\_subscription](https://registry.terraform.io/providers/hashicorp/azurerm/4.51.0/docs/resources/eventgrid_system_topic\_event\_subscription)
- **azurerm\_role\_assignment**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.51.0/docs/resources/role_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/4.51.0/docs/resources/role_assignment)
- **azurerm\_resource\_group** (data source): [https://registry.terraform.io/providers/hashicorp/azurerm/4.51.0/docs/data-sources/resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/4.51.0/docs/data-sources/resource_group)
- **Terraform AzureRM provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.51.0](https://registry.terraform.io/providers/hashicorp/azurerm/4.51.0)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->
