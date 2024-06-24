# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/directory_roles
data "azuread_directory_roles" "current" {}

# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/directory_role_assignment
resource "azuread_directory_role_assignment" "this" {
# { for role in local.flattened_role_assingments : role.name => role }
  for_each = {for directory_role in var.directory_roles : directory_role.role_name => directory_role }

  role_id             = [for role in data.azuread_directory_roles.current.roles : role if role.display_name == each.value.role_name][0].template_id

  principal_object_id = azuread_group.this.id

}
