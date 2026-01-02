# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/web_application_firewall_policy
resource "azurerm_web_application_firewall_policy" "default_waf_policy" {
  name                = var.web_application_firewall_policy.name #"central-waf-policy-default-predev"
  resource_group_name = var.resource_group_name
  location            = var.location

  policy_settings {
    enabled = var.web_application_firewall_policy.policy_settings.enabled
    mode    = var.web_application_firewall_policy.policy_settings.mode
    request_body_check = var.web_application_firewall_policy.policy_settings.request_body_check
    request_body_enforcement = var.web_application_firewall_policy.policy_settings.request_body_enforcement
    file_upload_limit_in_mb = var.web_application_firewall_policy.policy_settings.file_upload_limit_in_mb
    max_request_body_size_in_kb = var.web_application_firewall_policy.policy_settings.max_request_body_size_in_kb
  }

  dynamic "custom_rules" {
    for_each = var.web_application_firewall_policy.custom_rules
    content {
      enabled    = coalesce(custom_rules.value.enabled, true)
      name       = custom_rules.value.name
      priority   = custom_rules.value.priority
      rule_type  = custom_rules.value.rule_type
      action     = custom_rules.value.action

      # Optional fields for RateLimitRule
      rate_limit_duration   = custom_rules.value.rate_limit_duration
      rate_limit_threshold  = custom_rules.value.rate_limit_threshold
      group_rate_limit_by   = custom_rules.value.group_rate_limit_by

      dynamic "match_conditions" {
        for_each = coalesce(custom_rules.value.match_conditions, [])
        content {
          operator           = match_conditions.value.operator
          negation_condition = coalesce(match_conditions.value.negation_condition, false)
          match_values       = match_conditions.value.match_values
          transforms         = match_conditions.value.transforms

          dynamic "match_variables" {
            for_each = coalesce(match_conditions.value.match_variables, [])
            content {
              variable_name = match_variables.value.variable_name
              selector      = match_variables.value.selector
            }
          }
        }
      }
    }
  }

  managed_rules {
    dynamic "managed_rule_set" {
      for_each = var.web_application_firewall_policy.managed_rule_set
      content {
        type    = managed_rule_set.value.type
        version = managed_rule_set.value.version
        dynamic "rule_group_override" {
          for_each = coalesce(managed_rule_set.value.rule_group_override, [])
          content {
            rule_group_name = rule_group_override.value.rule_group_name
            dynamic "rule" {
              for_each = coalesce(rule_group_override.value.rule, [])
              content {
                id      = rule.value.id
                enabled = rule.value.enabled
                action  = rule.value.action
              }
            }
          }
        }
      }
    }
  }
  tags = local.tags
}
