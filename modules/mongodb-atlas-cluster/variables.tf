# Global variables
variable "mongo_region" {
  description = "The mongo region"
  type        = string
}

variable "provider_name" {
  description = "The provider name"
  type        = string
}

variable "project_id" {
  description = "The project ID"
  type        = string
}

# Cluster seccion variables
variable "cluster_name" {
  description = "The name of the cluster"
  type        = string
}

variable "cluster_type" {
  description = "The type of the cluster"
  type        = string
}

variable "cluster_replication_specs_config_analytics_nodes" {
  description = "The number of analytics nodes"
  type        = number
}

variable "cluster_replication_specs_config_electable_nodes" {
  description = "The number of electable nodes"
  type        = number
}

variable "cluster_replication_specs_config_priority" {
  description = "Priority value"
  type        = number
}

variable "cluster_replication_specs_config_read_only_nodes" {
  description = "The number of read only nodes"
  type        = number
}

variable "cluster_cloud_backup" {
  description = "Whether or not cloud backup is enabled"
  type        = bool
}

variable "cluster_auto_scaling_disk_gb_enabled" {
  description = "Whether or not disk autoscaling is enabled"
  type        = bool
}

variable "cluster_mongo_db_major_version" {
  description = "MongoDB major version"
  type        = string
}

variable "cluster_provider_disk_type_name" {
  description = "Provider disk type name"
  type        = string
}

variable "cluster_provider_instance_size_name" {
  description = "Provider instance size name"
  type        = string
}

variable "cluster_num_shards" {
  description = "The number of shards"
  type        = number
}

variable "cluster_zone" {
  description = "The zones of the cluster"
  type        = string
}

# Restore from snapshot variables
variable "create_cluster_from_snapshot" {
  description = "Whether or not to create a cluster from a snapshot"
  type        = bool
  default     = false
  # validation {
  #   condition     = var.create_cluster_from_pitr == true
  #   error_message = "If create_cluster_from_snapshot is true, create_cluster_from_pitr must be false"
  # }
  # validation {
  #   condition     = var.origin_project_id == null
  #   error_message = "If create_cluster_from_snapshot is true, origin_project_id must be set"
  # }
  # validation {
  #   condition     = var.origin_cluster_name == null
  #   error_message = "If create_cluster_from_snapshot is true, origin_cluster_name must be set"
  # }
}

variable "origin_project_id" {
  description = "The origin project ID"
  type        = string
  default     = null
}

variable "origin_cluster_name" {
  description = "The origin cluster name"
  type        = string
  default     = null
}

# Restore from pitr variables
variable "create_cluster_from_pitr" {
  description = "Whether or not to create a cluster from a point in time restore"
  type        = bool
  default     = false
  # validation {
  #   condition     = var.create_cluster_from_snapshot == true
  #   error_message = "If create_cluster_from_pi is true, create_cluster_from_snapshot must be false"
  # }
  # validation {
  #   condition     = var.point_in_time_utc_seconds == null
  #   error_message = "If create_cluster_from_pi is true, point_in_time_utc_seconds must be set"
  # }
}

variable "point_in_time_utc_seconds" {
  description = "The point in time to restore from"
  type        = number
  default     = null
}
