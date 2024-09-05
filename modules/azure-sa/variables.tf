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

    identity = optional(object({
      type         = lookup(var.storage_account.identity, "type", "SystemAssigned")
      identity_ids = lookup(var.storage_account.identity, "identity_ids", [])
    }))
    tags = optional(map(string), {})
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

## Storage queue variables
variable "storage_queue" {
  description = "Specifies the storage queues"
  type = list(object({
    name     = string
    metadata = optional(map(string))
  }))
  default = null
}

## Storage table variables
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
