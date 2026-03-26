locals {
  has_cross_account_copy_default = var.copy_action_default_values.destination_account_id != null && var.copy_action_default_values.destination_account_id != data.aws_caller_identity.current ? true : false
  # Devuelve true si hay algún copy_action con destination_vault_arn cuyo account_id es diferente al actual
  has_cross_account_copy_in_plan = anytrue([
    for vault in var.aws_backup_vault : (
      vault.plan != null ? anytrue([
        for plan in vault.plan : (
          plan.copy_action != null ? anytrue([
            for ca in plan.copy_action : (
              length(regexall("^arn:aws:backup:[^:]+:([0-9]+):backup-vault:.*$", ca.destination_vault_arn)) > 0 &&
              regex("^arn:aws:backup:[^:]+:([0-9]+):backup-vault:.*$", ca.destination_vault_arn)[0] != data.aws_caller_identity.current.account_id
            )
          ]) : false
        )
      ]) : false
    )
  ])
  has_cross_account_copy = local.has_cross_account_copy_in_plan || local.has_cross_account_copy_default
}
