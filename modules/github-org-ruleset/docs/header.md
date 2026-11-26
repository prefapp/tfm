# **GitHub Organization Ruleset Terraform Module**

## Overview

This module creates and manages a single **GitHub Organization Ruleset** using the `github_organization_ruleset` resource.

Organization Rulesets are a modern GitHub feature that supersedes branch protection rules, offering finer-grained control over branch and tag governance across all repositories in an organization. They support targeting by ref name patterns, repository name patterns, or repository custom properties; defining bypass actors; and enforcing a comprehensive set of rules including pull request requirements, status checks, commit message patterns, and more.

This module is designed to be driven by JSON configuration. It natively accepts the **GitHub API export format**, so you can use a ruleset exported directly from the GitHub API or the GitHub CLI as input — export-only fields such as `id`, `source_type`, and `source` are silently ignored.

Requires `integrations/github` **v6.12 or later**. `repository_property` targeting is not supported by earlier 6.x releases.

To manage **multiple rulesets** from a single module call, use the companion [`github-org-rulesets`](../github-org-rulesets) module, which wraps this module with `for_each`.

## Key Features

- **GitHub API export compatible**: Drop in a ruleset exported from `gh api` or the GitHub web UI without any manual reformatting
- **All bypass actor types**: Supports `Integration`, `OrganizationAdmin`, `Team`, `RepositoryRole`, and `DeployKey`
- **Bypass actors by slug or role**: Reference teams and GitHub Apps by slug, and repository roles as `maintain`, `write` or `admin`; the module resolves them to numeric IDs inside Terraform
- **Flexible conditions**: Target branches/tags by ref name pattern (`~DEFAULT_BRANCH`, `~ALL`, custom patterns) and repositories by name pattern or custom/system property
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

## Conditions

A ruleset must target repositories by **exactly one** of `repository_name` or
`repository_property`. The module rejects a configuration that sets both, sets
neither, or omits `conditions` entirely. The provider already rejects both or
neither when `conditions` is present; requiring `conditions` is this module's
stricter rule, so every ruleset states what it targets. Branch and tag rulesets
also target refs with `ref_name`; push rulesets operate on file content and must
not set it.

### Target by repository name

```json
"conditions": {
  "ref_name": { "include": ["~DEFAULT_BRANCH"], "exclude": [] },
  "repository_name": { "include": ["~ALL"], "exclude": ["legacy-*"] }
}
```

`repository_name.include` accepts `~ALL` and name patterns. Set
`repository_name.protected = true` to prevent renaming the matched repositories; it
does not filter for already-protected repositories.

### Target by repository property

`repository_property` selects repositories by a custom or system property instead of
by name pattern, so the ruleset follows the property as repositories are added or
retired:

```json
"conditions": {
  "ref_name": { "include": ["~DEFAULT_BRANCH"], "exclude": [] },
  "repository_property": {
    "include": [
      { "name": "environment", "property_values": ["production"], "source": "custom" }
    ],
    "exclude": []
  }
}
```

`include` requires every listed property to match. `exclude` stops the ruleset from
applying when any listed property matches. `source` is `custom` (the default) or
`system`, and `property_values` is required for each entry.

## Bypass actors

A bypass actor is a principal allowed past the rules. Each entry sets exactly one of:

- `actor_id` — numeric GitHub ID, forwarded verbatim (the export format).
- `actor_slug` — team or GitHub App slug, resolved to the numeric ID with the
  `github_team` / `github_app` data sources during plan.
- `actor_role` — `maintain`, `write` or `admin`, resolved to GitHub's fixed
  `RepositoryRole` IDs (`2`, `4`, `5`). Only valid for
  `actor_type = "RepositoryRole"`.

`actor_slug` is only valid for `actor_type = "Team"` or `"Integration"`.
`OrganizationAdmin` and `DeployKey` take no ID. Team, Integration and RepositoryRole
actors require one of the three references; the module rejects an entry that provides
two or none.

```json
"bypass_actors": [
  { "actor_type": "Team", "actor_slug": "platform-team", "bypass_mode": "always" },
  { "actor_type": "Integration", "actor_slug": "release-bot", "bypass_mode": "pull_request" },
  { "actor_type": "RepositoryRole", "actor_role": "admin", "bypass_mode": "always" },
  { "actor_type": "OrganizationAdmin", "bypass_mode": "pull_request" }
]
```

Slug lookups read the GitHub API during `terraform plan`, so the configured provider
must be able to see the referenced team or app. The resolved numeric ID appears in the
plan.

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
- Pattern rule types (`commit_message_pattern`, `commit_author_email_pattern`, `committer_email_pattern`, `branch_name_pattern`, `tag_name_pattern`) require `operator` (one of: `starts_with`, `ends_with`, `contains`, `regex`) and `pattern` to be non-null in `parameters`.
- Repositories are targeted by exactly one of `repository_name` or `repository_property`, and each `repository_property` entry uses `source` `custom` or `system`.
- Each bypass actor sets at most one of `actor_id`, `actor_slug` or `actor_role`, uses `actor_slug` only for teams and integrations, and uses `actor_role` only for `RepositoryRole`.

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
      repository_name = {
        include = ["~ALL"]
        exclude = ["legacy-*"]
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
      "ref_name": { "include": ["~DEFAULT_BRANCH"], "exclude": [] },
      "repository_name": { "include": ["~ALL"], "exclude": ["legacy-*"] }
    },
    "rules": [
      { "type": "deletion" },
      { "type": "non_fast_forward" }
    ]
  }
}
```

## Import and delete behavior

The module manages one resource, `github_organization_ruleset.this`. Find the ID of an existing ruleset with the GitHub CLI or API:

```console
gh api "orgs/<org>/rulesets" --jq '.[] | {id, name}'
```

Then import it by its numeric GitHub ruleset ID:

```console
terraform import github_organization_ruleset.this 12345
```

Import is optional for new rulesets but required to adopt one that already exists;
without it, Terraform creates a second ruleset with the same name and both apply.
The imported `config` must match the existing ruleset, or the next plan will change
it.

Deleting the module deletes the ruleset in GitHub. Every repository it covered loses
that protection immediately, so the blast radius is wider than removing one
repository's branch protection. During migration, create the ruleset first, confirm
it targets the intended repositories, and remove the old protection only afterwards.
