# https://registry.terraform.io/providers/mongodb/mongodbatlas/1.23.0/docs/resources/cluster
resource "mongodbatlas_cluster" "this" {
  project_id   = var.project_id
  name         = var.cluster_name
  cluster_type = var.cluster_type
  replication_specs {
    num_shards = var.cluster_num_shards
    zone_name  = var.cluster_zone
    regions_config {
      region_name     = var.mongo_region
      analytics_nodes = var.cluster_replication_specs_config_analytics_nodes
      electable_nodes = var.cluster_replication_specs_config_electable_nodes
      priority        = var.cluster_replication_specs_config_priority
      read_only_nodes = var.cluster_replication_specs_config_read_only_nodes
    }
  }
  cloud_backup                 = var.cluster_cloud_backup
  auto_scaling_disk_gb_enabled = var.cluster_auto_scaling_disk_gb_enabled
  mongo_db_major_version       = var.cluster_mongo_db_major_version
  # Provider Settings "block"
  provider_name               = var.provider_name
  provider_disk_type_name     = var.cluster_provider_disk_type_name
  provider_instance_size_name = var.cluster_provider_instance_size_name
  lifecycle {
    ignore_changes = [
      replication_specs,
      provider_name,
      provider_disk_type_name,
      provider_instance_size_name
    ]
  }
}
       
# https://registry.terraform.io/providers/mongodb/mongodbatlas/1.23.0/docs/resources/cloud_backup_snapshot_restore_job
resource "mongodbatlas_cloud_backup_snapshot_restore_job" "this_snapshot" {
  count        = var.create_cluster_from_snapshot ? 1 : 0
  project_id   = var.origin_project_id
  cluster_name = var.origin_cluster_name
  delivery_type_config {
    automated           = true
    target_cluster_name = mongodbatlas_cluster.this.name
    target_project_id   = mongodbatlas_cluster.this.project_id
  }
  lifecycle {
    precondition {
      condition     = !(var.create_cluster_from_snapshot == true && var.create_cluster_from_pitr == true)
      error_message = "create_cluster_from_snapshot and create_cluster_from_pitr cannot both be true"
    }
    precondition {
      condition     = var.create_cluster_from_snapshot == false || var.origin_project_id != null
      error_message = "If create_cluster_from_snapshot is true, origin_project_id must be set"
    }
    precondition {
      condition     = var.create_cluster_from_snapshot == false || var.origin_cluster_name != null
      error_message = "If create_cluster_from_snapshot is true, origin_cluster_name must be set"
    }
  }
}

# https://registry.terraform.io/providers/mongodb/mongodbatlas/1.23.0/docs/resources/cloud_backup_snapshot_restore_job
resource "mongodbatlas_cloud_backup_snapshot_restore_job" "this_pitr" {
  count        = var.create_cluster_from_pitr ? 1 : 0
  project_id   = mongodbatlas_cluster.this.project_id
  cluster_name = mongodbatlas_cluster.this.name

  delivery_type_config {
    point_in_time             = true
    target_cluster_name       = mongodbatlas_cluster.this.name
    target_project_id         = mongodbatlas_cluster.this.project_id
    point_in_time_utc_seconds = var.point_in_time_utc_seconds
  }
  lifecycle {
    precondition {
      condition     = !(var.create_cluster_from_pitr == true && var.create_cluster_from_snapshot == true)
      error_message = "create_cluster_from_pitr and create_cluster_from_snapshot cannot both be true"
    }
    precondition {
      condition     = var.create_cluster_from_pitr == false || var.point_in_time_utc_seconds != null
      error_message = "If create_cluster_from_pitr is true, point_in_time_utc_seconds must be set"
    }
  }
}
