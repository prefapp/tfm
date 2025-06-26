variable "backup_resource_group_name" {
  description = "Name of the resource group for backups"
  type        = string
}

variable "backup" {
  description = "Backup vault configuration"
  type = object({
    vault_name = string
    datastore_type = string
    redundancy = string
    identity_type = string
  })
}
# Disk variables
variable "backup_disk" {
  description = "Configuration for disk backups"
  type = object({
    vault_name    = string
    datastore_type = string
    redundancy    = string
    identity_type = string
    instance_disk_name = string
    disk_ids      = list(string)
    role_assignment = string
  })
}

# Blob variables
variable "backup_blob" {
  description = "Configuration for blob storage backups"
  type = object({
    storage_account_id = string
    vault_name    = string
    datastore_type = string
    redundancy    = string
    identity_type = string
    instance_blob_name = string
    storage_account_container_names = list(string)
    role_assignment = string
  })
}

# Kubernetes services variables
variable "backup_kubernetes_services" {
  description = "Configuration for Kubernetes services backups"
  type = object({
    name    = string
    datastore_type = string
    redundancy    = string
    instance_kubernetes_name = string
    cluster_ids   = list(string)
    role_assignment = string
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
    name = string
    roles = list(string)
  })
}

# Postgresql flexible server variables
variable "backup_postgresql_flexible" {
  description = "Configuration for PostgreSQL flexible servers backups"
  type = object({
    vault_name    = string
    datastore_type = string
    redundancy    = string
    identity_type = string
    instance_postgresql_flexible_name = string
    server_names  = list(string)
    role_assignment = string
  })
}

# MySQL flexible variables
variable "backup_mysql_flexible" {
  description = "Configuration for MySQL flexible servers backups"
  type = object({
    vault_name    = string
    datastore_type = string
    redundancy    = string
    identity_type = string
    instance_mysql_flexible_name = string
    server_names  = list(string)
    role_assignment = string
  })
}

# Policy variables
variable "policy" {
  description = "List of backup policies"
  type = list(object({
    name = string
    vault_id = string
    backup_repeating_time_intervals = list(string)
    operational_default_retention_duration = string
    retention_rule = list(object({
      name = string
      duration = string
      criteria = object({
        days_of_week = optional(list(string))
        days_of_month = optional(list(number))
      })
      life_cycle = object({
        data_store_type = string
        duration = string
      })
      priority = number
    }))
    time_zone = string
    vault_default_retention_duration = string
    retention_duration = string
  }))
}
