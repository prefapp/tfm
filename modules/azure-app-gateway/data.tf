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
      
      node -e "import('node:https').then(({get})=>get('$API_URL',{headers:{'User-Agent':'terraform-external-script'}},res=>{let d='';res.on('data',c=>d+=c);res.on('end',()=>{const j=JSON.parse(d);const r=j.filter(x=>/\.(pem|cer)$/i.test(x.name)).reduce((a,x)=>({...a,[x.name]:x.name}),{});console.log(JSON.stringify(r))})}))"
  
    done
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
    tmpfile=$(mktemp)
    echo '{}' > "$tmpfile"

    echo "$profiles" | jq -c '.[]' | while read -r item; do
      owner=$(echo "$item" | jq -r '.ca_certs_origin.github_owner')
      repository=$(echo "$item" | jq -r '.ca_certs_origin.github_repository')
      branch=$(echo "$item" | jq -r '.ca_certs_origin.github_branch')
      directory=$(echo "$item" | jq -r '.ca_certs_origin.github_directory')

      API_URL="https://api.github.com/repos/$owner/$repository/contents/$directory"
      files=$(node -e "import('node:https').then(({get})=>get('$API_URL',{headers:{'User-Agent':'terraform-external-script'}},res=>{let d='';res.on('data',c=>d+=c);res.on('end',()=>{const j=JSON.parse(d);const r=j.filter(x=>/\.(pem|cer)$/i.test(x.name)).map(x=>x.name);console.log(JSON.stringify(r))})}))")

      for file in $(echo "$files" | jq -r '.[]'); do
        RAW_URL="https://raw.githubusercontent.com/$owner/$repository/$branch/$directory/$file"
        CONTENT_B64=$(node -e "import('node:https').then(({get})=>get('$RAW_URL',{headers:{'User-Agent':'terraform-external-script'}},res=>{let d='';res.on('data',c=>d+=c);res.on('end',()=>console.log(Buffer.from(d).toString('base64')))}))")
        jq -n --arg file "$file" --arg b64 "$CONTENT_B64" --arg caDir "$directory" \
          '{($file): {"content_b64": $b64, "ca-dir": $caDir}}' \
          | jq -s '.[0] * input' "$tmpfile" > "$tmpfile.new" && mv "$tmpfile.new" "$tmpfile"
      done
    done

    cat "$tmpfile"
  EOF
  ]

  query = {
    ssl_profiles = jsonencode(var.ssl_profiles)
  }

}
