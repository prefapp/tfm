# AWS parameter-store Terraform Module

## Overview

This module provisions the necessary IAM permissions to allow an EKS cluster to securely read secrets from AWS Systems Manager Parameter Store. Permissions are granted only to the specific services you define, enabling fine-grained access control for Kubernetes workloads that require sensitive configuration data stored in Parameter Store.


## Key Features

- **EKS Integration**: Grants Kubernetes workloads running on Amazon EKS the required access to AWS Systems Manager Parameter Store.

- **IAM Role and Policy Management**: Automatically creates and configures IAM roles and policies to securely allow read access to Parameter Store secrets.

- **Parameter Store Access**: Enables secure retrieval of sensitive configuration data and secrets from Parameter Store for your EKS workloads. Optionally, this module can also create the required secrets in Parameter Store.

## Basic Usage

### Minimal usage

``` hcl
module "parameter-store" {
  source = "github.com/prefapp/tfm/modules/aws-parameter-store?ref=aws-parameter-store-vx.y.z"

  cluster_name = "common-env"
  env          = "dev"
  region       = "eu-west-1"
  aws_account  = "012456789"
  parameters   = {}
  services = {
    github = {
      name = "github"
    }
  }
}

```