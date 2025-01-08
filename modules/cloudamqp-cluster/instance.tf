# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault
data "azurerm_key_vault" "key_vault_corpme_common_predev" {
  name                = "corpme-common-predev-kv"
  resource_group_name = "corpme-common-predev"
}

# https://registry.terraform.io/providers/cloudamqp/cloudamqp/1.32.2/docs/resources/instance
resource "cloudamqp_instance" "this" {
  name                = var.cloudamqp_instance.name
  plan                = var.cloudamqp_instance.plan
  region              = var.cloudamqp_instance.region
  tags                = var.cloudamqp_instance.tags
  nodes               = var.cloudamqp_instance.nodes
  rmq_version         = var.cloudamqp_instance.rmq_version
  keep_associated_vpc = var.cloudamqp_instance.keep_associated_vpc
  no_default_alarms   = var.cloudamqp_instance.no_default_alarms
  lifecycle {
    ignore_changes = [rmq_version]
  }
}
