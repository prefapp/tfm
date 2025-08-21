## Common and vault data sources ##
# Data source to get the current Azure client configuration
data "azurerm_client_config" "current" {}

# Data source to get the resource group for the backup vault
data "azurerm_resource_group" "this" {
  name = var.backup_resource_group_name
}

## Disk specific data sources ##
# Data source to get the resource group for the disks
data "azurerm_resource_group" "disk_rg" {
  for_each = { for rg in local.unique_disk_resource_groups : rg => rg }
  name     = each.value
}
# Data source to get the managed disk by name
data "azurerm_managed_disk" "this" {
  for_each            = { for instance in var.disk_instances : instance.name => instance }
  name                = each.value.name
  resource_group_name = each.value.disk_resource_group
}

## PostgreSQL specific data sources ##
# Data source for each unique PostgreSQL resource group
data "azurerm_resource_group" "postgresql_rg" {
  for_each = { for rg in local.unique_postgresql_resource_groups : rg => rg }
  name     = each.value
}

## MySQL specific data sources ##
# Data source for each unique MySQL resource group
data "azurerm_resource_group" "mysql_rg" {
  for_each = { for rg in local.unique_mysql_resource_groups : rg => rg }
  name     = each.value
}

## Kubernetes specific data sources ##
# Data source to get cluster ID by name
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/kubernetes_cluster
data "azurerm_kubernetes_cluster" "this" {
  for_each            = { for instance in var.kubernetes_instances : instance.name => instance }
  name                = each.value.cluster_name
  resource_group_name = each.value.resource_group_name
}

data "azurerm_resource_group" "kubernetes_rg" {
  for_each = { for rg in local.unique_kubernetes_resource_groups : rg => rg }
  name     = each.value
}

data "azurerm_resource_group" "snapshot_rg" {
  for_each = { for instance in local.unique_kubernetes_snapshot_resource_groups : instance => instance }
  name     = each.value
}

data "azurerm_storage_account" "backup" {
  for_each = {
    for instance in var.kubernetes_instances :
    "${instance.extension_configuration.bucket_storage_account_name}|${instance.name}" => instance
    if instance.extension_configuration.bucket_storage_account_name != null && instance.extension_configuration.bucket_resource_group_name != null
  }
  name                = each.value.extension_configuration.bucket_storage_account_name
  resource_group_name = each.value.extension_configuration.bucket_resource_group_name
}
