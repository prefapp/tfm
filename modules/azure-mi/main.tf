# RESOURCES SECTION
## https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group.html
data "azurerm_resource_group" "resource_group" {
  name = var.resource_group
}

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
  tags           = var.tags_from_rg ? data.azurerm_resource_group.resource_group.tags : var.tags
}

## RESOURCES SECTION
## https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity
resource "azurerm_user_assigned_identity" "user_assigned_identity" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group
  tags                = local.tags
}

## https://registry.terraform.io/providers/hashicorp/azurerm/2.62.1/docs/resources/role_assignment
resource "azurerm_role_assignment" "role_assignment" {
  for_each             = { for r in local.flattened_rbac : "${r.name}-${r.role}" => r }
  role_definition_name = each.value.role
  scope                = each.value.scope
  principal_id         = azurerm_user_assigned_identity.user_assigned_identity.principal_id
}

## https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/federated_identity_credential
resource "azurerm_federated_identity_credential" "federated_identity_credential" {
  for_each            = { for federated_credential in var.federated_credentials : federated_credential.name => federated_credential }
  name                = each.key
  resource_group_name = var.resource_group
  audience            = var.audience
  issuer              = each.value.type == "github" ? coalesce(each.value.issuer, "https://token.actions.githubusercontent.com") : each.value.issuer
  parent_id           = azurerm_user_assigned_identity.user_assigned_identity.id
  subject             = each.value.type == "github" ? "repo:${each.value.organization}/${each.value.repository}:${each.value.entity}" : each.value.type == "kubernetes" ? "system:serviceaccount:${each.value.namespace}:${each.value.service_account_name}" : each.value.subject
}

## https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy
resource "azurerm_key_vault_access_policy" "access_policy" {
  for_each           = { for policy in var.access_policies : "${policy.tenant_id}-${policy.object_id}" => policy }
  key_vault_id       = azurerm_key_vault.example.id
  tenant_id          = each.value.tenant_id
  object_id          = each.value.object_id
  key_permissions    = each.value.key_permissions
  secret_permissions = each.value.secret_permissions
  certificate_permissions = each.value.certificate_permissions
  storage_permissions = each.value.storage_permissions
}
