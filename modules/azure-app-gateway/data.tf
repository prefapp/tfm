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

    profiles=$(jq -c '.ssl_profiles' < /dev/stdin)

    result="{}"

    echo "$profiles" | jq -c '.[]' | while read -r profile; do
      name=$(echo "$profile" | jq -r '.name')
      owner=$(echo "$profile" | jq -r '.ca_certs_origin.github_owner')
      repo=$(echo "$profile" | jq -r '.ca_certs_origin.github_repository')
      dir=$(echo "$profile" | jq -r '.ca_certs_origin.github_directory')

      API_URL="https://api.github.com/repos/$owner/$repo/contents/$dir"

      certs_json=$(wget -qO- "$API_URL" 2>/dev/null | \
        jq -r '[ .[] 
               | select(.name | test("\\.(pem|cer)$"; "i")) 
               | .name 
               | {(.): .} 
             ] | add // {}')

      result=$(echo "$result" | jq --arg name "$name" --argjson certs "$certs_json" '.[$name] = $certs')
    done

    echo "$result"
  EOF
  ]

  query = {
    ssl_profiles = jsonencode(var.ssl_profiles)
  }
}

data "external" "cert_content_base64" {
  for_each = {
    for profile_name, files in jsondecode(data.external.list_cert_files.result) :
    for filename, _ in files :
    "${profile_name}/${filename}" => {
      profile_name = profile_name
      filename     = filename
    }
  }

  program = ["bash", "-c", <<EOF
    set -euo pipefail

    profile_name=$(jq -r '.profile_name')
    filename=$(jq -r '.filename')
    ssl_profiles=$(jq -c '.ssl_profiles' < /dev/stdin)

    # Buscar el perfil correcto
    profile=$(echo "$ssl_profiles" | jq -c --arg name "$profile_name" '.[] | select(.name == $name)')
    owner=$(echo "$profile" | jq -r '.ca_certs_origin.github_owner')
    repo=$(echo "$profile" | jq -r '.ca_certs_origin.github_repository')
    branch=$(echo "$profile" | jq -r '.ca_certs_origin.github_branch')
    dir=$(echo "$profile" | jq -r '.ca_certs_origin.github_directory')

    RAW_URL="https://raw.githubusercontent.com/$owner/$repo/$branch/$dir/$filename"
    content_b64=$(wget -qO- "$RAW_URL" 2>/dev/null | base64 -w 0)

    jq -n \
      --arg content_b64 "$content_b64" \
      --arg filename "$filename" \
      --arg profile "$profile_name" \
      '{content_b64: $content_b64, filename: $filename, profile: $profile}'
  EOF
  ]

  query = {
    ssl_profiles = jsonencode(var.ssl_profiles)
    profile_name = each.value.profile_name
    filename     = each.value.filename
  }
}data "external" "cert_content_base64" {
  for_each = {
    for profile_name, files in jsondecode(data.external.list_cert_files.result) :
    for filename, _ in files :
    "${profile_name}/${filename}" => {
      profile_name = profile_name
      filename     = filename
    }
  }

  program = ["bash", "-c", <<EOF
    set -euo pipefail

    profile_name=$(jq -r '.profile_name')
    filename=$(jq -r '.filename')
    ssl_profiles=$(jq -c '.ssl_profiles' < /dev/stdin)

    # Buscar el perfil correcto
    profile=$(echo "$ssl_profiles" | jq -c --arg name "$profile_name" '.[] | select(.name == $name)')
    owner=$(echo "$profile" | jq -r '.ca_certs_origin.github_owner')
    repo=$(echo "$profile" | jq -r '.ca_certs_origin.github_repository')
    branch=$(echo "$profile" | jq -r '.ca_certs_origin.github_branch')
    dir=$(echo "$profile" | jq -r '.ca_certs_origin.github_directory')

    RAW_URL="https://raw.githubusercontent.com/$owner/$repo/$branch/$dir/$filename"
    content_b64=$(wget -qO- "$RAW_URL" 2>/dev/null | base64 -w 0)

    jq -n \
      --arg content_b64 "$content_b64" \
      --arg filename "$filename" \
      --arg profile "$profile_name" \
      '{content_b64: $content_b64, filename: $filename, profile: $profile}'
  EOF
  ]

  query = {
    ssl_profiles = jsonencode(var.ssl_profiles)
    profile_name = each.value.profile_name
    filename     = each.value.filename
  }
}data "external" "cert_content_base64" {
  for_each = {
    for profile_name, files in jsondecode(data.external.list_cert_files.result) :
    for filename, _ in files :
    "${profile_name}/${filename}" => {
      profile_name = profile_name
      filename     = filename
    }
  }

  program = ["bash", "-c", <<EOF
    set -euo pipefail

    profile_name=$(jq -r '.profile_name')
    filename=$(jq -r '.filename')
    ssl_profiles=$(jq -c '.ssl_profiles' < /dev/stdin)

    # Buscar el perfil correcto
    profile=$(echo "$ssl_profiles" | jq -c --arg name "$profile_name" '.[] | select(.name == $name)')
    owner=$(echo "$profile" | jq -r '.ca_certs_origin.github_owner')
    repo=$(echo "$profile" | jq -r '.ca_certs_origin.github_repository')
    branch=$(echo "$profile" | jq -r '.ca_certs_origin.github_branch')
    dir=$(echo "$profile" | jq -r '.ca_certs_origin.github_directory')

    RAW_URL="https://raw.githubusercontent.com/$owner/$repo/$branch/$dir/$filename"
    content_b64=$(wget -qO- "$RAW_URL" 2>/dev/null | base64 -w 0)

    jq -n \
      --arg content_b64 "$content_b64" \
      --arg filename "$filename" \
      --arg profile "$profile_name" \
      '{content_b64: $content_b64, filename: $filename, profile: $profile}'
  EOF
  ]

  query = {
    ssl_profiles = jsonencode(var.ssl_profiles)
    profile_name = each.value.profile_name
    filename     = each.value.filename
  }
}data "external" "cert_content_base64" {
  for_each = {
    for profile_name, files in jsondecode(data.external.list_cert_files.result) :
    for filename, _ in files :
    "${profile_name}/${filename}" => {
      profile_name = profile_name
      filename     = filename
    }
  }

  program = ["bash", "-c", <<EOF
    set -euo pipefail

    profile_name=$(jq -r '.profile_name')
    filename=$(jq -r '.filename')
    ssl_profiles=$(jq -c '.ssl_profiles' < /dev/stdin)

    # Buscar el perfil correcto
    profile=$(echo "$ssl_profiles" | jq -c --arg name "$profile_name" '.[] | select(.name == $name)')
    owner=$(echo "$profile" | jq -r '.ca_certs_origin.github_owner')
    repo=$(echo "$profile" | jq -r '.ca_certs_origin.github_repository')
    branch=$(echo "$profile" | jq -r '.ca_certs_origin.github_branch')
    dir=$(echo "$profile" | jq -r '.ca_certs_origin.github_directory')

    RAW_URL="https://raw.githubusercontent.com/$owner/$repo/$branch/$dir/$filename"
    content_b64=$(wget -qO- "$RAW_URL" 2>/dev/null | base64 -w 0)

    jq -n \
      --arg content_b64 "$content_b64" \
      --arg filename "$filename" \
      --arg profile "$profile_name" \
      '{content_b64: $content_b64, filename: $filename, profile: $profile}'
  EOF
  ]

  query = {
    ssl_profiles = jsonencode(var.ssl_profiles)
    profile_name = each.value.profile_name
    filename     = each.value.filename
  }
}data "external" "cert_content_base64" {
  for_each = {
    for profile_name, files in jsondecode(data.external.list_cert_files.result) :
    for filename, _ in files :
    "${profile_name}/${filename}" => {
      profile_name = profile_name
      filename     = filename
    }
  }

  program = ["bash", "-c", <<EOF
    set -euo pipefail

    profile_name=$(jq -r '.profile_name')
    filename=$(jq -r '.filename')
    ssl_profiles=$(jq -c '.ssl_profiles' < /dev/stdin)

    # Buscar el perfil correcto
    profile=$(echo "$ssl_profiles" | jq -c --arg name "$profile_name" '.[] | select(.name == $name)')
    owner=$(echo "$profile" | jq -r '.ca_certs_origin.github_owner')
    repo=$(echo "$profile" | jq -r '.ca_certs_origin.github_repository')
    branch=$(echo "$profile" | jq -r '.ca_certs_origin.github_branch')
    dir=$(echo "$profile" | jq -r '.ca_certs_origin.github_directory')

    RAW_URL="https://raw.githubusercontent.com/$owner/$repo/$branch/$dir/$filename"
    content_b64=$(wget -qO- "$RAW_URL" 2>/dev/null | base64 -w 0)

    jq -n \
      --arg content_b64 "$content_b64" \
      --arg filename "$filename" \
      --arg profile "$profile_name" \
      '{content_b64: $content_b64, filename: $filename, profile: $profile}'
  EOF
  ]

  query = {
    ssl_profiles = jsonencode(var.ssl_profiles)
    profile_name = each.value.profile_name
    filename     = each.value.filename
  }
}data "external" "cert_content_base64" {
  for_each = {
    for profile_name, files in jsondecode(data.external.list_cert_files.result) :
    for filename, _ in files :
    "${profile_name}/${filename}" => {
      profile_name = profile_name
      filename     = filename
    }
  }

  program = ["bash", "-c", <<EOF
    set -euo pipefail

    profile_name=$(jq -r '.profile_name')
    filename=$(jq -r '.filename')
    ssl_profiles=$(jq -c '.ssl_profiles' < /dev/stdin)

    # Buscar el perfil correcto
    profile=$(echo "$ssl_profiles" | jq -c --arg name "$profile_name" '.[] | select(.name == $name)')
    owner=$(echo "$profile" | jq -r '.ca_certs_origin.github_owner')
    repo=$(echo "$profile" | jq -r '.ca_certs_origin.github_repository')
    branch=$(echo "$profile" | jq -r '.ca_certs_origin.github_branch')
    dir=$(echo "$profile" | jq -r '.ca_certs_origin.github_directory')

    RAW_URL="https://raw.githubusercontent.com/$owner/$repo/$branch/$dir/$filename"
    content_b64=$(wget -qO- "$RAW_URL" 2>/dev/null | base64 -w 0)

    jq -n \
      --arg content_b64 "$content_b64" \
      --arg filename "$filename" \
      --arg profile "$profile_name" \
      '{content_b64: $content_b64, filename: $filename, profile: $profile}'
  EOF
  ]

  query = {
    ssl_profiles = jsonencode(var.ssl_profiles)
    profile_name = each.value.profile_name
    filename     = each.value.filename
  }
}data "external" "cert_content_base64" {
  for_each = {
    for profile_name, files in jsondecode(data.external.list_cert_files.result) :
    for filename, _ in files :
    "${profile_name}/${filename}" => {
      profile_name = profile_name
      filename     = filename
    }
  }

  program = ["bash", "-c", <<EOF
    set -euo pipefail

    profile_name=$(jq -r '.profile_name')
    filename=$(jq -r '.filename')
    ssl_profiles=$(jq -c '.ssl_profiles' < /dev/stdin)

    # Buscar el perfil correcto
    profile=$(echo "$ssl_profiles" | jq -c --arg name "$profile_name" '.[] | select(.name == $name)')
    owner=$(echo "$profile" | jq -r '.ca_certs_origin.github_owner')
    repo=$(echo "$profile" | jq -r '.ca_certs_origin.github_repository')
    branch=$(echo "$profile" | jq -r '.ca_certs_origin.github_branch')
    dir=$(echo "$profile" | jq -r '.ca_certs_origin.github_directory')

    RAW_URL="https://raw.githubusercontent.com/$owner/$repo/$branch/$dir/$filename"
    content_b64=$(wget -qO- "$RAW_URL" 2>/dev/null | base64 -w 0)

    jq -n \
      --arg content_b64 "$content_b64" \
      --arg filename "$filename" \
      --arg profile "$profile_name" \
      '{content_b64: $content_b64, filename: $filename, profile: $profile}'
  EOF
  ]

  query = {
    ssl_profiles = jsonencode(var.ssl_profiles)
    profile_name = each.value.profile_name
    filename     = each.value.filename
  }
}data "external" "cert_content_base64" {
  for_each = {
    for profile_name, files in jsondecode(data.external.list_cert_files.result) :
    for filename, _ in files :
    "${profile_name}/${filename}" => {
      profile_name = profile_name
      filename     = filename
    }
  }

  program = ["bash", "-c", <<EOF
    set -euo pipefail

    profile_name=$(jq -r '.profile_name')
    filename=$(jq -r '.filename')
    ssl_profiles=$(jq -c '.ssl_profiles' < /dev/stdin)

    # Buscar el perfil correcto
    profile=$(echo "$ssl_profiles" | jq -c --arg name "$profile_name" '.[] | select(.name == $name)')
    owner=$(echo "$profile" | jq -r '.ca_certs_origin.github_owner')
    repo=$(echo "$profile" | jq -r '.ca_certs_origin.github_repository')
    branch=$(echo "$profile" | jq -r '.ca_certs_origin.github_branch')
    dir=$(echo "$profile" | jq -r '.ca_certs_origin.github_directory')

    RAW_URL="https://raw.githubusercontent.com/$owner/$repo/$branch/$dir/$filename"
    content_b64=$(wget -qO- "$RAW_URL" 2>/dev/null | base64 -w 0)

    jq -n \
      --arg content_b64 "$content_b64" \
      --arg filename "$filename" \
      --arg profile "$profile_name" \
      '{content_b64: $content_b64, filename: $filename, profile: $profile}'
  EOF
  ]

  query = {
    ssl_profiles = jsonencode(var.ssl_profiles)
    profile_name = each.value.profile_name
    filename     = each.value.filename
  }
}data "external" "cert_content_base64" {
  for_each = {
    for profile_name, files in jsondecode(data.external.list_cert_files.result) :
    for filename, _ in files :
    "${profile_name}/${filename}" => {
      profile_name = profile_name
      filename     = filename
    }
  }

  program = ["bash", "-c", <<EOF
    set -euo pipefail

    profile_name=$(jq -r '.profile_name')
    filename=$(jq -r '.filename')
    ssl_profiles=$(jq -c '.ssl_profiles' < /dev/stdin)

    # Buscar el perfil correcto
    profile=$(echo "$ssl_profiles" | jq -c --arg name "$profile_name" '.[] | select(.name == $name)')
    owner=$(echo "$profile" | jq -r '.ca_certs_origin.github_owner')
    repo=$(echo "$profile" | jq -r '.ca_certs_origin.github_repository')
    branch=$(echo "$profile" | jq -r '.ca_certs_origin.github_branch')
    dir=$(echo "$profile" | jq -r '.ca_certs_origin.github_directory')

    RAW_URL="https://raw.githubusercontent.com/$owner/$repo/$branch/$dir/$filename"
    content_b64=$(wget -qO- "$RAW_URL" 2>/dev/null | base64 -w 0)

    jq -n \
      --arg content_b64 "$content_b64" \
      --arg filename "$filename" \
      --arg profile "$profile_name" \
      '{content_b64: $content_b64, filename: $filename, profile: $profile}'
  EOF
  ]

  query = {
    ssl_profiles = jsonencode(var.ssl_profiles)
    profile_name = each.value.profile_name
    filename     = each.value.filename
  }
}data "external" "cert_content_base64" {
  for_each = {
    for profile_name, files in jsondecode(data.external.list_cert_files.result) :
    for filename, _ in files :
    "${profile_name}/${filename}" => {
      profile_name = profile_name
      filename     = filename
    }
  }

  program = ["bash", "-c", <<EOF
    set -euo pipefail

    profile_name=$(jq -r '.profile_name')
    filename=$(jq -r '.filename')
    ssl_profiles=$(jq -c '.ssl_profiles' < /dev/stdin)

    # Buscar el perfil correcto
    profile=$(echo "$ssl_profiles" | jq -c --arg name "$profile_name" '.[] | select(.name == $name)')
    owner=$(echo "$profile" | jq -r '.ca_certs_origin.github_owner')
    repo=$(echo "$profile" | jq -r '.ca_certs_origin.github_repository')
    branch=$(echo "$profile" | jq -r '.ca_certs_origin.github_branch')
    dir=$(echo "$profile" | jq -r '.ca_certs_origin.github_directory')

    RAW_URL="https://raw.githubusercontent.com/$owner/$repo/$branch/$dir/$filename"
    content_b64=$(wget -qO- "$RAW_URL" 2>/dev/null | base64 -w 0)

    jq -n \
      --arg content_b64 "$content_b64" \
      --arg filename "$filename" \
      --arg profile "$profile_name" \
      '{content_b64: $content_b64, filename: $filename, profile: $profile}'
  EOF
  ]

  query = {
    ssl_profiles = jsonencode(var.ssl_profiles)
    profile_name = each.value.profile_name
    filename     = each.value.filename
  }
}data "external" "cert_content_base64" {
  for_each = {
    for profile_name, files in jsondecode(data.external.list_cert_files.result) :
    for filename, _ in files :
    "${profile_name}/${filename}" => {
      profile_name = profile_name
      filename     = filename
    }
  }

  program = ["bash", "-c", <<EOF
    set -euo pipefail

    profile_name=$(jq -r '.profile_name')
    filename=$(jq -r '.filename')
    ssl_profiles=$(jq -c '.ssl_profiles' < /dev/stdin)

    # Buscar el perfil correcto
    profile=$(echo "$ssl_profiles" | jq -c --arg name "$profile_name" '.[] | select(.name == $name)')
    owner=$(echo "$profile" | jq -r '.ca_certs_origin.github_owner')
    repo=$(echo "$profile" | jq -r '.ca_certs_origin.github_repository')
    branch=$(echo "$profile" | jq -r '.ca_certs_origin.github_branch')
    dir=$(echo "$profile" | jq -r '.ca_certs_origin.github_directory')

    RAW_URL="https://raw.githubusercontent.com/$owner/$repo/$branch/$dir/$filename"
    content_b64=$(wget -qO- "$RAW_URL" 2>/dev/null | base64 -w 0)

    jq -n \
      --arg content_b64 "$content_b64" \
      --arg filename "$filename" \
      --arg profile "$profile_name" \
      '{content_b64: $content_b64, filename: $filename, profile: $profile}'
  EOF
  ]

  query = {
    ssl_profiles = jsonencode(var.ssl_profiles)
    profile_name = each.value.profile_name
    filename     = each.value.filename
  }
}data "external" "cert_content_base64" {
  for_each = {
    for profile_name, files in jsondecode(data.external.list_cert_files.result) :
    for filename, _ in files :
    "${profile_name}/${filename}" => {
      profile_name = profile_name
      filename     = filename
    }
  }

  program = ["bash", "-c", <<EOF
    set -euo pipefail

    profile_name=$(jq -r '.profile_name')
    filename=$(jq -r '.filename')
    ssl_profiles=$(jq -c '.ssl_profiles' < /dev/stdin)

    # Buscar el perfil correcto
    profile=$(echo "$ssl_profiles" | jq -c --arg name "$profile_name" '.[] | select(.name == $name)')
    owner=$(echo "$profile" | jq -r '.ca_certs_origin.github_owner')
    repo=$(echo "$profile" | jq -r '.ca_certs_origin.github_repository')
    branch=$(echo "$profile" | jq -r '.ca_certs_origin.github_branch')
    dir=$(echo "$profile" | jq -r '.ca_certs_origin.github_directory')

    RAW_URL="https://raw.githubusercontent.com/$owner/$repo/$branch/$dir/$filename"
    content_b64=$(wget -qO- "$RAW_URL" 2>/dev/null | base64 -w 0)

    jq -n \
      --arg content_b64 "$content_b64" \
      --arg filename "$filename" \
      --arg profile "$profile_name" \
      '{content_b64: $content_b64, filename: $filename, profile: $profile}'
  EOF
  ]

  query = {
    ssl_profiles = jsonencode(var.ssl_profiles)
    profile_name = each.value.profile_name
    filename     = each.value.filename
  }
}data "external" "cert_content_base64" {
  for_each = {
    for profile_name, files in jsondecode(data.external.list_cert_files.result) :
    for filename, _ in files :
    "${profile_name}/${filename}" => {
      profile_name = profile_name
      filename     = filename
    }
  }

  program = ["bash", "-c", <<EOF
    set -euo pipefail

    profile_name=$(jq -r '.profile_name')
    filename=$(jq -r '.filename')
    ssl_profiles=$(jq -c '.ssl_profiles' < /dev/stdin)

    # Buscar el perfil correcto
    profile=$(echo "$ssl_profiles" | jq -c --arg name "$profile_name" '.[] | select(.name == $name)')
    owner=$(echo "$profile" | jq -r '.ca_certs_origin.github_owner')
    repo=$(echo "$profile" | jq -r '.ca_certs_origin.github_repository')
    branch=$(echo "$profile" | jq -r '.ca_certs_origin.github_branch')
    dir=$(echo "$profile" | jq -r '.ca_certs_origin.github_directory')

    RAW_URL="https://raw.githubusercontent.com/$owner/$repo/$branch/$dir/$filename"
    content_b64=$(wget -qO- "$RAW_URL" 2>/dev/null | base64 -w 0)

    jq -n \
      --arg content_b64 "$content_b64" \
      --arg filename "$filename" \
      --arg profile "$profile_name" \
      '{content_b64: $content_b64, filename: $filename, profile: $profile}'
  EOF
  ]

  query = {
    ssl_profiles = jsonencode(var.ssl_profiles)
    profile_name = each.value.profile_name
    filename     = each.value.filename
  }
}data "external" "cert_content_base64" {
  for_each = {
    for profile_name, files in jsondecode(data.external.list_cert_files.result) :
    for filename, _ in files :
    "${profile_name}/${filename}" => {
      profile_name = profile_name
      filename     = filename
    }
  }

  program = ["bash", "-c", <<EOF
    set -euo pipefail

    profile_name=$(jq -r '.profile_name')
    filename=$(jq -r '.filename')
    ssl_profiles=$(jq -c '.ssl_profiles' < /dev/stdin)

    # Buscar el perfil correcto
    profile=$(echo "$ssl_profiles" | jq -c --arg name "$profile_name" '.[] | select(.name == $name)')
    owner=$(echo "$profile" | jq -r '.ca_certs_origin.github_owner')
    repo=$(echo "$profile" | jq -r '.ca_certs_origin.github_repository')
    branch=$(echo "$profile" | jq -r '.ca_certs_origin.github_branch')
    dir=$(echo "$profile" | jq -r '.ca_certs_origin.github_directory')

    RAW_URL="https://raw.githubusercontent.com/$owner/$repo/$branch/$dir/$filename"
    content_b64=$(wget -qO- "$RAW_URL" 2>/dev/null | base64 -w 0)

    jq -n \
      --arg content_b64 "$content_b64" \
      --arg filename "$filename" \
      --arg profile "$profile_name" \
      '{content_b64: $content_b64, filename: $filename, profile: $profile}'
  EOF
  ]

  query = {
    ssl_profiles = jsonencode(var.ssl_profiles)
    profile_name = each.value.profile_name
    filename     = each.value.filename
  }
}data "external" "cert_content_base64" {
  for_each = {
    for profile_name, files in jsondecode(data.external.list_cert_files.result) :
    for filename, _ in files :
    "${profile_name}/${filename}" => {
      profile_name = profile_name
      filename     = filename
    }
  }

  program = ["bash", "-c", <<EOF
    set -euo pipefail

    profile_name=$(jq -r '.profile_name')
    filename=$(jq -r '.filename')
    ssl_profiles=$(jq -c '.ssl_profiles' < /dev/stdin)

    # Buscar el perfil correcto
    profile=$(echo "$ssl_profiles" | jq -c --arg name "$profile_name" '.[] | select(.name == $name)')
    owner=$(echo "$profile" | jq -r '.ca_certs_origin.github_owner')
    repo=$(echo "$profile" | jq -r '.ca_certs_origin.github_repository')
    branch=$(echo "$profile" | jq -r '.ca_certs_origin.github_branch')
    dir=$(echo "$profile" | jq -r '.ca_certs_origin.github_directory')

    RAW_URL="https://raw.githubusercontent.com/$owner/$repo/$branch/$dir/$filename"
    content_b64=$(wget -qO- "$RAW_URL" 2>/dev/null | base64 -w 0)

    jq -n \
      --arg content_b64 "$content_b64" \
      --arg filename "$filename" \
      --arg profile "$profile_name" \
      '{content_b64: $content_b64, filename: $filename, profile: $profile}'
  EOF
  ]

  query = {
    ssl_profiles = jsonencode(var.ssl_profiles)
    profile_name = each.value.profile_name
    filename     = each.value.filename
  }
}data "external" "cert_content_base64" {
  for_each = {
    for profile_name, files in jsondecode(data.external.list_cert_files.result) :
    for filename, _ in files :
    "${profile_name}/${filename}" => {
      profile_name = profile_name
      filename     = filename
    }
  }

  program = ["bash", "-c", <<EOF
    set -euo pipefail

    profile_name=$(jq -r '.profile_name')
    filename=$(jq -r '.filename')
    ssl_profiles=$(jq -c '.ssl_profiles' < /dev/stdin)

    # Buscar el perfil correcto
    profile=$(echo "$ssl_profiles" | jq -c --arg name "$profile_name" '.[] | select(.name == $name)')
    owner=$(echo "$profile" | jq -r '.ca_certs_origin.github_owner')
    repo=$(echo "$profile" | jq -r '.ca_certs_origin.github_repository')
    branch=$(echo "$profile" | jq -r '.ca_certs_origin.github_branch')
    dir=$(echo "$profile" | jq -r '.ca_certs_origin.github_directory')

    RAW_URL="https://raw.githubusercontent.com/$owner/$repo/$branch/$dir/$filename"
    content_b64=$(wget -qO- "$RAW_URL" 2>/dev/null | base64 -w 0)

    jq -n \
      --arg content_b64 "$content_b64" \
      --arg filename "$filename" \
      --arg profile "$profile_name" \
      '{content_b64: $content_b64, filename: $filename, profile: $profile}'
  EOF
  ]

  query = {
    ssl_profiles = jsonencode(var.ssl_profiles)
    profile_name = each.value.profile_name
    filename     = each.value.filename
  }
}data "external" "cert_content_base64" {
  for_each = {
    for profile_name, files in jsondecode(data.external.list_cert_files.result) :
    for filename, _ in files :
    "${profile_name}/${filename}" => {
      profile_name = profile_name
      filename     = filename
    }
  }

  program = ["bash", "-c", <<EOF
    set -euo pipefail

    profile_name=$(jq -r '.profile_name')
    filename=$(jq -r '.filename')
    ssl_profiles=$(jq -c '.ssl_profiles' < /dev/stdin)

    # Buscar el perfil correcto
    profile=$(echo "$ssl_profiles" | jq -c --arg name "$profile_name" '.[] | select(.name == $name)')
    owner=$(echo "$profile" | jq -r '.ca_certs_origin.github_owner')
    repo=$(echo "$profile" | jq -r '.ca_certs_origin.github_repository')
    branch=$(echo "$profile" | jq -r '.ca_certs_origin.github_branch')
    dir=$(echo "$profile" | jq -r '.ca_certs_origin.github_directory')

    RAW_URL="https://raw.githubusercontent.com/$owner/$repo/$branch/$dir/$filename"
    content_b64=$(wget -qO- "$RAW_URL" 2>/dev/null | base64 -w 0)

    jq -n \
      --arg content_b64 "$content_b64" \
      --arg filename "$filename" \
      --arg profile "$profile_name" \
      '{content_b64: $content_b64, filename: $filename, profile: $profile}'
  EOF
  ]

  query = {
    ssl_profiles = jsonencode(var.ssl_profiles)
    profile_name = each.value.profile_name
    filename     = each.value.filename
  }
}data "external" "cert_content_base64" {
  for_each = {
    for profile_name, files in jsondecode(data.external.list_cert_files.result) :
    for filename, _ in files :
    "${profile_name}/${filename}" => {
      profile_name = profile_name
      filename     = filename
    }
  }

  program = ["bash", "-c", <<EOF
    set -euo pipefail

    profile_name=$(jq -r '.profile_name')
    filename=$(jq -r '.filename')
    ssl_profiles=$(jq -c '.ssl_profiles' < /dev/stdin)

    # Buscar el perfil correcto
    profile=$(echo "$ssl_profiles" | jq -c --arg name "$profile_name" '.[] | select(.name == $name)')
    owner=$(echo "$profile" | jq -r '.ca_certs_origin.github_owner')
    repo=$(echo "$profile" | jq -r '.ca_certs_origin.github_repository')
    branch=$(echo "$profile" | jq -r '.ca_certs_origin.github_branch')
    dir=$(echo "$profile" | jq -r '.ca_certs_origin.github_directory')

    RAW_URL="https://raw.githubusercontent.com/$owner/$repo/$branch/$dir/$filename"
    content_b64=$(wget -qO- "$RAW_URL" 2>/dev/null | base64 -w 0)

    jq -n \
      --arg content_b64 "$content_b64" \
      --arg filename "$filename" \
      --arg profile "$profile_name" \
      '{content_b64: $content_b64, filename: $filename, profile: $profile}'
  EOF
  ]

  query = {
    ssl_profiles = jsonencode(var.ssl_profiles)
    profile_name = each.value.profile_name
    filename     = each.value.filename
  }
}data "external" "cert_content_base64" {
  for_each = {
    for profile_name, files in jsondecode(data.external.list_cert_files.result) :
    for filename, _ in files :
    "${profile_name}/${filename}" => {
      profile_name = profile_name
      filename     = filename
    }
  }

  program = ["bash", "-c", <<EOF
    set -euo pipefail

    profile_name=$(jq -r '.profile_name')
    filename=$(jq -r '.filename')
    ssl_profiles=$(jq -c '.ssl_profiles' < /dev/stdin)

    # Buscar el perfil correcto
    profile=$(echo "$ssl_profiles" | jq -c --arg name "$profile_name" '.[] | select(.name == $name)')
    owner=$(echo "$profile" | jq -r '.ca_certs_origin.github_owner')
    repo=$(echo "$profile" | jq -r '.ca_certs_origin.github_repository')
    branch=$(echo "$profile" | jq -r '.ca_certs_origin.github_branch')
    dir=$(echo "$profile" | jq -r '.ca_certs_origin.github_directory')

    RAW_URL="https://raw.githubusercontent.com/$owner/$repo/$branch/$dir/$filename"
    content_b64=$(wget -qO- "$RAW_URL" 2>/dev/null | base64 -w 0)

    jq -n \
      --arg content_b64 "$content_b64" \
      --arg filename "$filename" \
      --arg profile "$profile_name" \
      '{content_b64: $content_b64, filename: $filename, profile: $profile}'
  EOF
  ]

  query = {
    ssl_profiles = jsonencode(var.ssl_profiles)
    profile_name = each.value.profile_name
    filename     = each.value.filename
  }
}data "external" "cert_content_base64" {
  for_each = {
    for profile_name, files in jsondecode(data.external.list_cert_files.result) :
    for filename, _ in files :
    "${profile_name}/${filename}" => {
      profile_name = profile_name
      filename     = filename
    }
  }

  program = ["bash", "-c", <<EOF
    set -euo pipefail

    profile_name=$(jq -r '.profile_name')
    filename=$(jq -r '.filename')
    ssl_profiles=$(jq -c '.ssl_profiles' < /dev/stdin)

    # Buscar el perfil correcto
    profile=$(echo "$ssl_profiles" | jq -c --arg name "$profile_name" '.[] | select(.name == $name)')
    owner=$(echo "$profile" | jq -r '.ca_certs_origin.github_owner')
    repo=$(echo "$profile" | jq -r '.ca_certs_origin.github_repository')
    branch=$(echo "$profile" | jq -r '.ca_certs_origin.github_branch')
    dir=$(echo "$profile" | jq -r '.ca_certs_origin.github_directory')

    RAW_URL="https://raw.githubusercontent.com/$owner/$repo/$branch/$dir/$filename"
    content_b64=$(wget -qO- "$RAW_URL" 2>/dev/null | base64 -w 0)

    jq -n \
      --arg content_b64 "$content_b64" \
      --arg filename "$filename" \
      --arg profile "$profile_name" \
      '{content_b64: $content_b64, filename: $filename, profile: $profile}'
  EOF
  ]

  query = {
    ssl_profiles = jsonencode(var.ssl_profiles)
    profile_name = each.value.profile_name
    filename     = each.value.filename
  }
}data "external" "cert_content_base64" {
  for_each = {
    for profile_name, files in jsondecode(data.external.list_cert_files.result) :
    for filename, _ in files :
    "${profile_name}/${filename}" => {
      profile_name = profile_name
      filename     = filename
    }
  }

  program = ["bash", "-c", <<EOF
    set -euo pipefail

    profile_name=$(jq -r '.profile_name')
    filename=$(jq -r '.filename')
    ssl_profiles=$(jq -c '.ssl_profiles' < /dev/stdin)

    # Buscar el perfil correcto
    profile=$(echo "$ssl_profiles" | jq -c --arg name "$profile_name" '.[] | select(.name == $name)')
    owner=$(echo "$profile" | jq -r '.ca_certs_origin.github_owner')
    repo=$(echo "$profile" | jq -r '.ca_certs_origin.github_repository')
    branch=$(echo "$profile" | jq -r '.ca_certs_origin.github_branch')
    dir=$(echo "$profile" | jq -r '.ca_certs_origin.github_directory')

    RAW_URL="https://raw.githubusercontent.com/$owner/$repo/$branch/$dir/$filename"
    content_b64=$(wget -qO- "$RAW_URL" 2>/dev/null | base64 -w 0)

    jq -n \
      --arg content_b64 "$content_b64" \
      --arg filename "$filename" \
      --arg profile "$profile_name" \
      '{content_b64: $content_b64, filename: $filename, profile: $profile}'
  EOF
  ]

  query = {
    ssl_profiles = jsonencode(var.ssl_profiles)
    profile_name = each.value.profile_name
    filename     = each.value.filename
  }
}data "external" "cert_content_base64" {
  for_each = {
    for profile_name, files in jsondecode(data.external.list_cert_files.result) :
    for filename, _ in files :
    "${profile_name}/${filename}" => {
      profile_name = profile_name
      filename     = filename
    }
  }

  program = ["bash", "-c", <<EOF
    set -euo pipefail

    profile_name=$(jq -r '.profile_name')
    filename=$(jq -r '.filename')
    ssl_profiles=$(jq -c '.ssl_profiles' < /dev/stdin)

    # Buscar el perfil correcto
    profile=$(echo "$ssl_profiles" | jq -c --arg name "$profile_name" '.[] | select(.name == $name)')
    owner=$(echo "$profile" | jq -r '.ca_certs_origin.github_owner')
    repo=$(echo "$profile" | jq -r '.ca_certs_origin.github_repository')
    branch=$(echo "$profile" | jq -r '.ca_certs_origin.github_branch')
    dir=$(echo "$profile" | jq -r '.ca_certs_origin.github_directory')

    RAW_URL="https://raw.githubusercontent.com/$owner/$repo/$branch/$dir/$filename"
    content_b64=$(wget -qO- "$RAW_URL" 2>/dev/null | base64 -w 0)

    jq -n \
      --arg content_b64 "$content_b64" \
      --arg filename "$filename" \
      --arg profile "$profile_name" \
      '{content_b64: $content_b64, filename: $filename, profile: $profile}'
  EOF
  ]

  query = {
    ssl_profiles = jsonencode(var.ssl_profiles)
    profile_name = each.value.profile_name
    filename     = each.value.filename
  }
}data "external" "cert_content_base64" {
  for_each = {
    for profile_name, files in jsondecode(data.external.list_cert_files.result) :
    for filename, _ in files :
    "${profile_name}/${filename}" => {
      profile_name = profile_name
      filename     = filename
    }
  }

  program = ["bash", "-c", <<EOF
    set -euo pipefail

    profile_name=$(jq -r '.profile_name')
    filename=$(jq -r '.filename')
    ssl_profiles=$(jq -c '.ssl_profiles' < /dev/stdin)

    # Buscar el perfil correcto
    profile=$(echo "$ssl_profiles" | jq -c --arg name "$profile_name" '.[] | select(.name == $name)')
    owner=$(echo "$profile" | jq -r '.ca_certs_origin.github_owner')
    repo=$(echo "$profile" | jq -r '.ca_certs_origin.github_repository')
    branch=$(echo "$profile" | jq -r '.ca_certs_origin.github_branch')
    dir=$(echo "$profile" | jq -r '.ca_certs_origin.github_directory')

    RAW_URL="https://raw.githubusercontent.com/$owner/$repo/$branch/$dir/$filename"
    content_b64=$(wget -qO- "$RAW_URL" 2>/dev/null | base64 -w 0)

    jq -n \
      --arg content_b64 "$content_b64" \
      --arg filename "$filename" \
      --arg profile "$profile_name" \
      '{content_b64: $content_b64, filename: $filename, profile: $profile}'
  EOF
  ]

  query = {
    ssl_profiles = jsonencode(var.ssl_profiles)
    profile_name = each.value.profile_name
    filename     = each.value.filename
  }
}data "external" "cert_content_base64" {
  for_each = {
    for profile_name, files in jsondecode(data.external.list_cert_files.result) :
    for filename, _ in files :
    "${profile_name}/${filename}" => {
      profile_name = profile_name
      filename     = filename
    }
  }

  program = ["bash", "-c", <<EOF
    set -euo pipefail

    profile_name=$(jq -r '.profile_name')
    filename=$(jq -r '.filename')
    ssl_profiles=$(jq -c '.ssl_profiles' < /dev/stdin)

    # Buscar el perfil correcto
    profile=$(echo "$ssl_profiles" | jq -c --arg name "$profile_name" '.[] | select(.name == $name)')
    owner=$(echo "$profile" | jq -r '.ca_certs_origin.github_owner')
    repo=$(echo "$profile" | jq -r '.ca_certs_origin.github_repository')
    branch=$(echo "$profile" | jq -r '.ca_certs_origin.github_branch')
    dir=$(echo "$profile" | jq -r '.ca_certs_origin.github_directory')

    RAW_URL="https://raw.githubusercontent.com/$owner/$repo/$branch/$dir/$filename"
    content_b64=$(wget -qO- "$RAW_URL" 2>/dev/null | base64 -w 0)

    jq -n \
      --arg content_b64 "$content_b64" \
      --arg filename "$filename" \
      --arg profile "$profile_name" \
      '{content_b64: $content_b64, filename: $filename, profile: $profile}'
  EOF
  ]

  query = {
    ssl_profiles = jsonencode(var.ssl_profiles)
    profile_name = each.value.profile_name
    filename     = each.value.filename
  }
}data "external" "cert_content_base64" {
  for_each = {
    for profile_name, files in jsondecode(data.external.list_cert_files.result) :
    for filename, _ in files :
    "${profile_name}/${filename}" => {
      profile_name = profile_name
      filename     = filename
    }
  }

  program = ["bash", "-c", <<EOF
    set -euo pipefail

    profile_name=$(jq -r '.profile_name')
    filename=$(jq -r '.filename')
    ssl_profiles=$(jq -c '.ssl_profiles' < /dev/stdin)

    # Buscar el perfil correcto
    profile=$(echo "$ssl_profiles" | jq -c --arg name "$profile_name" '.[] | select(.name == $name)')
    owner=$(echo "$profile" | jq -r '.ca_certs_origin.github_owner')
    repo=$(echo "$profile" | jq -r '.ca_certs_origin.github_repository')
    branch=$(echo "$profile" | jq -r '.ca_certs_origin.github_branch')
    dir=$(echo "$profile" | jq -r '.ca_certs_origin.github_directory')

    RAW_URL="https://raw.githubusercontent.com/$owner/$repo/$branch/$dir/$filename"
    content_b64=$(wget -qO- "$RAW_URL" 2>/dev/null | base64 -w 0)

    jq -n \
      --arg content_b64 "$content_b64" \
      --arg filename "$filename" \
      --arg profile "$profile_name" \
      '{content_b64: $content_b64, filename: $filename, profile: $profile}'
  EOF
  ]

  query = {
    ssl_profiles = jsonencode(var.ssl_profiles)
    profile_name = each.value.profile_name
    filename     = each.value.filename
  }
}

data "external" "cert_content_base64" {
  for_each = {
    for profile_name, files in jsondecode(data.external.list_cert_files.result) :
    for filename, _ in files :
    "${profile_name}/${filename}" => {
      profile_name = profile_name
      filename     = filename
    }
  }

  program = ["bash", "-c", <<EOF
    set -euo pipefail

    profile_name=$(jq -r '.profile_name')
    filename=$(jq -r '.filename')
    ssl_profiles=$(jq -c '.ssl_profiles' < /dev/stdin)

    # Buscar el perfil correcto
    profile=$(echo "$ssl_profiles" | jq -c --arg name "$profile_name" '.[] | select(.name == $name)')
    owner=$(echo "$profile" | jq -r '.ca_certs_origin.github_owner')
    repo=$(echo "$profile" | jq -r '.ca_certs_origin.github_repository')
    branch=$(echo "$profile" | jq -r '.ca_certs_origin.github_branch')
    dir=$(echo "$profile" | jq -r '.ca_certs_origin.github_directory')

    RAW_URL="https://raw.githubusercontent.com/$owner/$repo/$branch/$dir/$filename"
    content_b64=$(wget -qO- "$RAW_URL" 2>/dev/null | base64 -w 0)

    jq -n \
      --arg content_b64 "$content_b64" \
      --arg filename "$filename" \
      --arg profile "$profile_name" \
      '{content_b64: $content_b64, filename: $filename, profile: $profile}'
  EOF
  ]

  query = {
    ssl_profiles = jsonencode(var.ssl_profiles)
    profile_name = each.value.profile_name
    filename     = each.value.filename
  }
}

