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
