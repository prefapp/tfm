variable "project_id" {
  description = "Optional Public Cloud project ID (project_id or service_name); takes precedence over project_name."
  type        = string
  default     = null

  validation {
    condition     = var.project_id == null || length(trimspace(var.project_id)) > 0
    error_message = "project_id must be null or a non-empty string."
  }
}

variable "project_name" {
  description = "Optional Public Cloud project name; matched against OVHcloud project_name and description."
  type        = string
  default     = null

  validation {
    condition     = var.project_name == null || length(trimspace(var.project_name)) > 0
    error_message = "project_name must be null or a non-empty string."
  }
}

variable "network_name" {
  description = "Name of the private network Kubernetes will use."
  type        = string

  validation {
    condition     = length(trimspace(var.network_name)) > 0
    error_message = "network_name must not be empty or whitespace."
  }
}

variable "gateway_name" {
  description = "Name of the private network gateway."
  type        = string

  validation {
    condition     = length(trimspace(var.gateway_name)) > 0
    error_message = "gateway_name must not be empty or whitespace."
  }
}

variable "region" {
  description = "OVHcloud region in which to create the network, for example EU-WEST-PAR or GRA11."
  type        = string

  validation {
    condition     = length(trimspace(var.region)) > 0
    error_message = "region must not be empty or whitespace."
  }
}

variable "vlan_id" {
  description = "VLAN ID for the private network."
  type        = number

  validation {
    condition     = var.vlan_id == floor(var.vlan_id) && var.vlan_id >= 0 && var.vlan_id <= 4000
    error_message = "vlan_id must be an integer between 0 and 4000, as supported by OVHcloud Public Cloud."
  }
}

variable "network_cidr" {
  description = "Private subnet CIDR."
  type        = string

  validation {
    condition = can(cidrnetmask(var.network_cidr)) && !anytrue([
      for prefix in [
        "10.2.",
        "10.3.",
        "10.240.",
        "10.241.",
        "10.242.",
        "10.243.",
        "10.244.",
        "10.245.",
        "10.246.",
        "10.247.",
        "172.17.",
      ] : startswith(var.network_cidr, prefix)
      ]) && !anytrue([
      for prohibited in [
        "10.0.0.0/8",
        "10.240.0.0/13",
        "10.240.0.0/12",
        "10.224.0.0/11",
        "10.192.0.0/10",
        "10.128.0.0/9",
        "10.2.0.0/16",
        "10.3.0.0/16",
        "172.17.0.0/16",
      ] : var.network_cidr == prohibited
    ])
    error_message = "network_cidr must be a valid IPv4 CIDR and must not start with a reserved prefix or exactly match a prohibited CIDR."
  }
}

variable "subnet_pool_start" {
  description = "First address in the DHCP pool."
  type        = string

  validation {
    condition     = can(cidrhost("${var.subnet_pool_start}/32", 0))
    error_message = "subnet_pool_start must be a valid IPv4 address."
  }
}

variable "subnet_pool_end" {
  description = "Last address in the DHCP pool."
  type        = string

  validation {
    condition     = can(cidrhost("${var.subnet_pool_end}/32", 0))
    error_message = "subnet_pool_end must be a valid IPv4 address."
  }
}

variable "gateway_model" {
  description = "Public Cloud gateway model: s, m, l, xl, or 2xl. Availability may vary by region."
  type        = string

  validation {
    condition     = contains(["s", "m", "l", "xl", "2xl"], lower(var.gateway_model))
    error_message = "gateway_model must be one of: s, m, l, xl, or 2xl."
  }
}
