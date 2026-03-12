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
}

variable "point_in_time_utc_seconds" {
  description = "The point in time to restore from"
  type        = number
  default     = null
}

# Snapshot execution config variables
variable "snapshot_execution_config" {
  description = "Configuration for snapshot execution"
  type = object({
    reference_hour_of_day    = number
    reference_minute_of_hour = number
    restore_window_days      = number
  })
}

# Scheduled retention policies for snapshots
variable "scheduled_retention_policies" {
  description = "Scheduled retention policies for snapshots"
  type = object({
    hourly = optional(object({
      frequency_interval = number
      retention_unit     = string
      retention_value    = number
    }))
    daily = optional(object({
      frequency_interval = number
      retention_unit     = string
      retention_value    = number
    }))
    weekly = optional(object({
      frequency_interval = number
      retention_unit     = string
      retention_value    = number
    }))
    monthly = optional(object({
      frequency_interval = number
      retention_unit     = string
      retention_value    = number
    }))
    yearly = optional(object({
      frequency_interval = number
      retention_unit     = string
      retention_value    = number
    }))
  })

  validation {
    condition = (
      (
        !contains(keys(var.scheduled_retention_policies), "hourly") ||
        (
          contains([1, 2, 4, 6, 8, 12], var.scheduled_retention_policies.hourly.frequency_interval) &&
          contains(["days", "weeks", "months", "years"], var.scheduled_retention_policies.hourly.retention_unit)
        )
      )
      &&
      (
        !contains(keys(var.scheduled_retention_policies), "daily") ||
        (
          var.scheduled_retention_policies.daily.frequency_interval > 0 &&
          contains(["days", "weeks", "months", "years"], var.scheduled_retention_policies.daily.retention_unit)
        )
      )
      &&
      (
        !contains(keys(var.scheduled_retention_policies), "weekly") ||
        (
          var.scheduled_retention_policies.weekly.frequency_interval >= 1 &&
          var.scheduled_retention_policies.weekly.frequency_interval <= 7 &&
          contains(["days", "weeks", "months", "years"], var.scheduled_retention_policies.weekly.retention_unit)
        )
      )
      &&
      (
        !contains(keys(var.scheduled_retention_policies), "monthly") ||
        (
          (
        (var.scheduled_retention_policies.monthly.frequency_interval >= 1 && var.scheduled_retention_policies.monthly.frequency_interval <= 28) ||
        var.scheduled_retention_policies.monthly.frequency_interval == 40
          ) &&
          contains(["days", "weeks", "months", "years"], var.scheduled_retention_policies.monthly.retention_unit)
        )
      )
      &&
      (
        !contains(keys(var.scheduled_retention_policies), "yearly") ||
        (
          var.scheduled_retention_policies.yearly.frequency_interval >= 1 &&
          var.scheduled_retention_policies.yearly.frequency_interval <= 12 &&
          contains(["days", "weeks", "months", "years"], var.scheduled_retention_policies.yearly.retention_unit)
        )
      )
    )
    error_message = "Retention policy values are invalid. Check allowed values for frequency_interval and retention_unit for each policy type."
  }
}
