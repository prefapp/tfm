## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-alerts/_examples):

- [action_group](https://github.com/prefapp/tfm/tree/main/modules/azure-alerts/_examples/action_group) - Example provisioning an Action Group with multiple receiver types (email, SMS, webhook, ARM role, etc.).
- [action_group_existing](https://github.com/prefapp/tfm/tree/main/modules/azure-alerts/_examples/action_group_existing) - Example referencing an existing Action Group by name/resource group from a log alert.
- [action_groups_multiple](https://github.com/prefapp/tfm/tree/main/modules/azure-alerts/_examples/action_groups_multiple) - Example provisioning multiple Action Groups in the same module instance.
- [budget_alert](https://github.com/prefapp/tfm/tree/main/modules/azure-alerts/_examples/budget_alert) - Example provisioning a Budget Alert to monitor subscription spending.
- [quota_alert](https://github.com/prefapp/tfm/tree/main/modules/azure-alerts/_examples/quota_alert) - Example provisioning a Quota Alert to monitor subscription-level quotas (vCPU, storage, etc.).
- [activity_log_alert](https://github.com/prefapp/tfm/tree/main/modules/azure-alerts/_examples/activity_log_alert) - Example provisioning Activity Log Alerts to monitor administrative activities, VM deletion, and service health events.

## Use Cases

### Action Group
Use one or more Action Groups to define notification channels for your alerts. The `action_group` block is optional and can contain zero or more named groups.

Supports multiple receiver types:
- Email notifications for alerting teams
- SMS notifications for on-call personnel
- Webhooks for integration with incident management systems
- Azure Functions for custom processing
- Logic Apps for automation workflows
- ARM role receivers for permission-based routing

> Note: receiver `name` values must be unique per receiver type to guarantee stable ordering and avoid plan churn.

### Budget Alert
Monitor your Azure subscription spending and receive early warnings when costs approach budget limits:
- Set budget thresholds at different percentage levels (e.g., 75%, 100%)
- Notify specific contacts when thresholds are exceeded
- Reference contact groups by Action Group name, full resource ID, or object `{ name, resource_group_name }`
- Preserve Azure-side budget filtering using the optional `budget.filter` block (e.g. `ChargeType = Usage`)
- Configure recurring monthly, quarterly, or annual budgets
- Useful for cost governance and preventing budget overruns

### Multiple Action Groups
Use multiple entries inside `action_group` when you need to manage more than one Action Group in the same module instance:
- Budget notifications can reference any configured group by name
- Quota alerts can target all configured groups by default, or explicit `quota_alert.action_groups`
- Activity log alerts should set `action.action_group` or `action.action_group_id` explicitly when more than one Action Group is configured
### Quota Alert
Track subscription-level quota usage to prevent hitting Azure limits:
- Monitor vCPU quotas across regions
- Track storage and compute resource availability
- Use KQL queries for custom threshold logic
- Requires a managed identity for query execution (automatically created by the module)

### Activity Log Alert
Monitor administrative and operational events across your subscription:
- VM creation, deletion, and state changes
- Security policy modifications
- Service health incidents
- Resource group and RBAC changes
- Audit and compliance monitoring

## Remote Resources

- **Azure Monitor Action Group**: [azurerm_monitor_action_group documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_action_group)
- **Consumption Budget**: [azurerm_consumption_budget_subscription documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/consumption_budget_subscription)
- **Scheduled Query Rules Alert V2**: [azurerm_monitor_scheduled_query_rules_alert_v2 documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_scheduled_query_rules_alert_v2)
- **Activity Log Alert**: [azurerm_monitor_activity_log_alert documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_activity_log_alert)
- **Alert Processing Rule**: [azurerm_monitor_alert_processing_rule_action_group documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_alert_processing_rule_action_group)
- **Terraform Azure Provider**: [Terraform Provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
