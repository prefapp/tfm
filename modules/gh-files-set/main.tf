# ─────────────────────────────────────────────────────────────
# 1. Normal files — Terraform fully manages them (enforces content)
# ─────────────────────────────────────────────────────────────
resource "github_repository_file" "managed" {
  for_each = {
    for f in var.config.files : "${f.repository}/${f.file}/${f.branch}" => f
    if !f.userManaged
  }

  repository          = each.value.repository
  branch              = each.value.branch
  file                = each.value.file
  content             = each.value.content
  commit_message      = each.value.commitMessage
  overwrite_on_create = each.value.overwriteOnCreate
}

# ─────────────────────────────────────────────────────────────
# 2. User-managed files — provision once + ignore content changes
# ─────────────────────────────────────────────────────────────
resource "github_repository_file" "user_managed" {
  for_each = {
    for f in var.config.files : "${f.repository}/${f.file}/${f.branch}" => f
    if f.userManaged
  }

  repository          = each.value.repository
  branch              = each.value.branch
  file                = each.value.file
  content             = each.value.content
  commit_message      = each.value.commitMessage
  overwrite_on_create = each.value.overwriteOnCreate

  lifecycle {
    ignore_changes = [content]   # static — required by Terraform/OpenTofu
  }
}

# ─────────────────────────────────────────────────────────────
# 3. Untrack user-managed files so they survive `terraform destroy`
# ─────────────────────────────────────────────────────────────
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
      terraform state rm "github_repository_file.${replace(replace(each.value.file, "/", "_"), ".", "_")}" || true
    EOT
  }
}
