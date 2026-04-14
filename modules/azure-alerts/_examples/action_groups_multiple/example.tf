# Example: Configure multiple Action Groups

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

  action_group = {
    operations = {
      name                = "ops-action-group"
      resource_group_name = "example-alerts-rg"
      short_name          = "OpsAG"

      email_receivers = {
        ops_team = {
          name          = "Operations Team"
          email_address = "ops@example.com"
        }
      }
    }

    finance = {
      name                = "finance-action-group"
      resource_group_name = "example-alerts-rg"
      short_name          = "FinAG"

      email_receivers = {
        finance_team = {
          name          = "Finance Team"
          email_address = "finance@example.com"
        }
      }
    }
  }

  budget = {
    monthly = {
      name            = "monthly-subscription-budget"
      subscription_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
      amount          = 5000
      time_grain      = "Monthly"
      time_period = {
        start_date = "2026-01-01"
        end_date   = "2027-12-31"
      }
      notification = [
        {
          enabled        = true
          operator       = "GreaterThan"
          threshold      = 80
          contact_emails = ["finance@example.com"]
          contact_groups = ["finance-action-group", "ops-action-group"]
        }
      ]
    }
  }
}

output "action_group_ids" {
  description = "IDs of all configured Action Groups"
  value       = module.azure_alerts.action_group_ids
}
