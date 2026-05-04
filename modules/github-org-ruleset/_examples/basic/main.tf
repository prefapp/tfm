terraform {
  required_version = ">= 1.5"
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

locals {
  config = jsondecode(file("${path.module}/config.json")).config
}

module "org_ruleset" {
  source = "../../"

  config = local.config
}

output "ruleset_id" {
  value = module.org_ruleset.ruleset_id
}
