variable "name" {
  type        = string
  description = "Globally unique name of the Key Vault (Azure naming rules apply)."
}

variable "enabled_for_disk_encryption" {
  type        = bool
  description = "Whether the Key Vault can be used for Azure Disk Encryption."
}

variable "soft_delete_retention_days" {
  type        = number
  description = "Number of days soft-deleted items are retained before permanent deletion."
}

variable "purge_protection_enabled" {
  type        = bool
  description = "Whether purge protection is enabled (prevents permanent delete until retention elapses)."
}

variable "sku_name" {
  type        = string
  description = "SKU for the Key Vault (for example `standard` or `premium`)."
}

variable "resource_group" {
  type        = string
  description = "Name of the existing resource group where the Key Vault is created."
}

variable "enable_rbac_authorization" {
  type        = bool
  description = "If true, use Azure RBAC for data plane access; `access_policies` must then be empty."
}

variable "tags_from_rg" {
  type        = bool
  default     = false
  description = "When true, merge resource group tags with `tags` (module tags override on key conflict)."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied to the Key Vault (merged with resource group tags when `tags_from_rg` is true)."
}

variable "access_policies" {
  type = list(object({
    type                    = optional(string)
    name                    = optional(string)
    object_id               = optional(string, "")
    key_permissions         = optional(list(string))
    secret_permissions      = optional(list(string))
    certificate_permissions = optional(list(string))
    storage_permissions     = optional(list(string))
  }))
  default     = []
  description = <<-EOT
    Access policy entries when `enable_rbac_authorization` is false. Use a non-empty `object_id` to skip Azure AD lookup,
    or set `type` to `user`, `group`, or `service_principal` and `name` for lookup. Entries that do not resolve to an
    object id are omitted from the vault access policies. Must be empty when `enable_rbac_authorization` is true.
  EOT
}
