# Plan: Add bypass actors support to branch protections in github-repo module

**Spec:** spec.md
**Module:** `modules/github-repo`

## Implementation Steps

### 1. Create spec/plan/tasks files
Create this spec directory with `spec.md`, `plan.md`, and `tasks.md`.

### 2. Update `variables.tf`
Add `bypassPullRequestAllowances` and `pushAllowances` optional objects to each `branch_protections` entry:

```hcl
bypassPullRequestAllowances = optional(object({
  apps  = optional(list(string), [])
  teams = optional(list(string), [])
  users = optional(list(string), [])
}), null)

pushAllowances = optional(object({
  apps  = optional(list(string), [])
  teams = optional(list(string), [])
  users = optional(list(string), [])
}), null)
```

Add validations for non-empty entries with no leading/trailing whitespace for both fields.

### 3. Update `main.tf`
Add locals to flatten users/teams/apps from **both** fields across all branch protections:

```hcl
locals {
  _bypasser_users = toset(flatten([
    for bp in coalesce(var.config.branch_protections, []) : concat(
      try(coalesce(bp.bypassPullRequestAllowances.users, []), []),
      try(coalesce(bp.pushAllowances.users, []), []),
    )
  ]))
  # same for _bypasser_teams, _bypasser_apps
}
```

Add `data.github_user.bypasser`, `data.github_team.bypasser`, and `data.github_app.bypasser` for_each lookups.

Wire `pull_request_bypassers` from `bypassPullRequestAllowances` only:

```hcl
pull_request_bypassers = each.value.bypassPullRequestAllowances != null ? distinct(concat(
  [for slug in coalesce(each.value.bypassPullRequestAllowances.apps, []) : data.github_app.bypasser[slug].node_id],
  [for slug in coalesce(each.value.bypassPullRequestAllowances.teams, []) : data.github_team.bypasser[slug].node_id],
  [for login in coalesce(each.value.bypassPullRequestAllowances.users, []) : data.github_user.bypasser[login].node_id],
)) : null
```

Wire `restrict_pushes.push_allowances` from `pushAllowances` only:

```hcl
dynamic "restrict_pushes" {
  for_each = each.value.pushAllowances != null ? [1] : []
  content {
    push_allowances = distinct(concat(
      [for slug in coalesce(each.value.pushAllowances.apps, []) : data.github_app.bypasser[slug].node_id],
      [for slug in coalesce(each.value.pushAllowances.teams, []) : data.github_team.bypasser[slug].node_id],
      [for login in coalesce(each.value.pushAllowances.users, []) : data.github_user.bypasser[login].node_id],
    ))
  }
}
```

Fix `required_approving_review_count` to default to 1 when bypass allowances are set but `requiredReviewersCount` is 0 (GitHub minimum):

```hcl
required_approving_review_count = each.value.bypassPullRequestAllowances != null ? max(each.value.requiredReviewersCount, 1) : each.value.requiredReviewersCount
```

### 4. Update `docs/header.md`
Update the "With branch protections + bypass actors" example to show both fields independently.

### 5. Create `_examples/bypass-actors/main.tf`
Create a standalone example with both fields.

### 6. Update `docs/footer.md`
Add Resources section with provider links and link to `_examples`.

### 7. Regenerate `README.md`
Run `terraform-docs .` from the module directory.

### 8. Validate
Run `terraform fmt` on the module.
