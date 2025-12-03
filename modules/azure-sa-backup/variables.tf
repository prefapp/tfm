# VARIABLES SECTION
## General
variable "backup_resource_group_name" {
  description = "The name for the resource group for the backups"
  type        = string
}

variable "storage_account_id" {
  description = "The ID of the storage account"
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

## Backup fileshares variables
variable "backup_share" {
  description = "Specifies the backup configuration for the storage share"
  type = object({
    policy_name                  = string
    recovery_services_vault_name = string
    sku                          = string
    soft_delete_enabled          = optional(bool)
    storage_mode_type            = optional(string, "GeoRedundant")
    cross_region_restore_enabled = optional(bool)
    source_file_share_name       = list(string)
    identity = optional(object({
      type         = optional(string, "SystemAssigned")
      identity_ids = optional(list(string), [])
    }))
    encryption = optional(object({
      key_id                            = optional(string, null)
      infrastructure_encryption_enabled = optional(bool, false)
      user_assigned_identity_id         = optional(string, null)
      use_system_assigned_identity      = optional(bool, false)
    }))
    timezone = optional(string)
    backup = object({
      frequency = string
      time      = string
    })
    retention_daily = object({
      count = number
    })
    retention_weekly = optional(object({
      count    = number
      weekdays = optional(list(string), ["Sunday"])
    }))
    retention_monthly = optional(object({
      count    = number
      weekdays = optional(list(string), ["Sunday"])
      weeks    = optional(list(string), ["First"])
      days     = optional(list(number))
    }))
    retention_yearly = optional(object({
      count    = number
      months   = optional(list(string), ["January"])
      weekdays = optional(list(string), ["Sunday"])
      weeks    = optional(list(string), ["First"])
      days     = optional(list(number))
    }))
  })
  default = null
}

## Backup blobs variables
variable "backup_blob" {
  description = "Specifies the backup configuration for the storage blob"
  type = object({
    vault_name                      = string
    datastore_type                  = string
    redundancy                      = string
    identity_type                   = optional(string)
    role_assignment                 = string
    instance_blob_name              = string
    storage_account_container_names = optional(list(string))
    policy = object({
      name                                   = string
      backup_repeating_time_intervals        = optional(list(string))
      operational_default_retention_duration = optional(string)
      retention_rule = optional(list(object({
        name     = string
        duration = string
        criteria = object({
          absolute_criteria      = optional(string)
          days_of_month          = optional(list(number))
          days_of_week           = optional(list(string))
          months_of_year         = optional(list(string))
          scheduled_backup_times = optional(list(string))
          weeks_of_month         = optional(list(string))
        })
        life_cycle = object({
          data_store_type = string
          duration        = string
        })
        priority = number
      })))
      time_zone                        = optional(string)
      vault_default_retention_duration = optional(string)
      retention_duration               = optional(string)
    })
  })
  default = null
}

variable "lifecycle_policy_rule" {
  type = list(object({
    name    = string
    enabled = bool
    filters = object({
      prefix_match = list(string)
      blob_types   = list(string)
    })
    actions = object({
      base_blob = object({ delete_after_days_since_creation_greater_than = number })
      snapshot  = object({ delete_after_days_since_creation_greater_than = number })
      version   = object({ delete_after_days_since_creation = number })
    })
  }))
  default = null
}
