# Example: Minimal GitHub Repository creation

terraform {
  required_version = ">= 1.5"
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}

provider "github" {
  token = var.github_token
}

module "test" {
  source = "./../.."

  config = {
    repository = {
      name        = "minimal-repo"
      description = "A minimal example of github-repo module usage."
      visibility  = "public"
    }

    default_branch = {
      branch = "main"
    }

    files = [
      {
        branch        = "main"
        file          = "README.md"
        content       = "# Minimal Repository\n\nThis is a minimal example of using the github-repo module."
        commitMessage = "Add README.md"
      }
    ]

    variables = [
      {
        variableName = "EXAMPLE_VARIABLE"
        value        = "example_value"
      }
    ]
  }
}
