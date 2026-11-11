variable "project_id" {
  description = "Optional Public Cloud project ID or service_name; takes precedence over project_name."
  type        = string
  default     = null
}

variable "project_name" {
  description = "Optional Public Cloud project name; matched against OVHcloud project_name and description."
  type        = string
  default     = null
}

variable "name" {
  description = "Description assigned to the managed MySQL service."
  type        = string

  validation {
    condition     = length(trimspace(var.name)) > 0
    error_message = "name must not be empty."
  }
}

variable "region" {
  description = "OVHcloud region where all MySQL nodes are deployed. OVHcloud validates regional availability when creating the service."
  type        = string

  validation {
    condition     = length(trimspace(var.region)) > 0
    error_message = "region must not be empty."
  }
}

variable "engine_version" {
  description = "MySQL engine version; must be present in the selected project's live capabilities."
  type        = string

  validation {
    condition     = length(trimspace(var.engine_version)) > 0
    error_message = "engine_version must not be empty."
  }
}

variable "plan" {
  description = "MySQL plan: discovery (1 node), production (2 nodes), or advanced (3 nodes)."
  type        = string

  validation {
    condition     = contains(["discovery", "production", "advanced"], var.plan)
    error_message = "plan must be discovery, production, or advanced."
  }
}

variable "flavor" {
  description = "MySQL node flavor; must be present in the selected project's live capabilities."
  type        = string

  validation {
    condition     = length(trimspace(var.flavor)) > 0
    error_message = "flavor must not be empty."
  }
}

variable "disk_size" {
  description = "Optional database disk size in GB. OVHcloud validates its supported range for the selected MySQL flavor."
  type        = number
  default     = null

  validation {
    condition     = var.disk_size == null || (var.disk_size >= 0 && floor(var.disk_size) == var.disk_size)
    error_message = "disk_size must be a non-negative integer when set. OVHcloud validates flavor-specific limits."
  }
}

variable "use_private_network" {
  description = "Attach every MySQL node to an existing private network and subnet. Set false explicitly for a service without private-network attachment."
  type        = bool
  default     = true
}

variable "network_name" {
  description = "Exact name of the existing private network. Required when use_private_network is true."
  type        = string
  default     = null
}

variable "subnet_cidr" {
  description = "CIDR of the existing subnet to attach and, by default, allow through the MySQL IP restriction list. Required when use_private_network is true."
  type        = string
  default     = null

  validation {
    condition     = var.subnet_cidr == null || can(cidrhost(var.subnet_cidr, 0))
    error_message = "subnet_cidr must be a valid CIDR when set."
  }
}

variable "ip_restrictions" {
  description = "Allowed source CIDRs. null defaults to the private subnet CIDR (or no allowed IPs without private networking); an empty list denies all incoming IP connections."
  type = list(object({
    ip          = string
    description = optional(string, "")
  }))
  default = null

  validation {
    condition = var.ip_restrictions == null || alltrue([
      for restriction in var.ip_restrictions : can(cidrhost(restriction.ip, 0))
    ])
    error_message = "Every ip_restrictions ip must be a valid CIDR."
  }

  validation {
    condition = var.ip_restrictions == null || alltrue([
      for restriction in var.ip_restrictions : restriction.ip != "0.0.0.0/0" && restriction.ip != "::/0"
    ]) || var.allow_public_access
    error_message = "The unrestricted IPv4 or IPv6 CIDR is rejected unless allow_public_access is true."
  }
}

variable "allow_public_access" {
  description = "Explicitly allow 0.0.0.0/0 or ::/0 in ip_restrictions. Avoid this outside temporary testing."
  type        = bool
  default     = false
}

variable "databases" {
  description = "List of MySQL database names to create in the service; names must be unique."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for database in var.databases : length(trimspace(database)) > 0 && length(database) <= 64
    ])
    error_message = "Each database name must contain 1 to 64 non-whitespace characters."
  }

  validation {
    condition     = length(var.databases) == length(toset(var.databases))
    error_message = "Database names must be unique."
  }
}

variable "advanced_configuration" {
  description = "Optional MySQL advanced configuration settings supported by OVHcloud."
  type        = map(string)
  default     = {}
}

variable "backup_time" {
  description = "Optional daily backup start time in UTC, formatted as hh:mm:ss."
  type        = string
  default     = null

  validation {
    condition     = var.backup_time == null || can(regex("^([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$", var.backup_time))
    error_message = "backup_time must use 24-hour UTC hh:mm:ss format."
  }
}

variable "maintenance_time" {
  description = "Optional daily maintenance start time in UTC, formatted as hh:mm:ss."
  type        = string
  default     = null

  validation {
    condition     = var.maintenance_time == null || can(regex("^([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$", var.maintenance_time))
    error_message = "maintenance_time must use 24-hour UTC hh:mm:ss format."
  }
}

variable "backup_regions" {
  description = "Optional backup destination regions, with at most two regions and including the MySQL node region. OVHcloud validates availability of each backup region."
  type        = set(string)
  default     = null

  validation {
    condition     = var.backup_regions == null || length(var.backup_regions) <= 2
    error_message = "backup_regions may contain at most two distinct regions."
  }
}

variable "deletion_protection" {
  description = "Enable OVHcloud deletion protection. Disable and apply it before destroying the service."
  type        = bool
  default     = true
}
