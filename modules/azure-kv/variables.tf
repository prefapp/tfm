variable "name" {
  type = string
}

variable "enabled_for_disk_encryption" {
  type = bool
}

variable "soft_delete_retention_days" {
  type = number
}

variable "purge_protection_enabled" {
  type = bool
}

variable "sku_name" {
  type = string
}

variable "resource_group" {
  type = string
}

variable "enable_rbac_authorization" {
  type = bool
}

variable "tags_from_rg" {
  type    = bool
  default = false
}

variable "tags" {
  type = map(string)
  default = {}
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
  default = []
}
