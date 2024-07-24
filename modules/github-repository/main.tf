resource "github_repository" "this" {
  name        = var.name
  visibility = var.visibility
  auto_init = true

  lifecycle {
    ignore_changes = [
      allow_auto_merge,
      description,
      allow_merge_commit,
      allow_rebase_merge,
      allow_squash_merge,
      allow_update_branch,
      archived,
      delete_branch_on_merge,
      has_discussions,
      has_downloads,
      has_issues,
      has_projects,
      has_wiki,
      id,
      is_template,
      merge_commit_message,
      merge_commit_title,
      squash_merge_commit_message,
      squash_merge_commit_title,
      topics,
      vulnerability_alerts,
      web_commit_signoff_required,
    ]
  }
}

resource "github_branch_default" "this" {
  repository = github_repository.this.name
  branch     = var.default_branch
  rename = true
  depends_on = [
    github_repository.this
  ]
}
