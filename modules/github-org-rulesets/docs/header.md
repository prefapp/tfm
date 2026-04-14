# **GitHub Organization Ruleset Terraform Module**

## Overview

This module creates and manages **GitHub Organization Rulesets** using the `github_organization_ruleset` resource. It accepts a map of ruleset definitions, creating one ruleset resource per entry via `for_each`.

Organization Rulesets are a modern GitHub feature that supersedes branch protection rules, offering finer-grained control over branch and tag governance across all repositories in an organization. They support targeting by ref name patterns or repository name patterns, defining bypass actors, and enforcing a comprehensive set of rules including pull request requirements, status checks, commit message patterns, and more.

This module is designed to be driven by JSON configuration. It natively accepts the **GitHub API export format**, so you can use a ruleset exported directly from the GitHub API or the GitHub CLI as input — extra fields such as `id`, `source_type`, `source`, and `required_reviewers` are silently ignored.

## Key Features

- **GitHub API export compatible**: Drop in a ruleset exported from `gh api` or the GitHub web UI without any manual reformatting
- **Multi-ruleset composition**: Manage multiple rulesets from a single module call using a `rulesets` map
- **All bypass actor types**: Supports `Integration`, `OrganizationAdmin`, `Team`, `RepositoryRole`, and `DeployKey`
- **Flexible conditions**: Target branches/tags by ref name pattern (`~DEFAULT_BRANCH`, `~ALL`, custom patterns) and repositories by name pattern or protected status
- **Full rules coverage**: All boolean rules (`creation`, `deletion`, `update`, `non_fast_forward`, `required_linear_history`, `required_signatures`) plus all block rules (`pull_request`, `required_status_checks`, and all pattern rules)
- **All dynamic blocks**: Every optional block is conditional, so unused rules add zero noise to the Terraform plan

## Known limitations

### `ref_name` with empty include

The GitHub API can export rulesets where `ref_name.include` is `[]` (displayed in the UI as _"Branch targeting has not been configured"_). The Terraform provider **requires** at least one entry in `ref_name.include` and panics with empty arrays — this state is irrepresentable through the provider.

When the module receives `ref_name.include = []`, it automatically substitutes a safe fallback based on the target type:

| `target` | Default `ref_name.include` |
|----------|---------------------------|
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

This is a provider-level nil pointer dereference in `validateRulesForPushTarget` — the SDK passes `[nil]` for unset optional blocks and the provider does not guard against it. There is no module-level workaround.

**Options until the provider is fixed:**
- Pin to a provider version that does not have this bug (check the [provider changelog](https://github.com/integrations/terraform-provider-github/releases))
- Add at least one push-specific rule to any push target ruleset
- Track the upstream issue: [integrations/terraform-provider-github](https://github.com/integrations/terraform-provider-github/issues)

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
      "dismiss_stale_reviews_on_push": true
    }
  }
]
```

Boolean rules (`creation`, `deletion`, `update`, `non_fast_forward`, `required_linear_history`, `required_signatures`) require no `parameters` block. Complex rules (`pull_request`, `required_status_checks`, pattern rules) carry their configuration inside `parameters`.

## Basic Usage

### Org-wide default branch protection

```hcl
module "org_rulesets" {
  source = "git::https://github.com/prefapp/tfm.git//modules/github-org-rulesets"

  rulesets = {
    default-branch-protection = {
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

### Using `terraform.tfvars.json` (recommended for GitOps)

```hcl
module "org_rulesets" {
  source = "git::https://github.com/prefapp/tfm.git//modules/github-org-rulesets"

  rulesets = var.rulesets
}
```
