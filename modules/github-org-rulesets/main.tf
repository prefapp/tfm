locals {
  # Index rules by type for O(1) lookup in dynamic blocks.
  # Boolean rules (deletion, non_fast_forward, …) have null parameters — that's fine,
  # we only check key presence for those. Complex rules carry their parameters object.
  rules_by_type = {
    for k, v in var.rulesets : k => {
      for r in v.rules : r.type => r.parameters
    }
  }
}

resource "github_organization_ruleset" "this" {
  for_each = var.rulesets

  name        = each.value.name
  target      = each.value.target
  enforcement = each.value.enforcement

  dynamic "bypass_actors" {
    for_each = each.value.bypass_actors
    content {
      actor_id    = bypass_actors.value.actor_id
      actor_type  = bypass_actors.value.actor_type
      bypass_mode = bypass_actors.value.bypass_mode
    }
  }

  dynamic "conditions" {
    for_each = each.value.conditions != null ? [each.value.conditions] : []
    content {
      # ref_name is only valid for branch and tag targets — not for push.
      dynamic "ref_name" {
        for_each = each.value.target != "push" && conditions.value.ref_name != null ? [conditions.value.ref_name] : []
        content {
          # The GitHub API exports "Targeting not configured" as include=[].
          # The Terraform provider requires at least one entry and panics with empty
          # arrays. Since this state is irrepresentable in the provider, we default
          # to ~DEFAULT_BRANCH for branch targets and ~ALL for tag targets.
          include = length(ref_name.value.include) > 0 ? ref_name.value.include : (
            each.value.target == "branch" ? ["~DEFAULT_BRANCH"] : ["~ALL"]
          )
          exclude = ref_name.value.exclude
        }
      }

      dynamic "repository_name" {
        for_each = conditions.value.repository_name != null ? [conditions.value.repository_name] : []
        content {
          include   = repository_name.value.include
          exclude   = repository_name.value.exclude
          protected = repository_name.value.protected
        }
      }
    }
  }

  rules {
    # Boolean rules — enabled by presence of the rule type in the list
    creation                = contains(keys(local.rules_by_type[each.key]), "creation") ? true : null
    deletion                = contains(keys(local.rules_by_type[each.key]), "deletion") ? true : null
    update                  = contains(keys(local.rules_by_type[each.key]), "update") ? true : null
    non_fast_forward        = contains(keys(local.rules_by_type[each.key]), "non_fast_forward") ? true : null
    required_linear_history = contains(keys(local.rules_by_type[each.key]), "required_linear_history") ? true : null
    required_signatures     = contains(keys(local.rules_by_type[each.key]), "required_signatures") ? true : null

    dynamic "pull_request" {
      for_each = lookup(local.rules_by_type[each.key], "pull_request", null) != null ? [local.rules_by_type[each.key]["pull_request"]] : []
      content {
        dismiss_stale_reviews_on_push     = pull_request.value.dismiss_stale_reviews_on_push
        require_code_owner_review         = pull_request.value.require_code_owner_review
        require_last_push_approval        = pull_request.value.require_last_push_approval
        required_approving_review_count   = pull_request.value.required_approving_review_count
        required_review_thread_resolution = pull_request.value.required_review_thread_resolution
        allowed_merge_methods             = pull_request.value.allowed_merge_methods

        dynamic "required_reviewers" {
          for_each = [for r in coalesce(pull_request.value.required_reviewers, []) : r if r.reviewer != null]
          content {
            reviewer {
              id   = required_reviewers.value.reviewer.id
              type = required_reviewers.value.reviewer.type
            }
            file_patterns     = required_reviewers.value.file_patterns
            minimum_approvals = required_reviewers.value.minimum_approvals
          }
        }
      }
    }

    dynamic "required_status_checks" {
      for_each = lookup(local.rules_by_type[each.key], "required_status_checks", null) != null ? [local.rules_by_type[each.key]["required_status_checks"]] : []
      content {
        strict_required_status_checks_policy = required_status_checks.value.strict_required_status_checks_policy
        do_not_enforce_on_create             = required_status_checks.value.do_not_enforce_on_create

        dynamic "required_check" {
          for_each = coalesce(required_status_checks.value.required_status_checks, [])
          content {
            context        = required_check.value.context
            integration_id = required_check.value.integration_id
          }
        }
      }
    }

    dynamic "commit_message_pattern" {
      for_each = lookup(local.rules_by_type[each.key], "commit_message_pattern", null) != null ? [local.rules_by_type[each.key]["commit_message_pattern"]] : []
      content {
        operator = commit_message_pattern.value.operator
        pattern  = commit_message_pattern.value.pattern
        name     = commit_message_pattern.value.name
        negate   = commit_message_pattern.value.negate
      }
    }

    dynamic "commit_author_email_pattern" {
      for_each = lookup(local.rules_by_type[each.key], "commit_author_email_pattern", null) != null ? [local.rules_by_type[each.key]["commit_author_email_pattern"]] : []
      content {
        operator = commit_author_email_pattern.value.operator
        pattern  = commit_author_email_pattern.value.pattern
        name     = commit_author_email_pattern.value.name
        negate   = commit_author_email_pattern.value.negate
      }
    }

    dynamic "committer_email_pattern" {
      for_each = lookup(local.rules_by_type[each.key], "committer_email_pattern", null) != null ? [local.rules_by_type[each.key]["committer_email_pattern"]] : []
      content {
        operator = committer_email_pattern.value.operator
        pattern  = committer_email_pattern.value.pattern
        name     = committer_email_pattern.value.name
        negate   = committer_email_pattern.value.negate
      }
    }

    dynamic "branch_name_pattern" {
      for_each = lookup(local.rules_by_type[each.key], "branch_name_pattern", null) != null ? [local.rules_by_type[each.key]["branch_name_pattern"]] : []
      content {
        operator = branch_name_pattern.value.operator
        pattern  = branch_name_pattern.value.pattern
        name     = branch_name_pattern.value.name
        negate   = branch_name_pattern.value.negate
      }
    }

    dynamic "tag_name_pattern" {
      for_each = lookup(local.rules_by_type[each.key], "tag_name_pattern", null) != null ? [local.rules_by_type[each.key]["tag_name_pattern"]] : []
      content {
        operator = tag_name_pattern.value.operator
        pattern  = tag_name_pattern.value.pattern
        name     = tag_name_pattern.value.name
        negate   = tag_name_pattern.value.negate
      }
    }

    dynamic "copilot_code_review" {
      for_each = lookup(local.rules_by_type[each.key], "copilot_code_review", null) != null ? [local.rules_by_type[each.key]["copilot_code_review"]] : []
      content {
        review_on_push             = copilot_code_review.value.review_on_push
        review_draft_pull_requests = copilot_code_review.value.review_draft_pull_requests
      }
    }

    # Push-only rules
    dynamic "file_path_restriction" {
      for_each = lookup(local.rules_by_type[each.key], "file_path_restriction", null) != null ? [local.rules_by_type[each.key]["file_path_restriction"]] : []
      content {
        restricted_file_paths = file_path_restriction.value.restricted_file_paths
      }
    }

    dynamic "file_extension_restriction" {
      for_each = lookup(local.rules_by_type[each.key], "file_extension_restriction", null) != null ? [local.rules_by_type[each.key]["file_extension_restriction"]] : []
      content {
        restricted_file_extensions = file_extension_restriction.value.restricted_file_extensions
      }
    }

    dynamic "max_file_size" {
      for_each = lookup(local.rules_by_type[each.key], "max_file_size", null) != null ? [local.rules_by_type[each.key]["max_file_size"]] : []
      content {
        max_file_size = max_file_size.value.max_file_size
      }
    }

    dynamic "max_file_path_length" {
      for_each = lookup(local.rules_by_type[each.key], "max_file_path_length", null) != null ? [local.rules_by_type[each.key]["max_file_path_length"]] : []
      content {
        max_file_path_length = max_file_path_length.value.max_file_path_length
      }
    }
  }
}
