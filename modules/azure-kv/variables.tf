variable "name" {
  type        = string
  description = "Name of the Key Vault (must be globally unique, 3–24 alphanumeric characters)."
}

variable "enabled_for_disk_encryption" {
  type        = bool
  description = "Whether the vault can be used for Azure Disk Encryption."
}

variable "soft_delete_retention_days" {
  type        = number
  description = "Soft-delete retention period in days for deleted keys, secrets, and certificates."
}

variable "purge_protection_enabled" {
  type        = bool
  description = "Whether purge protection is enabled (prevents permanent purge of soft-deleted items)."
}

variable "sku_name" {
  type        = string
  description = "SKU for the vault (`standard` or `premium`)."
}

variable "resource_group" {
  type        = string
  description = "Name of the existing resource group where the Key Vault will be created."
}

variable "enable_rbac_authorization" {
  type        = bool
  description = "When true, use Azure RBAC for data plane access; access policies must be empty (see precondition in main.tf)."
}

variable "tags_from_rg" {
  type        = bool
  description = "When true, merge tags from the resource group with `tags`."
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to the Key Vault (merged with resource group tags when `tags_from_rg` is true)."
  default     = {}
}

variable "access_policies" {
  type = list(object({
    type                    = optional(string)
    name                    = string
    object_id               = optional(string, "")
    key_permissions         = optional(list(string))
    secret_permissions      = optional(list(string))
    certificate_permissions = optional(list(string))
    storage_permissions     = optional(list(string))
  }))
  description = "Legacy access policies when `enable_rbac_authorization` is false. Each entry requires a unique, non-empty `name` (used as the stable key in Terraform maps and in lookups). Provide `object_id` or set `type` to `user` / `group` / `service_principal` and use `name` for Entra lookup."
  default     = []

  validation {
    condition = alltrue([
      for p in var.access_policies : trimspace(p.name) != ""
    ])
    error_message = "Each access_policies entry must have a non-empty name."
  }

  validation {
    condition     = length(distinct([for p in var.access_policies : p.name])) == length(var.access_policies)
    error_message = "Each access_policies entry must have a unique name."
  }
}
