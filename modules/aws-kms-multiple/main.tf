module "multiple-kms" {
  source = "../aws-kms"
  for_each = {
    for kms in var.kms_to_create : kms.name => {
      name             = kms.name
      alias            = kms.alias != null ? kms.alias : kms.name
      kms_alias_prefix = kms.kms_alias_prefix != null ? kms.kms_alias_prefix : var.kms_alias_prefix
      via_service      = kms.via_service != null ? kms.via_service : []
    }
  }
  aws_region              = var.aws_region
  aws_accounts_access     = var.aws_accounts_access
  aws_regions_replica     = var.aws_regions_replica
  description             = var.description
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = var.enable_key_rotation
  multiregion             = var.multiregion
  tags                    = var.tags
  kms_alias_prefix        = (each.value.kms_alias_prefix != "" && each.value.kms_alias_prefix != null) ? each.value.kms_alias_prefix : var.kms_alias_prefix
  alias                   = (each.value.alias != "" && each.value.alias != null) ? each.value.alias : each.value.name
  administrator_role_name = var.administrator_role_name
  via_service             = length(each.value.via_service) > 0 ? each.value.via_service : null
}