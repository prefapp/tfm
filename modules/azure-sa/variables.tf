# VARIABLES SECTION
## General
variable "tags" {
  description = "The tags to associate with your resources"
  type        = map(string)
}

variable "resource_group_name" {
  description = "The name for the resource group"
  type = string
}

## Network variables
variable "subnet" {
  default = "Subnet values for data"
  type = object({
    name = string
    vnet = string
    resource_group = string 
  })
}

variable "additional_subnet_ids" {
  description = "Additional subnets id for storage account network rules"
  type        = list(string)
}

## Storage account variables
variable "resource_group_name" {
  description = "The name of the resource group in which the storage account is located"
  type        = string
}

variable "storage_account_name" {
  description = "The name for this storage account"
  type        = string
}

variable "storage_account_network_rule_default_action" {
  description = "The default action of allow or deny when no other rules match"
  type        = string
  default     = null
}

variable "storage_account_network_rule_bypass" {
  description = "Specifies whether traffic is bypassed for Logging/Metrics/AzureServices"
  type        = string
  default     = null
}

variable "storage_account_tier" {
  description = "The Tier to use for this storage account"
  type        = string
}

variable "storage_account_kind" {
  description = "The Kind of account to create"
  type        = string
  default     = null
}

variable "storage_account_container_name" {
  description = "The Tier to use for this storage account"
  type        = list(object({
    name         = string
    access_type  = string
  }))
  default     = null
}

variable "storage_account_replication_type" {
  description = "The type of replication to use for this storage account"
  type        = string
}

variable "storage_account_min_tls_version" {
  description = "The minimum supported TLS version for the storage account"
  type        = string
  default     = null
}

variable "storage_account_https_traffic_only_enabled" {
  description = "Allows https traffic only to storage service"
  type        = bool
  default     = null
}

variable "storage_account_cross_tenant_replication_enabled" {
  description = "Allow or disallow public access to the nested files and directories"
  type        = bool
  default     = null
}

variable "storage_account_allow_nested_items_to_be_public" {
  description = "Allow or disallow public access to the nested files and directories"
  type        = bool
  default     = null
}

variable "threat_protection_enabled" {
  description = "Enable threat protection"
  type        = bool
  default     = null
}

variable "quota" {
  description = "The maximum size of the share, in gigabytes."
  type        = string
  default     = null
}

## Backup fileshares variables
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
  type        = object({
    frequency         = string
    time              = string
    retention_daily   = number
    retention_monthly = number
    retention_yearly  = number
  })
  default     = null
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
    name     = string
    enabled  = bool
    filters  = object({
      prefix_match = list(string)
      blob_types   = list(string)
    })
    actions = object({
      base_blob   = object({ delete_after_days_since_creation_greater_than = number })
      snapshot    = object({ delete_after_days_since_creation_greater_than = number })
      version     = object({ delete_after_days_since_creation              = number })
    })
  }))
  default    = null
}
