variable "kms_id" {
  description = "ID of the OKMS that holds the Harbor admin credentials and receives the robot credentials."
  type        = string
}

variable "registry_name" {
  description = "Name of the Managed Private Registry. Used as the KMS path prefix of the robot secrets."
  type        = string
}

variable "registry_url" {
  description = "Access URL of the registry, as returned by the root module registry_url output."
  type        = string
}

variable "admin_secret_path" {
  description = "KMS path of the Harbor admin credentials ({username, password}), as returned by the root module admin_secret_path output."
  type        = string
}

variable "secret_custom_metadata" {
  description = "Custom metadata added to every robot KMS secret. The registry, access and project keys are always set by the module."
  type        = map(string)
  default = {
    owner = "firestartr"
  }
}

variable "global_robots" {
  description = "System robot accounts with access to every Harbor project, keyed by robot name. access: write (pull and push) or read (pull)."
  type = map(object({
    access      = string
    description = optional(string, "")
  }))
  default = {}

  validation {
    condition     = alltrue([for robot in values(var.global_robots) : contains(["read", "write"], robot.access)])
    error_message = "global_robots access must be read or write."
  }
}

variable "projects" {
  description = "Harbor projects to create, keyed by project name. public allows anonymous pull (default false). robots are optional project-scoped robot accounts."
  type = map(object({
    public = optional(bool, false)
    robots = optional(map(object({
      access      = string
      description = optional(string, "")
    })), {})
  }))
  default = {}

  validation {
    condition = alltrue(flatten([
      for project in values(var.projects) : [
        for robot in values(project.robots) : contains(["read", "write"], robot.access)
      ]
    ]))
    error_message = "projects robots access must be read or write."
  }
}
