# Common variables for Azure Backup Vault module
variable "backup_resource_group_name" {
  description = "Name of the resource group for backups"
  type        = string
}

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

# Disk variables
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

variable "disk_instances" {
  description = "Map of backup instances for disks"
  type = map(object({
    instance_disk_name = string
    policy_key         = string
  }))
  default = {}
}

# Blob variables
variable "backup_blob" {
  description = "Configuration for blob storage backups"
  type = object({
    storage_account_id              = string
    vault_name                      = string
    datastore_type                  = string
    redundancy                      = string
    identity_type                   = string
    instance_blob_name              = string
    storage_account_container_names = list(string)
    role_assignment                 = string
  })
  default = {}
}

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

variable "blob_instances" {
  description = "Map of blob backup instances"
  type = map(object({
    instance_blob_name              = string
    storage_account_id              = string
    storage_account_container_names = list(string)
    policy_key                      = string
  }))
  default = {}
}

# Postgresql flexible server variables
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
        days_of_week  = optional(list(string))
      })
    }))
  }))
  default = {}
}

variable "postgresql_instances" {
  description = "Map of PostgreSQL Flexible Server backup instances"
  type = map(object({
    instance_name     = string
    server_id         = string
    resource_group_id = string
    policy_key        = string
  }))
  default = {}
}

# Kubernetes services variables
variable "backup_kubernetes_services" {
  description = "Configuration for Kubernetes services backups"
  type = object({
    name                     = string
    datastore_type           = string
    redundancy               = string
    instance_kubernetes_name = string
    cluster_ids              = list(string)
    role_assignment          = string
  })
}

variable "extension" {
  description = "Configuration for the kubernetes cluster extension"
  type = object({
    name           = string
    extension_type = string
  })
}

variable "trusted_role" {
  description = "Configuration for the cluster access role binding"
  type = object({
    name  = string
    roles = list(string)
  })
}



# MySQL flexible variables
variable "mysql_policies" {
  description = "Map of backup policies for MySQL Flexible Server. The key is the logical name of the policy."
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

variable "mysql_instances" {
  description = "Map of MySQL Flexible Server backup instances. The key is the logical name of the instance."
  type = map(object({
    instance_name     = string
    server_id         = string
    resource_group_id = string # Resource group of the server, required for Reader role assignment
    policy_key        = string # Must match a key in mysql_policies
  }))
  default = {}
}

# Policy variables
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
}

