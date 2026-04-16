# **GitHub Organization Ruleset Terraform Module**

## Overview

This module creates and manages a single **GitHub Organization Ruleset** using the `github_organization_ruleset` resource.

Organization Rulesets are a modern GitHub feature that supersedes branch protection rules, offering finer-grained control over branch and tag governance across all repositories in an organization. They support targeting by ref name patterns or repository name patterns, defining bypass actors, and enforcing a comprehensive set of rules including pull request requirements, status checks, commit message patterns, and more.

This module is designed to be driven by JSON configuration. It natively accepts the **GitHub API export format**, so you can use a ruleset exported directly from the GitHub API or the GitHub CLI as input — export-only fields such as `id`, `source_type`, and `source` are silently ignored.

To manage **multiple rulesets** from a single module call, use the companion [`github-org-rulesets`](../github-org-rulesets) module, which wraps this module with `for_each`.

## Key Features

- **GitHub API export compatible**: Drop in a ruleset exported from `gh api` or the GitHub web UI without any manual reformatting
- **All bypass actor types**: Supports `Integration`, `OrganizationAdmin`, `Team`, `RepositoryRole`, and `DeployKey`
- **Flexible conditions**: Target branches/tags by ref name pattern (`~DEFAULT_BRANCH`, `~ALL`, custom patterns) and repositories by name pattern or protected status
- **Full rules coverage**: All boolean rules, `pull_request` (including `required_reviewers`), `required_status_checks`, all five pattern rules, `copilot_code_review`, and all four push-only rules
- **All dynamic blocks**: Every optional block is conditional, so unused rules add zero noise to the Terraform plan

## Supported rule types

| Rule type | Target | Parameters |
| --------- | ------ | ---------- |
| `creation` | branch, tag | — |
| `deletion` | branch, tag | — |
| `update` | branch, tag | — |
| `non_fast_forward` | branch, tag | — |
| `required_linear_history` | branch, tag | — |
| `required_signatures` | branch, tag | — |
| `pull_request` | branch | `required_approving_review_count`, `dismiss_stale_reviews_on_push`, `require_code_owner_review`, `require_last_push_approval`, `required_review_thread_resolution`, `allowed_merge_methods`, `required_reviewers[]` |
| `required_status_checks` | branch | `required_status_checks[]`, `strict_required_status_checks_policy`, `do_not_enforce_on_create` |
| `commit_message_pattern` | branch, tag | `operator`, `pattern`, `name`, `negate` |
| `commit_author_email_pattern` | branch, tag | `operator`, `pattern`, `name`, `negate` |
| `committer_email_pattern` | branch, tag | `operator`, `pattern`, `name`, `negate` |
| `branch_name_pattern` | branch | `operator`, `pattern`, `name`, `negate` |
| `tag_name_pattern` | tag | `operator`, `pattern`, `name`, `negate` |
| `copilot_code_review` | branch | `review_on_push`, `review_draft_pull_requests` |
| `file_path_restriction` | push | `restricted_file_paths[]` |
| `file_extension_restriction` | push | `restricted_file_extensions[]` |
| `max_file_size` | push | `max_file_size` (MB, 1–100) |
| `max_file_path_length` | push | `max_file_path_length` (1–32767) |

## Known limitations

### `ref_name` with empty include

The GitHub API can export rulesets where `ref_name.include` is `[]` (displayed in the UI as *"Branch targeting has not been configured"*). The Terraform provider **requires** at least one entry in `ref_name.include` and panics with empty arrays — this state is irrepresentable through the provider.

When the module receives `ref_name.include = []`, it automatically substitutes a safe fallback based on the target type:

| `target` | Default `ref_name.include` |
| -------- | ------------------------- |
| `branch` | `["~DEFAULT_BRANCH"]` |
| `tag`    | `["~ALL"]` |

If you need a different value, set `ref_name.include` explicitly in your JSON before applying.

### Push target rulesets with no push-specific rules (provider bug)

`target = "push"` rulesets that do not include at least one of the push-only rule types (`file_path_restriction`, `max_file_path_length`, `file_extension_restriction`, `max_file_size`) trigger a **panic in terraform-provider-github v6.11.1**:

```
panic: interface conversion: interface {} is nil, not map[string]interface {}
github.com/integrations/terraform-provider-github/v6/github.validateRules(...)
    util_ruleset_validation.go:94
```

This is a provider-level nil pointer dereference in `validateRulesForPushTarget`. The module guards against this at the input validation layer — attempting to apply a `push` ruleset with no push-specific rules will produce a clear Terraform validation error rather than a provider panic.

## Rules format

Rules follow the GitHub API array format — a list of objects with a `type` field and an optional `parameters` field:

```json
"rules": [
  { "type": "deletion" },
  { "type": "non_fast_forward" },
  {
    "type": "pull_request",
    "parameters": {
      "required_approving_review_count": 1,
      "dismiss_stale_reviews_on_push": true,
      "required_reviewers": [
        {
          "minimum_approvals": 1,
          "file_patterns": ["src/payments/**"],
          "reviewer": { "id": 12345, "type": "Team" }
        }
      ]
    }
  },
  {
    "type": "copilot_code_review",
    "parameters": {
      "review_on_push": true,
      "review_draft_pull_requests": false
    }
  }
]
```

Boolean rules (`creation`, `deletion`, `update`, `non_fast_forward`, `required_linear_history`, `required_signatures`) require no `parameters` block. All other rules **must** include a `parameters` block — the module validates this and will produce a clear error if `parameters` is omitted for a non-boolean rule type.

The module also validates that:
- Rule types are restricted to the supported set listed above — unknown types produce a clear error instead of being silently ignored.
- Rule types are compatible with the ruleset `target` — e.g., `tag_name_pattern` is rejected on a `branch` target, and push-only rules are rejected on `branch` or `tag` targets.
- Each rule type appears at most once per ruleset.
- Every entry in `required_reviewers` must include a `reviewer` block — omitting it produces a clear error instead of silently dropping the entry.

## Basic Usage

### Inline HCL

```hcl
module "org_ruleset" {
  source = "git::https://github.com/prefapp/tfm.git//modules/github-org-ruleset"

  config = {
    name        = "default-branch-protection"
    target      = "branch"
    enforcement = "active"

    conditions = {
      ref_name = {
        include = ["~DEFAULT_BRANCH"]
        exclude = []
      }
    }

    rules = [
      { type = "deletion" },
      { type = "non_fast_forward" },
      {
        type = "pull_request"
        parameters = {
          required_approving_review_count   = 1
          dismiss_stale_reviews_on_push     = true
          require_last_push_approval        = true
          required_review_thread_resolution = true
        }
      }
    ]
  }
}
```

### Using `config.json` (recommended for GitOps)

```hcl
locals {
  config = jsondecode(file("${path.module}/config.json")).config
}

module "org_ruleset" {
  source = "git::https://github.com/prefapp/tfm.git//modules/github-org-ruleset"

  config = local.config
}
```

`config.json`:

```json
{
  "config": {
    "name": "default-branch-protection",
    "target": "branch",
    "enforcement": "active",
    "conditions": {
      "ref_name": { "include": ["~DEFAULT_BRANCH"], "exclude": [] }
    },
    "rules": [
      { "type": "deletion" },
      { "type": "non_fast_forward" }
    ]
  }
}
```
