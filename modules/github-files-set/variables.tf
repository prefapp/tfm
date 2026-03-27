variable "config" {
  description = "GitHub files configuration — userManaged files are provisioned once and survive destroy"
  type = object({
    files = list(object({
      branch            = string
      commitMessage     = string
      content           = string
      file              = string
      overwriteOnCreate = optional(bool, true)
      userManaged       = optional(bool, false)
    }))

    repository = string
  })

  validation {
    condition     = length(var.config.files) > 0
    error_message = "At least one file must be defined in config.files"
  }

  validation {
    condition = can(regex("^[a-zA-Z0-9_-]+/[a-zA-Z0-9_.-]+$", var.config.repository))
    error_message = "config.repository must be in 'owner/repo' format."
  }

  validation {
    condition = length(var.config.files) == length(distinct([
      for f in var.config.files : jsonencode([f.file, f.branch])
    ]))
    error_message = "Duplicate file+branch combinations detected in config.files. Each combination of 'file' and 'branch' must be unique."
  }

  validation {
    condition = alltrue([
      for f in var.config.files :
      length(trimspace(f.branch)) > 0 &&
      length(trimspace(f.commitMessage)) > 0 &&
      length(trimspace(f.file)) > 0
    ])
    error_message = "Every file must have non-empty branch, commitMessage, and file path."
  }
}
