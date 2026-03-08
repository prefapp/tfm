variable "config" {
  description = "Configuration for multiple GitHub repository files to be created/updated"
  type = object({
    files = list(object({
      branch            = string
      commitMessage     = string
      content           = string
      file              = string
      repository        = string
      overwriteOnCreate = optional(bool, true)
      lifecycle         = optional(any, {})   # placeholder for future extensions
    }))
  })

  validation {
    condition = length(var.config.files) > 0
    error_message = "At least one file must be defined in config.files"
  }

  validation {
    condition = alltrue([
      for f in var.config.files :
      length(trimspace(f.branch)) > 0 &&
      length(trimspace(f.commitMessage)) > 0 &&
      length(trimspace(f.file)) > 0 &&
      length(trimspace(f.repository)) > 0
    ])
    error_message = "Every file entry must have non-empty branch, commitMessage, file path, and repository name."
  }
}
