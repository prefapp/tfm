# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/web_application_firewall_policy
resource "azurerm_web_application_firewall_policy" "default_waf_policy" {
  name                = var.web_application_firewall_policy.name #"central-waf-policy-default-predev"
  resource_group_name = var.resource_group_name
  location            = var.location
  # Max 1 managed_rule_set block
  policy_settings {
    enabled = var.web_application_firewall_policy.policy_settings.enabled
    mode    = var.web_application_firewall_policy.policy_settings.mode
    request_body_check = var.web_application_firewall_policy.policy_settings.request_body_check
    file_upload_limit_in_mb = var.web_application_firewall_policy.policy_settings.file_upload_limit_in_mb
    max_request_body_size_in_kb = var.web_application_firewall_policy.policy_settings.max_request_body_size_in_kb
  }

  managed_rules {
    dynamic "managed_rule_set" {
        for_each = var.web_application_firewall_policy.managed_rule_sets
        content {
            type    = managed_rule_set.value.type
            version = managed_rule_set.value.version
        }
    }
  }

  lifecycle {
    ignore_changes = [tags]
  }
}
