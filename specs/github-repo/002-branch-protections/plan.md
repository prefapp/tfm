# Plan: Add support for legacy branch protections in github-repo module

**Spec:** spec.md
**Module:** `modules/github-repo`

## Implementation Steps

### 1. Create spec/plan/tasks files
Create this spec directory with `spec.md`, `plan.md`, and `tasks.md`.

### 2. Update `variables.tf`
Add an optional `branchProtections` field to the `config` object type:

```hcl
branchProtections = optional(list(object({
  branch                       = string
  statusChecks                 = optional(list(string), [])
  requiredReviewersCount       = optional(number, 0)
  requiredCodeownersReviewers  = optional(bool, false)
  enforceAdmins                = optional(bool, false)
  requireSignedCommits         = optional(bool, false)
  requireConversationResolution = optional(bool, false)
})), [])
```

Add a validation to ensure branch patterns are unique.

### 3. Update `main.tf`
Add `github_branch_protection` resource using `for_each` on `branchProtections`:

```hcl
resource "github_branch_protection" "this" {
  for_each = { for bp in coalesce(var.config.branchProtections, []) : bp.branch => bp }

  repository_id                   = github_repository.this.node_id
  pattern                         = each.value.branch
  enforce_admins                  = each.value.enforceAdmins
  require_signed_commits          = each.value.requireSignedCommits
  require_conversation_resolution = each.value.requireConversationResolution

  dynamic "required_status_checks" {
    for_each = length(coalesce(each.value.statusChecks, [])) > 0 ? [each.value.statusChecks] : []
    content {
      contexts = required_status_checks.value
    }
  }

  required_pull_request_reviews {
    required_approving_review_count = each.value.requiredReviewersCount
    require_code_owner_reviews      = each.value.requiredCodeownersReviewers
  }
}
```

### 4. Update `outputs.tf`
Add a `branch_protections` output listing the managed branch patterns.

### 5. Update `docs/header.md`
Add a "With branch protections" usage example.

### 6. Update `docs/footer.md`
Add a branch protections example section.

### 7. Regenerate `README.md`
Run `terraform-docs .` from the module directory.

### 8. Validate
Run `terraform fmt` and `terraform validate` on the module.
