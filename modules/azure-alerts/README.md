<!-- BEGIN_TF_DOCS -->
# **Azure Alerts Terraform Module**

## Overview

This module provisions and manages Azure Monitor alerts for comprehensive monitoring and alerting across your Azure infrastructure. It provides a unified interface to create and manage multiple alert types including Action Groups, Budget Alerts, Quota Alerts, Activity Log Alerts, and Alert Processing Rules.

This module is suitable for production, staging, and development environments, enabling centralized alert management and automated notification workflows.

## Key Features

- **Action Group Management**: Configure multiple receiver types (email, SMS, webhooks, Azure Functions, Logic Apps, and more) to route alerts to the appropriate teams.
- **Budget Alerts**: Monitor subscription spending and receive notifications when spending exceeds defined thresholds.
- **Quota Alerts**: Track subscription-level quota usage (vCPU, storage, etc.) and alert before hitting limits.
- **Activity Log Alerts**: Monitor administrative activities, resource changes, and service health events at the subscription level.
- **Alert Processing Rules**: Suppress or modify alerts based on custom rules (e.g., during maintenance windows).
- **Managed Identity Integration**: Automatic creation and role assignment of managed identities for quota alert execution.
- **Tag Inheritance and Customization**: Inherit tags from the resource group or specify custom tags for all resources.
- **Flexible Configuration**: Use maps and optional parameters for granular control over each alert type.

## Supported Resources

- **azurerm\_monitor\_action\_group**: Central hub for alert notifications with multiple receiver types.
- **azurerm\_consumption\_budget\_subscription**: Monitor subscription-level spending and costs.
- **azurerm\_monitor\_scheduled\_query\_rules\_alert\_v2**: Query-based alerts for quota and custom metric monitoring.
- **azurerm\_monitor\_activity\_log\_alert**: Activity-based alerts on subscription events and service health.
- **azurerm\_monitor\_alert\_processing\_rule\_action\_group**: Manage alert suppression and routing rules.

## Basic Usage

See the `_examples/` directory for detailed examples for each alert type.

```hcl
module "azure_alerts" {
  source = "../../"

  # Common configuration
  common = {
    location            = "eastus"
    resource_group_name = "my-alerts-rg"
    tags = {
      environment = "production"
    }
  }

  # Action Group(s) for notifications
  # This block is optional. If omitted, the module will not create any Action Group.
  action_group = {
    operations = {
      name                = "my-action-group"
      resource_group_name = "my-alerts-rg"
      short_name          = "MyAG"

      email_receivers = {
        admin = {
          name          = "Admin"
          email_address = "admin@example.com"
        }
      }
    }
  }

  # Budget Alert - Optional
  budget = {
    name            = "monthly-budget"
    subscription_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
    amount          = 10000
    time_grain      = "Monthly"
    time_period = {
      start_date = "2026-01-01"
    }

    # Optional: preserve existing budget filters to avoid drift
    filter = {
      dimension = [{
        name     = "ChargeType"
        operator = "In"
        values   = ["Usage"]
      }]
    }

    notification = [
      {
        enabled        = true
        operator       = "GreaterThan"
        threshold      = 75
        contact_emails = ["admin@example.com"]

        # Accepts Action Group names, full resource IDs,
        # or objects with `name` + `resource_group_name`
        contact_groups = [
          "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-alerts-rg/providers/Microsoft.Insights/actionGroups/my-action-group"
        ]
      }
      # Also supports objects for cross-resource-group lookups:
      # {
      #   enabled        = true
      #   operator       = "GreaterThan"
      #   threshold      = 100
      #   contact_emails = ["admin@example.com"]
      #   contact_groups = [{
      #     name                = "shared-monitoring-action-group"
      #     resource_group_name = "shared-monitoring-rg"
      #   }]
      # }
    ]
  }

  # Activity Log Alerts - Optional
  log_alert = [
    {
      name    = "vm-delete-alert"
      enabled = true
      scopes  = ["/subscriptions/00000000-0000-0000-0000-000000000000"]
      criteria = {
        category       = "Administrative"
        resource_types = ["Microsoft.Compute/virtualMachines"]
      }
      action = {}
    }
  ]
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.67.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.67.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_consumption_budget_subscription.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/consumption_budget_subscription) | resource |
| [azurerm_monitor_action_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_action_group) | resource |
| [azurerm_monitor_activity_log_alert.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_activity_log_alert) | resource |
| [azurerm_monitor_alert_processing_rule_action_group.backup](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_alert_processing_rule_action_group) | resource |
| [azurerm_monitor_scheduled_query_rules_alert_v2.quota](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_scheduled_query_rules_alert_v2) | resource |
| [azurerm_role_assignment.quota_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_user_assigned_identity.quota_alert_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_monitor_action_group.referenced](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/monitor_action_group) | data source |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_action_group"></a> [action\_group](#input\_action\_group) | Optional map of Azure Monitor Action Groups keyed by logical name. Can contain zero or more entries. | <pre>map(object({<br/>    name                = string<br/>    resource_group_name = string<br/>    short_name          = string<br/>    arm_role_receivers = optional(map(object({<br/>      name                    = string<br/>      role_id                 = string<br/>      use_common_alert_schema = optional(bool, true)<br/>    })), {})<br/>    automation_runbook_receivers = optional(map(object({<br/>      name                    = string<br/>      automation_account_id   = string<br/>      runbook_name            = string<br/>      webhook_resource_id     = optional(string, null)<br/>      service_uri             = optional(string, null)<br/>      is_global_runbook       = optional(bool, false)<br/>      use_common_alert_schema = optional(bool, true)<br/>    })), {})<br/>    azure_app_push_receivers = optional(map(object({<br/>      name          = string<br/>      email_address = string<br/>    })), {})<br/>    azure_function_receivers = optional(map(object({<br/>      name                     = string<br/>      function_app_resource_id = string<br/>      function_name            = string<br/>      http_trigger_url         = string<br/>      use_common_alert_schema  = optional(bool, true)<br/>    })), {})<br/>    email_receivers = optional(map(object({<br/>      name                    = string<br/>      email_address           = string<br/>      use_common_alert_schema = optional(bool, true)<br/>    })), {})<br/>    event_hub_receivers = optional(map(object({<br/>      name                    = string<br/>      event_hub_name          = string<br/>      event_hub_namespace     = string<br/>      use_common_alert_schema = optional(bool, true)<br/>    })), {})<br/>    itsm_receivers = optional(map(object({<br/>      name                 = string<br/>      workspace_id         = string<br/>      connection_id        = string<br/>      region               = optional(string, null)<br/>      ticket_configuration = optional(string, null)<br/>    })), {})<br/>    logic_app_receivers = optional(map(object({<br/>      name                    = string<br/>      resource_id             = string<br/>      callback_url            = string<br/>      use_common_alert_schema = optional(bool, true)<br/>    })), {})<br/>    sms_receivers = optional(map(object({<br/>      name         = string<br/>      country_code = string<br/>      phone_number = string<br/>    })), {})<br/>    voice_receivers = optional(map(object({<br/>      name         = string<br/>      country_code = string<br/>      phone_number = string<br/>    })), {})<br/>    webhook_receivers = optional(map(object({<br/>      name                    = string<br/>      service_uri             = string<br/>      use_common_alert_schema = optional(bool, true)<br/>      aad_auth = optional(object({<br/>        object_id      = string<br/>        identifier_uri = optional(string, null)<br/>        tenant_id      = string<br/>      }), null)<br/>    })), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_backup_alert"></a> [backup\_alert](#input\_backup\_alert) | Configuration for the alert processing rule action group (e.g. backup alerts). Set to null to disable. | <pre>object({<br/>    name                 = string<br/>    resource_group_name  = optional(string, null)<br/>    scopes               = list(string)<br/>    description          = optional(string)<br/>    add_action_group_ids = list(string)<br/>  })</pre> | `null` | no |
| <a name="input_budget"></a> [budget](#input\_budget) | Optional map of subscription consumption budget alerts keyed by logical name. Can contain zero or more entries. | <pre>map(object({<br/>    name            = string<br/>    subscription_id = optional(string, null)<br/>    amount          = number<br/>    time_grain      = string<br/>    time_period = object({<br/>      start_date = string<br/>      end_date   = optional(string)<br/>    })<br/>    notification = list(object({<br/>      enabled        = bool<br/>      operator       = string<br/>      threshold      = number<br/>      threshold_type = optional(string, "Actual")<br/>      contact_emails = list(string)<br/>      contact_groups = optional(list(any), [])<br/>      contact_roles  = optional(list(string), [])<br/>    }))<br/>    filter = optional(object({<br/>      dimension = optional(list(object({<br/>        name     = string<br/>        operator = optional(string, "In")<br/>        values   = list(string)<br/>      })), [])<br/>      tag = optional(list(object({<br/>        name     = string<br/>        operator = optional(string, "In")<br/>        values   = list(string)<br/>      })), [])<br/>    }), null)<br/>  }))</pre> | `{}` | no |
| <a name="input_common"></a> [common](#input\_common) | Common variables for the module | <pre>object({<br/>    location            = optional(string, "westeurope")<br/>    resource_group_name = optional(string, null)<br/>    tags                = optional(map(string), {})<br/>    tags_from_rg        = optional(bool, false)<br/>  })</pre> | `{}` | no |
| <a name="input_identity"></a> [identity](#input\_identity) | Identity for Quota Alert | <pre>object({<br/>    name                 = string<br/>    scope                = string<br/>    role_definition_name = optional(string, "Reader")<br/>  })</pre> | `null` | no |
| <a name="input_log_alert"></a> [log\_alert](#input\_log\_alert) | List of activity log alert configurations. Set to empty list to disable. | <pre>list(object({<br/>    name                = string<br/>    resource_group_name = optional(string, null)<br/>    location            = optional(string, "global")<br/>    description         = optional(string)<br/>    enabled             = optional(bool, true)<br/>    scopes              = list(string)<br/>    action = object({<br/>      action_group       = optional(any, null)<br/>      action_group_id    = optional(string, null)<br/>      webhook_properties = optional(map(string), {})<br/>    })<br/>    criteria = object({<br/>      category           = string<br/>      levels             = optional(list(string), [])<br/>      resource_groups    = optional(list(string), [])<br/>      resource_ids       = optional(list(string), [])<br/>      resource_providers = optional(list(string), [])<br/>      resource_types     = optional(list(string), [])<br/>      statuses           = optional(list(string), [])<br/>      sub_statuses       = optional(list(string), [])<br/>      service_health = optional(object({<br/>        events    = optional(list(string), [])<br/>        locations = optional(list(string), [])<br/>        services  = optional(list(string), [])<br/>      }))<br/>    })<br/>  }))</pre> | `[]` | no |
| <a name="input_quota_alert"></a> [quota\_alert](#input\_quota\_alert) | Optional map of quota scheduled query rule alerts keyed by logical name. Can contain zero or more entries. | <pre>map(object({<br/>    auto_mitigation_enabled          = optional(bool, true)<br/>    display_name                     = string<br/>    description                      = optional(string)<br/>    enabled                          = optional(bool, true)<br/>    evaluation_frequency             = string<br/>    location                         = string<br/>    name                             = string<br/>    scopes                           = list(string)<br/>    severity                         = number<br/>    skip_query_validation            = optional(bool, false)<br/>    target_resource_types            = optional(list(string), [])<br/>    window_duration                  = string<br/>    workspace_alerts_storage_enabled = optional(bool, false)<br/>    criteria = object({<br/>      metric_measure_column   = string<br/>      operator                = string<br/>      query                   = string<br/>      threshold               = number<br/>      time_aggregation_method = string<br/>      dimension = list(object({<br/>        name     = string<br/>        operator = string<br/>        values   = list(string)<br/>      }))<br/>      failing_periods = object({<br/>        minimum_failing_periods_to_trigger_alert = number<br/>        number_of_evaluation_periods             = number<br/>      })<br/>    })<br/>    identity = object({<br/>      type         = string<br/>      identity_ids = optional(list(string), [])<br/>    })<br/>    action_groups = optional(list(any), [])<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_action_group_id"></a> [action\_group\_id](#output\_action\_group\_id) | The ID of the Azure Monitor Action Group when exactly one is configured; otherwise null. |
| <a name="output_action_group_ids"></a> [action\_group\_ids](#output\_action\_group\_ids) | Map of configured action group keys to their resource IDs. |
| <a name="output_action_group_name"></a> [action\_group\_name](#output\_action\_group\_name) | The name of the Azure Monitor Action Group when exactly one is configured; otherwise null. |
| <a name="output_action_group_names"></a> [action\_group\_names](#output\_action\_group\_names) | Map of configured action group keys to their names. |
| <a name="output_activity_log_alert_ids"></a> [activity\_log\_alert\_ids](#output\_activity\_log\_alert\_ids) | Map of activity log alert names to their resource IDs. |
| <a name="output_backup_alert_id"></a> [backup\_alert\_id](#output\_backup\_alert\_id) | The ID of the alert processing rule for backup alerts. Null if not created. |
| <a name="output_budget_alert_id"></a> [budget\_alert\_id](#output\_budget\_alert\_id) | The ID of the consumption budget subscription alert when exactly one is configured; otherwise null. |
| <a name="output_budget_alert_ids"></a> [budget\_alert\_ids](#output\_budget\_alert\_ids) | Map of configured budget keys to their resource IDs. |
| <a name="output_quota_alert_id"></a> [quota\_alert\_id](#output\_quota\_alert\_id) | The ID of the quota scheduled query rules alert when exactly one is configured; otherwise null. |
| <a name="output_quota_alert_ids"></a> [quota\_alert\_ids](#output\_quota\_alert\_ids) | Map of configured quota\_alert keys to their resource IDs. |
| <a name="output_quota_alert_reader_identity_id"></a> [quota\_alert\_reader\_identity\_id](#output\_quota\_alert\_reader\_identity\_id) | The ID of the User Assigned Managed Identity used for the quota alert. Null if not created. |
| <a name="output_quota_alert_reader_principal_id"></a> [quota\_alert\_reader\_principal\_id](#output\_quota\_alert\_reader\_principal\_id) | The principal ID of the quota alert Managed Identity. Null if not created. |

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-alerts/_examples):

- [action\_group](https://github.com/prefapp/tfm/tree/main/modules/azure-alerts/_examples/action\_group) - Example provisioning an Action Group with multiple receiver types (email, SMS, webhook, ARM role, etc.).
- [action\_group\_existing](https://github.com/prefapp/tfm/tree/main/modules/azure-alerts/_examples/action\_group\_existing) - Example referencing an existing Action Group by name/resource group from a log alert.
- [action\_groups\_multiple](https://github.com/prefapp/tfm/tree/main/modules/azure-alerts/_examples/action\_groups\_multiple) - Example provisioning multiple Action Groups in the same module instance.
- [budget\_alert](https://github.com/prefapp/tfm/tree/main/modules/azure-alerts/_examples/budget\_alert) - Example provisioning a Budget Alert to monitor subscription spending.
- [quota\_alert](https://github.com/prefapp/tfm/tree/main/modules/azure-alerts/_examples/quota\_alert) - Example provisioning a Quota Alert to monitor subscription-level quotas (vCPU, storage, etc.).
- [activity\_log\_alert](https://github.com/prefapp/tfm/tree/main/modules/azure-alerts/_examples/activity\_log\_alert) - Example provisioning Activity Log Alerts to monitor administrative activities, VM deletion, and service health events.

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

## Resource Group Name Resolution

The module derives an effective `resource_group_name` using this order of precedence:

1. **`common.resource_group_name`** – always preferred when set.
2. **Single configured `action_group` entry** – if exactly one entry exists in the `action_group` map and it shares a single `resource_group_name`, that value is used as the fallback.
3. **`null`** – when neither of the above is available.

This effective value is used for:
- Creating module-managed resources (`identity`, `quota_alert`, `backup_alert`, `log_alert` entries without an explicit `resource_group_name`).
- Resolving external Action Group references that are specified by **name** (plain string) or by **object without `resource_group_name`** in `budget.notification[*].contact_groups`, `quota_alert.action_groups`, and `log_alert[*].action.action_group`.

> **Mismatch validation is enforced** when both values are set: if `common.resource_group_name` is provided, every `action_group.*.resource_group_name` must be equal to it. Terraform fails fast with a clear check error when they differ.

If name-based external Action Group references are used without an explicit `resource_group_name`, the module will fail at plan time with a descriptive `precondition` error if the effective resource group name cannot be inferred. Use a full resource ID (e.g. `/subscriptions/.../resourceGroups/.../providers/microsoft.insights/actionGroups/...`) or provide `resource_group_name` in the reference object to avoid this requirement.

## Remote Resources

- **Azure Monitor Action Group**: [azurerm\_monitor\_action\_group documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_action_group)
- **Consumption Budget**: [azurerm\_consumption\_budget\_subscription documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/consumption_budget_subscription)
- **Scheduled Query Rules Alert V2**: [azurerm\_monitor\_scheduled\_query\_rules\_alert\_v2 documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_scheduled_query_rules_alert_v2)
- **Activity Log Alert**: [azurerm\_monitor\_activity\_log\_alert documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_activity_log_alert)
- **Alert Processing Rule**: [azurerm\_monitor\_alert\_processing\_rule\_action\_group documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_alert_processing_rule_action_group)
- **Terraform Azure Provider**: [Terraform Provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->
