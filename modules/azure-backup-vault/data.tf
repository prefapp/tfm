#Locals section
locals {
  tags = var.tags_from_rg ? merge(data.azurerm_resource_group.resource_group.tags, var.tags) : var.tags
}

#Data Section
#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group
data "azurerm_resource_group" "resource_group" {
  name = var.backup_resource_group_name
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/managed_disk
data "azurerm_managed_disk" "this" {
  for_each            = { for instance in var.disk_instances : instance.disk_name => instance }
  name                = each.value.disk_name
  resource_group_name = each.value.disk_resource_group
}

# Data source to get cluster ID by name
data "azurerm_kubernetes_cluster" "this" {
  for_each            = var.kubernetes_instances
  name                = each.value.cluster_name
  resource_group_name = each.value.resource_group_name
}
