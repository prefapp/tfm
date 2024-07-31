
resource "github_repository_file" "user_managed" {
  for_each = { for file in local.managed_features: file.repoPath => file }
  repository          = github_repository.this.name
  branch              = var.default_branch
  file                = each.value.repoPath
  content             = data.github_repository_file.user_managed_files[each.value.repoPath].id == null ? each.value.content : data.github_repository_file.user_managed_files[each.value.repoPath].content
  commit_message      = "Managed by Terraform"
  commit_author       = "@prefapp/firestartr"
  commit_email        = "firestartr@firestartr.dev" 
  overwrite_on_create = true

  lifecycle {
    ignore_changes = [ 
        content 
    ]
  }

  depends_on = [ github_branch_default.this ]
}

resource "github_repository_file" "auto_managed" { 
  for_each = { for file in local.auto_managed_features: file.repoPath => file }
  repository          = github_repository.this.name
  branch              = var.default_branch
  file                = each.value.repoPath
  content             = each.value.content
  commit_message      = "Managed by Terraform"
  commit_author       = "@prefapp/firestartr"
  commit_email        = "firestartr@firestartr.dev" 
  overwrite_on_create = true

  depends_on = [ github_branch_default.this ]
}

