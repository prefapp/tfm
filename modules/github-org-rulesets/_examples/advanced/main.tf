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

module "org_rulesets" {
  source = "../../"

  config = local.config
}

output "ruleset_ids" {
  value = module.org_rulesets.ruleset_ids
}

output "ruleset_etags" {
  value = module.org_rulesets.ruleset_etags
}
