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
        jq --arg caDir "$directory" -r '.[]
          | select(.name | test("\\.(pem|cer)$"; "i"))
          | {(.name): {"url": .download_url, "caDir": $caDir}}' | \
        jq -s 'add' >> /tmp/$(echo $directory | tr / -).json
    
    done
    
    jq -c -s 'reduce .[1:][] as $file (.[0];
      reduce ($file | to_entries[]) as $item (.;
        if .[$item.key] then
          .[$item.key]["caDir"] = .[$item.key]["caDir"] + "," + $item.value["caDir"]
        else
          .[$item.key] = $item.value
        end
      )
    ) | to_entries | map({key: .key, value: (.value | tostring)}) | from_entries' /tmp/*.json
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

    CERT_DATA='${each.value}'
    URL=$(echo "$CERT_DATA" | jq -r '.url')

    CONTENT_B64=$(wget -qO- "$URL" | base64 -w 0)

    jq -n --arg b64 "$CONTENT_B64" '{"content_b64": $b64}'
  EOF
  ]
}
