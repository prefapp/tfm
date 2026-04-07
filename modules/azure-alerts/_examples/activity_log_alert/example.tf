# Example: Configure Activity Log Alerts to monitor subscription activity

module "azure_alerts" {
  source = "../../"

  # Common configuration
  common = {
    location            = "global"  # Activity Log Alerts use global location
    resource_group_name = "example-alerts-rg"
    tags = {
      environment = "production"
      project     = "azure-alerts"
    }
  }

  # Action Group for alert notifications
  action_group = {
    name                = "activity-log-action-group"
    resource_group_name = "example-alerts-rg"
    short_name          = "ActivityAG"

    email_receivers = {
      security_team = {
        name          = "Security Team"
        email_address = "security@example.com"
      }
      ops_team = {
        name          = "Operations Team"
        email_address = "ops@example.com"
      }
    }
  }

  # Activity Log Alerts - Monitor specific activities
  log_alert = [
    {
      name        = "vm-delete-alert"
      description = "Alert when VMs are deleted"
      enabled     = true
      scopes      = ["/subscriptions/00000000-0000-0000-0000-000000000000"]  # Replace with your subscription ID
      
      criteria = {
        category        = "Administrative"
        resource_types  = ["Microsoft.Compute/virtualMachines"]
        statuses        = ["Succeeded"]
      }

      action = {
        action_group_id = "azurerm_monitor_action_group.this.id"
      }
    },
    {
      name        = "security-policy-change-alert"
      description = "Alert when security policies are created or updated"
      enabled     = true
      scopes      = ["/subscriptions/00000000-0000-0000-0000-000000000000"]  # Replace with your subscription ID
      
      criteria = {
        category          = "Administrative"
        resource_providers = ["Microsoft.Security"]
        statuses          = ["Succeeded"]
      }

      action = {
        action_group_id = "azurerm_monitor_action_group.this.id"
      }
    },
    {
      name        = "service-health-alert"
      description = "Alert on Azure service health incidents"
      enabled     = true
      scopes      = ["/subscriptions/00000000-0000-0000-0000-000000000000"]  # Replace with your subscription ID
      
      criteria = {
        category = "ServiceHealth"
        service_health = {
          events    = ["Incident", "Maintenance", "Informational"]
          locations = ["Global"]
          services  = ["All"]
        }
      }

      action = {
        action_group_id = "azurerm_monitor_action_group.this.id"
      }
    }
  ]
}

output "activity_log_alert_ids" {
  description = "Map of activity log alert names to their IDs"
  value       = module.azure_alerts.activity_log_alert_ids
}
