variable "installed_managed_files" {
  description = "Accumulated list of user-managed file addresses (\"<file>/<branch>\") that have been provisioned at least once. Passed in by gh_provisioner from the entity's output secrets on every reconciliation. Defaults to [] on first apply."
  type        = list(string)
  default     = []
}

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

  # NOTE: config.files is intentionally allowed to be empty.
  # Under the provision-once design, callers (e.g. gh_provisioner) exclude
  # already-provisioned userManaged files from config.files and track them in
  # installed_managed_files instead. A feature whose files are all userManaged
  # therefore reaches a legitimate steady state where config.files == [] while
  # installed_managed_files is non-empty. Enforcing length > 0 here would break
  # every subsequent apply/destroy for those features.

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+/[a-zA-Z0-9_.-]+$", var.config.repository))
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
