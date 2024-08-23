# RESOURCES SECTION
## https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group.html
data "azurerm_resource_group" "resource_group" {
  name = var.resource_group_name
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
  tags = var.tags_from_rg ? data.azurerm_resource_group.resource_group.tags : var.tags
}

## RESOURCES SECTION
## https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity
resource "azurerm_user_assigned_identity" "user_assigned_identity" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
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
  resource_group_name = var.resource_group_name
  audience            = var.audience
  issuer              = each.value.issuer
  parent_id           = azurerm_user_assigned_identity.user_assigned_identity.id
  subject = each.value.type == "github" ? "repo:${each.value.organization}/${each.value.repository}:${each.value.entity}" : each.value.type == "K8s" ? "system:serviceaccount:${each.value.namespace}:${each.value.service_account_name}" : each.value.subject
 }
