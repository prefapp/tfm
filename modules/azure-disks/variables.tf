# Variable section
variable "environment" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "disks" {
  description = "A map of managed disk configurations."
  type = map(object({
    name_prefix          = optional(string)
    custom_name          = optional(string)
    storage_account_type = string
  }))
}
