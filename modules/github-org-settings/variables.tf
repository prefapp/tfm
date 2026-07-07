variable "config" {
  description = "GitHub organization settings configuration"
  type = object({
    billingEmail = string

    company         = optional(string)
    blog            = optional(string)
    email           = optional(string)
    twitterUsername = optional(string)
    location        = optional(string)
    name            = optional(string)
    description     = optional(string)

    hasOrganizationProjects              = optional(bool, true)
    hasRepositoryProjects                = optional(bool, true)
    defaultRepositoryPermission          = optional(string, "read")
    membersCanCreateRepositories         = optional(bool, true)
    membersCanCreatePublicRepositories   = optional(bool, true)
    membersCanCreatePrivateRepositories  = optional(bool, true)
    membersCanCreateInternalRepositories = optional(bool)
    membersCanCreatePages                = optional(bool, true)
    membersCanCreatePublicPages          = optional(bool, true)
    membersCanCreatePrivatePages         = optional(bool, true)
    membersCanForkPrivateRepositories    = optional(bool, false)
    webCommitSignoffRequired             = optional(bool, false)

    advancedSecurityEnabledForNewRepositories             = optional(bool, false)
    dependabotAlertsEnabledForNewRepositories             = optional(bool, false)
    dependabotSecurityUpdatesEnabledForNewRepositories    = optional(bool, false)
    dependencyGraphEnabledForNewRepositories              = optional(bool, false)
    secretScanningEnabledForNewRepositories               = optional(bool, false)
    secretScanningPushProtectionEnabledForNewRepositories = optional(bool, false)
  })

  validation {
    condition     = length(trimspace(var.config.billingEmail)) > 0
    error_message = "config.billingEmail must be a non-empty email address."
  }

  validation {
    condition     = can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", var.config.billingEmail))
    error_message = "config.billingEmail must look like a valid email address."
  }

  validation {
    condition     = contains(["read", "write", "admin", "none"], var.config.defaultRepositoryPermission)
    error_message = "config.defaultRepositoryPermission must be one of: read, write, admin, none."
  }
}
