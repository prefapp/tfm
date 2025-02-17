# RESOURCES SECTION
## https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group.html
data "azurerm_resource_group" "resource_group" {
  name = var.resource_group
}

data "azurerm_client_config" "current" {}

## LOCALS SECTION
locals {
  rbac = [
    for r in var.rbac : [
      for role in r.roles : {
        name  = r.name
        scope = r.scope
        role  = role
      }
    ]
  ]
  flattened_rbac = flatten(local.rbac)
  rbac_custom = { for role in var.rbac_custom_roles : role.name => role } 
  tags           = var.tags_from_rg ? data.azurerm_resource_group.resource_group.tags : var.tags
}

## RESOURCES SECTION
## https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity
resource "azurerm_user_assigned_identity" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group
  tags                = local.tags
}

## https://registry.terraform.io/providers/hashicorp/azurerm/4.19.0/docs/resources/role_definition
resource "azurerm_role_definition" "custom_role" {
  for_each = local.rbac_custom
  name = each.value.name
  scope = each.value.definition_scope
  description = "Custom role: ${each.value.name}"
  permissions {
    actions = each.value.permissions.actions
    data_actions = each.value.permissions.data_actions
    not_actions = each.value.permissions.not_actions
    not_data_actions = each.value.permissions.not_data_actions
  }
}

## https://registry.terraform.io/providers/hashicorp/azurerm/2.62.1/docs/resources/role_assignment
resource "azurerm_role_assignment" "custom_role_assignment" {
  for_each = azurerm_role_definition.custom_role
  principal_id         = azurerm_user_assigned_identity.this.principal_id
  role_definition_name = each.value.name
  scope                = local.rbac_custom[each.value.name].scope
}

## https://registry.terraform.io/providers/hashicorp/azurerm/2.62.1/docs/resources/role_assignment
resource "azurerm_role_assignment" "that" {
  for_each             = { for r in local.flattened_rbac : "${r.name}-${r.role}" => r }
  role_definition_name = each.value.role
  scope                = each.value.scope
  principal_id         = azurerm_user_assigned_identity.this.principal_id
}

## https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/federated_identity_credential
resource "azurerm_federated_identity_credential" "that" {
  for_each            = { for federated_credential in var.federated_credentials : federated_credential.name => federated_credential }
  name                = each.key
  resource_group_name = var.resource_group
  audience            = var.audience
  issuer              = each.value.type == "github" ? coalesce(each.value.issuer, "https://token.actions.githubusercontent.com") : each.value.issuer
  parent_id           = azurerm_user_assigned_identity.this.id
  subject             = each.value.type == "github" ? "repo:${each.value.organization}/${each.value.repository}:${each.value.entity}" : each.value.type == "kubernetes" ? "system:serviceaccount:${each.value.namespace}:${each.value.service_account_name}" : each.value.subject
}

## https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy
resource "azurerm_key_vault_access_policy" "access_policy" {
  for_each           = { for policy in var.access_policies : policy.key_vault_id => policy }
  key_vault_id       = each.value.key_vault_id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = azurerm_user_assigned_identity.this.principal_id
  key_permissions    = each.value.key_permissions
  secret_permissions = each.value.secret_permissions
  certificate_permissions = each.value.certificate_permissions
  storage_permissions = each.value.storage_permissions
}
