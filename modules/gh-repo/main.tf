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

# Commit files
resource "github_repository_file" "this" {
  for_each = {
    for entry in var.config.files :
    "${entry.file}__${entry.branch}" => entry
  }

  repository          = github_repository.this.name
  branch              = each.value.branch
  file                = each.value.file
  content             = each.value.content
  commit_message      = each.value.commitMessage
  overwrite_on_create = each.value.overwriteOnCreate
  auto_init           = true
}

# GitHub Repository Variables
resource "github_actions_variable" "this" {
  for_each = { for v in var.config.variables : v.variableName => v }

  repository    = github_repository.this.name
  variable_name = each.value.variableName
  value         = each.value.value
}

# OIDC Subject Claim Customization Template
resource "github_actions_repository_oidc_subject_claim_customization_template" "this" {
  count = var.config.oidc_subject_claim_customization_template != null ? 1 : 0

  repository  = github_repository.this.name
  use_default = try(var.config.oidc_subject_claim_customization_template.useDefault, true)

  include_claim_keys = (
    try(var.config.oidc_subject_claim_customization_template.useDefault, true) == false &&
    length(coalesce(try(var.config.oidc_subject_claim_customization_template.includeClaimKeys, []), [])) > 0
  ) ? try(var.config.oidc_subject_claim_customization_template.includeClaimKeys, null) : null
}

# Add teams to repository using teamId
resource "github_team_repository" "this" {
    for_each = { for t in var.config.teams : "${t.permission}-${t.teamId}" => t }

    repository    = github_repository.this.name
        team_id    = each.value.teamId      
        permission = each.value.permission
}

# Add outside collaborators
resource "github_repository_collaborator" "this" {
    for_each = { for c in var.config.collaborators : "${c.permission}-${c.username}" => c }

    repository    = github_repository.this.name
        username   = each.value.username
        permission = each.value.permission
}
