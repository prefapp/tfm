# Example: Configure a Quota Alert to monitor subscription quotas (e.g., vCPU limits)

module "azure_alerts" {
  source = "../../"

  # Common configuration
  common = {
    location            = "eastus"
    resource_group_name = "example-alerts-rg"
    tags = {
      environment = "production"
      project     = "azure-alerts"
    }
  }

  # Managed Identity for the Quota Alert to read quota metrics
  identity = {
    name                 = "quota-alert-reader"
    scope                = "/subscriptions/00000000-0000-0000-0000-000000000000"  # Replace with your subscription ID
    role_definition_name = "Reader"
  }

  # Action Group for alert notifications
  action_group = [
    {
      name                = "quota-alert-action-group"
      resource_group_name = "example-alerts-rg"
      short_name          = "QuotaAG"

      email_receivers = {
        platform_team = {
          name          = "Platform Team"
          email_address = "platform@example.com"
        }
      }
    }
  ]

  # Quota Alert - Monitor vCPU quota usage and alert when threshold is exceeded
  quota_alert = [
    {
      name                             = "vcpu-quota-alert"
      display_name                     = "vCPU Quota Usage Alert"
      description                      = "Alert when vCPU quota usage exceeds 80%"
      enabled                          = true
      location                         = "eastus"
      evaluation_frequency             = "PT1H" # Check every hour
      window_duration                  = "PT1H" # 1 hour window
      severity                         = 2       # 0-4, where 0 is critical
      scopes                           = ["/subscriptions/00000000-0000-0000-0000-000000000000"]
      skip_query_validation            = false
      workspace_alerts_storage_enabled = false

      criteria = {
        query                   = "Resources | where type == 'microsoft.compute/virtualmachines' | summarize count() by location"
        operator                = "GreaterThan"
        threshold               = 800
        metric_measure_column   = "count_"
        time_aggregation_method = "Total"
        dimension = [
          {
            name     = "location"
            operator = "Include"
            values   = ["eastus", "westus"]
          }
        ]
        failing_periods = {
          minimum_failing_periods_to_trigger_alert = 1
          number_of_evaluation_periods             = 1
        }
      }

      identity = {
        type         = "UserAssigned"
        identity_ids = [] # Will be populated by the module
      }

      action_groups = ["quota-alert-action-group"]
    }
  ]
}

output "quota_alert_id" {
  description = "The ID of the created Quota Alert"
  value       = module.azure_alerts.quota_alert_id
}

output "quota_alert_ids" {
  description = "Map of configured Quota Alert IDs"
  value       = module.azure_alerts.quota_alert_ids
}

output "quota_alert_reader_identity_id" {
  description = "The ID of the Managed Identity for the Quota Alert"
  value       = module.azure_alerts.quota_alert_reader_identity_id
}
