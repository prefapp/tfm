# Example: Configure an Action Group with multiple receiver types

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

  # Action Group with email, SMS, webhook, and automation runbook receivers
  action_group = {
    name                = "example-action-group"
    resource_group_name = "example-alerts-rg"
    short_name          = "ExmplAG"

    email_receivers = {
      alert_admin = {
        name          = "Alert Admin"
        email_address = "alert-admin@example.com"
      }
      ops_team = {
        name          = "Operations Team"
        email_address = "ops@example.com"
      }
    }

    sms_receivers = {
      on_call = {
        name         = "On Call"
        country_code = "US"
        phone_number = "+12345678900"
      }
    }

    webhook_receivers = {
      incident_response = {
        name        = "Incident Response Webhook"
        service_uri = "https://incidents.example.com/webhook"
      }
    }

    arm_role_receivers = {
      owner_role = {
        name    = "Subscription Owner"
        role_id = "8e3af657-a8ff-443c-a75c-2fe8c4bcb635" # Owner role
      }
    }
  }
}

output "action_group_id" {
  description = "The ID of the created Action Group"
  value       = module.azure_alerts.action_group_id
}

output "action_group_name" {
  description = "The name of the created Action Group"
  value       = module.azure_alerts.action_group_name
}
