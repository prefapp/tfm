# Specification: Add bypass actors support to branch protections in github-repo module

**Issue:** [github-repo Add support for bypass actors in branch protections](https://github.com/prefapp/tfm/issues/1280)
**Parent Issue:** [gitops-k8s Add fs-admin github app to branch protection bypassers](https://github.com/prefapp/gitops-k8s/issues/2207)
**Module:** `modules/github-repo`

## Problem

The `github-repo` module's branch protections do not allow specifying bypass actors (users, teams, or GitHub Apps) that can bypass pull request requirements. The Firestartr provisioner needs the `fs-admin` GitHub App to be able to bypass branch protections on managed repositories.

## Goal

Add a `bypassPullRequestAllowances` field inside each `branch_protections` entry to allow specifying apps, teams, and users that can bypass pull request requirements.

## Input Shape

```yaml
branchProtections:
  - branch: main
    requiredReviewersCount: 1
    bypassPullRequestAllowances:
      apps:   ["<github_app_node_id>"]
      teams:  ["my-team-slug"]
      users:  ["some-user"]
```

## Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `bypassPullRequestAllowances.apps` | `list(string)` | `[]` | GitHub App node IDs (pre-resolved, no `data.github_app` source exists) |
| `bypassPullRequestAllowances.teams` | `list(string)` | `[]` | Team slugs, resolved via `data.github_team` |
| `bypassPullRequestAllowances.users` | `list(string)` | `[]` | User logins, resolved via `data.github_user` |

## Scope

- Add `bypassPullRequestAllowances` to the `branch_protections` object in `variables.tf`
- Create locals, data sources, and `pull_request_bypassers` wiring in `main.tf`
- Add input validations for non-empty entries
- Update `docs/header.md` with example
- Regenerate `README.md`

## Out of Scope

- Support for `data.github_app` (provider has no such data source; apps must pass pre-resolved node IDs)
- Rulesets support (separate module)
- Changing the `github_branch_protection` resource to use `push_restrictions` or other bypass modes

## Acceptance Criteria

- `bypassPullRequestAllowances` is optional (defaults to `null` — not set) per branch protection
- Apps pass node IDs directly; teams and users are resolved via data sources
- `pull_request_bypassers` is only set when `bypassPullRequestAllowances` is provided (avoids clearing existing actors)
- Input validations reject empty/whitespace-only entries
- Module passes `terraform validate` and `terraform fmt`
- Documentation is updated and README regenerated
- `tasks.md` is complete and included in the PR
