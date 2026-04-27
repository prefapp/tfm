# Example: Configure a Backup Alert Processing Rule Action Group

module "azure_alerts" {
  source = "../../"

  common = {
    location            = "global"
    resource_group_name = "example-alerts-rg"
    tags = {
      environment = "production"
      project     = "azure-alerts"
    }
  }

  backup_alert = [
    {
      name                = "suppress-backup-window"
      resource_group_name = "example-alerts-rg"
      scopes              = ["/subscriptions/00000000-0000-0000-0000-000000000000"]
      description         = "Route/suppress alerts during backup window"
      add_action_group_ids = [
        "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-alerts-rg/providers/Microsoft.Insights/actionGroups/backup-action-group"
      ]
    }
  ]
}

output "backup_alert_id" {
  description = "The ID of the created backup alert processing rule"
  value       = module.azure_alerts.backup_alert_id
}

output "backup_alert_ids" {
  description = "Map of configured backup alert processing rule IDs"
  value       = module.azure_alerts.backup_alert_ids
}
