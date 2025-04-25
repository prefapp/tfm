# https://registry.terraform.io/providers/hashicorp/azurerm/4.26.0/docs/resources/role_assignment
resource "azurerm_role_assignment" "role_assignment" {
  for_each             = var.role_assignments
  scope                = each.value.scope
  delegated_managed_identity_resource_id         = each.value.target_id
  principal_type       = each.value.type
  role_definition_name = contains(keys(each.value), "role_definition_name") ? each.value.role_definition_name : null
  role_definition_id   = contains(keys(each.value), "role_definition_id") ? each.value.role_definition_id : null
}
