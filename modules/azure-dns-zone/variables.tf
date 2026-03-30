variable "a_record_ttl" {
  description = "TTL for A records. Default: 3600."
  type        = number
  default     = 60
}

variable "cname_record_ttl" {
  description = "TTL for CNAME records. Default: 3600."
  type        = number
  default     = 60
}
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
  description = "A records to create. Map of name => list of IPs."
  type        = map(list(string))
  default     = {}
}

variable "cname_records" {
  description = "CNAME records to create. Map of name => target (string)."
  type        = map(string)
  default     = {}
}

variable "mx_records" {
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
}
