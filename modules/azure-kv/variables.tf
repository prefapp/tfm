variable "name" {
  type        = string
  description = "Globally unique name of the Key Vault (3–24 characters; letters, numbers, and hyphens)."
}

variable "enabled_for_disk_encryption" {
  type        = bool
  description = "Whether the vault can be used for Azure Disk Encryption."
}

variable "soft_delete_retention_days" {
  type        = number
  description = "Number of days soft-deleted items are retained before permanent deletion."
}

variable "purge_protection_enabled" {
  type        = bool
  description = "Whether purge protection is enabled (prevents permanent purge of soft-deleted vaults and objects when true)."
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
    name                    = optional(string)
    object_id               = optional(string, "")
    key_permissions         = optional(list(string))
    secret_permissions      = optional(list(string))
    certificate_permissions = optional(list(string))
    storage_permissions     = optional(list(string))
  }))
  description = <<-EOT
    Legacy access policies when `enable_rbac_authorization` is false.

    Each object must include a **non-empty, unique `name`**: the module uses `name` as the map key in `for_each` and to index Azure AD data sources, so duplicate or empty values will fail at plan time.

    Provide `object_id` (with `type` unset/empty) or set `type` to `user`, `group`, or `service_principal` and use `name` as UPN, group display name, or service principal display name for lookup.
  EOT
  default     = []
}
