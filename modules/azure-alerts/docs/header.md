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

- **azurerm_monitor_action_group**: Central hub for alert notifications with multiple receiver types.
- **azurerm_consumption_budget_subscription**: Monitor subscription-level spending and costs.
- **azurerm_monitor_scheduled_query_rules_alert_v2**: Query-based alerts for quota and custom metric monitoring.
- **azurerm_monitor_activity_log_alert**: Activity-based alerts on subscription events and service health.
- **azurerm_monitor_alert_processing_rule_action_group**: Manage alert suppression and routing rules.

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

  # Action Group for notifications
  action_group = {
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

  # Budget Alert - Optional
  budget = {
    name            = "monthly-budget"
    subscription_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
    amount          = 10000
    time_grain      = "Monthly"
    time_period = {
      start_date = "2026-01-01"
    }
    notification = [
      {
        enabled        = true
        operator       = "GreaterThan"
        threshold      = 75
        contact_emails = ["admin@example.com"]
      }
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
