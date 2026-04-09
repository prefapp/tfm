variable "name" {
  type        = string
  description = "Name of the user-assigned managed identity."
}

variable "resource_group" {
  type        = string
  description = "Resource group name where the identity is created (must exist)."
}

variable "location" {
  type        = string
  description = "Azure region for the identity."
}

variable "tags" {
  type        = map(string)
  description = "Tags for the identity when tags_from_rg is false."
  default     = {}
}

variable "tags_from_rg" {
  type        = bool
  description = "If true, use tags from the resource group data source instead of var.tags."
  default     = false
}

variable "rbac" {
  type = list(object({
    name  = string
    scope = string
    roles = list(string)
  }))
  description = "RBAC blocks: each entry expands to one role assignment per role in roles."
}

variable "access_policies" {
  description = "Key Vault access policies for this identity (one object per key_vault_id)."
  type = list(object({
    key_vault_id            = string
    key_permissions         = optional(list(string), [])
    secret_permissions      = optional(list(string), [])
    certificate_permissions = optional(list(string), [])
    storage_permissions     = optional(list(string), [])
  }))
  default = []
}

variable "federated_credentials" {
  type = list(object({
    name                 = string
    type                 = string
    issuer               = optional(string)
    namespace            = optional(string)
    service_account_name = optional(string)
    organization         = optional(string)
    repository           = optional(string)
    entity               = optional(string)
    subject              = optional(string)
  }))
  validation {
    condition     = alltrue([for cred in var.federated_credentials : contains(["kubernetes", "github", "other"], cred.type)])
    error_message = "The type must be either 'kubernetes', 'github' or 'other'."
  }
  validation {
    condition = alltrue([
      for cred in var.federated_credentials :
      cred.type != "github" || (cred.organization != null && cred.repository != null)
    ])
    error_message = "GitHub federated credentials require organization and repository."
  }
  validation {
    condition = alltrue([
      for cred in var.federated_credentials :
      cred.type != "kubernetes" || (
        cred.issuer != null && cred.namespace != null && cred.service_account_name != null
      )
    ])
    error_message = "Kubernetes federated credentials require issuer, namespace, and service_account_name."
  }
  validation {
    condition = alltrue([
      for cred in var.federated_credentials :
      cred.type != "other" || (cred.issuer != null && cred.subject != null)
    ])
    error_message = "Federated credentials with type 'other' require issuer and subject."
  }
  description = "Federated identity credentials (GitHub Actions, Kubernetes, or custom issuer/subject)."
  default     = []
}

variable "audience" {
  type        = list(string)
  description = "Audience list passed to every federated identity credential."
  default     = ["api://AzureADTokenExchange"]
}
