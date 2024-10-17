# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_policy_disk
resource "azurerm_data_protection_backup_policy_disk" "this" {
    for_each = { for policy in var.backup_policies : policy.name => policy }

    name     = each.value.name
    vault_id = azurerm_data_protection_backup_vault.this.id

    backup_repeating_time_intervals = each.value.backup_repeating_time_intervals
    default_retention_duration      = each.value.default_retention_duration
    time_zone                       = each.value.time_zone

    dynamic "retention_rule" {
        for_each = each.value.retention_rules
        content {
            name     = retention_rule.value.name
            duration = retention_rule.value.duration
            priority = retention_rule.value.priority
            criteria {
                absolute_criteria = retention_rule.value.criteria.absolute_criteria
            }
        }
    }
    depends_on = [
      azurerm_data_protection_backup_vault.this
    ]
}
