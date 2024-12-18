
# Global variables
variable "mongo_region" {
  description = "The mongo region"
  type        = string
}

variable "provider_name" {
  description = "The provider name"
  type        = string
}

# Project seccion variables
variable "org_id" {
  description = "The organization ID"
  type        = string
}

variable "project_name" {
  description = "The name of the project"
  type        = string
}

# Users seccion variables
variable "database_users" {
  description = "A map of database users to create"
  type = map(object({
    username           = string
    password           = string
    auth_database_name = string
    roles = object({
      role_name     = string
      database_name = string
    })
    scopes = object({
      name = string
      type = string
    })
  }))
}

# Network seccion variables
variable "whitelist_ips" {
  description = "The whitelist IPs for the project"
  type = list(object({
    ip   = string
    name = string
  }))
}
