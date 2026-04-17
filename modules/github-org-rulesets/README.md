<!-- BEGIN_TF_DOCS -->
# **GitHub Organization Rulesets Terraform Module**

## Overview

This module creates and manages **multiple GitHub Organization Rulesets** by calling the [`github-org-ruleset`](../github-org-ruleset) module with `for_each`. It accepts a map of ruleset definitions, creating one ruleset per map entry.

Organization Rulesets are a modern GitHub feature that supersedes branch protection rules, offering finer-grained control over branch and tag governance across all repositories in an organization. They support targeting by ref name patterns or repository name patterns, defining bypass actors, and enforcing a comprehensive set of rules including pull request requirements, status checks, commit message patterns, and more.

This module is designed to be driven by JSON configuration. It natively accepts the **GitHub API export format**, so you can use a ruleset exported directly from the GitHub API or the GitHub CLI as input — export-only fields such as `id`, `source_type`, and `source` are silently ignored.

To manage a **single ruleset**, use the [`github-org-ruleset`](../github-org-ruleset) module directly.

## Key Features

- **GitHub API export compatible**: Drop in a ruleset exported from `gh api` or the GitHub web UI without any manual reformatting
- **Multi-ruleset composition**: Manage multiple rulesets from a single module call using a `config` map
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
- Pattern rule types (`commit_message_pattern`, `commit_author_email_pattern`, `committer_email_pattern`, `branch_name_pattern`, `tag_name_pattern`) require `operator` (one of: `starts_with`, `ends_with`, `contains`, `regex`) and `pattern` to be non-null in `parameters`.

## Basic Usage

### Org-wide default branch protection

```hcl
module "org_rulesets" {
  source = "git::https://github.com/prefapp/tfm.git//modules/github-org-rulesets"

  config = {
    "default-branch-protection" = {
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
}
```

### Using `config.json` (recommended for GitOps)

```hcl
locals {
  config = jsondecode(file("${path.module}/config.json")).config
}

module "org_rulesets" {
  source = "git::https://github.com/prefapp/tfm.git//modules/github-org-rulesets"

  config = local.config
}
```

`config.json`:

```json
{
  "config": {
    "default-branch-protection": {
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
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_github"></a> [github](#requirement\_github) | ~> 6.0 |

## Providers

This wrapper module does not expose any direct provider entries in terraform-docs, but it **does require** the [`integrations/github`](https://registry.terraform.io/providers/integrations/github/latest) provider because it calls the nested [`github-org-ruleset`](../github-org-ruleset) module. Consumers of this module must configure the GitHub provider, using version `~> 6.0` as shown in the [Requirements](#requirements) section above.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ruleset"></a> [ruleset](#module\_ruleset) | ../github-org-ruleset | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_config"></a> [config](#input\_config) | Map of GitHub organization rulesets. Accepts the GitHub API export format directly for modeled fields, including top-level export fields (id, source\_type, source), which are ignored by the module. Rule parameters must be limited to the supported attributes declared by this variable type; callers must strip any unknown or unmodeled parameter keys before passing input to the module. | <pre>map(object({<br/>    name        = string<br/>    target      = string # "branch" | "tag" | "push"<br/>    enforcement = string # "disabled" | "evaluate" | "active"<br/><br/>    # GitHub API export fields — present in exports, ignored by the module<br/>    id          = optional(number)<br/>    source_type = optional(string)<br/>    source      = optional(string)<br/><br/>    bypass_actors = optional(list(object({<br/>      actor_id    = optional(number)<br/>      actor_type  = string # "Integration" | "OrganizationAdmin" | "Team" | "RepositoryRole" | "DeployKey"<br/>      bypass_mode = string # "always" | "pull_request"<br/>    })), [])<br/><br/>    conditions = optional(object({<br/>      ref_name = optional(object({<br/>        include = optional(list(string), [])<br/>        exclude = optional(list(string), [])<br/>      }))<br/>      repository_name = optional(object({<br/>        include   = optional(list(string), [])<br/>        exclude   = optional(list(string), [])<br/>        protected = optional(bool, false)<br/>      }))<br/>    }))<br/><br/>    # Rules in GitHub API array format: [{ "type": "...", "parameters": {...} }]<br/>    # Boolean rules (creation, deletion, update, non_fast_forward,<br/>    # required_linear_history, required_signatures) carry no parameters.<br/>    rules = optional(list(object({<br/>      type = string<br/>      parameters = optional(object({<br/>        # pull_request<br/>        required_approving_review_count   = optional(number)<br/>        dismiss_stale_reviews_on_push     = optional(bool)<br/>        require_code_owner_review         = optional(bool)<br/>        require_last_push_approval        = optional(bool)<br/>        required_review_thread_resolution = optional(bool)<br/>        allowed_merge_methods             = optional(list(string))<br/>        required_reviewers = optional(list(object({<br/>          minimum_approvals = optional(number, 0)<br/>          file_patterns     = optional(list(string), [])<br/>          reviewer = optional(object({<br/>            id   = number<br/>            type = string # "Team"<br/>          }))<br/>        })), [])<br/><br/>        # required_status_checks<br/>        required_status_checks               = optional(list(object({<br/>          context        = string<br/>          integration_id = optional(number)<br/>        })))<br/>        strict_required_status_checks_policy = optional(bool)<br/>        do_not_enforce_on_create             = optional(bool)<br/><br/>        # Pattern rules: commit_message_pattern, commit_author_email_pattern,<br/>        # committer_email_pattern, branch_name_pattern, tag_name_pattern<br/>        operator = optional(string) # "starts_with" | "ends_with" | "contains" | "regex"<br/>        pattern  = optional(string)<br/>        name     = optional(string)<br/>        negate   = optional(bool)<br/><br/>        # copilot_code_review<br/>        review_on_push             = optional(bool)<br/>        review_draft_pull_requests = optional(bool)<br/><br/>        # update rule — GitHub API field, not forwarded (provider uses a boolean)<br/>        update_allows_fetch_and_merge = optional(bool)<br/><br/>        # Push-only rules<br/>        restricted_file_paths      = optional(list(string))   # file_path_restriction<br/>        restricted_file_extensions = optional(list(string))   # file_extension_restriction<br/>        max_file_size              = optional(number)          # max_file_size (MB, 1-100)<br/>        max_file_path_length       = optional(number)          # max_file_path_length (1-32767)<br/>      }))<br/>    })), [])<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_node_ids"></a> [node\_ids](#output\_node\_ids) | Map of ruleset logical key to ruleset GraphQL node\_id |
| <a name="output_ruleset_etags"></a> [ruleset\_etags](#output\_ruleset\_etags) | Map of ruleset logical key to ruleset etag |
| <a name="output_ruleset_ids"></a> [ruleset\_ids](#output\_ruleset\_ids) | Map of ruleset logical key to ruleset GraphQL ruleset\_id |

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/github-org-rulesets/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/github-org-rulesets/_examples/basic) - Org-wide default branch protection with CI status check and bypass actor (`config.json`)
- [advanced](https://github.com/prefapp/tfm/tree/main/modules/github-org-rulesets/_examples/advanced) - Multiple rulesets using full GitHub API export format, including required\_reviewers, copilot\_code\_review, and extra fields that are silently ignored (`config.json`)

## Resources

- **github\_organization\_ruleset**: [Official Documentation](https://registry.terraform.io/providers/integrations/github/6.11.1/docs/resources/organization_ruleset)
- **GitHub Terraform Provider**: [Official Documentation](https://registry.terraform.io/providers/integrations/github/latest/docs)
- **GitHub Organization Rulesets**: [GitHub Docs](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->