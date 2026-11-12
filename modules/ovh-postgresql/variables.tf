variable "project_id" {
  description = "Optional Public Cloud project ID or service_name; takes precedence over project_name."
  type        = string
  default     = null

  validation {
    condition     = var.project_id == null || length(trimspace(var.project_id)) > 0
    error_message = "project_id must be null or a non-empty string."
  }
}

variable "project_name" {
  description = "Optional Public Cloud project name; matched against project_name and description."
  type        = string
  default     = null

  validation {
    condition     = var.project_name == null || length(trimspace(var.project_name)) > 0
    error_message = "project_name must be null or a non-empty string."
  }
}

variable "name" {
  description = "Database service description and prefix for generated OKMS secret paths."
  type        = string

  validation {
    condition     = length(trimspace(var.name)) > 0
    error_message = "name must not be empty."
  }
}

variable "region" {
  description = "OVHcloud region for the cluster and all its nodes. Must be in the maintained PostgreSQL offer catalogue."
  type        = string

  validation {
    condition     = contains(jsondecode(file("${path.module}/data/postgresql-offers.json")).regions, var.region)
    error_message = "region must be listed in the maintained OVHcloud PostgreSQL offer catalogue."
  }
}

variable "network_name" {
  description = "Exact name of the existing private network to attach to the cluster."
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR of the existing subnet to attach to the cluster."
  type        = string

  validation {
    condition     = can(cidrhost(var.subnet_cidr, 0))
    error_message = "subnet_cidr must be a valid CIDR."
  }
}

variable "engine_version" {
  description = "Required PostgreSQL engine major version. Must appear in the maintained OVHcloud offer catalogue."
  type        = string
  nullable    = false

  validation {
    condition     = contains(jsondecode(file("${path.module}/data/postgresql-offers.json")).versions, var.engine_version)
    error_message = "engine_version must be listed in the maintained OVHcloud PostgreSQL offer catalogue."
  }
}

variable "plan" {
  description = "OVHcloud database plan. discovery has one node, production two, and advanced three."
  type        = string

  validation {
    condition     = contains(keys(jsondecode(file("${path.module}/data/postgresql-offers.json")).plans), var.plan)
    error_message = "plan must be listed in the maintained OVHcloud PostgreSQL offer catalogue."
  }
}

variable "flavor" {
  description = "Database node flavor available for the selected plan, region and PostgreSQL version in the maintained OVHcloud offer catalogue."
  type        = string

  validation {
    condition     = contains(keys(try(jsondecode(file("${path.module}/data/postgresql-offers.json")).plans[var.plan].flavors, {})), lower(var.flavor))
    error_message = "flavor must be offered for the selected plan in the maintained OVHcloud PostgreSQL catalogue."
  }
}

variable "disk_size" {
  description = "Database disk size in GB. Must meet the maintained OVHcloud offer's minimum, maximum and increment for the selected plan and flavor."
  type        = number

  validation {
    condition     = var.disk_size > 0 && floor(var.disk_size) == var.disk_size
    error_message = "disk_size must be a positive integer; it must also fit the selected offer's range and increment."
  }
}

variable "ip_restrictions" {
  description = "Optional CIDR allow-list. When empty, only subnet_cidr is allowed."
  type = list(object({
    ip          = string
    description = optional(string, "")
  }))
  default = []

  validation {
    condition     = alltrue([for restriction in var.ip_restrictions : can(cidrhost(restriction.ip, 0))])
    error_message = "Every ip_restrictions ip must be a valid CIDR."
  }
}

variable "allow_all_ips" {
  description = "Explicit opt-in required before allowing 0.0.0.0/0 or ::/0 in ip_restrictions."
  type        = bool
  default     = false
}

variable "advanced_configuration" {
  description = "PostgreSQL advanced configuration key/value pairs supported by OVHcloud."
  type        = map(string)
  default     = {}
}

variable "backup_time" {
  description = "Daily backup start time in UTC, formatted as hh:mm:ss."
  type        = string
  default     = null

  validation {
    condition = var.backup_time == null || (
      can(regex("^[0-2][0-9]:[0-5][0-9]:[0-5][0-9]$", var.backup_time)) &&
      tonumber(substr(var.backup_time, 0, 2)) < 24
    )
    error_message = "backup_time must be null or a valid 24-hour hh:mm:ss time."
  }
}

variable "maintenance_time" {
  description = "Daily maintenance start time in UTC, formatted as hh:mm:ss."
  type        = string
  default     = null

  validation {
    condition = var.maintenance_time == null || (
      can(regex("^[0-2][0-9]:[0-5][0-9]:[0-5][0-9]$", var.maintenance_time)) &&
      tonumber(substr(var.maintenance_time, 0, 2)) < 24
    )
    error_message = "maintenance_time must be null or a valid 24-hour hh:mm:ss time."
  }
}

variable "backup_regions" {
  description = "One or two backup regions; one must be the database region."
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.backup_regions) <= 2 && length(var.backup_regions) == length(distinct(var.backup_regions))
    error_message = "backup_regions must contain at most two unique regions."
  }
}

variable "deletion_protection" {
  description = "Protect the database service from deletion. Disable only for discovery environments."
  type        = bool
  default     = true
}

variable "databases" {
  description = "Databases to create, keyed by stable Terraform identifier and mapped to their OVHcloud names."
  type        = map(string)

  validation {
    condition = alltrue([
      for name in values(var.databases) : length(trimspace(name)) > 0
    ]) && length(values(var.databases)) == length(distinct(values(var.databases)))
    error_message = "Database names must be non-empty and unique."
  }
}

variable "users" {
  description = "PostgreSQL users. Each user references one declared database and gets a direct-connection secret in OKMS."
  type = map(object({
    name           = string
    database       = string
    roles          = optional(list(string), [])
    password_reset = optional(string)
    secret_path    = optional(string)
  }))

  validation {
    condition = alltrue([
      for user in values(var.users) :
      length(trimspace(user.name)) > 0 &&
      length(trimspace(user.database)) > 0 &&
      (user.secret_path == null || length(trimspace(user.secret_path)) > 0) &&
      alltrue([for role in user.roles : contains(["replication"], role)])
    ]) && length([for user in values(var.users) : user.name]) == length(distinct([for user in values(var.users) : user.name]))
    error_message = "Users need unique non-empty names and database references; supported explicit role is replication."
  }
}

variable "connection_pools" {
  description = "PgBouncer pools keyed by stable Terraform identifier."
  type = map(object({
    name        = string
    database    = string
    mode        = string
    size        = number
    user        = optional(string)
    secret_path = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for pool in values(var.connection_pools) :
      length(trimspace(pool.name)) > 0 &&
      length(trimspace(pool.database)) > 0 &&
      contains(["session", "transaction", "statement"], pool.mode) &&
      pool.size > 0 && floor(pool.size) == pool.size &&
      (pool.user == null || length(trimspace(pool.user)) > 0) &&
      (pool.secret_path == null || length(trimspace(pool.secret_path)) > 0)
    ]) && length([for pool in values(var.connection_pools) : pool.name]) == length(distinct([for pool in values(var.connection_pools) : pool.name]))
    error_message = "Pools need unique non-empty names, a supported mode, and a positive integer size."
  }
}

variable "required_extensions" {
  description = "Extensions required by the workload. Checked against the OVHcloud catalogue and documented PostgreSQL version constraints; extensions are activated separately with CREATE EXTENSION."
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.required_extensions) == length(distinct(var.required_extensions))
    error_message = "required_extensions must not contain duplicates."
  }
}

variable "kms_id" {
  description = "ID of the existing OVHcloud KMS (OKMS) where database credentials are stored."
  type        = string
}

variable "secret_custom_metadata" {
  description = "Custom metadata added to generated OKMS secrets."
  type        = map(string)
  default = {
    owner = "firestartr"
  }
}
