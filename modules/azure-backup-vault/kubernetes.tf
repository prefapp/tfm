# Role assignment: Reader for the AKS cluster identity over the Kubernetes cluster
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
resource "azurerm_role_assignment" "kubernetes_reader" {
  for_each             = { for instance in var.kubernetes_instances : instance.name => instance }
  scope                = data.azurerm_kubernetes_cluster.this[each.value.cluster_name].id
  role_definition_name = "Reader"
  principal_id         = data.azurerm_kubernetes_cluster.this[each.value.cluster_name].identity[0].principal_id
}

# Role assignment: Reader for the Backup Vault identity over the snapshot resource group
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
resource "azurerm_role_assignment" "vault_reader_on_snapshot_rg" {
  for_each             = { for instance in var.kubernetes_instances : instance.snapshot_resource_group_name => instance }
  scope                = data.azurerm_resource_group.snapshot_rg[each.key].id
  role_definition_name = "Reader"
  principal_id         = azurerm_data_protection_backup_vault.this.identity[0].principal_id
}

# Role assignment: Contributor for the AKS cluster identity over the snapshot resource group
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
resource "azurerm_role_assignment" "aks_contributor_on_snapshot_rg" {
  for_each             = { for instance in var.kubernetes_instances : instance.name => instance }
  scope                = data.azurerm_resource_group.snapshot_rg[each.value.snapshot_resource_group_name].id
  role_definition_name = "Contributor"
  principal_id         = data.azurerm_kubernetes_cluster.this[each.value.cluster_name].identity[0].principal_id
}

# Role assignment: Storage Blob Data Contributor for the AKS cluster extension identity over the storage account
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
resource "azurerm_role_assignment" "extension_storage_blob_data_contributor" {
  for_each             = { for instance in var.kubernetes_instances : instance.name => instance }
  scope                = data.azurerm_storage_account.backup[each.value.name].id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_kubernetes_cluster_extension.this[each.value.cluster_name].aks_assigned_identity[0].principal_id
}

# Ensure the Microsoft.KubernetesConfiguration provider is registered
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_provider_registration
resource "azurerm_resource_provider_registration" "this" {
  count = length(var.kubernetes_instances) > 0 ? 1 : 0
  name = "Microsoft.KubernetesConfiguration"
}

# Cluster extension for backup
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_extension
resource "azurerm_kubernetes_cluster_extension" "this" {
  for_each = local.kubernetes_instances_by_cluster

  name              = "backup-extension"
  cluster_id        = data.azurerm_kubernetes_cluster.this[each.key].id
  extension_type    = "Microsoft.DataProtection.Kubernetes"
  release_train     = "stable"
  release_namespace = "dataprotection-microsoft"
  configuration_settings = {
    "configuration.backupStorageLocation.bucket"                   = try(each.value.extension_configuration.bucket_name, null)
    "configuration.backupStorageLocation.config.resourceGroup"     = try(each.value.extension_configuration.bucket_resource_group_name, null)
    "configuration.backupStorageLocation.config.storageAccount"    = try(each.value.extension_configuration.bucket_storage_account_name, null)
    "configuration.backupStorageLocation.config.subscriptionId"    = data.azurerm_client_config.current.subscription_id
    "credentials.tenantId"                                         = data.azurerm_client_config.current.tenant_id
    "configuration.backupStorageLocation.config.useAAD"            = true
    "configuration.backupStorageLocation.config.storageAccountURI" = data.azurerm_storage_account.backup[each.value.name].primary_blob_endpoint
  }
  depends_on = [
    azurerm_resource_provider_registration.this[0],
    azurerm_data_protection_backup_instance_blob_storage.this,
    azurerm_role_assignment.vault_reader_on_snapshot_rg,
    azurerm_role_assignment.aks_contributor_on_snapshot_rg
  ]
}

# Cluster trusted access role binding for backup
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_trusted_access_role_binding
resource "azurerm_kubernetes_cluster_trusted_access_role_binding" "this" {
  for_each              = { for instance in var.kubernetes_instances : instance.name => instance }
  kubernetes_cluster_id = data.azurerm_kubernetes_cluster.this[each.value.cluster_name].id
  name                  = each.value.name
  roles                 = ["Microsoft.DataProtection/backupVaults/backup-operator"]
  source_resource_id    = azurerm_data_protection_backup_vault.this.id
  depends_on = [
    azurerm_kubernetes_cluster_extension.this
  ]
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
  kubernetes_cluster_id        = data.azurerm_kubernetes_cluster.this[each.value.cluster_name].id
  snapshot_resource_group_name = each.value.snapshot_resource_group_name
  backup_policy_id             = azurerm_data_protection_backup_policy_kubernetes_cluster.this[each.value.policy_key].id

  backup_datasource_parameters {
    excluded_namespaces              = try(each.value.backup_datasource_parameters.excluded_namespaces, [])
    excluded_resource_types          = try(each.value.backup_datasource_parameters.excluded_resource_types, [])
    cluster_scoped_resources_enabled = try(each.value.backup_datasource_parameters.cluster_scoped_resources_enabled, false)
    included_namespaces              = try(each.value.backup_datasource_parameters.included_namespaces, [])
    included_resource_types          = try(each.value.backup_datasource_parameters.included_resource_types, [])
    label_selectors                  = try(each.value.backup_datasource_parameters.label_selectors, [])
    volume_snapshot_enabled          = try(each.value.backup_datasource_parameters.volume_snapshot_enabled, false)
  }

  depends_on = [
    azurerm_kubernetes_cluster_extension.this,
    azurerm_kubernetes_cluster_trusted_access_role_binding.this,
    azurerm_role_assignment.kubernetes_reader,
    azurerm_role_assignment.vault_reader_on_snapshot_rg,
    azurerm_role_assignment.aks_contributor_on_snapshot_rg,
    azurerm_role_assignment.extension_storage_blob_data_contributor,
    azurerm_data_protection_backup_policy_kubernetes_cluster.this,
    azurerm_data_protection_backup_vault.this
  ]
}
