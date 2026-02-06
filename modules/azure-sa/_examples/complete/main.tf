locals {
  values = yamldecode(file("./values.yaml"))
}

module "storage_account" {
  source = "../.."
  resource_group_name = local.values.resource_group_name
  storage_account     = local.values.storage_account
  allowed_subnets     = local.values.allowed_subnets
  additional_allowed_subnet_ids = local.values.additional_allowed_subnet_ids
  network_rules       = local.values.network_rules
  containers          = local.values.containers
  queues              = local.values.queues
  tables              = local.values.tables
  shares              = local.values.shares
  lifecycle_policy_rules = local.values.lifecycle_policy_rules
  tags                = local.values.tags
}
