# RESOURCES SECTION
## https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition
resource "azurerm_role_definition" "this" {
  name              = var.name
  scope             = var.assignable_scopes[0]
  assignable_scopes = var.assignable_scopes
  permissions {
    actions          = var.permissions.actions
    data_actions     = var.permissions.data_actions
    not_actions      = var.permissions.not_actions
    not_data_actions = var.permissions.not_data_actions
  }
}
