<!-- BEGIN_TF_DOCS -->
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
- **Flexible conditions**: Target branches/tags by ref name pattern (`~DEFAULT_BRANCH`, `~ALL`, custom patterns) and repositories by name pattern, protected status, or custom/system property
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
`repository_name.protected = true` to target only protected repositories.

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

## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_github"></a> [github](#requirement\_github) | ~> 6.12 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_github"></a> [github](#provider\_github) | ~> 6.12 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [github_organization_ruleset.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/organization_ruleset) | resource |
| [github_app.bypass_actor](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/app) | data source |
| [github_team.bypass_actor](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/team) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_config"></a> [config](#input\_config) | GitHub organization ruleset configuration. Accepts the GitHub API export format directly for top-level export fields (id, source\_type, source), which are ignored by the module. Within rules[*].parameters, only the explicitly modeled fields are accepted. Bypass actors may also be referenced by slug (actor\_slug) or repository role (actor\_role), which the module resolves to the numeric actor\_id inside Terraform. | <pre>object({<br/>    name        = string<br/>    target      = string # "branch" | "tag" | "push"<br/>    enforcement = string # "disabled" | "evaluate" | "active"<br/><br/>    # GitHub API export fields — present in exports, ignored by the module<br/>    id          = optional(number)<br/>    source_type = optional(string)<br/>    source      = optional(string)<br/><br/>    bypass_actors = optional(list(object({<br/>      actor_id    = optional(number) # actor_id, actor_slug and actor_role are mutually exclusive (validated below)<br/>      actor_slug  = optional(string) # Team or Integration slug, resolved to actor_id by the module<br/>      actor_role  = optional(string) # "maintain" | "write" | "admin"; RepositoryRole only<br/>      actor_type  = string           # "Integration" | "OrganizationAdmin" | "Team" | "RepositoryRole" | "DeployKey"<br/>      bypass_mode = string           # "always" | "pull_request"<br/>    })), [])<br/><br/>    conditions = optional(object({<br/>      ref_name = optional(object({<br/>        include = optional(list(string), [])<br/>        exclude = optional(list(string), [])<br/>      }))<br/>      repository_name = optional(object({<br/>        include   = optional(list(string), [])<br/>        exclude   = optional(list(string), [])<br/>        protected = optional(bool, false)<br/>      }))<br/>      repository_property = optional(object({<br/>        include = optional(list(object({<br/>          name            = string<br/>          property_values = list(string)<br/>          source          = optional(string, "custom") # "custom" | "system"<br/>        })), [])<br/>        exclude = optional(list(object({<br/>          name            = string<br/>          property_values = list(string)<br/>          source          = optional(string, "custom") # "custom" | "system"<br/>        })), [])<br/>      }))<br/>    }))<br/><br/>    # Rules in GitHub API array format: [{ "type": "...", "parameters": {...} }]<br/>    # Boolean rules (creation, deletion, update, non_fast_forward,<br/>    # required_linear_history, required_signatures) carry no parameters.<br/>    rules = optional(list(object({<br/>      type = string<br/>      parameters = optional(object({<br/>        # pull_request<br/>        required_approving_review_count   = optional(number)<br/>        dismiss_stale_reviews_on_push     = optional(bool)<br/>        require_code_owner_review         = optional(bool)<br/>        require_last_push_approval        = optional(bool)<br/>        required_review_thread_resolution = optional(bool)<br/>        allowed_merge_methods             = optional(list(string))<br/>        required_reviewers = optional(list(object({<br/>          minimum_approvals = optional(number, 0)<br/>          file_patterns     = optional(list(string), [])<br/>          reviewer = optional(object({<br/>            id   = number<br/>            type = string # "Team"<br/>          }))<br/>        })), [])<br/><br/>        # required_status_checks<br/>        required_status_checks               = optional(list(object({<br/>          context        = string<br/>          integration_id = optional(number)<br/>        })))<br/>        strict_required_status_checks_policy = optional(bool)<br/>        do_not_enforce_on_create             = optional(bool)<br/><br/>        # Pattern rules: commit_message_pattern, commit_author_email_pattern,<br/>        # committer_email_pattern, branch_name_pattern, tag_name_pattern<br/>        operator = optional(string) # "starts_with" | "ends_with" | "contains" | "regex"<br/>        pattern  = optional(string)<br/>        name     = optional(string)<br/>        negate   = optional(bool)<br/><br/>        # copilot_code_review<br/>        review_on_push             = optional(bool)<br/>        review_draft_pull_requests = optional(bool)<br/><br/>        # update rule — GitHub API field, not forwarded (provider uses a boolean)<br/>        update_allows_fetch_and_merge = optional(bool)<br/><br/>        # Push-only rules<br/>        restricted_file_paths      = optional(list(string))   # file_path_restriction<br/>        restricted_file_extensions = optional(list(string))   # file_extension_restriction<br/>        max_file_size              = optional(number)          # max_file_size (MB, 1-100)<br/>        max_file_path_length       = optional(number)          # max_file_path_length (1-32767)<br/>      }))<br/>    })), [])<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_etag"></a> [etag](#output\_etag) | The ruleset etag |
| <a name="output_node_id"></a> [node\_id](#output\_node\_id) | The ruleset GraphQL node\_id |
| <a name="output_ruleset_id"></a> [ruleset\_id](#output\_ruleset\_id) | The ruleset GraphQL ruleset\_id |

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/github-org-ruleset/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/github-org-ruleset/_examples/basic) - Org-wide default branch protection targeting repositories by name, with a CI status check and a numeric bypass actor (`config.json`)
- [advanced](https://github.com/prefapp/tfm/tree/main/modules/github-org-ruleset/_examples/advanced) - Full GitHub API export format targeting repositories by custom property, with required\_reviewers, copilot\_code\_review, and extra fields that are silently ignored (`config.json`)
- [bypass-actors](https://github.com/prefapp/tfm/tree/main/modules/github-org-ruleset/_examples/bypass-actors) - Bypass actors referenced by team slug, app slug, and repository role instead of numeric IDs (`config.json`)
- [push-ruleset](https://github.com/prefapp/tfm/tree/main/modules/github-org-ruleset/_examples/push-ruleset) - Push ruleset targeting repositories by custom property, with file extension and file size rules (`config.json`)

## Resources

- **github\_organization\_ruleset**: [Official Documentation](https://registry.terraform.io/providers/integrations/github/6.11.1/docs/resources/organization_ruleset)
- **GitHub Terraform Provider**: [Official Documentation](https://registry.terraform.io/providers/integrations/github/latest/docs)
- **GitHub Organization Rulesets**: [GitHub Docs](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->