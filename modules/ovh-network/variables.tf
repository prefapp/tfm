variable "project_id" {
  description = "Optional Public Cloud project ID (project_id or service_name); takes precedence over project_name."
  type        = string
  default     = null
}

variable "project_name" {
  description = "Optional Public Cloud project name; matched against OVHcloud project_name and description."
  type        = string
  default     = null
}

variable "network_name" {
  description = "Name of the private network Kubernetes will use."
  type        = string
}

variable "gateway_name" {
  description = "Name of the private network gateway."
  type        = string
}

variable "region" {
  description = "OVHcloud region in which to create the network, for example EU-WEST-PAR or GRA11."
  type        = string
}

variable "vlan_id" {
  description = "VLAN ID for the private network."
  type        = number
}

variable "network_cidr" {
  description = "Private subnet CIDR."
  type        = string
}

variable "subnet_pool_start" {
  description = "First address in the DHCP pool."
  type        = string
}

variable "subnet_pool_end" {
  description = "Last address in the DHCP pool."
  type        = string
}

variable "gateway_model" {
  description = "Public Cloud gateway model."
  type        = string
}
