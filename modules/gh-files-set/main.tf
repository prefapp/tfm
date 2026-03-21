# ─────────────────────────────────────────────────────────────
# Fetch repository info (validates existence + gives canonical name)
# ─────────────────────────────────────────────────────────────
data "github_repository" "this" {
  full_name = var.config.repository
}

# Normal files — Terraform fully enforces content
resource "github_repository_file" "managed" {
  for_each = {
    for f in var.config.files : "${f.file}/${f.branch}" => f
    if !f.userManaged
  }

  repository          = data.github_repository.this.name
  branch              = each.value.branch
  file                = each.value.file
  content             = each.value.content
  commit_message      = each.value.commitMessage
  overwrite_on_create = each.value.overwriteOnCreate
}

# User-managed files — provisioned once via the GitHub API and never deleted by Terraform.
# On `terraform destroy` the state entry is removed but the file in GitHub is preserved.
# Requires GITHUB_TOKEN to be set in the environment (same requirement as the GitHub provider).
resource "terraform_data" "user_managed" {
  for_each = {
    for f in var.config.files : "${f.file}/${f.branch}" => f
    if f.userManaged
  }

  input = {
    repository     = var.config.repository
    file           = each.value.file
    branch         = each.value.branch
    commit_message = each.value.commitMessage
    content_b64    = base64encode(each.value.content)
    overwrite      = each.value.overwriteOnCreate
  }

  # Re-provision only when file path or branch changes; content drift is intentionally ignored
  triggers_replace = [each.value.file, each.value.branch]

  provisioner "local-exec" {
    environment = {
      REPO      = self.input.repository
      FILE      = self.input.file
      BRANCH    = self.input.branch
      MESSAGE   = self.input.commit_message
      CONTENT   = self.input.content_b64
      OVERWRITE = tostring(self.input.overwrite)
    }
    command = <<-EOT
      set -e
      # Validate that BRANCH and FILE contain no characters that would break the API URL
      if printf '%s' "$BRANCH$FILE" | grep -qE '[[:space:]#?]'; then
        printf 'Error: BRANCH or FILE contains invalid URL characters\n' >&2; exit 1
      fi
      # JSON-encode the commit message to safely handle quotes and special characters
      if command -v python3 >/dev/null 2>&1; then
        MSG_JSON=$(printf '%s' "$MESSAGE" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))")
      else
        MSG_JSON=$(printf '"%s"' "$(printf '%s' "$MESSAGE" | sed 's/\\/\\\\/g; s/"/\\"/g')")
      fi
      # Fetch current file SHA — non-zero curl exit is ok; the file may not exist yet
      RESPONSE=$(curl -s \
        -H "Authorization: Bearer $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github+json" \
        "https://api.github.com/repos/$REPO/contents/$FILE?ref=$BRANCH" || true)
      SHA=$(echo "$RESPONSE" | jq -r '.sha // empty' 2>/dev/null || \
            echo "$RESPONSE" | grep -oE '"sha":"[^"]+"' | head -1 | sed 's/"sha":"//;s/"//')
      if [ -n "$SHA" ] && [ "$OVERWRITE" = "true" ]; then
        RESULT=$(curl -s -X PUT \
          -H "Authorization: Bearer $GITHUB_TOKEN" \
          -H "Accept: application/vnd.github+json" \
          -H "Content-Type: application/json" \
          "https://api.github.com/repos/$REPO/contents/$FILE" \
          -d "{\"message\":$MSG_JSON,\"content\":\"$CONTENT\",\"branch\":\"$BRANCH\",\"sha\":\"$SHA\"}")
      elif [ -n "$SHA" ]; then
        echo "File $FILE on branch $BRANCH already exists; overwrite_on_create=false, skipping."
        exit 0
      else
        RESULT=$(curl -s -X PUT \
          -H "Authorization: Bearer $GITHUB_TOKEN" \
          -H "Accept: application/vnd.github+json" \
          -H "Content-Type: application/json" \
          "https://api.github.com/repos/$REPO/contents/$FILE" \
          -d "{\"message\":$MSG_JSON,\"content\":\"$CONTENT\",\"branch\":\"$BRANCH\"}")
      fi
      if ! echo "$RESULT" | grep -q '"commit"'; then
        printf 'GitHub API error for %s@%s: %s\n' "$FILE" "$BRANCH" "$RESULT" >&2
        exit 1
      fi
    EOT
  }

  # No when = destroy provisioner — the file in GitHub is preserved on terraform destroy
}
