variable "config" {
  description = "GitHub repository configuration (repository + default branch + files + variables + OIDC + teams + collaborators + pages + labels + branch_protections) as a single complex object"
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
      hasWiki             = optional(bool, true)
      hasDiscussions      = optional(bool, false)
    })

    default_branch = object({
      branch = string
      rename = optional(bool, false)
    })

    files = optional(list(object({
      branch            = string
      commitMessage     = string
      content           = string
      file              = string
      overwriteOnCreate = optional(bool, true)
    })), [])

    variables = optional(list(object({
      variableName = string
      value        = string
    })), [])

    oidc_subject_claim_customization_template = optional(object({
      useDefault       = optional(bool, true)
      includeClaimKeys = optional(list(string), [])
    }), null)

    teams = optional(list(object({
      teamId     = number # Use numeric team ID to remain stable if team slugs change
      permission = string
    })), [])

    collaborators = optional(list(object({
      username   = string
      permission = string
    })), [])

    # GitHub Pages configuration (handled via github_repository_pages resource; input remains for backward compatibility)
    pages = optional(object({
      # buildType: "legacy" (default) or "workflow". Previously set in the deprecated pages block of github_repository; now used in github_repository_pages.
      buildType = optional(string, "legacy")
      cname     = optional(string, null)
      source = optional(object({
        branch = string
        path   = optional(string, "/")
      }), null)
    }), null)

    labels = optional(list(object({
      name        = string
      description = optional(string, null)
      color       = string # 6-digit hex without # (e.g. "d73a4a")
    })), [])

    branch_protections = optional(list(object({
      branch                        = string
      statusChecks                  = optional(list(string), [])
      requiredReviewersCount        = optional(number, 0)
      requiredCodeownersReviewers   = optional(bool, false)
      enforceAdmins                 = optional(bool, false)
      requireSignedCommits          = optional(bool, false)
      requireConversationResolution = optional(bool, false)
      bypassPullRequestAllowances = optional(object({
        # apps  — GitHub App node IDs (pre-resolved by caller; the GitHub
        #         provider has no data.github_app data source)
        apps = optional(list(string), [])
        # teams — team slugs, resolved by data.github_team
        teams = optional(list(string), [])
        # users — user logins, resolved by data.github_user
        users = optional(list(string), [])
      }), null)
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
      for f in var.config.files : length(trimspace(f.branch)) > 0 && length(trimspace(f.file)) > 0 && length(trimspace(f.commitMessage)) > 0
    ])
    error_message = "Every file must have a non-empty 'branch', 'file' path and 'commitMessage'."
  }

  validation {
    condition = alltrue([
      for v in var.config.variables : length(trimspace(v.variableName)) > 0 && length(trimspace(v.value)) > 0
    ])
    error_message = "Every repository variable must have a non-empty variableName and value."
  }

  validation {
    condition     = var.config.pages == null ? true : contains(["legacy", "workflow"], var.config.pages.buildType)
    error_message = "pages.buildType must be 'legacy' or 'workflow'."
  }

  validation {
    condition = alltrue([
      for l in coalesce(var.config.labels, []) : length(trimspace(l.name)) > 0
    ])
    error_message = "Every label must have a non-empty 'name'."
  }

  validation {
    condition     = length(coalesce(var.config.labels, [])) == length(distinct([for l in coalesce(var.config.labels, []) : trimspace(l.name)]))
    error_message = "Label names must be unique."
  }

  validation {
    condition = alltrue([
      for l in coalesce(var.config.labels, []) : can(regex("^([A-Fa-f0-9]{6})$", l.color))
    ])
    error_message = "Label color must be a valid 6-character hex code without '#' (example: d73a4a)."
  }

  validation {
    condition = length(coalesce(var.config.branch_protections, [])) == length(distinct([
      for bp in coalesce(var.config.branch_protections, []) : trimspace(bp.branch)
    ]))
    error_message = "Branch protection patterns must be unique."
  }

  validation {
    condition = alltrue([
      for bp in coalesce(var.config.branch_protections, []) :
      bp.branch == trimspace(bp.branch) && length(trimspace(bp.branch)) > 0
    ])
    error_message = "Every branch protection must have a non-empty 'branch' pattern with no leading/trailing whitespace."
  }

  validation {
    condition = alltrue([
      for bp in coalesce(var.config.branch_protections, []) : bp.requiredReviewersCount >= 0
    ])
    error_message = "branch_protections.requiredReviewersCount must be >= 0."
  }

  validation {
    condition = alltrue(flatten([
      for bp in coalesce(var.config.branch_protections, []) : [
        for sc in coalesce(bp.statusChecks, []) : length(trimspace(sc)) > 0
      ]
    ]))
    error_message = "branch_protections.statusChecks entries must be non-empty strings."
  }

  validation {
    condition = alltrue(flatten([
      for bp in coalesce(var.config.branch_protections, []) : [
        for entry in coalesce(try(bp.bypassPullRequestAllowances.apps, []), []) :
        length(trimspace(entry)) > 0 && trimspace(entry) == entry
      ]
    ]))
    error_message = "branch_protections.bypassPullRequestAllowances.apps entries must be non-empty with no leading/trailing whitespace."
  }

  validation {
    condition = alltrue(flatten([
      for bp in coalesce(var.config.branch_protections, []) : [
        for entry in coalesce(try(bp.bypassPullRequestAllowances.teams, []), []) :
        length(trimspace(entry)) > 0 && trimspace(entry) == entry
      ]
    ]))
    error_message = "branch_protections.bypassPullRequestAllowances.teams entries must be non-empty with no leading/trailing whitespace."
  }

  validation {
    condition = alltrue(flatten([
      for bp in coalesce(var.config.branch_protections, []) : [
        for entry in coalesce(try(bp.bypassPullRequestAllowances.users, []), []) :
        length(trimspace(entry)) > 0 && trimspace(entry) == entry
      ]
    ]))
    error_message = "branch_protections.bypassPullRequestAllowances.users entries must be non-empty with no leading/trailing whitespace."
  }
}
