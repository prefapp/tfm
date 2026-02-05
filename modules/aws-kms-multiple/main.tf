module "multiple-kms" {
  source                  = "../aws-kms"
  for_each                = toset(var.kms_to_create)
  aws_region              = var.aws_region
  aws_accounts_access     = var.aws_accounts_access
  aws_regions_replica     = var.aws_regions_replica
  description             = var.description
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = var.enable_key_rotation
  multiregion             = var.multiregion
  tags                    = var.tags
  alias                   = "custom/${each.value}"
  administrator_role_name = var.administrator_role_name
}