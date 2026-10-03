# **AWS Terraform Backend Terraform Module**

## Overview

This module provisions the AWS infrastructure used as a remote Terraform backend. It creates an S3 state bucket with server-side encryption, public-access protections, and optional versioning, then optionally creates a DynamoDB locks table for Terraform versions that use DynamoDB state locking.

It also creates an IAM backend access role and policies for reading and writing state. The role can trust the configured AWS account, optionally accept GitHub Actions OIDC tokens from one repository, and attach limited backend access to additional existing roles.

For multi-account bootstrapping, the module always renders a CloudFormation template for an administrator role in a client account and uploads it to S3 when `s3_bucket_cloudformation_role` is non-empty. Use it to establish a shared backend for development, staging, or production stacks; give each environment a distinct bucket name and object prefix where isolation is required.

## Key Features

- **Protected state bucket**: Creates an S3 bucket with AES-256 server-side encryption and blocks all public access.
- **State recovery**: Enables S3 versioning by default so previous state-object versions can be recovered.
- **Optional lock coordination**: Creates a pay-per-request DynamoDB table with `LockID` as its hash key when `locks_table_name` is set.
- **Scoped backend access**: Creates an IAM role and policies for state access, with optional GitHub Actions OIDC trust and attachments for existing roles.
- **Client-account bootstrap**: Renders a CloudFormation template that can create an administrator role in a client account and optionally uploads it to S3.

## Basic Usage

### Backend with S3 Lockfiles

Terraform 1.11 and later can use S3 lockfiles without a DynamoDB table. This configuration creates the backend access IAM resources without a DynamoDB table and adds GitHub Actions OIDC trust for the specified repository. Create the GitHub OIDC provider in the AWS account before enabling this option.

```hcl
module "terraform_backend" {
  source = "git::https://github.com/prefapp/tfm.git//modules/aws-terraform-backend"

  tfstate_bucket_name                       = "acme-production-tfstate"
  tfstate_object_prefix                     = "platform/terraform.tfstate"
  aws_account_id                            = "123456789012"
  cloudformation_admin_role_for_client_account = "TerraformClientAdmin"
  create_github_iam                         = true
  github_repository                         = "acme/platform-infrastructure"

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```

### Backend with DynamoDB State Locking

Use this configuration when consumers still require a DynamoDB locks table. The table uses on-demand capacity and the same tags as the state bucket.

```hcl
module "terraform_backend" {
  source = "git::https://github.com/prefapp/tfm.git//modules/aws-terraform-backend"

  tfstate_bucket_name                       = "acme-staging-tfstate"
  tfstate_object_prefix                     = "platform/terraform.tfstate"
  locks_table_name                          = "acme-staging-terraform-locks"
  aws_account_id                            = "123456789012"
  cloudformation_admin_role_for_client_account = "TerraformClientAdmin"

  tags = {
    Environment = "staging"
    ManagedBy   = "Terraform"
  }
}
```

## Importing Existing Infrastructure

Import the state bucket and its bucket-level configuration separately before applying this module. Replace the placeholders with the existing bucket name and table name.

```bash
terraform import module.terraform_backend.aws_s3_bucket.tfstate existing-tfstate-bucket
terraform import module.terraform_backend.aws_s3_bucket_versioning.this existing-tfstate-bucket
terraform import module.terraform_backend.aws_s3_bucket_server_side_encryption_configuration.this existing-tfstate-bucket
terraform import module.terraform_backend.aws_s3_bucket_public_access_block.this existing-tfstate-bucket
terraform import 'module.terraform_backend.aws_dynamodb_table.this[0]' existing-terraform-locks
```

Import the IAM resources independently when they already exist. Replace the placeholders with the existing names and policy ARNs.

```bash
terraform import module.terraform_backend.aws_iam_role.this terraform-backend-access-role
terraform import module.terraform_backend.aws_iam_policy.full arn:aws:iam::123456789012:policy/terraform-backend-access-role
terraform import module.terraform_backend.aws_iam_policy.limited arn:aws:iam::123456789012:policy/terraform-backend-access-role-extra
terraform import module.terraform_backend.aws_iam_role_policy_attachment.client 'terraform-backend-access-role/arn:aws:iam::123456789012:policy/terraform-backend-access-role'
terraform import 'module.terraform_backend.aws_iam_role_policy_attachment.extra_roles["existing-role"]' 'existing-role/arn:aws:iam::123456789012:policy/terraform-backend-access-role-extra'
terraform import 'module.terraform_backend.aws_s3_object.this[0]' 'template-bucket,cloudformation/rendered-template.yaml'
```

Import `aws_iam_role_policy_attachment.extra_roles` once for each value in `backend_extra_roles`. Import `aws_s3_object.this[0]` only when `s3_bucket_cloudformation_role` is non-empty.

## Delete Behavior

Destroying the module removes the state bucket and, when configured, the DynamoDB locks table and IAM access resources. By default, Terraform refuses to delete a non-empty state bucket. Setting `tfstate_force_destroy = true` permanently deletes all state objects and versions in that bucket; use it only when every consumer has migrated or been decommissioned.

The generated CloudFormation template grants `AdministratorAccess` to the client-account role. Review and apply that template outside this module only where that privilege is intended; removing this module does not delete a stack created from the template. The legacy `generate_cloudformation_role_for_client_account` and `upload_cloudformation_role` inputs do not alter the current module behavior.
