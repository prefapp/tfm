# MongoDB Atlas Cluster module variables
variable "project_id" {
  description = "The project ID to create the cluster in"
  type        = string
}

# Cluster seccion variables
variable "clusters" {
  description = "A map of clusters to create"
  type = map(object({
    name                         = string
    cluster_type                 = string
    num_shards                   = number
    zone_name                    = string
    region_name                  = string
    analytics_nodes              = number
    electable_nodes              = number
    priority                     = number
    read_only_nodes              = number
    cloud_backup                 = bool
    auto_scaling_disk_gb_enabled = bool
    mongo_db_major_version       = string
    provider_name                = string
    provider_disk_type_name      = string
    provider_instance_size_name  = string
  }))
}
