variable "rulesets" {
  description = "Map of GitHub organization rulesets. Accepts the GitHub API export format directly — top-level export fields (id, source_type, source) and unknown rule parameters are silently ignored."
  type = map(object({
    name        = string
    target      = string # "branch" | "tag" | "push"
    enforcement = string # "disabled" | "evaluate" | "active"

    # GitHub API export fields — present in exports, ignored by the module
    id          = optional(number)
    source_type = optional(string)
    source      = optional(string)

    bypass_actors = optional(list(object({
      actor_id    = optional(number)
      actor_type  = string # "Integration" | "OrganizationAdmin" | "Team" | "RepositoryRole" | "DeployKey"
      bypass_mode = string # "always" | "pull_request"
    })), [])

    conditions = optional(object({
      ref_name = optional(object({
        include = optional(list(string), [])
        exclude = optional(list(string), [])
      }))
      repository_name = optional(object({
        include   = optional(list(string), [])
        exclude   = optional(list(string), [])
        protected = optional(bool, false)
      }))
    }))

    # Rules in GitHub API array format: [{ "type": "...", "parameters": {...} }]
    # Boolean rules (creation, deletion, update, non_fast_forward,
    # required_linear_history, required_signatures) carry no parameters.
    rules = optional(list(object({
      type = string
      parameters = optional(object({
        # pull_request
        required_approving_review_count   = optional(number)
        dismiss_stale_reviews_on_push     = optional(bool)
        require_code_owner_review         = optional(bool)
        require_last_push_approval        = optional(bool)
        required_review_thread_resolution = optional(bool)
        allowed_merge_methods             = optional(list(string))
        required_reviewers = optional(list(object({
          minimum_approvals = optional(number, 0)
          file_patterns     = optional(list(string), [])
          reviewer = optional(object({
            id   = number
            type = string # "Team"
          }))
        })), [])

        # required_status_checks
        required_status_checks               = optional(list(object({
          context        = string
          integration_id = optional(number)
        })))
        strict_required_status_checks_policy = optional(bool)
        do_not_enforce_on_create             = optional(bool)

        # Pattern rules: commit_message_pattern, commit_author_email_pattern,
        # committer_email_pattern, branch_name_pattern, tag_name_pattern
        operator = optional(string) # "starts_with" | "ends_with" | "contains" | "regex"
        pattern  = optional(string)
        name     = optional(string)
        negate   = optional(bool)

        # copilot_code_review
        review_on_push             = optional(bool)
        review_draft_pull_requests = optional(bool)

        # update rule — GitHub API field, not forwarded (provider uses a boolean)
        update_allows_fetch_and_merge = optional(bool)

        # Push-only rules
        restricted_file_paths      = optional(list(string))   # file_path_restriction
        restricted_file_extensions = optional(list(string))   # file_extension_restriction
        max_file_size              = optional(number)          # max_file_size (MB, 1-100)
        max_file_path_length       = optional(number)          # max_file_path_length (1-32767)
      }))
    })), [])
  }))

  default = {}

  validation {
    condition = alltrue([
      for k, v in var.rulesets : contains(["branch", "tag", "push"], v.target)
    ])
    error_message = "Each ruleset target must be one of: 'branch', 'tag', 'push'."
  }

  validation {
    condition = alltrue([
      for k, v in var.rulesets : contains(["disabled", "evaluate", "active"], v.enforcement)
    ])
    error_message = "Each ruleset enforcement must be one of: 'disabled', 'evaluate', 'active'."
  }

  validation {
    condition = alltrue(flatten([
      for k, v in var.rulesets : [
        for a in v.bypass_actors : contains(["Integration", "OrganizationAdmin", "Team", "RepositoryRole", "DeployKey"], a.actor_type)
      ]
    ]))
    error_message = "Each bypass_actor actor_type must be one of: 'Integration', 'OrganizationAdmin', 'Team', 'RepositoryRole', 'DeployKey'."
  }

  validation {
    condition = alltrue(flatten([
      for k, v in var.rulesets : [
        for a in v.bypass_actors : contains(["always", "pull_request"], a.bypass_mode)
      ]
    ]))
    error_message = "Each bypass_actor bypass_mode must be one of: 'always', 'pull_request'."
  }

  validation {
    condition = alltrue([
      for k, v in var.rulesets : alltrue([
        for r in v.rules :
        r.type != "pull_request" ? true :
        r.parameters == null ? true :
        r.parameters.required_approving_review_count == null ? true :
        (r.parameters.required_approving_review_count >= 0 && r.parameters.required_approving_review_count <= 10)
      ])
    ])
    error_message = "required_approving_review_count must be between 0 and 10."
  }
}
