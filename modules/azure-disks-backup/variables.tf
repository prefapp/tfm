variable "resource_group_name" {
  description = "The name of the resource group used for the backup vault and backup instances."
  type        = string
}

variable "vault_name" {
  description = "The name of the backup vault."
  type        = string
}

variable "datastore_type" {
  description = "The type of datastore."
  type        = string
  default     = "VaultStore"

  validation {
    condition = contains(["ArchiveStore", "OperationalStore", "SnapshotStore", "VaultStore"], var.datastore_type)
    error_message = "Valid values for datastore_type are (ArchiveStore, OperationalStore, SnapshotStore, VaultStore)"
  }
}

variable "redundancy" {
  description = "The redundancy type."
  type        = string
  default     = "LocallyRedundant"

  validation {
    condition = contains(["GeoRedundant", "LocallyRedundant", "ZoneRedundant"], var.redundancy)
    error_message = "Valid values for redundancy are (GeoRedundant, LocallyRedundant, ZoneRedundant)"
  }
}

variable "soft_delete" {
  description = "Enable soft delete."
  type        = string
  default     = "Off"

  validation {
    condition = contains(["AlwaysOn", "Off", "On"], var.soft_delete)
    error_message = "Valid values for soft_delete are (AlwaysOn, Off, On)"
  }
}

variable "retention_duration_in_days" {
  description = "The retention duration in days before the backup is purged. 14 days free."
  type        = number
  default     = 14
}

variable "backup_policies" {
  description = "List of backup policies."
  type = list(object({
    name                            = string
    backup_repeating_time_intervals = list(string)
    default_retention_duration      = string
    time_zone                       = string
    retention_rules = list(object({
      name     = string
      duration = string
      priority = number
      criteria = object({
        absolute_criteria = string
      })
    }))
  }))
}

variable "backup_instances" {
  description = "List of backup instances."
  type = list(object({
    disk_name                    = string
    disk_resource_group          = string
    backup_policy_name           = string
  }))
}

