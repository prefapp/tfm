resource "null_resource" "untrack" {
  for_each = { for f in var.config.files : f.file => f }

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
