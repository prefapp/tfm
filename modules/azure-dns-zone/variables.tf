variable "dns_zone_name" {
  description = "Name of the Azure DNS Zone."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name where DNS zone will be created."
  type        = string
}

variable "tags" {
  description = "Tags to apply to the DNS zone."
  type        = map(string)
  default     = {}
}

variable "tags_from_rg" {
  description = "Use the tags from the resource group"
  type        = bool
  default     = false
}

# DNS Records support
variable "a_records" {
  description = "A records to create. List of objects: { name, ttl, records (list of IPs) }"
  type = list(object({
    name    = string
    ttl     = optional(number, 60)
    records = list(string)
  }))
  default = []

  validation {
    condition     = length(var.a_records) == length(distinct([for r in var.a_records : r.name]))
    error_message = "A records must have unique names. Found duplicate record names."
  }
}

variable "aaaa_records" {
  description = "AAAA records to create. List of objects: { name, ttl, records (list of IPs) }"
  type = list(object({
    name    = string
    ttl     = optional(number, 60)
    records = list(string)
  }))
  default = []

  validation {
    condition     = length(var.aaaa_records) == length(distinct([for r in var.aaaa_records : r.name]))
    error_message = "AAAA records must have unique names. Found duplicate record names."
  }
}

variable "cname_records" {
  description = "CNAME records to create. List of objects: { name, ttl, record (target) }"
  type = list(object({

  validation {
    condition     = length(var.cname_records) == length(distinct([for r in var.cname_records : r.name]))
    error_message = "CNAME records must have unique names. Found duplicate record names."
  }
    name   = string
    ttl    = optional(number, 60)
    record = string
  }))
  default = []
}

variable "mx_records" {

  validation {
    condition     = length(var.mx_records) == length(distinct([for r in var.mx_records : r.name]))
    error_message = "MX records must have unique names. Found duplicate record names."
  }
  description = "MX records to create. List of objects: { name, ttl, records (list of { preference, exchange }) }"
  type = list(object({
    name    = string
    ttl     = optional(number, 60)
    records = list(object({
      preference = number
      exchange   = string
    }))
  }))
  default = []

  validation {
    condition     = length(var.txt_records) == length(distinct([for r in var.txt_records : r.name]))
    error_message = "TXT records must have unique names. Found duplicate record names."
  }
}

variable "txt_records" {
  description = "TXT records to create. List of objects: { name, ttl, records (list of { value }) }"
  type = list(object({
    name    = string
    ttl     = optional(number, 60)
    records = list(object({
      value = string
    }))
  }))
  default = []
}

variable "ns_records" {
  description = "NS records to create. List of objects: { name, ttl, records (list of strings) }"
  type = list(object({
    name    = string
    ttl     = optional(number, 60)
    records = list(string)
  }))
  default = []

  validation {
    condition     = length(var.ns_records) == length(distinct([for r in var.ns_records : r.name]))
    error_message = "NS records must have unique names. Found duplicate record names."
  }
}

variable "caa_records" {
  description = "CAA records to create. List of objects: { name, ttl, records (list of { flags, tag, value }) }"
  type = list(object({
    name    = string
    ttl     = optional(number, 60)
    records = list(object({
      flags = number

  validation {
    condition     = length(var.caa_records) == length(distinct([for r in var.caa_records : r.name]))
    error_message = "CAA records must have unique names. Found duplicate record names."
  }
      tag   = string
      value = string
    }))
  }))
  default = []
}

variable "ptr_records" {
  description = "PTR records to create. List of objects: { name, ttl, records (list of strings) }"
  type = list(object({

  validation {
    condition     = length(var.ptr_records) == length(distinct([for r in var.ptr_records : r.name]))
    error_message = "PTR records must have unique names. Found duplicate record names."
  }
    name    = string
    ttl     = optional(number, 60)
    records = list(string)
  }))
  default = []
}

variable "srv_records" {
  description = "SRV records to create. List of objects: { name, ttl, records (list of { priority, weight, port, target }) }"
  type = list(object({

  validation {
    condition     = length(var.srv_records) == length(distinct([for r in var.srv_records : r.name]))
    error_message = "SRV records must have unique names. Found duplicate record names."
  }
    name    = string
    ttl     = optional(number, 60)
    records = list(object({
      priority = number
      weight   = number
      port     = number
      target   = string
    }))
  }))
  default = []
}
