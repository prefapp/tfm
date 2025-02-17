variable "name" {
  type        = string
  description = "The name of the User Assigned Identity."
}

variable "resource_group" {
  type        = string
  description = "The name of the Resource Group."
}

variable "location" {
  type        = string
  description = "The location/region where the User Assigned Identity should be created."
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the User Assigned Identity."
  default = {
    "name" = "value"
  }
}

variable "tags_from_rg" {
  type        = bool
  description = "If true, the User Assigned Identity will inherit the tags from the Resource Group."
  default     = false
}

variable "rbac" {
  type = list(object({
    name  = string
    scope = string
    roles = list(string)
  }))
  description = "A list of objects containing the RBAC roles to assign to the User Assigned Identity."
}

variable "rbac_custom_roles" {
  type = list(object({
    name             = string
    scope            = string
    definition_scope = string
    permissions      = object({
      actions          = optional(list(string), [])
      data_actions     = optional(list(string), [])
      not_actions      = optional(list(string), [])
      not_data_actions = optional(list(string), [])
    })
  }))
  description = "A list of objects containing custom roles to assign to the User Assigned Identity."
}


variable "access_policies" {
  description = "List of access policies for the Key Vault"
  type = list(object({
    key_vault_id = string
    key_permissions = optional(list(string), [])
    secret_permissions = optional(list(string), [])
    certificate_permissions = optional(list(string), [])
    storage_permissions = optional(list(string), [])
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
  description = "A list of objects containing the federated credentials to assign to the User Assigned Identity."
  default     = []
}

variable "audience" {
  type        = list(string)
  description = "The audience for the federated identity credential."
  default     = ["api://AzureADTokenExchange"]
}
