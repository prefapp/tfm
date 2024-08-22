variable "name" {
  type        = string
  description = "The name of the User Assigned Identity."
}

variable "resource_group_name" {
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

variable "federated_credentials" {
  type = list(object({
    name                 = string
    type                 = string
    issuer               = string
    namespace            = optional(string)
    service_account_name = optional(string)
    organization         = optional(string)
    repository           = optional(string)
    entity               = optional(string)
  }))
  validation {
    condition     = contains(["K8s", "github"], var.federated_credentials[*].type)
    error_message = "The type must be either 'K8s' or 'github'."
  }
  description = "A list of objects containing the federated credentials to assign to the User Assigned Identity."
  default     = [{}]
}
