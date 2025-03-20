locals {
  mgmnt_flattened_role_assingments = flatten([
    for management_group_rol in var.management_group_roles : [
      for scope in management_group_rol.resources_scopes : {
        name      = replace("${management_group_rol.role_name}-${scope}", "/", "")
        role_name = management_group_rol.role_name
        scope     = scope
      }]
  ])
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
resource "azurerm_role_assignment" "that" {
  for_each = length(local.mgmnt_flattened_role_assingments) > 0 ? { for role in local.mgmnt_flattened_role_assingments : role.name => role } : {}
  scope                = each.value.scope 
  role_definition_name = each.value.role_name
  principal_id         = azuread_group.this.id
}
