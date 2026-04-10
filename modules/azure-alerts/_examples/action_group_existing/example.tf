# Example: Reuse an existing Action Group (brownfield mode)

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

  # Reuse an existing Action Group instead of creating a new one.
  action_group = {
    create              = false
    name                = "existing-action-group"
    resource_group_name = "example-alerts-rg"
  }

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
      action = {}
    }
  ]
}

output "action_group_id" {
  description = "The ID of the reused Action Group"
  value       = module.azure_alerts.action_group_id
}
