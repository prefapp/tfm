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

    input = $(cat)
    
    echo "$input" | jq -c '.ssl_profiles[]' | while read -r item; do
      
      github_owner=$(echo "$item" | jq -r '.ca_certs_origin.github_owner')
      github_repository=$(echo "$item" | jq -r '.ca_certs_origin.github_repository')
      github_directory=$(echo "$item" | jq -r '.ca_certs_origin.github_directory')

      API_URL="https://api.github.com/repos/${github_owner}/${github_repository}/contents/${github_directory}"
      
      curl -s "$API_URL" | \
        jq -r '.[] 
          | select(.name | test("\\.(pem|cer)$"; "i")) 
          | .name' | \
        jq -R '{(.): .}' | \
        jq -s 'add'
  
    done
  EOF
  ]

  query = {
    ssl_profiles = var.ssl_profiles
  }
}

data "external" "cert_content_base64" {
  for_each = data.external.list_cert_files.result

  program = ["bash", "-c", <<EOF

    set -euo pipefail

    input = $(cat)
    
    echo "$input" | jq -c '.ssl_profiles[]' | while read -r item; do
      
      github_owner=$(echo "$item" | jq -r '.ca_certs_origin.github_owner')
      github_repository=$(echo "$item" | jq -r '.ca_certs_origin.github_repository')
      github_branch=$(echo "$item" | jq -r '.ca_certs_origin.github_branch')
      github_directory=$(echo "$item" | jq -r '.ca_certs_origin.github_directory')


      RAW_URL="https://raw.githubusercontent.com/${github_owner}/${github_repository}/${github_branch}/${github_directory}/${each.key}"
    
      CONTENT_B64=$(curl -s "$RAW_URL" | base64 -w 0)
    
      jq -n --arg b64 "$CONTENT_B64" --arg ca-dir "${github_directory}" '{"content_b64": $b64, "ca-dir": $ca-dir}'
  
    done
  
  EOF
  ]

  query = {
    ssl_profiles = var.ssl_profiles
  }

}