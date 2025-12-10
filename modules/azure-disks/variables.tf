# Variable section
variable "location" {
  description = "The Azure region where the managed disk should be created."
  type = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which the managed disk should be created."
  type = string
}

variable "disks" {
  description = "A map of managed disk configurations."
}

variable "assign_role" {
  description = "Whether to assign a role definition to the managed disk."
  type = bool
  default = false
}

variable "role_definition_name" {
  description = "The name of the role definition to assign to the managed disk."
  default = "Contributor"
}

variable "principal_id" {
  description = "The ID of the principal to assign the role definition to."
  type = string
  default = ""
}

variable "tags_from_rg" {
  description = "Use resource group tags as base for module tags"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
