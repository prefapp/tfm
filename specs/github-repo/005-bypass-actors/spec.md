# Specification: Add bypass actors support to branch protections in github-repo module

**Issue:** [github-repo Add support for bypass actors in branch protections](https://github.com/prefapp/tfm/issues/1280)
**Parent Issue:** [gitops-k8s Add fs-admin github app to branch protection bypassers](https://github.com/prefapp/gitops-k8s/issues/2207)
**Module:** `modules/github-repo`

## Problem

The `github-repo` module's branch protections do not allow specifying bypass actors (users, teams, or GitHub Apps) that can bypass pull request requirements or push restrictions independently. The Firestartr provisioner needs the `fs-admin` GitHub App to bypass PR requirements while other tools (e.g. Dependabot) may need only push bypass.

> **Note on scope:** Issue #1280's motivation included automatically adding the current user as a bypass actor. This spec limits scope to explicit configuration fields only. Consumers must provide the desired actors explicitly in `bypassPullRequestAllowances` or `pushAllowances`.

## Goal

Add two independent fields inside each `branch_protections` entry:

- `bypassPullRequestAllowances` — actors that bypass pull request requirements
- `pushAllowances` — actors that bypass push restrictions

## Input Shape

```yaml
branchProtections:
  - branch: main
    requiredReviewersCount: 1
    bypassPullRequestAllowances:
      apps:   ["fs-admin"]
      teams:  ["my-team-slug"]
      users:  ["some-user"]
    pushAllowances:
      apps:   ["dependabot"]
      teams:  []
      users:  []
```

## Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `bypassPullRequestAllowances.apps` | `list(string)` | `[]` | GitHub App slugs, resolved via `data.github_app` |
| `bypassPullRequestAllowances.teams` | `list(string)` | `[]` | Team slugs, resolved via `data.github_team` |
| `bypassPullRequestAllowances.users` | `list(string)` | `[]` | User logins, resolved via `data.github_user` |
| `pushAllowances.apps` | `list(string)` | `[]` | GitHub App slugs, resolved via `data.github_app` |
| `pushAllowances.teams` | `list(string)` | `[]` | Team slugs, resolved via `data.github_team` |
| `pushAllowances.users` | `list(string)` | `[]` | User logins, resolved via `data.github_user` |

## Scope

- Add `bypassPullRequestAllowances` and `pushAllowances` to the `branch_protections` object in `variables.tf`
- Create locals, data sources, and per-field wiring in `main.tf`
- Add input validations for non-empty entries on both fields
- `bypassPullRequestAllowances` drives `required_pull_request_reviews.pull_request_bypassers`
- `pushAllowances` drives `restrict_pushes.push_allowances`
- Update `docs/header.md` with example showing both fields
- Add `_examples/bypass-actors/main.tf`
- Regenerate `README.md`

## Out of Scope

- Support for passing GitHub App node IDs directly (apps are specified by slug and resolved via `data.github_app`)
- Rulesets support (separate module)
- Automatic resolution of the current calling user as a bypass actor (actors must be provided explicitly)

## Acceptance Criteria

- Both `bypassPullRequestAllowances` and `pushAllowances` are optional (default to `null` — not set) per branch protection
- Apps are specified by slug and resolved via `data.github_app`; teams and users via `data.github_team`/`data.github_user`
- `pull_request_bypassers` is set from `bypassPullRequestAllowances` when provided
- `restrict_pushes.push_allowances` is set from `pushAllowances` when provided
- Neither field is set when its corresponding config is `null`
- `required_approving_review_count` defaults to at least 1 when `bypassPullRequestAllowances` is set but `requiredReviewersCount` is 0
- Input validations reject empty/whitespace-only entries
- Module passes `terraform validate` and `terraform fmt`
- Documentation is updated and README regenerated
- `_examples/bypass-actors/` is created with a working example
