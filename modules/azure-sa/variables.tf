# VARIABLES SECTION
## General
variable "tags" {
  description = "The tags to associate with your resources"
  type        = map(string)
}


variable "resource_group_name" {
  description = "The name for the resource group"
  type        = string
}

## Network variables
variable "subnet" {
  description = "Subnet values for data"
  type = list(object({
    name           = string
    vnet           = string
    resource_group = string
  }))
}

variable "additional_subnet_ids" {
  description = "Additional subnets id for storage account network rules"
  type        = list(string)
}

## Storage account variables
variable "storage_account" {
  description = "Configuration for the Azure Storage Account"
  type = object({
    name                             = string
    account_tier                     = optional(string, "Standard")
    account_replication_type         = optional(string, "LRS")
    account_kind                     = optional(string, "StorageV2")
    access_tier                      = optional(string, "Hot")
    cross_tenant_replication_enabled = optional(bool, false)
    https_traffic_only_enabled       = optional(bool, true)
    min_tls_version                  = optional(string, "TLS1_2")

    blob_properties = optional(object({
      versioning_enabled      = optional(bool, false)
      change_feed_enabled     = optional(bool, false)
      default_service_version = optional(string, "2020-06-12")
      delete_retention_policy = optional(object({
        days = optional(number, 7)
      }))
      container_delete_retention_policy = optional(object({
        days = optional(number, 7)
      }))
    }))

    share_properties = optional(object({
      retention_policy = optional(object({
        days = optional(number, 7)
      }))
    }))

    identity = optional(object({
      type         = optional(string, "SystemAssigned")
      identity_ids = optional(list(string), [])
    }))

    tags = optional(map(string), {})
  })
}


## Storage account network rules
variable "storage_account_network_rules" {
  description = "Network rules for the storage account"
  type = object({
    default_action = string
    bypass         = optional(string, "AzureServices")
    ip_rules       = optional(string)
  })
}

## Storage share variables
variable "storage_share" {
  description = "Specifies the storage shaares"
  type = list(object({
    name             = string
    access_tier      = optional(string)
    enabled_protocol = optional(string)
    quota            = number
    metadata         = optional(map(string))
    acl = optional(list(object({
      id = string
      access_policy = optional(object({
        permissions = string
        start       = optional(string)
        expiry      = optional(string)
      }))
    })))
  }))
  default = null
}

## Storage container variables
variable "storage_container" {
  description = "Specifies the storage containers"
  type = list(object({
    name                              = string
    container_access_type             = optional(string)
    default_encryption_scope          = optional(string)
    encryption_scope_override_enabled = optional(bool)
    metadata                          = optional(map(string))
  }))
  default = null
}

## Storage blob variables
variable "storage_blob" {
  description = "Specifies the storage blobs"
  type = list(object({
    name                   = string
    storage_container_name = string
    type                   = string
    source                 = optional(string)
    size                   = optional(number)
    cache_control          = optional(string)
    content_type           = optional(string)
    content_md5            = optional(string)
    access_tier            = optional(string)
    encryption_scope       = optional(string)
    source_content         = optional(string)
    source_uri             = optional(string)
    parallelism            = optional(number)
  }))
  default = null
}

variable "storage_queue" {
  description = "Specifies the storage queues"
  type = list(object({
    name     = string
    metadata = optional(map(string))
  }))
  default = null
}

variable "storage_table" {
  description = "Specifies the storage tables"
  type = list(object({
    name = string
    acl = optional(object({
      id = string
      access_policy = optional(object({
        permissions = string
        start       = optional(string)
        expiry      = optional(string)
      }))
    }))
  }))
  default = null
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
      key_id                            = optional(string, "")
      infrastructure_encryption_enabled = optional(bool, false)
      user_assigned_identity_id         = optional(string, "")
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
      weekdays = list(string)
    }))
    retention_monthly = optional(object({
      count    = number
      weekdays = list(string)
      weeks    = list(string)
    }))
    retention_yearly = optional(object({
      count    = number
      weekdays = list(string)
      weeks    = list(string)
      months   = list(string)
    }))
  })
  default = null
}

variable "blob_retention_soft_delete" {
  description = "Specifies the number of days that the blob should be retained"
  type        = number
  default     = null
}

variable "container_retention_soft_delete" {
  description = "Specifies the number of days that the container should be retained"
  type        = number
  default     = null
}

variable "recovery_services_vault_name" {
  description = "Recovery service vault name"
  type        = string
  default     = null
}

variable "policy_name" {
  description = "Name of the backup policy"
  type        = string
  default     = null
}

variable "timezone" {
  description = "Timezone"
  type        = string
  default     = null
}

variable "sku" {
  type        = string
  description = "The SKU (Stock Keeping Unit) of the resource"
  default     = null
}

variable "soft_delete_enabled" {
  type        = bool
  description = "Enable soft delete"
  default     = null
}

variable "change_feed_enabled" {
  type        = bool
  description = "Specifies whether the change feed is enabled for the storage account"
  default     = null
}

variable "versioning_enabled" {
  type        = bool
  description = "Specifies whether versioning is enabled for the blobs in the storage account"
  default     = null
}

variable "backup_policy" {
  description = "A map of backup policies to be created in the Recovery Services Vault."
  type = object({
    frequency         = string
    time              = string
    retention_daily   = number
    retention_monthly = number
    retention_yearly  = number
  })
  default = null
}

## Backup blobs variables
variable "backup_vault_name" {
  type        = string
  description = "The name of the backup vault"
  default     = null
}

variable "backup_vault_datastore_type" {
  type        = string
  description = "The type of data store for the backup vault"
  default     = null
}

variable "backup_vault_redundancy" {
  type        = string
  description = "The redundancy setting for the backup vault"
  default     = null
}

variable "backup_vault_identity_type" {
  type        = string
  description = "The type of identity assigned to the backup vault"
  default     = null
}

variable "backup_role_assignment" {
  type        = string
  description = "The role assignment for managing backups"
  default     = null
}

variable "backup_policy_blob_name" {
  type        = string
  description = "The name of the blob storing backup policies"
  default     = null
}

variable "backup_policy_retention_duration" {
  type        = string
  description = "The retention duration for backups"
  default     = null
}

variable "backup_instance_blob_name" {
  type        = string
  description = "The name of the blob storing backup instances"
  default     = null
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
