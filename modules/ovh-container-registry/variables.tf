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
  description = "Name of the Managed Private Registry. Also used as the KMS path prefix of its secrets."
  type        = string

  validation {
    condition     = length(trimspace(var.name)) > 0
    error_message = "name must not be empty."
  }
}

variable "region" {
  description = "Registry region as listed in the container registry capabilities, such as GRA."
  type        = string
  default     = "GRA"
}

variable "plan_name" {
  description = "Registry plan: SMALL, MEDIUM or LARGE. OVHcloud only allows upgrading the plan, never downgrading it."
  type        = string
  default     = "SMALL"

  validation {
    condition     = contains(["SMALL", "MEDIUM", "LARGE"], var.plan_name)
    error_message = "plan_name must be SMALL, MEDIUM or LARGE."
  }
}

variable "kms_id" {
  description = "ID of the OVHcloud KMS (OKMS) where the Harbor admin credentials are stored."
  type        = string
}

variable "admin_login" {
  description = "Login of the local Harbor admin user used to manage projects and robot accounts."
  type        = string
  default     = "root"
}

variable "admin_email" {
  description = "Email of the local Harbor admin user."
  type        = string
}

variable "secret_custom_metadata" {
  description = "Custom metadata added to the admin KMS secret. The registry key is always set to the registry name."
  type        = map(string)
  default = {
    owner = "firestartr"
  }
}

variable "ip_restrictions_management" {
  description = "CIDRs allowed to reach the Harbor UI and API. An empty list means no restriction."
  type = list(object({
    ip_block    = string
    description = optional(string, "")
  }))
  default = []

  validation {
    condition     = alltrue([for restriction in var.ip_restrictions_management : can(cidrhost(restriction.ip_block, 0))])
    error_message = "Every ip_restrictions_management ip_block must be a valid CIDR."
  }
}

variable "ip_restrictions_registry" {
  description = "CIDRs allowed to reach the registry endpoint (docker push and pull). An empty list means no restriction."
  type = list(object({
    ip_block    = string
    description = optional(string, "")
  }))
  default = []

  validation {
    condition     = alltrue([for restriction in var.ip_restrictions_registry : can(cidrhost(restriction.ip_block, 0))])
    error_message = "Every ip_restrictions_registry ip_block must be a valid CIDR."
  }
}
