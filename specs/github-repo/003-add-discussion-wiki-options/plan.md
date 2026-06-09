# Plan: Add `hasDiscussions` and `hasWiki` options to github-repo module

**Spec:** spec.md
**Module:** `modules/github-repo`

## Implementation Steps

### 1. Create spec/plan/tasks files
Create this spec directory with `spec.md`, `plan.md`, and `tasks.md`.

### 2. Update `variables.tf`
Add optional `hasDiscussions` and `hasWiki` fields to the `config.repository` object type, following the existing `hasIssues` pattern:

```hcl
repository = object({
  name                = string
  description         = optional(string, "")
  visibility          = optional(string, "private")
  topics              = optional(list(string), [])
  autoInit            = optional(bool, false)
  archiveOnDestroy    = optional(bool, false)
  allowMergeCommit    = optional(bool, true)
  allowSquashMerge    = optional(bool, true)
  allowRebaseMerge    = optional(bool, true)
  allowAutoMerge      = optional(bool, false)
  deleteBranchOnMerge = optional(bool, false)
  allowUpdateBranch   = optional(bool, false)
  hasIssues           = optional(bool, true)
  hasDiscussions      = optional(bool, false)
  hasWiki             = optional(bool, false)
})
```

### 3. Update `main.tf`
Add `has_discussions` and `has_wiki` attributes to the `github_repository` resource:

```hcl
resource "github_repository" "this" {
  name                   = var.config.repository.name
  description            = var.config.repository.description
  visibility             = var.config.repository.visibility
  auto_init              = var.config.repository.autoInit
  archive_on_destroy     = var.config.repository.archiveOnDestroy
  allow_merge_commit     = var.config.repository.allowMergeCommit
  allow_squash_merge     = var.config.repository.allowSquashMerge
  allow_rebase_merge     = var.config.repository.allowRebaseMerge
  allow_auto_merge       = var.config.repository.allowAutoMerge
  delete_branch_on_merge = var.config.repository.deleteBranchOnMerge
  allow_update_branch    = var.config.repository.allowUpdateBranch
  has_issues             = var.config.repository.hasIssues
  has_discussions        = var.config.repository.hasDiscussions
  has_wiki               = var.config.repository.hasWiki
}
```

### 4. Update `outputs.tf`
No new outputs needed — `repository_id`, `repository_name`, etc. already cover the repository resource. The new attributes are part of the existing resource.

### 5. Update `docs/header.md`
Add a brief mention that the module supports `hasDiscussions` and `hasWiki` configuration in the key features or usage section.

### 6. Update `docs/footer.md`
No changes needed unless there is a specific example to add for discussions/wiki.

### 7. Regenerate `README.md`
Run `terraform-docs .` from the module directory.

### 8. Validate
Run `terraform fmt` and `terraform validate` on the module.
