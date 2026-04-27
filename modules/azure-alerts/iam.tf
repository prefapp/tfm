# Managed Identity for Quota Alert to read the quota metrics from the subscription
## https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity
resource "azurerm_user_assigned_identity" "quota_alert_reader" {
  count               = local.needs_module_identity && local.resource_group_name != null ? 1 : 0
  name                = coalesce(try(var.identity.name, null), "quota-alert-reader")
  resource_group_name = local.resource_group_name
  location            = var.common.location
}

# Role Assignment for the Managed Identity to have Reader access on the subscription to read the quota metrics
## https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
resource "azurerm_role_assignment" "quota_reader" {
  count                = local.needs_module_identity && local.resource_group_name != null ? 1 : 0
  scope                = coalesce(try(var.identity.scope, null), "/subscriptions/${data.azurerm_client_config.current.subscription_id}")
  role_definition_name = coalesce(try(var.identity.role_definition_name, null), "Reader")
  principal_id         = azurerm_user_assigned_identity.quota_alert_reader[0].principal_id
}

check "action_group_resource_group_fallback" {
  assert {
    condition = (
      length(local.action_group_resource_group_names) <= 1 ||
      !(
        var.common.resource_group_name == null && (
          var.common.tags_from_rg ||
          local.needs_module_identity ||
          length(local.quota_alert_entries) > 0 ||
          length([for _, alert in local.backup_alert_entries : alert if try(alert.resource_group_name, null) == null]) > 0 ||
          length([for alert in var.log_alert : alert if try(alert.resource_group_name, null) == null]) > 0
        )
      )
    )
    error_message = "action_group entries may use different resource_group_name values unless a single resource group must be inferred for tags_from_rg, identity, quota_alert, backup_alert, or log_alert entries without resource_group_name."
  }
}

check "action_group_resource_group_mismatch" {
  assert {
    condition = var.common.resource_group_name == null || length([
      for rg in local.action_group_resource_group_names : rg
      if rg != var.common.resource_group_name
    ]) == 0
    error_message = "common.resource_group_name and action_group[*].resource_group_name must match when both are set."
  }
}

check "resource_group_name_required_when_needed" {
  assert {
    condition = !(
      var.common.tags_from_rg ||
      local.needs_module_identity ||
      length(local.quota_alert_entries) > 0 ||
      length([for _, alert in local.backup_alert_entries : alert if try(alert.resource_group_name, null) == null]) > 0 ||
      length([for alert in var.log_alert : alert if try(alert.resource_group_name, null) == null]) > 0
    ) || local.resource_group_name != null
    error_message = "common.resource_group_name must be set when tags_from_rg, identity, quota_alert, backup_alert, or log_alert entries without resource_group_name are used and no single action_group resource group can be inferred."
  }
}
