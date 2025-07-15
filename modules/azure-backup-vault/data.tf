# Locals section
locals {
  tags = var.tags_from_rg && length(data.azurerm_resource_group.this) > 0 ? merge(data.azurerm_resource_group.this[0].tags, var.tags) : var.tags
}

# Data source to get the current Azure client configuration
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources
data "azurerm_client_config" "current" {}

# Data source to get the resource group for the backup vault
#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group
data "azurerm_resource_group" "this" {
  count = var.vault != null && var.backup_resource_group_name != null ? 1 : 0
  name  = var.backup_resource_group_name
}

# Data source to get the managed disk by name
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/managed_disk
data "azurerm_managed_disk" "this" {
  for_each            = { for instance in var.disk_instances : instance.disk_name => instance }
  name                = each.value.disk_name
  resource_group_name = each.value.disk_resource_group
}

# Data source to get cluster ID by name
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/kubernetes_cluster
data "azurerm_kubernetes_cluster" "this" {
  for_each            = var.kubernetes_instances
  name                = each.value.cluster_name
  resource_group_name = each.value.resource_group_name
}
