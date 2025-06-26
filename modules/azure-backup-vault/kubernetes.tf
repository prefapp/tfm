# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_vault
resource "azurerm_data_protection_backup_vault" "kubernetes" {
  count               = var.backup_kubernetes_services != null ? 1 : 0
  name                = var.backup_kubernetes_services.vault_name
  resource_group_name = data.azurerm_resource_group.name
  location            = data.azurerm_resource_group.resource_group.location
  datastore_type      = var.backup_kubernetes_services.datastore_type
  redundancy          = var.backup_kubernetes_services.redundancy
  tags                = local.tags
  identity {
    type = "SystemAssigned"
    }

  lifecycle {
    ignore_changes = [tags]
  }
}

# Kubernetes instance backup
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_instance_kubernetes_cluster
resource "azurerm_data_protection_backup_instance_kubernetes_cluster" "this" {
  count                        = var.backup_kubernetes_services.vault_name != null ? 1 : 0
  name                         = var.backup_kubernetes_services.instance_name
  redundancy                   = var.backup_kubernetes_services.redundancy
  location                     = data.azurerm_resource_group.resource_group.location
  vault_id                     = azurerm_data_protection_backup_vault.kubernetes.id
  kubernetes_cluster_id        = var.backup_kubernetes_services.cluster_ids[0]
  snapshot_resource_group_name = var.backup_kubernetes_services.snapshot_resource_group_name
  backup_policy_id             = # Policy module

  backup_datasource_parameters {
    excluded_namespaces = var.backup_kubernetes_services.backup_datasource_parameters.excluded_namespaces
    excluded_resource_types = var.backup_kubernetes_services.backup_datasource_parameters.excluded_resource_types
    cluster_scoped_resources_enabled = var.backup_kubernetes_services.backup_datasource_parameters.cluster_scoped_resources_enabled
    included_namespaces = var.backup_kubernetes_services.backup_datasource_parameters.included_namespaces
    included_resource_types = var.backup_kubernetes_services.backup_datasource_parameters.included_resource_types
  }

  depends_on = [azurerm_role_assignment.this_rg,
                azurerm_role_assignment.this_kubernetes]
  }

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_extension
resource "azurerm_kubernetes_cluster_extension" "this" {
  name           = var.extension.name
  cluster_id     = var.backup_kubernetes_services.cluster_ids[0]
  extension_type = var.extension.extension_type

  depends_on = [azurerm_data_protection_backup_instance_kubernetes_cluster.this]
}

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_trusted_access_role_binding
resource "azurerm_kubernetes_cluster_trusted_access_role_binding" "this" {
  kubernetes_cluster_id = var.backup_kubernetes_services.cluster_ids[0]
  name                  = var.trusted_role.name
  roles                 = var.trusted_role.roles
  source_resource_id    = azurerm_data_protection_backup_vault.kubernetes.id
}
