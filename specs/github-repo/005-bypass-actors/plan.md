# Plan: Add bypass actors support to branch protections in github-repo module

**Spec:** spec.md
**Module:** `modules/github-repo`

## Implementation Steps

### 1. Create spec/plan/tasks files
Create this spec directory with `spec.md`, `plan.md`, and `tasks.md`.

### 2. Update `variables.tf`
Add `bypassPullRequestAllowances` optional object to the `branch_protections` entry:

```hcl
bypassPullRequestAllowances = optional(object({
  apps  = optional(list(string), [])
  teams = optional(list(string), [])
  users = optional(list(string), [])
}), null)
```

Add validations for non-empty entries with no leading/trailing whitespace.

### 3. Update `main.tf`
Add locals to flatten bypass users/teams/apps across all branch protections:

    locals {
      _bypasser_users = toset(flatten([
        for bp in coalesce(var.config.branch_protections, []) :
        try(coalesce(bp.bypassPullRequestAllowances.users, []), [])
      ]))
      _bypasser_teams = toset(flatten([
        for bp in coalesce(var.config.branch_protections, []) :
        try(coalesce(bp.bypassPullRequestAllowances.teams, []), [])
      ]))
      _bypasser_apps = toset(flatten([
        for bp in coalesce(var.config.branch_protections, []) :
        try(coalesce(bp.bypassPullRequestAllowances.apps, []), [])
      ]))
    }

Add `data.github_user.bypasser`, `data.github_team.bypasser`, and `data.github_app.bypasser` for_each lookups.

Wire `pull_request_bypassers` on `github_branch_protection`:

```hcl
pull_request_bypassers = each.value.bypassPullRequestAllowances != null ? distinct(concat(
  [for slug in coalesce(each.value.bypassPullRequestAllowances.apps, []) : data.github_app.bypasser[slug].node_id],
  [for slug in coalesce(each.value.bypassPullRequestAllowances.teams, []) : data.github_team.bypasser[slug].node_id],
  [for login in coalesce(each.value.bypassPullRequestAllowances.users, []) : data.github_user.bypasser[login].node_id],
)) : null
```

### 4. Update `docs/header.md`
Add a "With branch protections + bypass actors" usage example.

### 5. Regenerate `README.md`
Run `terraform-docs .` from the module directory.

### 6. Validate
Run `terraform fmt` and `terraform validate` on the module.
