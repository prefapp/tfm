# Project section
# https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/project
resource "mongodbatlas_project" "project" {
  name   = var.project_name
  org_id = var.org_id
}
