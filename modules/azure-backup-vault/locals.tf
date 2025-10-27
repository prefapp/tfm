locals {
  # Handle tags based on whether to use resource group tags or module-defined tags
  tags = var.tags_from_rg && length(data.azurerm_resource_group.this) > 0
    ? merge(data.azurerm_resource_group.this[0].tags, var.tags)
    : var.tags

  ## Disk specific locals ##
  # List of unique disk resource groups from the disk instances
  unique_disk_resource_groups = distinct([for instance in var.disk_instances : instance.disk_resource_group])

  ## MySQL specific locals ##
  # Convert the list of policies to a map for easy lookup
  mysql_policies_by_name = { for policy in var.mysql_policies : policy.name => policy }
  # Get unique MySQL resource groups
  unique_mysql_resource_groups = distinct([for instance in var.mysql_instances : instance.resource_group_name])

  ## PostgreSQL specific locals ##
  # Convert the list of policies to a map for easy lookup
  postgresql_policies_by_name = { for policy in var.postgresql_policies : policy.name => policy }
  # Get unique PostgreSQL resource groups
  unique_postgresql_resource_groups = distinct([for instance in var.postgresql_instances : instance.resource_group_name])

  ## Kubernetes specific locals ##
  # Get unique Kubernetes resource groups
  unique_kubernetes_snapshot_resource_groups = distinct([for instance in var.kubernetes_instances : instance.snapshot_resource_group_name])
  unique_kubernetes_resource_groups          = distinct([for instance in var.kubernetes_instances : instance.resource_group_name])
  # Groups only the first instance by cluster_name
  kubernetes_instances_by_cluster = {
    for instance in var.kubernetes_instances : instance.cluster_name => instance
    if length([
      for i in var.kubernetes_instances : i if i.cluster_name == instance.cluster_name
      ]) > 0 && instance.name == try([
      for i in var.kubernetes_instances : i.name if i.cluster_name == instance.cluster_name
    ][0], null)
  }
}

