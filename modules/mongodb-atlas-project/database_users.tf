# https://registry.terraform.io/providers/mongodb/mongodbatlas/1.23.0/docs/resources/database_user
resource "mongodbatlas_database_user" "this" {
  for_each           = var.database_users
  username           = each.value.username
  password           = each.value.password
  project_id         = mongodbatlas_project.this.id
  auth_database_name = each.value.auth_database_name
  roles {
    role_name     = each.value.roles.role_name
    database_name = each.value.roles.database_name
  }
  dynamic "scopes" {
    for_each = each.value.scopes != null ? [each.value.scopes] : []
    content {
      name = scopes.value.name
      type = scopes.value.type
    }
  }
}
