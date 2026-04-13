# Example: Reference an existing Action Group by name (brownfield mode)

module "azure_alerts" {
  source = "../../"

  common = {
    location            = "eastus"
    resource_group_name = "example-alerts-rg"
    tags = {
      environment = "production"
      project     = "azure-alerts"
    }
  }

  # No action_group block: this module will not create Action Groups.

  log_alert = [
    {
      name    = "resource-group-write-alert"
      enabled = true
      scopes  = ["/subscriptions/00000000-0000-0000-0000-000000000000"]
      criteria = {
        category        = "Administrative"
        resource_groups = ["example-alerts-rg"]
        statuses        = ["Succeeded"]
      }
      action = {
        action_group = {
          name                = "existing-action-group"
          resource_group_name = "example-alerts-rg"
        }
      }
    }
  ]
}

output "action_group_id" {
  description = "Null in this example because no Action Group is created by the module"
  value       = module.azure_alerts.action_group_id
}
