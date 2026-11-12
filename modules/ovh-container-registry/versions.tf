terraform {
  required_version = ">= 1.5.0"
  required_providers {
    ovh = {
      source  = "ovh/ovh"
      version = ">= 2.24.0, < 3.0.0"
    }
  }
}
