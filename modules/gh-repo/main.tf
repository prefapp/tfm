# Create the GitHub Repository
resource "github_repository" "this" {
  name                 = var.config.repository.name
  description          = var.config.repository.description
  visibility           = var.config.repository.visibility
  topics               = var.config.repository.topics
  auto_init            = var.config.repository.autoInit
  archive_on_destroy   = var.config.repository.archiveOnDestroy
  allow_merge_commit   = var.config.repository.allowMergeCommit
  allow_squash_merge   = var.config.repository.allowSquashMerge
  allow_rebase_merge   = var.config.repository.allowRebaseMerge
  allow_auto_merge     = var.config.repository.allowAutoMerge
  delete_branch_on_merge = var.config.repository.deleteBranchOnMerge
  allow_update_branch  = var.config.repository.allowUpdateBranch
  has_issues           = var.config.repository.hasIssues
}

# Set the default branch
resource "github_branch_default" "this" {
  repository = github_repository.this.name
  branch     = var.config.default_branch.branch
  rename     = var.config.default_branch.rename
}

# Commit files (CODEOWNERS, workflows, README, etc.)
resource "github_repository_file" "this" {
  for_each = {
    for f in var.config.files : f.file => f
  }

  repository          = each.value.repository
  branch              = each.value.branch
  file                = each.value.file
  content             = each.value.content
  commit_message      = each.value.commitMessage
  overwrite_on_create = each.value.overwriteOnCreate
}

# GitHub Repository Variables (plain-text variables for GitHub Actions)
resource "github_actions_variable" "this" {
  for_each = {
    for v in var.config.variables : v.variableName => v
  }

  repository    = each.value.repository
  variable_name = each.value.variableName
  value         = each.value.value
}
