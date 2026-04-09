variable "name" {
  type        = string
  description = "Key Vault name (globally unique, 3–24 alphanumeric characters)."
}

variable "enabled_for_disk_encryption" {
  type        = bool
  description = "Whether Azure Disk Encryption can retrieve secrets from this vault."
}

variable "soft_delete_retention_days" {
  type        = number
  description = "Soft-delete retention in days (7–90 for new vaults; see provider docs)."
}

variable "purge_protection_enabled" {
  type        = bool
  description = "Enable purge protection (irreversible once enabled)."
}

variable "sku_name" {
  type        = string
  description = "SKU: standard or premium."
}

variable "resource_group" {
  type        = string
  description = "Name of the existing resource group for the Key Vault."
}

variable "enable_rbac_authorization" {
  type        = bool
  description = "Use Azure RBAC for data plane; when true, access_policies must be empty (enforced by precondition)."
}

variable "tags_from_rg" {
  type        = bool
  description = "If true, merge tags from the resource group with var.tags (var.tags override on key conflicts)."
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "Tags for the Key Vault; merged with resource group tags when tags_from_rg is true."
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
    Access-policy entries when enable_rbac_authorization is false. Each entry needs a unique `name` (used as internal key).
    Set `object_id` to use a principal directly; otherwise set `type` to `user`, `group`, or `service_principal` and `name` to the UPN / display name for lookup.
  EOT
  validation {
    condition = alltrue([
      for p in var.access_policies : try(trimspace(p.name), "") != ""
    ])
    error_message = "Each access_policies entry must have a non-empty name."
  }
  validation {
    condition     = length(distinct([for p in var.access_policies : try(p.name, "")])) == length(var.access_policies)
    error_message = "Each access_policies entry must have a unique name."
  }
  default = []
}
