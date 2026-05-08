terraform {
  required_version = ">= 1.5.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

module "repo_secrets" {
  source = "../.."

  config = var.config # Terraform automatically loads terraform.tfvars.json
}
