module "custom_role" {
  source = "../../"
  name   = var.name
  assignable_scopes = var.assignable_scopes
  permissions = var.permissions
}
