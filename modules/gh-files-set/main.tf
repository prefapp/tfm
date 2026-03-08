# 1. Create all files
resource "github_repository_file" "this" {
  for_each = { for f in var.config.files : "${f.repository}/${f.file}" => f }

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

# 2. Automatically untrack user-managed files on destroy
resource "null_resource" "untrack" {
  for_each = { for f in var.config.files : "${f.repository}/${f.file}" => f if f.userManaged }

  triggers = {
    address = "github_repository_file.${replace(replace(each.value.file, "/", "_"), ".", "_")}"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "terraform state rm ${self.triggers.address} || true"
  }
}
