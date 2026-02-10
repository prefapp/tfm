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

## Basic Usage

### Minimal Example (S3 bucket)

```hcl
module "s3" {
  source = "github.com/prefapp/tfm/modules/aws-s3"
  bucket = "my-bucket"
}
```

### Enabling Replication to Another Bucket

```hcl
module "s3" {
  source               = "github.com/prefapp/tfm/modules/aws-s3"
  bucket               = "my-bucket-origin"
  region               = "eu-west-1"
  s3_bucket_versioning = "Enabled"
  s3_replication_destination = {
    account       = "1122334455"
    bucket_arn    = "arn:aws:s3:::my-bucket-destination"
    storage_class = "STANDARD"
  }
}
```

## Enabling accept copy from other bucket

```hcl
module "s3" {
  source = "github.com/prefapp/tfm/modules/aws-s3"

  bucket               = "my-bucket-origin"
  region               = "eu-west-1"
  s3_bucket_versioning = "Enabled"
  s3_replication_source = {
    account  = "5544332211"
    role_arn = "arn:aws:iam::5544332211:role/my-bucket-origin-replication"
  }
}
```

## File Structure

The module is organized with the following directory and file structure:

```
├── data.tf
├── lifecycle.tf
├── local.tf
├── main.tf
├── outputs.tf
├── replication.tf
└── variables.tf
```
- **`data.tf`**: If bucket is not created, we use data of bucket
- **`lifecycle.tf`**: Lifecycle configurations for S3 buckets. 
- **`main.tf`**: Entry point that wires together all module components.
- **`outputs.tf`**: Outputs of module
- **`replication.tf`**: Replication configuration of bucket

