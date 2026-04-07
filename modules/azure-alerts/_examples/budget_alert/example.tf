# Example: Configure a Budget Alert to monitor subscription spending

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

  # Action Group for alert notifications
  action_group = {
    name                = "budget-alert-action-group"
    resource_group_name = "example-alerts-rg"
    short_name          = "BudgetAG"

    email_receivers = {
      finance_team = {
        name          = "Finance Team"
        email_address = "finance@example.com"
      }
      ops_team = {
        name          = "Operations Team"
        email_address = "ops@example.com"
      }
    }
  }

  # Budget Alert - Monitor monthly spending and alert when thresholds are reached
  budget = {
    name            = "monthly-subscription-budget"
    subscription_id = "/subscriptions/00000000-0000-0000-0000-000000000000"  # Replace with your subscription ID
    amount          = 5000  # $5000 monthly budget
    time_grain      = "Monthly"
    time_period = {
      start_date = "2026-01-01"
      end_date   = "2027-12-31"
    }
    notification = [
      {
        enabled        = true
        operator       = "GreaterThan"
        threshold      = 75  # Alert at 75% of budget
        threshold_type = "Actual"
        contact_emails = ["finance@example.com"]
      },
      {
        enabled        = true
        operator       = "GreaterThan"
        threshold      = 100  # Alert at 100% of budget
        threshold_type = "Actual"
        contact_emails = ["finance@example.com"]
      }
    ]
  }
}

output "budget_alert_id" {
  description = "The ID of the created Budget Alert"
  value       = module.azure_alerts.budget_alert_id
}
