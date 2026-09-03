terraform {
  required_version = ">= 1.5"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

module "org_settings" {
  source = "../../"

  config = jsondecode(file("${path.module}/config.json")).config
}

output "organization_settings_id" {
  value = module.org_settings.organization_settings_id
}
