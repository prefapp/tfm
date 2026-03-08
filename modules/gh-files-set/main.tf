# 1. Create / update all files
resource "github_repository_file" "files" {
  for_each = {
    for f in var.config.files : "${f.repository}/${f.file}/${f.branch}" => f
  }

  repository          = each.value.repository
  branch              = each.value.branch
  file                = each.value.file
  content             = each.value.content
  commit_message      = each.value.commitMessage
  overwrite_on_create = each.value.overwriteOnCreate

  lifecycle {
    ignore_changes = each.value.userManaged ? ["content"] : []
  }
}

# 2. Untrack user-managed files so they survive `terraform destroy`
resource "null_resource" "untrack_user_managed" {
  for_each = {
    for f in var.config.files : "${f.repository}/${f.file}" => f
    if f.userManaged
  }

  triggers = {
    repository = each.value.repository
    file       = each.value.file
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      echo "🔓 Untracking user-managed file: ${each.value.repository}/${each.value.file}"
      terraform state rm "github_repository_file.${replace(replace(each.value.file, "/", "_"), ".", "_")}_${replace(each.value.branch, "/", "_")}" || true
    EOT
  }
}
