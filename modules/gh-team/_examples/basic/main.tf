terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

module "example_team" {
  source = "../../"   # points to the module root

  config = jsondecode(file("${path.module}/team-config.json"))
}

output "team_id" {
  value = module.example_team.team_id
}
