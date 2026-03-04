# Variables
variable "resource_group_name" {
  description = "The name of the resource group in which to create the NAt Gateway"
  type = string
}

variable "nat_gateway_name" {
  description = "The name of the NAT GAteway"
  type = string
}

variable "location" {
  description = "The location/region where the NAT Gateway will be created"
  type = string
}

variable "nat_gateway_timeout" {
  description = "The idle timeout which should be used"
  type = number
  default = 4
}

variable "nat_gateway_sku" {
  description = "The SKU of the NAT Gateway"
  type = string
  default = "Standard"
}

variable "nat_gateway_zones" {
  description = "Availability zones where the NAT Gateway should be deployed"
  type = list(string)
  default = []
}

variable "public_ip_id" {
  description = "The ID of the public IP to be attached to the NAT Gateway"
  type = string
}

variable "subnet_id" {
  description = "The ID of the subnet where the NAT Gateway will connect"
  type = string
}

variable "tags" {
  description = "A map of tags to add to the public IP"
  type = map(string)
  default = {}
}

variable "tags_from_rg" {
  description = "Use the tags from the resource group"
  type = bool
  default = true
}
