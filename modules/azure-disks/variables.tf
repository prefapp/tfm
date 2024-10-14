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
