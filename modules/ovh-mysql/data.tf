data "ovh_cloud_project_database_certificates" "ca" {
  service_name = local.service_name
  engine       = "mysql"
  cluster_id   = ovh_cloud_project_database.mysql.id
}

data "ovh_okms_resource" "kms" {
  id = var.okms_id
}
