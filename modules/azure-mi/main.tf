# RESOURCES SECTION
## https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group.html
data "azurerm_resource_group" "resource_group" {
  name = local.vars_yaml.resource_group_name
}

## LOCALS SECTION
locals {
  vars_yaml = yamldecode(file("vars.yaml"))
  rbac = [
    for r in local.vars_yaml.rbac : [
      for role in r.roles : {
        name  = r.name
        scope = r.scope
        role  = role
      }
    ]
  ]
  flattened_rbac = flatten(local.rbac)
  tags = contains(keys(local.vars_yaml), "tags_from_rg") ? data.azurerm_resource_group.resource_group.tags : local.vars_yaml.tags
}

## RESOURCES SECTION
## https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity
resource "azurerm_user_assigned_identity" "user_assigned_identity" {
  name                = local.vars_yaml.name
  location            = local.vars_yaml.location
  resource_group_name = local.vars_yaml.resource_group_name
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
  for_each            = { for federated_credential in local.vars_yaml.federated_credentials : federated_credential.name => federated_credential }
  name                = each.key
  resource_group_name = local.vars_yaml.resource_group_name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = each.value.issuer
  parent_id           = azurerm_user_assigned_identity.user_assigned_identity.id
  # subject github example: repo:{Organization}/{Repository}:{Entity}
  # subject k8s example: system:serviceaccount:<namespace>:<serviceaccount>
  subject = each.value.type == "github" ? "repo:${each.value.organization}/${each.value.repository}:${each.value.entity}" : "system:serviceaccount:${each.value.namespace}:${each.value.service_account_name}"
}
