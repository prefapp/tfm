module "azure_sa" {
  source = "../../"

  resource_group_name = var.resource_group_name
  allowed_subnets     = var.allowed_subnets
  additional_allowed_subnet_ids = var.additional_allowed_subnet_ids

  storage_account = var.storage_account
  network_rules   = var.network_rules
  containers      = var.containers
  queues          = var.queues
  tables          = var.tables
  shares          = var.shares
  lifecycle_policy_rules = var.lifecycle_policy_rules
  tags            = var.tags
}