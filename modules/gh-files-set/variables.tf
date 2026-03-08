variable "config" {
  description = "GitHub files configuration — userManaged files survive terraform destroy"
  type = object({
    files = list(object({
      branch            = string
      commitMessage     = string
      content           = string
      file              = string
      repository        = string
      overwriteOnCreate = optional(bool, true)
      userManaged       = optional(bool, false)   # ← this decides everything
    }))
  })

  validation {
    condition     = length(var.config.files) > 0
    error_message = "At least one file must be defined."
  }

  validation {
    condition = alltrue([
      for f in var.config.files :
      length(trimspace(f.branch)) > 0 &&
      length(trimspace(f.commitMessage)) > 0 &&
      length(trimspace(f.file)) > 0 &&
      length(trimspace(f.repository)) > 0
    ])
    error_message = "Every file must have non-empty branch, commitMessage, file path, and repository."
  }
}
