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
variable "allowed_subnets" {
  description = "Subnet values for data"
  type = list(object({
    name           = string
    vnet           = string
    resource_group = string
  }))
}

variable "additional_allowed_subnet_ids" {
  description = "Additional subnets id for storage account network rules"
  type        = list(string)
}

## Storage account variables
variable "storage_account" {
  description = "Configuration for the Azure Storage Account"
  type = object({
    name                             = string
    account_tier                     = string
    account_replication_type         = string
    account_kind                     = optional(string, "StorageV2")
    access_tier                      = optional(string, "Hot")
    cross_tenant_replication_enabled = optional(bool, false)
    edge_zone                        = optional(string)
    allow_nested_items_to_be_public  = optional(bool, true)
    https_traffic_only_enabled       = optional(bool, true)
    min_tls_version                  = optional(string, "TLS1_2")
    public_network_access_enabled    = optional(bool, true)
    tags                             = optional(map(string), {})
    identity = optional(object({
      type         = optional(string, "SystemAssigned")
      identity_ids = optional(list(string), [])
    }))
  })

  # Validation block for `account_kind`
  validation {
    condition     = contains(["BlobStorage", "BlockBlobStorage", "FileStorage", "Storage", "StorageV2"], var.storage_account["account_kind"])
    error_message = "account_kind must be one of: BlobStorage, BlockBlobStorage, FileStorage, Storage, or StorageV2."
  }

  # Validation block for `account_tier` with conditional logic
  validation {
    condition = (
      (var.storage_account["account_kind"] == "BlockBlobStorage" || var.storage_account["account_kind"] == "FileStorage") && var.storage_account["account_tier"] == "Premium"
      ) || (
      contains(["Storage", "StorageV2", "BlobStorage"], var.storage_account["account_kind"]) && contains(["Standard", "Premium"], var.storage_account["account_tier"])
    )
    error_message = "account_tier must be 'Premium' when account_kind is 'BlockBlobStorage' or 'FileStorage'. Otherwise, it must be either 'Standard' or 'Premium'."
  }

  # Validation block for `account_replication_type`
  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.storage_account["account_replication_type"])
    error_message = "account_replication_type must be one of: LRS, GRS, RAGRS, ZRS, GZRS, or RAGZRS."
  }

  # Validation block for `access_tier`
  validation {
    condition     = contains(["Hot", "Cool"], var.storage_account["access_tier"])
    error_message = "access_tier must be one of: Hot or Cool. Defaults to Hot if not specified."
  }

  # Validation block for `min_tls_version`
  validation {
    condition     = contains(["TLS1_0", "TLS1_1", "TLS1_2"], var.storage_account["min_tls_version"])
    error_message = "min_tls_version must be one of: TLS1_0, TLS1_1, or TLS1_2."
  }

  # Validation for identity type and identity_ids
  validation {
    condition = (
      var.storage_account.identity == null ||
      (var.storage_account.identity.type != "UserAssigned" && var.storage_account.identity.type != "SystemAssigned, UserAssigned") ||
      (var.storage_account.identity.type == "UserAssigned" || var.storage_account.identity.type == "SystemAssigned, UserAssigned") && length(var.storage_account.identity.identity_ids) > 0
    )
    error_message = "identity_ids must be provided when identity.type is set to 'UserAssigned' or 'SystemAssigned, UserAssigned'."
  }
}

## Storage account network rules
variable "network_rules" {
  description = "Network rules for the storage account"
  type = object({
    default_action = string
    bypass         = optional(string, "AzureServices")
    ip_rules       = optional(list(string))
    private_link_access = optional(list(object({
      endpoint_resource_id = string
      endpoint_tenant_id   = optional(string)
    })))
  })
}

## Storage container variables
variable "containers" {
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

## Storage share variables
variable "shares" {
  description = "Specifies the storage shares"
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

## Storage queue variables
variable "queues" {
  description = "Specifies the storage queues"
  type = list(object({
    name     = string
    metadata = optional(map(string))
  }))
  default = null
}

## Storage table variables
variable "tables" {
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

## Lifecycle policy rules variable
variable "lifecycle_policy_rules" {
  description = "List of lifecycle management rules for the Azure Storage Account"
  type = list(object({
    name    = string
    enabled = bool
    filters = object({
      blob_types   = list(string)
      prefix_match = optional(list(string))

      match_blob_index_tag = optional(list(object({
        name      = string
        operation = optional(string, "==")
        value     = string
      })), [])
    })
    actions = object({
      base_blob = optional(object({
        tier_to_cool_after_days_since_modification_greater_than        = optional(number)
        tier_to_cool_after_days_since_last_access_time_greater_than    = optional(number)
        tier_to_cool_after_days_since_creation_greater_than            = optional(number)
        auto_tier_to_hot_from_cool_enabled                             = optional(bool, false)
        tier_to_archive_after_days_since_modification_greater_than     = optional(number)
        tier_to_archive_after_days_since_last_access_time_greater_than = optional(number)
        tier_to_archive_after_days_since_creation_greater_than         = optional(number)
        delete_after_days_since_modification_greater_than              = optional(number)
        delete_after_days_since_last_access_time_greater_than          = optional(number)
        delete_after_days_since_creation_greater_than                  = optional(number)
      }), {})
      snapshot = optional(object({
        change_tier_to_archive_after_days_since_creation               = optional(number)
        tier_to_archive_after_days_since_last_tier_change_greater_than = optional(number)
        change_tier_to_cool_after_days_since_creation                  = optional(number)
        tier_to_cold_after_days_since_creation_greater_than            = optional(number)
        delete_after_days_since_creation_greater_than                  = optional(number)
      }), {})
      version = optional(object({
        change_tier_to_archive_after_days_since_creation               = optional(number)
        tier_to_archive_after_days_since_last_tier_change_greater_than = optional(number)
        change_tier_to_cool_after_days_since_creation                  = optional(number)
        tier_to_cold_after_days_since_creation_greater_than            = optional(number)
        delete_after_days_since_creation                               = optional(number)
      }), {})
    })
  }))
  default = []
}
