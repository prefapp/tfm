# Data section
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/user_assigned_identity
data "azurerm_user_assigned_identity" "that" {
  name                = var.user_assigned_identity #"appgw-management-certs"
  resource_group_name = var.resource_group_name
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet
data "azurerm_subnet" "that" {
  name                 =  var.subnet.name
  virtual_network_name =  var.subnet.virtual_network_name
  resource_group_name  =  var.resource_group_name
}

data "external" "list_cert_files" {
  program = ["bash", "-c", <<EOF
    API_URL="https://api.github.com/repos/${var.github_owner}/${var.github_repository}/contents/${var.github_directory}"
    curl -s "$API_URL" | \
      jq -r '.[] 
        | select(.name | test("\\.(pem|cer)$"; "i")) 
        | .name' | \
      jq -R '{(.): .}' | \
      jq -s 'add'
  EOF
  ]
}

data "external" "cert_content_base64" {
  for_each = data.external.list_cert_files.result

  program = ["bash", "-c", <<EOF
    RAW_URL="https://raw.githubusercontent.com/${var.github_owner}/${var.github_repository}/${var.github_branch}/${var.github_directory}/${each.key}"
    CONTENT_B64=$(curl -s "$RAW_URL" | base64 -w 0)
    jq -n --arg b64 "$CONTENT_B64" '{"content_b64": $b64}'
  EOF
  ]
}