# Common variables for Backup Vault
variable "backup_resource_group_name" {
  description = "Name of the resource group for backups"
  type        = string
}

variable "tags_from_rg" {
  description = "Use resource group tags as base for module tags"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

# Backup vault
variable "vault" {
  description = "Backup vault configuration"
  type = object({
    name                         = string
    datastore_type               = string
    redundancy                   = string
    cross_region_restore_enabled = optional(bool)
    retention_duration_in_days   = optional(number)
    immutability                 = optional(string)
    soft_delete                  = optional(string)
    identity = optional(object({
      type = string
    }))
  })
  default = {}
}

# Backup vault policies
variable "policy" {
  description = "List of backup policies"
  type = list(object({
    name                                   = string
    vault_id                               = string
    backup_repeating_time_intervals        = list(string)
    operational_default_retention_duration = string
    retention_rule = list(object({
      name     = string
      duration = string
      criteria = object({
        days_of_week  = optional(list(string))
        days_of_month = optional(list(number))
      })
      life_cycle = object({
        data_store_type = string
        duration        = string
      })
      priority = number
    }))
    time_zone                        = string
    vault_default_retention_duration = string
    retention_duration               = string
  }))
  default = []
}


# Disk backup variables
variable "disk_policies" {
  description = "Map of backup policies for disks"
  type = map(object({
    policy_name                     = string
    backup_repeating_time_intervals = list(string)
    default_retention_duration      = string
    time_zone                       = optional(string)
    retention_rule = optional(list(object({
      name     = string
      duration = string
      priority = number
      criteria = object({
        absolute_criteria = optional(string)
      })
    })))
  }))
  default = {}
}

# Disk backup instances
variable "disk_instances" {
  description = "Map of backup instances for disks"
  type = map(object({
    instance_disk_name = string
    policy_key         = string
  }))
  default = {}
}

# Blob backup policies
variable "blob_policies" {
  description = "Map of backup policies for blobs"
  type = map(object({
    policy_name                            = string
    backup_repeating_time_intervals        = optional(list(string))
    operational_default_retention_duration = optional(string)
    time_zone                              = optional(string)
    vault_default_retention_duration       = optional(string)
    retention_rule = optional(list(object({
      name     = string
      priority = number
      criteria = object({
        absolute_criteria      = optional(string)
        days_of_week           = optional(list(string))
        days_of_month          = optional(list(number))
        months_of_year         = optional(list(string))
        weeks_of_month         = optional(list(string))
        scheduled_backup_times = optional(list(string))
      })
      life_cycle = object({
        data_store_type = string
        duration        = string
      })
    })))
  }))
  default = {}
}

# Blob backup instances
variable "blob_instances" {
  description = "Map of backup instances for blobs"
  type = map(object({
    instance_blob_name              = string
    storage_account_id              = string
    storage_account_container_names = list(string)
    policy_key                      = string
  }))
  default = {}
}

# Postgresql backup policies
variable "postgresql_policies" {
  description = "Map of backup policies for PostgreSQL Flexible Server"
  type = map(object({
    policy_name                     = string
    backup_repeating_time_intervals = list(string)
    default_retention_duration      = string
    time_zone                       = optional(string)
    retention_rule = list(object({
      name     = string
      duration = string
      priority = number
      criteria = object({
        absolute_criteria      = optional(string)
        months_of_year         = optional(list(string))
        weeks_of_month         = optional(list(string))
        scheduled_backup_times = optional(list(string))
        days_of_week           = optional(list(string))
      })
    }))
  }))
  default = {}
}

#Postgresql backup instances
variable "postgresql_instances" {
  description = "Map of backup instances for PostgreSQL Flexible Server"
  type = map(object({
    instance_name     = string
    server_id         = string
    resource_group_id = string
    policy_key        = string
  }))
  default = {}
}


# MySQL backup policies
variable "mysql_policies" {
  description = "Map of backup policies for MySQL Flexible Server"
  type = map(object({
    policy_name                     = string
    backup_repeating_time_intervals = list(string)
    time_zone                       = optional(string)
    default_retention_rule = list(object({
      life_cycle = object({
        duration        = string
        data_store_type = string
      })
    }))
    retention_rule = optional(list(object({
      name     = string
      priority = number
      life_cycle = object({
        data_store_type = string
        duration        = string
      })
      criteria = object({
        absolute_criteria      = optional(string)
        days_of_week           = optional(list(string))
        months_of_year         = optional(list(string))
        weeks_of_month         = optional(list(string))
        scheduled_backup_times = optional(list(string))
      })
    })))
  }))
  default = {}
}

# MySQL backup instances
variable "mysql_instances" {
  description = "Map of MySQL Flexible Server backup instances"
  type = map(object({
    instance_name     = string
    server_id         = string
    resource_group_id = string
    policy_key        = string
  }))
  default = {}
}

# Kubernetes backup policies
variable "kubernetes_policies" {
  description = "Map of backup policies for Kubernetes clusters"
  type = map(object({
    policy_name                     = string
    backup_repeating_time_intervals = list(string)
    time_zone                       = optional(string)
    default_retention_rule = object({
      life_cycle = object({
        duration        = string
        data_store_type = string
      })
    })
    retention_rule = optional(list(object({
      name     = string
      priority = number
      life_cycle = object({
        data_store_type = string
        duration        = string
      })
      criteria = object({
        absolute_criteria      = optional(string)
        days_of_week           = optional(list(string))
        months_of_year         = optional(list(string))
        weeks_of_month         = optional(list(string))
        scheduled_backup_times = optional(list(string))
      })
    })))
  }))
  default = {}
}

# Kubernetes backup instances
variable "kubernetes_instances" {
  description = "Map of Kubernetes cluster backup instances"
  type = map(object({
    instance_name                = string
    cluster_name                 = string
    snapshot_resource_group_name = string
    policy_key                   = string
    backup_datasource_parameters = object({
      excluded_namespaces              = optional(list(string))
      excluded_resource_types          = optional(list(string))
      cluster_scoped_resources_enabled = optional(bool)
      included_namespaces              = optional(list(string))
      included_resource_types          = optional(list(string))
      label_selectors                  = optional(map(string))
      volume_snapshot_enabled          = optional(bool)
    })
    extension_configuration = optional(object({
      bucket_name                 = optional(string)
      bucket_resource_group_name  = optional(string)
      bucket_storage_account_name = optional(string)
    }))
  }))
  default = {}
}
