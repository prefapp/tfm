resource "azurerm_role_assignment" "this" {
  
  for_each = { for role in var.subscription_roles : role.role_name => role }
  
  scope                = each.value.scope 
  
  role_definition_name = each.value.role_name
  
  principal_id         = azuread_group.this.id

}
