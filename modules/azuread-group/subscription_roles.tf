locals {
  subscription_flattened_role_assingments = flatten([
    for subscription_rol in var.subscription_roles : [
      for scope in subscription_rol.resources_scopes : {
        name      = replace("${subscription_rol.role_name}-${scope}", "/", "")
        role_name = subscription_rol.role_name
        scope     = scope
      }]
  ])
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
resource "azurerm_role_assignment" "this" {
  for_each = length(local.subscription_flattened_role_assingments) > 0 ? { for role in local.subscription_flattened_role_assingments : role.name => role } : {}
  scope                = each.value.scope 
  role_definition_name = each.value.role_name
  principal_id         = azuread_group.this.id
}
