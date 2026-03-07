variable "config" {
  description = "GitHub repository configuration (repository + default branch + files) as a single complex object"
  type = object({
    repository = object({
      name                = string
      description         = optional(string, "")
      visibility          = optional(string, "private")
      topics              = optional(list(string), [])
      autoInit            = optional(bool, false)
      archiveOnDestroy    = optional(bool, false)
      allowMergeCommit    = optional(bool, true)
      allowSquashMerge    = optional(bool, true)
      allowRebaseMerge    = optional(bool, true)
      allowAutoMerge      = optional(bool, false)
      deleteBranchOnMerge = optional(bool, false)
      allowUpdateBranch   = optional(bool, false)
      hasIssues           = optional(bool, true)
    })

    default_branch = object({
      branch     = string
      rename     = optional(bool, false)
      repository = string
    })

    files = optional(list(object({
      branch            = string
      commitMessage     = string
      content           = string
      file              = string
      overwriteOnCreate = optional(bool, true)
      repository        = string
    })), [])
  })

  validation {
    condition     = length(trimspace(var.config.repository.name)) > 0
    error_message = "repository.name cannot be empty."
  }

  validation {
    condition     = contains(["public", "private", "internal"], var.config.repository.visibility)
    error_message = "repository.visibility must be 'public', 'private' or 'internal'."
  }

  validation {
    condition     = length(trimspace(var.config.default_branch.branch)) > 0
    error_message = "default_branch.branch cannot be empty."
  }

  validation {
    condition = alltrue([
      for f in var.config.files : length(trimspace(f.file)) > 0 && length(trimspace(f.commitMessage)) > 0
    ])
    error_message = "Every file must have non-empty 'file' path and 'commitMessage'."
  }
}
