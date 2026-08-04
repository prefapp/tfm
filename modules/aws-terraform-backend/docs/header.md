# **AWS Terraform Backend Module**

## Overview

This module provisions the AWS infrastructure typically required by a Terraform backend: an S3 bucket for state files, optional DynamoDB locking, and IAM policies/roles to access backend resources.

It also supports rendering an optional CloudFormation template and uploading it to S3 so another account can assume an administrative role for backend operations when needed.

The module is intended for shared platform/backend setups where consistency, least-privilege access, and safe state handling are important.

## Key Features

- **S3 state bucket**: Creates an S3 bucket with versioning, encryption, and public access blocking.
- **Optional DynamoDB locking**: Creates a lock table when `locks_table_name` is provided.
- **IAM backend access role and policies**: Manages backend IAM role plus attachable policy for extra roles.
- **Optional CloudFormation role template upload**: Generates and uploads role template to S3 when enabled.

## Basic Usage

### Backend with DynamoDB locking

```hcl
module "terraform_backend" {
  source = "git::https://github.com/prefapp/tfm.git//modules/aws-terraform-backend"

  tfstate_bucket_name   = "my-terraform-state-bucket"
  tfstate_object_prefix = "envs/prod/terraform.tfstate"
  locks_table_name      = "my-terraform-locks"

  aws_account_id                              = "123456789012"
  cloudformation_admin_role_for_client_account = "tf-backend-admin"
}
```

### Backend without DynamoDB locking (Terraform >= 1.11)

```hcl
module "terraform_backend" {
  source = "git::https://github.com/prefapp/tfm.git//modules/aws-terraform-backend"

  tfstate_bucket_name   = "my-terraform-state-bucket"
  tfstate_object_prefix = "envs/dev/terraform.tfstate"
  locks_table_name      = null

  aws_account_id                              = "123456789012"
  cloudformation_admin_role_for_client_account = "tf-backend-admin"
}
```
