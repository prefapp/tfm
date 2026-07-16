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
| `bypassPullRequestAllowances.apps` | `list(string)` | `[]` | GitHub App slugs, resolved via `data.github_app` |
| `bypassPullRequestAllowances.teams` | `list(string)` | `[]` | Team slugs, resolved via `data.github_team` |
| `bypassPullRequestAllowances.users` | `list(string)` | `[]` | User logins, resolved via `data.github_user` |

## Scope

- Add `bypassPullRequestAllowances` to the `branch_protections` object in `variables.tf`
- Create locals, data sources, and `pull_request_bypassers` wiring in `main.tf`
- Add input validations for non-empty entries
- Update `docs/header.md` with example
- Regenerate `README.md`

## Out of Scope

- Support for passing GitHub App node IDs directly (apps are specified by slug and resolved via `data.github_app`)
- Rulesets support (separate module)
- Changing the `github_branch_protection` resource to use `push_restrictions` or other bypass modes

## Acceptance Criteria

- `bypassPullRequestAllowances` is optional (defaults to `null` — not set) per branch protection
- Apps are specified by slug and resolved via `data.github_app`; teams and users are resolved via `data.github_team`/`data.github_user`
- `pull_request_bypassers` is only set when `bypassPullRequestAllowances` is provided (avoids clearing existing actors)
- Input validations reject empty/whitespace-only entries
- Module passes `terraform validate` and `terraform fmt`
- Documentation is updated and README regenerated
- `tasks.md` is complete and included in the PR
