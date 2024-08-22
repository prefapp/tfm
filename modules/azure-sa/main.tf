# DATA SECTION
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet
data "azurerm_subnet" "this" {
  for_each = { for subnet in var.subnet_name : subnet => subnet }
  name                 = each.value
  virtual_network_name = var.vnet_name
  resource_group_name  = var.vnet_resource_group_name
}

# https://registry.terraform.io/providers/hashicorp/azurerm/3.91.0/docs/data-sources/resource_group
data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

# RESOURCES SECTION
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account
resource "azurerm_storage_account" "this" {
  name                             = var.storage_account_name
  resource_group_name              = data.azurerm_resource_group.this.name
  location                         = data.azurerm_resource_group.this.location
  account_tier                     = var.storage_account_tier
  account_kind                     = var.storage_account_kind
  account_replication_type         = var.storage_account_replication_type
  min_tls_version                  = var.storage_account_min_tls_version
  enable_https_traffic_only        = var.storage_account_enable_https_traffic_only
  cross_tenant_replication_enabled = var.storage_account_cross_tenant_replication_enabled
  allow_nested_items_to_be_public  = var.storage_account_allow_nested_items_to_be_public

  blob_properties {
    versioning_enabled  = var.versioning_enabled
    change_feed_enabled = var.change_feed_enabled
    delete_retention_policy {
      days = var.blob_retention_soft_delete
    }
    container_delete_retention_policy {
      days = var.container_retention_soft_delete
    }
  }
  lifecycle {
    ignore_changes = [tags]
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_network_rules
resource "azurerm_storage_account_network_rules" "this" {
  storage_account_id = azurerm_storage_account.this.id
  default_action     = var.storage_account_network_rule_default_action
  virtual_network_subnet_ids = [ for subnet in data.azurerm_subnet.this : subnet.id ]
  bypass = [var.storage_account_network_rule_bypass]
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container.html
resource "azurerm_storage_container" "this" {
  for_each = {
    for container in var.storage_account_container_name : container.name => container
  }
  name                  = each.value.name
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = each.value.access_type
}

# BACKUPS
## BACKUPS FILE SHARES
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/recovery_services_vault
resource "azurerm_recovery_services_vault" "this" {
  name                = var.recovery_services_vault_name
  resource_group_name = data.azurerm_resource_group.this.name
  location            = data.azurerm_resource_group.this.location
  sku                 = var.sku
  soft_delete_enabled = var.soft_delete_enabled
  lifecycle {
    ignore_changes = [tags]
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/backup_container_storage_account
resource "azurerm_backup_container_storage_account" "this" {
  resource_group_name = data.azurerm_resource_group.this.name
  recovery_vault_name = var.recovery_services_vault_name
  storage_account_id  = azurerm_storage_account.this.id
}

## BACKUPS BLOBS
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_vault
resource "azurerm_data_protection_backup_vault" "this" {
  name                = var.backup_vault_name
  resource_group_name = data.azurerm_resource_group.this.name
  location            = data.azurerm_resource_group.this.location
  datastore_type      = var.backup_vault_datastore_type
  redundancy          = var.backup_vault_redundancy
  identity {
    type = var.backup_vault_identity_type
  }
  lifecycle {
    ignore_changes = [tags]
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
resource "azurerm_role_assignment" "this" {
  scope                = azurerm_storage_account.this.id
  role_definition_name = var.backup_role_assignment
  principal_id         = azurerm_data_protection_backup_vault.this.identity[0].principal_id
  depends_on           = [azurerm_data_protection_backup_vault.this]
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_policy_blob_storage
resource "azurerm_data_protection_backup_policy_blob_storage" "this" {
  name               = var.backup_policy_blob_name
  vault_id           = azurerm_data_protection_backup_vault.this.id
  retention_duration = var.backup_policy_retention_duration
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_instance_blob_storage
resource "azurerm_data_protection_backup_instance_blob_storage" "this" {
  name               = var.backup_instance_blob_name
  vault_id           = azurerm_data_protection_backup_vault.this.id
  location           = data.azurerm_resource_group.this.location
  storage_account_id = azurerm_storage_account.this.id
  backup_policy_id   = azurerm_data_protection_backup_policy_blob_storage.this.id
}

resource "azurerm_storage_management_policy" "this" {
  storage_account_id = azurerm_storage_account.this.id

  for_each = { for rule in var.lifecycle_policy_rule : rule.name => rule }

  rule {
    name    = each.value.name
    enabled = each.value.enabled

    filters {
      prefix_match = each.value.filters.prefix_match
      blob_types   = each.value.filters.blob_types
    }

    actions {
      base_blob { delete_after_days_since_creation_greater_than = each.value.actions.base_blob.delete_after_days_since_creation_greater_than }
      snapshot { delete_after_days_since_creation_greater_than = each.value.actions.snapshot.delete_after_days_since_creation_greater_than }
      version { delete_after_days_since_creation = each.value.actions.version.delete_after_days_since_creation }
    }
  }
}
