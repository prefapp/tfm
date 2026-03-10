resource "null_resource" "untrack" {
  for_each = {
    for f in var.config.files :
    "${f.repository}/${f.file}/${coalesce(f.branch, "main")}" => f
  }

  # No triggers needed — we pass everything via environment
  provisioner "local-exec" {
    command = <<-EOT
      echo "🔓 Untracking user-managed file: ${each.value.repository}/${each.value.file}"

      # Use the exact address format used in gh-files-set
      terraform state rm 'github_repository_file.user_managed["${each.value.repository}/${each.value.file}/${coalesce(each.value.branch, "main")}"]' || true
    EOT
  }
}
