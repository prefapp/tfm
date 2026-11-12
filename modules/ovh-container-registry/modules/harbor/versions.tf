terraform {
  required_version = ">= 1.5.0"
  required_providers {
    ovh = {
      source  = "ovh/ovh"
      version = ">= 2.24.0, < 3.0.0"
    }
    harbor = {
      source  = "goharbor/harbor"
      version = ">= 3.12.0, < 4.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.9.0, < 4.0.0"
    }
  }
}

# Harbor is a service provider: its credentials come from the registry itself
# (the admin secret written by the root module), not from the platform caller.
# Keeping this block here makes the submodule a legacy module: callers cannot use
# count, for_each or depends_on on it. See ../../docs/adr/0002.
provider "harbor" {
  url      = startswith(var.registry_url, "https://") ? var.registry_url : "https://${var.registry_url}"
  username = local.admin.username
  password = local.admin.password
  insecure = false
}
