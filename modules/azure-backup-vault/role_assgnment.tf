# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
# Role assignment RG
resource "azurerm_role_assignment" "this_rg" {
    scope                = data.azurerm_resource_group.resource_group.id
    role_definition_name = "Disk Snapshot Contributor" #Inputs
    principal_id         = azurerm_data_protection_backup_vault.this.identity[0].principal_id
    depends_on = [
      azurerm_data_protection_backup_vault.this
    ]
}

# Role assignment blob
resource "azurerm_role_assignment" "this_blob" {
  count                = var.backup_blob != null && can(var.backup_blob.identity_type) ? 1 : 0
  scope                = var.backup_blob.storage_account_id
  role_definition_name = var.backup_blob.role_assignment
  principal_id         = azurerm_data_protection_backup_vault.this.identity.principal_id
}

# Role assignment Disks
resource "azurerm_role_assignment" "this_disk" {
    for_each             = data.azurerm_managed_disk.this
    scope                = each.value.id
    role_definition_name = each.value.role_assignment
    principal_id         = azurerm_data_protection_backup_vault.this.identity.principal_id
}

# Role assignment kubernetes services
resource "azurerm_role_assignment" "this_kubernetes" {
  scope                = var.backup_kubernetes_services.cluster_ids[0]
  role_definition_name = var.backup_kubernetes_services.role_assignment
  principal_id         = azurerm_data_protection_backup_vault.this.identity.parincipal_id
}

# Role assignment postgresql flexible server
resource "azurerm_role_assignment" "this_postgresql_flexible" {
  scope                = var.backup_postgresql_flexible.server_names[0]
  role_definition_name = var.backup_postgresql_flexible.role_assignment
  principal_id         = azurerm_data_protection_backup_vault.this.identity.parincipal_id
}

# Role assignment MySQL server
resource "azurerm_role_assignment" "this_MySQL" {
  scope                = var.backup_mysql.server_names[0]
  role_definition_name = var.backup_mysql.role_assignment
  principal_id         = azurerm_data_protection_backup_vault.this.identity.parincipal_id
}
