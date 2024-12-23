terraform {
  required_version = ">= 1.7.0"
  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = ">= 1.23.0"
    }
  }
}
