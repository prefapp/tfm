# Plan: Add `hasDiscussions` option to github-repo module

**Spec:** spec.md
**Module:** `modules/github-repo`

---

## Implementation Steps

### 1. Update `variables.tf`

Add optional `hasDiscussions` field to the `config.repository` object type,
following the existing `hasWiki` pattern:

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
  hasWiki             = optional(bool, true)
  hasDiscussions      = optional(bool, true)
})
```

### 2. Update `main.tf`

Add `has_discussions` attribute to the `github_repository` resource:

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
  has_wiki               = var.config.repository.hasWiki
  has_discussions        = var.config.repository.hasDiscussions
}
```

### 3. Update `outputs.tf`

No new outputs needed — `has_discussions` is part of the existing
`github_repository.this` resource. All existing outputs continue to cover it.

### 4. Update `docs/header.md`

Mention Discussions in the key features section. The existing line 12 reads:

```
- **Full GitHub repository settings**: Merge strategies, visibility, topics, auto-init, archive on destroy, wiki, etc.
```

Change `wiki, etc.` to `wiki, discussions, etc.`:

```
- **Full GitHub repository settings**: Merge strategies, visibility, topics, auto-init, archive on destroy, wiki, discussions, etc.
```

### 5. Regenerate `README.md`

```sh
cd modules/github-repo
terraform-docs .
```

Or if not installed locally:

```sh
cd modules/github-repo
go run github.com/terraform-docs/terraform-docs@latest .
```

### 6. Validate

```sh
cd modules/github-repo
terraform fmt
terraform validate
```
