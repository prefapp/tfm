terraform {
  required_version = ">= 1.5"
  required_providers {
    github = {
      source  = "opentofu/github"
      version = "~> 6.0"
    }
  }
}
