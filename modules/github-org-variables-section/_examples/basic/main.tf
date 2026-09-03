terraform {
  required_version = ">= 1.5"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

module "org_variables" {
  source = "../../"

  config = jsondecode(file("${path.module}/config.json")).config
}

output "managed_variables" {
  value = module.org_variables.managed_variables
}

output "variable_ids" {
  value = module.org_variables.variable_ids
}
