resource "null_resource" "untrack" {
  for_each = {
    for f in var.config.files : "${f.repository}/${f.file}" => f
  }

  triggers = {
    state_address = "github_repository_file.${replace(replace(each.value.file, "/", "_"), ".", "_")}"
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      echo "🔓 Untracking user-managed file: ${self.triggers.state_address}"
      terraform state rm "${self.triggers.state_address}" || true
    EOT
  }
}
