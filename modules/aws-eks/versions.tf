/*
  This Terraform script is used to specify the required versions for Terraform 
  and the providers used in the project. 

  The AWS provider is required to interact with AWS resources, the Kubernetes 
  provider is used to manage Kubernetes resources, the Time provider is used for 
  time-based resources, and the TLS provider is used for resources related to 
  TLS certificates. 
*/

terraform {

  required_version = ">= 1.5"

  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.83"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35"
    }

    time = {
      source  = "hashicorp/time"
      version = "~> 0.12"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }

  }

}
