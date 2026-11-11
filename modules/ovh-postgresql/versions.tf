terraform {
  required_version = ">= 1.5.0"
  required_providers {
    ovh = {
      source  = "ovh/ovh"
      version = ">= 2.24.0, < 3.0.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.4"
    }
  }
}

# The OKMS provider stores version.data in Terraform state even though it is sensitive.
# Use an encrypted, access-restricted state backend for this module.
