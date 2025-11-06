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

    # Recibir perfiles como JSON válido
    profiles=$(jq -c '.ssl_profiles' < /dev/stdin)

    # Inicializar resultado como objeto vacío
    result="{}"

    # Iterar sobre cada perfil
    echo "$profiles" | jq -c '.[]' | while read -r profile; do
      name=$(echo "$profile" | jq -r '.name')
      owner=$(echo "$profile" | jq -r '.ca_certs_origin.github_owner')
      repo=$(echo "$profile" | jq -r '.ca_certs_origin.github_repository')
      dir=$(echo "$profile" | jq -r '.ca_certs_origin.github_directory')

      API_URL="https://api.github.com/repos/$owner/$repo/contents/$dir"

      # Obtener nombres de archivos .pem/.cer
      certs_json=$(wget -qO- "$API_URL" 2>/dev/null | \
        jq -r '[ .[] 
               | select(.name | test("\\.(pem|cer)$"; "i")) 
               | .name 
               | {(.): .} 
             ] | add // {}')

      # Acumular en $result
      result=$(echo "$result" | jq --arg name "$name" --argjson certs "$certs_json" '.[$name] = $certs')
    done

    # Salida final: un solo JSON
    echo "$result"
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

    profiles=$(jq -c '.ssl_profiles | fromjson')

    echo "$profiles" | jq -c '.[]' | while read -r item; do

      owner=$(echo "$item" | jq -r '.ca_certs_origin.github_owner')
      repository=$(echo "$item" | jq -r '.ca_certs_origin.github_repository')
      branch=$(echo "$item" | jq -r '.ca_certs_origin.github_branch')
      directory=$(echo "$item" | jq -r '.ca_certs_origin.github_directory')
      RAW_URL="https://raw.githubusercontent.com/$owner/$repository/$branch/$directory/${each.key}"

      CONTENT_B64=$(wget -qO- "$RAW_URL" | base64 -w 0)

      jq -n --arg b64 "$CONTENT_B64" --arg caDir "$directory" '{"content_b64": $b64, "ca-dir": $caDir}'
    done
  EOF
  ]

  query = {
    ssl_profiles = jsonencode(var.ssl_profiles)
  }

}


