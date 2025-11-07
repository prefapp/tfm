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
    set -euo pipefail
    profiles=$(jq -c '.ssl_profiles | fromjson')
    echo "$profiles" | jq -c '.[]' | while read -r item; do
      owner=$(echo "$item" | jq -r '.ca_certs_origin.github_owner')
      repository=$(echo "$item" | jq -r '.ca_certs_origin.github_repository')
      directory=$(echo "$item" | jq -r '.ca_certs_origin.github_directory')
      API_URL="https://api.github.com/repos/$owner/$repository/contents/$directory"
      wget -qO- "$API_URL" | \
        jq -r '.[] 
          | select(.name | test("\\.(pem|cer)$"; "i")) 
          | .name' | \
        jq -R '{(.): .}' | \
        jq -s 'add' >> certs.json
    done

    jq -s 'reduce .[] as $item ({}; . * $item)' certs.json

  EOF

  ]

  query = {
    ssl_profiles = jsonencode(var.ssl_profiles)
  }

}



data "external" "cert_content_base64" {

  for_each = data.external.list_cert_files.result

  program = ["bash", "-c", <<EOF
    set -euo pipefail
    CONTENT_B64=$(wget -qO- "${each.url}" | base64 -w 0)
    jq -n --arg b64 "$CONTENT_B64" '{"content_b64": $b64}'
  EOF
  ]
}
