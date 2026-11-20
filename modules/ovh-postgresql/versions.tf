terraform {
  required_version = ">= 1.9.0"
  required_providers {
    ovh = {
      source  = "ovh/ovh"
      version = "~> 2.25"
    }
  }
}

# The OKMS provider stores version.data in Terraform state even though it is sensitive.
# Use an encrypted, access-restricted state backend for this module.
