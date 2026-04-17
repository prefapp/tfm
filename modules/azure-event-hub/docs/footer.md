## Generated README tables

When this module’s README is produced with **terraform-docs**, **Requirements** lists provider **constraints** from `versions.tf`. If `settings.lockfile: true` is used and a `.terraform.lock.hcl` only when that lockfile is present at generation time, **Providers** can list the **resolved** provider versions from that lockfile; otherwise, regenerated docs may show different or no resolved provider versions. These tables are complementary, not contradictory.

## Examples

- [Basic](https://github.com/prefapp/tfm/tree/main/modules/azure-event-hub/_examples/basic)
- [Comprehensive](https://github.com/prefapp/tfm/tree/main/modules/azure-event-hub/_examples/comprehensive)

## Provider documentation (aligned with `versions.tf`)

- [azurerm_eventhub_namespace](https://registry.terraform.io/providers/hashicorp/azurerm/4.51.0/docs/resources/eventhub_namespace)
- [azurerm_eventhub](https://registry.terraform.io/providers/hashicorp/azurerm/4.51.0/docs/resources/eventhub)
- [azurerm_eventhub_consumer_group](https://registry.terraform.io/providers/hashicorp/azurerm/4.51.0/docs/resources/eventhub_consumer_group)
- [azurerm_eventhub_authorization_rule](https://registry.terraform.io/providers/hashicorp/azurerm/4.51.0/docs/resources/eventhub_authorization_rule)
- [azurerm_eventgrid_system_topic](https://registry.terraform.io/providers/hashicorp/azurerm/4.51.0/docs/resources/eventgrid_system_topic)
- [azurerm_eventgrid_system_topic_event_subscription](https://registry.terraform.io/providers/hashicorp/azurerm/4.51.0/docs/resources/eventgrid_system_topic_event_subscription)
- [azurerm_role_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/4.51.0/docs/resources/role_assignment)
- [azurerm_resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/4.51.0/docs/data-sources/resource_group)

## Issues

[https://github.com/prefapp/tfm/issues](https://github.com/prefapp/tfm/issues)
