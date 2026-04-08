output "action_group_id" {
  description = "The ID of the Azure Monitor Action Group."
  value       = azurerm_monitor_action_group.this.id
}

output "action_group_name" {
  description = "The name of the Azure Monitor Action Group."
  value       = azurerm_monitor_action_group.this.name
}

output "quota_alert_id" {
  description = "The ID of the quota scheduled query rules alert. Null if not created."
  value       = var.quota_alert != null ? azurerm_monitor_scheduled_query_rules_alert_v2.quota[0].id : null
}

output "quota_alert_reader_identity_id" {
  description = "The ID of the User Assigned Managed Identity used for the quota alert. Null if not created."
  value       = length(azurerm_user_assigned_identity.quota_alert_reader) > 0 ? azurerm_user_assigned_identity.quota_alert_reader[0].id : null
}

output "quota_alert_reader_principal_id" {
  description = "The principal ID of the quota alert Managed Identity. Null if not created."
  value       = length(azurerm_user_assigned_identity.quota_alert_reader) > 0 ? azurerm_user_assigned_identity.quota_alert_reader[0].principal_id : null
}

output "budget_alert_id" {
  description = "The ID of the consumption budget subscription alert. Null if not created."
  value       = var.budget != null ? azurerm_consumption_budget_subscription.this[0].id : null
}

output "activity_log_alert_ids" {
  description = "Map of activity log alert names to their resource IDs."
  value       = { for k, v in azurerm_monitor_activity_log_alert.this : k => v.id }
}

output "backup_alert_id" {
  description = "The ID of the alert processing rule for backup alerts. Null if not created."
  value       = var.backup_alert != null ? azurerm_monitor_alert_processing_rule_action_group.backup[0].id : null
}
