# Role assignment: Kubernetes Backup Contributor to each cluster
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
resource "azurerm_role_assignment" "kubernetes_backup_contributor" {
  for_each             = { for instance in var.kubernetes_instances : instance.name => instance }
  scope                = data.azurerm_kubernetes_cluster.this[each.key].id
  role_definition_name = "Kubernetes Backup Contributor"
  principal_id         = azurerm_data_protection_backup_vault.this.identity[0].principal_id
}

# Role assignment for restore operations
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
resource "azurerm_role_assignment" "kubernetes_cluster_admin" {
  for_each             = { for instance in var.kubernetes_instances : instance.name => instance }
  scope                = data.azurerm_kubernetes_cluster.this[each.key].id
  role_definition_name = "Kubernetes Cluster Admin"
  principal_id         = azurerm_data_protection_backup_vault.this.identity[0].principal_id
}

# Cluster extension for backup
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_extension
resource "azurerm_kubernetes_cluster_extension" "this" {
  for_each          = { for instance in var.kubernetes_instances : instance.name => instance }
  name              = each.value.name
  cluster_id        = data.azurerm_kubernetes_cluster.this[each.key].id
  extension_type    = "Microsoft.DataProtection.Kubernetes"
  release_train     = "stable"
  release_namespace = "dataprotection-microsoft"
  configuration_settings = {
    "configuration.backupStorageLocation.bucket"                = try(each.value.extension_configuration.bucket_name, null)
    "configuration.backupStorageLocation.config.resourceGroup"  = try(each.value.extension_configuration.bucket_resource_group_name, null)
    "configuration.backupStorageLocation.config.storageAccount" = try(each.value.extension_configuration.bucket_storage_account_name, null)
    "configuration.backupStorageLocation.config.subscriptionId" = data.azurerm_client_config.current.subscription_id
    "credentials.tenantId"                                      = data.azurerm_client_config.current.tenant_id
  }
}

# Cluster trusted access role binding
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_trusted_access_role_binding
resource "azurerm_kubernetes_cluster_trusted_access_role_binding" "this" {
  for_each              = { for instance in var.kubernetes_instances : instance.name => instance }
  kubernetes_cluster_id = data.azurerm_kubernetes_cluster.this[each.key].id
  name                  = "role-binding-${each.value.name}"
  roles                 = ["Microsoft.DataProtection/backupVaults/backup-operator"]
  source_resource_id    = azurerm_data_protection_backup_vault.this.id
}

# Backup policy for Kubernetes cluster
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_policy_kubernetes_cluster
resource "azurerm_data_protection_backup_policy_kubernetes_cluster" "this" {
  for_each                        = { for policy in var.kubernetes_policies : policy.name => policy }
  name                            = each.value.name
  resource_group_name             = data.azurerm_resource_group.this.name
  vault_name                      = azurerm_data_protection_backup_vault.this.name
  time_zone                       = try(each.value.time_zone, null)
  backup_repeating_time_intervals = each.value.backup_repeating_time_intervals

  default_retention_rule {
    life_cycle {
      data_store_type = each.value.default_retention_rule.life_cycle.data_store_type
      duration        = each.value.default_retention_rule.life_cycle.duration
    }
  }

  dynamic "retention_rule" {
    for_each = each.value.retention_rule != null ? each.value.retention_rule : []
    content {
      name     = retention_rule.value.name
      priority = retention_rule.value.priority
      life_cycle {
        data_store_type = retention_rule.value.life_cycle.data_store_type
        duration        = retention_rule.value.life_cycle.duration
      }
      criteria {
        absolute_criteria      = try(retention_rule.value.criteria.absolute_criteria, null)
        days_of_week           = try(retention_rule.value.criteria.days_of_week, null)
        months_of_year         = try(retention_rule.value.criteria.months_of_year, null)
        weeks_of_month         = try(retention_rule.value.criteria.weeks_of_month, null)
        scheduled_backup_times = try(retention_rule.value.criteria.scheduled_backup_times, null)
      }
    }
  }
}

# Backup instance for Kubernetes cluster
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_instance_kubernetes_cluster
resource "azurerm_data_protection_backup_instance_kubernetes_cluster" "this" {
  for_each                     = { for instance in var.kubernetes_instances : instance.name => instance }
  name                         = each.value.name
  location                     = data.azurerm_resource_group.this.location
  vault_id                     = azurerm_data_protection_backup_vault.this.id
  kubernetes_cluster_id        = data.azurerm_kubernetes_cluster.this[each.key].id
  snapshot_resource_group_name = each.value.snapshot_resource_group_name
  backup_policy_id             = azurerm_data_protection_backup_policy_kubernetes_cluster.this[each.value.policy_key].id

  backup_datasource_parameters {
    excluded_namespaces              = try(each.value.backup_datasource_parameters.excluded_namespaces, null)
    excluded_resource_types          = try(each.value.backup_datasource_parameters.excluded_resource_types, null)
    cluster_scoped_resources_enabled = try(each.value.backup_datasource_parameters.cluster_scoped_resources_enabled, null)
    included_namespaces              = try(each.value.backup_datasource_parameters.included_namespaces, null)
    included_resource_types          = try(each.value.backup_datasource_parameters.included_resource_types, null)
    label_selectors                  = try(each.value.backup_datasource_parameters.label_selectors, [])
    volume_snapshot_enabled          = try(each.value.backup_datasource_parameters.volume_snapshot_enabled, null)
  }

  depends_on = [
    azurerm_role_assignment.kubernetes_backup_contributor,
    azurerm_role_assignment.kubernetes_cluster_admin,
    azurerm_kubernetes_cluster_extension.this,
    azurerm_kubernetes_cluster_trusted_access_role_binding.this,
    azurerm_role_assignment.vault_backup_contributor
  ]
}
