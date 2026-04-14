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
  rulesets = jsondecode(file("${path.module}/rulesets.json"))
}

module "org_rulesets" {
  source = "../../"

  rulesets = local.rulesets
}

output "ruleset_ids" {
  value = module.org_rulesets.ruleset_ids
}
