variable "config" {
  description = "GitHub files — userManaged files survive terraform destroy"
  type = object({
    files = list(object({
      branch            = string
      commitMessage     = string
      content           = string
      file              = string
      repository        = string
      overwriteOnCreate = optional(bool, true)
      userManaged       = optional(bool, false)
    }))
  })

  validation {
    condition     = length(var.config.files) > 0
    error_message = "At least one file must be defined."
  }
}
