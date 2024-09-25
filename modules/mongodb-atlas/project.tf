# Project section
# https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/project
resource "mongodbatlas_project" "project" {
  name   = var.provider.provider_name
  org_id = var.provider.global_resource_group_name
}
