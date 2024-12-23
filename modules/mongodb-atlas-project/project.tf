# https://registry.terraform.io/providers/mongodb/mongodbatlas/1.23.0/docs/resources/project
resource "mongodbatlas_project" "this" {
  name   = var.project_name
  org_id = var.org_id
}
