resource "null_resource" "untrack" {
  for_each = {
    for f in var.config.files :
    "${f.repository}/${f.file}/${coalesce(f.branch, "main")}" => f
  }

  # We store the exact Terraform resource address during creation
  # so it can be safely referenced during destroy
  triggers = {
    address = "github_repository_file.user_managed[\"${each.value.repository}/${each.value.file}/${coalesce(each.value.branch, "main")}\"]"
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      echo "🔓 Untracking user-managed file: ${each.value.repository}/${each.value.file}"
      terraform state rm '${self.triggers.address}' || true
    EOT
  }
}
