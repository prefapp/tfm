# Cluster section
# https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/cluster
resource "mongodbatlas_cluster" "cluster" {
  project_id   = mongodbatlas_project.project.id
  name         = var.cluster_name
  cluster_type = var.cluster_type

  # Replication specifications
  replication_specs {
    num_shards = var.cluster_num_shards
    zone_name  = var.cluster_zone

    # Regions configuration
    regions_config {
      region_name     = var.mongo_region
      analytics_nodes = var.cluster_replication_specs_config_analytics_nodes
      electable_nodes = var.cluster_replication_specs_config_electable_nodes
      priority        = var.cluster_replication_specs_config_priority
      read_only_nodes = var.cluster_replication_specs_config_analytics_nodes
    }
  }

  cloud_backup                 = var.cluster_cloud_backup
  auto_scaling_disk_gb_enabled = var.cluster_auto_scaling_disk_gb_enabled
  mongo_db_major_version       = var.cluster_mongo_db_major_version

  # Provider settings
  provider_name               = var.provider_name
  provider_disk_type_name     = var.cluster_provider_disk_type_name
  provider_instance_size_name = var.cluster_provider_instance_size_name

  # Lifecycle settings to ignore changes
  lifecycle {
    ignore_changes = [
      replication_specs,
      provider_name,
      provider_disk_type_name,
      provider_instance_size_name,
    ]
  }

  # Ensure the cluster is created after the project
  depends_on = [mongodbatlas_project.project]
}
