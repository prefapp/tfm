# Cluster seccion
# https://registry.terraform.io/providers/mongodb/mongodbatlas/1.23.0/docs/resources/cluster
resource "mongodbatlas_cluster" "this" {
  for_each = var.clusters

  project_id   = var.project_id
  name         = each.value.name
  cluster_type = each.value.cluster_type
  replication_specs {
    num_shards = each.value.num_shards
    zone_name  = each.value.zone_name
    regions_config {
      region_name     = each.value.region_name
      analytics_nodes = each.value.analytics_nodes
      electable_nodes = each.value.electable_nodes
      priority        = each.value.priority
      read_only_nodes = each.value.read_only_nodes
    }
  }
  cloud_backup                 = each.value.cloud_backup
  auto_scaling_disk_gb_enabled = each.value.auto_scaling_disk_gb_enabled
  mongo_db_major_version       = each.value.mongo_db_major_version
  provider_name                = each.value.provider_name
  provider_disk_type_name      = each.value.provider_disk_type_name
  provider_instance_size_name  = each.value.provider_instance_size_name
  lifecycle {
    ignore_changes = [
      replication_specs,
      provider_name,
      provider_disk_type_name,
      provider_instance_size_name
    ]
  }
}
