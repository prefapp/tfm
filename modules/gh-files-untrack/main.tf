resource "null_resource" "untrack" {
  for_each = {
    for f in var.config.files :
    "${f.repository}/${f.file}/${f.branch}" => f
  }

  triggers = {
    full_address = "github_repository_file.user_managed[\"${each.value.repository}/${each.value.file}/${each.value.branch}\"]"
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      echo "🔓 Untracking user-managed file: ${each.value.repository}/${each.value.file}"
      terraform state rm '${self.triggers.full_address}' || true
    EOT
  }
}
