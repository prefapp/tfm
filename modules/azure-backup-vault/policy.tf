resource "azurerm_data_protection_backup_policy" "this" {
  for_each = { for p in var.policy : p.name => p }

  name                                   = each.value.name
  vault_id                               = each.value.vault_id
  time_zone                              = each.value.time_zone
  backup_repeating_time_intervals        = each.value.backup_repeating_time_intervals
  operational_default_retention_duration = each.value.operational_default_retention_duration
  vault_default_retention_duration       = each.value.vault_default_retention_duration
  retention_duration                     = each.value.retention_duration

  dynamic "retention_rule" {
    for_each = each.value.retention_rule
    content {
      name     = retention_rule.value.name
      duration = retention_rule.value.duration
      priority = retention_rule.value.priority

      dynamic "criteria" {
        for_each = retention_rule.value.criteria != null ? [retention_rule.value.criteria] : []
        content {
          days_of_week  = lookup(criteria.value, "days_of_week", null)
          days_of_month = lookup(criteria.value, "days_of_month", null)
        }
      }

      dynamic "life_cycle" {
        for_each = retention_rule.value.life_cycle != null ? [retention_rule.value.life_cycle] : []
        content {
          data_store_type = life_cycle.value.data_store_type
          duration        = life_cycle.value.duration
        }
      }
    }
  }
}
