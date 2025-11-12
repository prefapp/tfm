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
          | {(.name): {"url": .download_url, "ca-dir": $caDir}}' | \
        jq -s 'add' >> $(echo $directory | tr / -).json
    
    done
    
    jq -c -s 'reduce .[1:][] as $file (.[0];
      reduce ($file | to_entries[]) as $item (.;
        if .[$item.key] then
          .[$item.key]["ca-dir"] = .[$item.key]["ca-dir"] + "," + $item.value["ca-dir"]
        else
          .[$item.key] = $item.value
        end
      )
    ) | {merged: (. | tojson)}' *.json
  EOF
  ]
  query = {
    ssl_profiles = jsonencode(var.ssl_profiles)
  }
}

output "debug_raw_result" {
  value = data.external.list_cert_files.result
}

output "debug_merged_field" {
  value = data.external.list_cert_files.result.merged
}

locals {
  cert_data = jsondecode(data.external.list_cert_files.result.merged)
}

output "debug_cert_data" {
  value = local.cert_data
}

data "external" "cert_content_base64" {
  for_each = local.cert_data
  
  program = ["bash", "-c", <<EOF
    set -euo pipefail
    CONTENT_B64=$(wget -qO- "${each.value.url}" | base64 -w 0)
    jq -n --arg b64 "$CONTENT_B64" --arg caDir "${each.value["ca-dir"]}" \
      '{"content_b64": $b64, "ca_dir": $caDir}'
  EOF
  ]
}
