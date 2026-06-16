# **AWS S3 Terraform Module**

## Overview

This module is designed to provision Amazon S3 buckets with advanced features such as cross-account (and cross-region) replication, default and custom lifecycle rules, and versioning. It also supports configuring buckets to allow replication from other sources and can be used with existing buckets to add replication and lifecycle management capabilities.

This module provisions the following resources:

- Amazon S3 bucket
- Replication configuration
- Lifecycle rules
- S3 permissions
- IAM role for replication

It is flexible, production-ready, and easy to integrate into existing infrastructures.

## Key Features

- **Amazon S3 bucket** provisioning
- **Replication** across accounts and regions
- **Lifecycle management** with default and custom rules
- **Versioning** support
- **IAM role** for replication
- **Support for existing buckets**

## ⚠️ Important: Replication Setup Order

When setting up S3 replication between buckets, follow this order to avoid failures:

1. **Create the destination bucket first** (without any replication source configuration)
   - Deploy the destination bucket without `s3_replication_source` parameter
   
2. **Apply replication source configuration** 
   - Deploy the source bucket with `s3_replication_destination` configured
   - This generates the IAM role and policies needed for replication
   
3. **Configure destination to accept replication**
   - Update the destination bucket Terraform with the `s3_replication_source` parameter
   - Use the role ARN generated from step 2
   - Apply the full Terraform configuration

This two-stage approach ensures that:
- IAM roles and policies are properly propagated across accounts
- The destination bucket exists before the source tries to replicate to it
- Cross-account permissions are correctly established before replication starts

## Basic Usage

### Minimal Example (S3 bucket)

```hcl
module "s3" {
  source = "git::https://github.com/prefapp/tfm.git//modules/aws-s3?ref=aws-s3-v0.1.1"
  bucket = "my-bucket"
}
```

### Enabling Replication to Another Bucket

```hcl
module "s3" {
  source = "git::https://github.com/prefapp/tfm.git//modules/aws-s3?ref=aws-s3-v0.1.1"
  bucket               = "my-bucket-origin"
  region               = "eu-west-1"
  s3_bucket_versioning = "Enabled"
  s3_replication_destination = {
    account       = "112233445566"
    bucket_arn    = "arn:aws:s3:::my-bucket-destination"
    storage_class = "STANDARD"
  }
}
```

## Enabling accept copy from other bucket

```hcl
module "s3" {
  source = "git::https://github.com/prefapp/tfm.git//modules/aws-s3?ref=aws-s3-v0.1.1"

  bucket               = "my-bucket-origin"
  region               = "eu-west-1"
  s3_bucket_versioning = "Enabled"
  s3_replication_source = {
    account  = "665544332211"
    role_arn = "arn:aws:iam::665544332211:role/my-bucket-origin-replication"
  }
}
```

## File Structure

The module is organized with the following directory and file structure:

.
├── .terraform-docs.yml          # terraform-docs configuration
├── README.md                    # Auto-generated documentation
├── _examples/
│   ├── basic/main.tf
│   ├── minimal_destination_source_and_destination/main.tf
│   ├── minimal_replication/main.tf
│   └── minimal_source/main.tf
├── data.tf                      # Data source for existing bucket
├── docs/
│   ├── footer.md
│   └── header.md
├── lifecycle.tf                 # Lifecycle configuration
├── local.tf                     # Locals (lifecycle rules merge)
├── main.tf                      # Bucket, ACL, policy, versioning
├── outputs.tf                   # Module outputs
├── replication.tf               # Replication + IAM
├── variables.tf                 # Input variables
└── versions.tf                  # Required providers
- **`data.tf`**: If bucket is not created, we use data of bucket
- **`lifecycle.tf`**: Lifecycle configurations for S3 buckets. 
- **`main.tf`**: Entry point that wires together all module components.
- **`outputs.tf`**: Outputs of module
- **`replication.tf`**: Replication configuration of bucket

