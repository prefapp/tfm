# DATA SECTION
## https://registry.terraform.io/providers/hashicorp/azurerm/3.113.0/docs/data-sources/client_config
data "azurerm_client_config" "current" {}

## https://registry.terraform.io/providers/hashicorp/azurerm/3.113.0/docs/data-sources/resource_group
data "azurerm_resource_group" "this" {
  name = var.resource_group
}

## https://registry.terraform.io/providers/hashicorp/azuread/2.53.0/docs/data-sources/user
data "azuread_user" "this" {
  for_each = {
    for entity in var.access_policies : entity.name => entity
    if entity.type == "user"
  }
  user_principal_name = each.value.name
}

## https://registry.terraform.io/providers/hashicorp/azuread/2.53.0/docs/data-sources/group
data "azuread_group" "this" {
  for_each = {
    for entity in var.access_policies : entity.name => entity
    if entity.type == "group"
  }
  display_name     = each.value.name
  security_enabled = true
}

## https://registry.terraform.io/providers/hashicorp/azuread/2.53.0/docs/data-sources/service_principal
data "azuread_service_principal" "this" {
  for_each = {
    for entity in var.access_policies : entity.name => entity
    if entity.type == "service_principal"
  }
  display_name = each.value.name
}

## Locals for the datas of the entities
locals {
  # Creating a map with entity names as keys and their object_ids as values
  entity_ids = {
    for entity in var.access_policies : entity.name => (
      entity.object_id != "" ? entity.object_id :
      entity.type == "user" ? data.azuread_user.this[entity.name].id :
      entity.type == "group" ? data.azuread_group.this[entity.name].id :
      entity.type == "service_principal" ? data.azuread_service_principal.this[entity.name].object_id :
      null
    )
  }

  # Convert the map values to a list and filter out nulls
  object_ids = [for id in local.entity_ids : id if id != null]

  # Check if access policies are defined when RBAC is enabled
  has_access_policies = length(var.access_policies) > 0 && var.enable_rbac_authorization
}


# RESOURCES SECTION
## https://registry.terraform.io/providers/hashicorp/azurerm/3.113.0/docs/resources/key_vault
resource "azurerm_key_vault" "this" {
  name                        = var.name
  location                    = data.azurerm_resource_group.this.location
  resource_group_name         = data.azurerm_resource_group.this.name
  enabled_for_disk_encryption = var.enabled_for_disk_encryption
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = var.soft_delete_retention_days
  enable_rbac_authorization   = var.enable_rbac_authorization
  purge_protection_enabled    = var.purge_protection_enabled
  sku_name                    = var.sku_name
  tags                        = var.tags_from_rg ? merge(data.azurerm_resource_group.this.tags, var.tags) : var.tags
  lifecycle {
    precondition {
      condition     = !local.has_access_policies
      error_message = "Access policies cannot be defined when RBAC authorization is enabled."
    }
  }

  dynamic "access_policy" {
    for_each = var.enable_rbac_authorization ? [] : [for entity in var.access_policies : entity if lookup(local.entity_ids, entity.name, null) != null]
    content {
      tenant_id               = data.azurerm_client_config.current.tenant_id
      object_id               = lookup(local.entity_ids, access_policy.value.name, null)
      key_permissions         = access_policy.value.key_permissions
      secret_permissions      = access_policy.value.secret_permissions
      certificate_permissions = access_policy.value.certificate_permissions
      storage_permissions     = access_policy.value.storage_permissions
    }
  }
}
