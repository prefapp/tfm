# https://registry.terraform.io/providers/mongodb/mongodbatlas/1.23.0/docs/resources/project_ip_access_list
resource "mongodbatlas_project_ip_access_list" "this" {
  for_each = {
    for index, ip in var.whitelist_ips :
    ip.ip => ip
  }
  project_id = mongodbatlas_project.this.id
  ip_address = each.value.ip
  comment    = each.value.name
}
