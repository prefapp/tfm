module "multiple-kms" {
  source = "../aws-kms"
  for_each = {
    for kms in var.kms_to_create : kms.name => {
      name                       = kms.name
      alias                      = try(kms.alias, null)
      kms_alias_prefix           = try(kms.kms_alias_prefix, null)
      via_service                = try(kms.via_service, [])
      user_roles_with_read       = try(kms.user_roles_with_read, [])
      user_roles_with_read_write = try(kms.user_roles_with_read_write, [])
    }
  }
  aws_region                 = var.aws_region
  aws_accounts_access        = var.aws_accounts_access
  aws_regions_replica        = var.aws_regions_replica
  description                = var.description
  deletion_window_in_days    = var.deletion_window_in_days
  enable_key_rotation        = var.enable_key_rotation
  multiregion                = var.multiregion
  tags                       = var.tags
  kms_alias_prefix           = (each.value.kms_alias_prefix != "" && each.value.kms_alias_prefix != null) ? each.value.kms_alias_prefix : var.kms_alias_prefix
  alias                      = (each.value.alias != "" && each.value.alias != null) ? each.value.alias : each.value.name
  administrator_role_name    = var.administrator_role_name
  user_roles_with_read       = (each.value.user_roles_with_read != null && each.value.user_roles_with_read != []) ? each.value.user_roles_with_read : var.user_roles_with_read
  user_roles_with_read_write = (each.value.user_roles_with_read_write != null && each.value.user_roles_with_read_write != []) ? each.value.user_roles_with_read_write : var.user_roles_with_read_write
  via_service                = (each.value.via_service != null && each.value.via_service != []) ? each.value.via_service : null
}