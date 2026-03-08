variable "config" {
  description = "Configuration for GitHub repository files with explicit lifecycle control"
  type = object({
    files = list(object({
      branch                = string
      commitMessage         = string
      content               = string
      file                  = string
      repository            = string
      overwriteOnCreate     = optional(bool, true)
      lifecycle_ignore_changes = optional(list(string), [])   # ← EXPLICIT control from config
    }))
  })

  validation {
    condition     = length(var.config.files) > 0
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
    error_message = "Every file must have non-empty branch, commitMessage, file path, and repository name."
  }
}
