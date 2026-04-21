## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-event-hub/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-event-hub/_examples/basic) — Namespace, one hub, consumer group, and auth rule; empty `system_topic` so no Event Grid (see folder README).
- [comprehensive](https://github.com/prefapp/tfm/tree/main/modules/azure-event-hub/_examples/comprehensive) — Illustrative `values.reference.yaml` including network rules and Event Grid-style configuration (see folder README).

## Resources

Terraform resource docs use **4.51.0** as a baseline aligned with the `azurerm` constraint in `versions.tf` (`>= 4.51.0`).

- **Azure Event Hubs**: [https://learn.microsoft.com/azure/event-hubs/event-hubs-about](https://learn.microsoft.com/azure/event-hubs/event-hubs-about)
- **azurerm_eventhub_namespace**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.51.0/docs/resources/eventhub_namespace](https://registry.terraform.io/providers/hashicorp/azurerm/4.51.0/docs/resources/eventhub_namespace)
- **azurerm_eventhub**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.51.0/docs/resources/eventhub](https://registry.terraform.io/providers/hashicorp/azurerm/4.51.0/docs/resources/eventhub)
- **azurerm_eventhub_consumer_group**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.51.0/docs/resources/eventhub_consumer_group](https://registry.terraform.io/providers/hashicorp/azurerm/4.51.0/docs/resources/eventhub_consumer_group)
- **azurerm_eventhub_authorization_rule**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.51.0/docs/resources/eventhub_authorization_rule](https://registry.terraform.io/providers/hashicorp/azurerm/4.51.0/docs/resources/eventhub_authorization_rule)
- **azurerm_eventgrid_system_topic**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.51.0/docs/resources/eventgrid_system_topic](https://registry.terraform.io/providers/hashicorp/azurerm/4.51.0/docs/resources/eventgrid_system_topic)
- **azurerm_eventgrid_system_topic_event_subscription**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.51.0/docs/resources/eventgrid_system_topic_event_subscription](https://registry.terraform.io/providers/hashicorp/azurerm/4.51.0/docs/resources/eventgrid_system_topic_event_subscription)
- **azurerm_role_assignment**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.51.0/docs/resources/role_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/4.51.0/docs/resources/role_assignment)
- **azurerm_resource_group** (data source): [https://registry.terraform.io/providers/hashicorp/azurerm/4.51.0/docs/data-sources/resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/4.51.0/docs/data-sources/resource_group)
- **Terraform AzureRM provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.51.0](https://registry.terraform.io/providers/hashicorp/azurerm/4.51.0)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
