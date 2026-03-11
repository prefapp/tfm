terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

module "membership" {
  source = "../../"

  config = jsondecode(file("${path.module}/config.json")).config
}

output "user_managed" {
  value = module.membership.organization_membership
}

output "team_memberships" {
  value = module.membership.team_memberships
}
