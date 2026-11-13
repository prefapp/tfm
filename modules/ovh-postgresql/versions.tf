terraform {
  required_version = ">= 1.5.0"
  required_providers {
    ovh = {
      source = "ovh/ovh"
      # Avoid the built-in avnadmin adoption panic regressed in v2.23.0.
      # Widen this range after the v2.25.0 fix is published in the Registry.
      version = ">= 2.22.0, < 2.23.0"
    }
  }
}

# The OKMS provider stores version.data in Terraform state even though it is sensitive.
# Use an encrypted, access-restricted state backend for this module.
