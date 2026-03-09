resource "null_resource" "untrack" {
  for_each = {
    for f in var.config.files :
    "${f.repository}/${f.file}/${coalesce(f.branch, "main")}" => f
  }

  # This runs ONLY on destroy
  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      echo "🔓 Untracking user-managed file: ${each.value.repository}/${each.value.file}"

      # Build the exact resource address that Terraform uses in gh-files-set
      terraform state rm 'github_repository_file.user_managed["${each.value.repository}/${each.value.file}/${coalesce(each.value.branch, "main")}"]' || true
    EOT
  }
}
