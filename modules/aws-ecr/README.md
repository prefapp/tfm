# AWS ECR Terraform Module

> [!WARNING]
> This directory **DOES NOT contain a Terraform module managed by Prefapp**. For managing Amazon Elastic Container Registry (ECR) repositories on AWS, you **must use directly the official AWS community module**: [terraform-aws-modules/ecr/aws](https://registry.terraform.io/modules/terraform-aws-modules/ecr/aws/latest).
>
> This document provides only reference information about the official module you should use in your projects.

## Overview

The official AWS ECR Terraform module provides a comprehensive solution for creating and managing Amazon Elastic Container Registry resources. This module handles the creation of both private and public ECR repositories, lifecycle policies, registry scanning configurations, replication rules, and pull-through cache configurations with best practices built-in.

## Key Features

- **Private & Public Repositories**: Create both private and public ECR repositories
- **Lifecycle Policies**: Automated image cleanup with customizable lifecycle rules
- **Repository Policies**: Fine-grained IAM policies for repository access control
- **Registry Scanning**: Enhanced and basic scanning configurations with custom scan rules
- **Replication**: Cross-region and cross-account repository replication
- **Pull Through Cache**: Configure pull-through cache rules for upstream registries (Docker Hub, ECR Public, etc.)
- **Image Scanning**: Automated scanning on push with configurable settings
- **Tag Mutability**: Control image tag mutability with exclusion filters
- **KMS Encryption**: Support for KMS-encrypted repositories

## Basic Usage

### Private Repository

```hcl
module "ecr" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name = "private-example"

  repository_read_write_access_arns = ["arn:aws:iam::012345678901:role/terraform"]

  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 30
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
```

### Public Repository

```hcl
module "public_ecr" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name = "public-example"
  repository_type = "public"

  repository_read_write_access_arns = ["arn:aws:iam::012345678901:role/terraform"]

  public_repository_catalog_data = {
    description       = "Docker container for some things"
    about_text        = file("${path.module}/files/ABOUT.md")
    usage_text        = file("${path.module}/files/USAGE.md")
    operating_systems = ["Linux"]
    architectures     = ["x86"]
    logo_image_blob   = filebase64("${path.module}/files/clowd.png")
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
```

## Advanced Features

### Registry Scanning Configuration

Configure enhanced scanning with custom rules:

```hcl
module "ecr_registry" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name = "registry-example"
  create_repository = false

  manage_registry_scanning_configuration = true
  registry_scan_type                     = "ENHANCED"

  registry_scan_rules = [
    {
      scan_frequency = "SCAN_ON_PUSH"
      filter = [
        {
          filter      = "example1"
          filter_type = "WILDCARD"
        }
      ]
    },
    {
      scan_frequency = "CONTINUOUS_SCAN"
      filter = [
        {
          filter      = "example"
          filter_type = "WILDCARD"
        }
      ]
    }
  ]
}
```

### Registry Replication

Configure cross-region and cross-account replication:

```hcl
module "ecr_registry" {
  source = "terraform-aws-modules/ecr/aws"

  create_repository = false
  create_registry_replication_configuration = true

  registry_replication_rules = [
    {
      destinations = [
        {
          region      = "us-west-2"
          registry_id = "012345678901"
        },
        {
          region      = "eu-west-1"
          registry_id = "012345678901"
        }
      ]
      repository_filters = [
        {
          filter      = "prod-microservice"
          filter_type = "PREFIX_MATCH"
        }
      ]
    }
  ]
}
```

### Pull Through Cache Rules

Configure pull-through cache for upstream registries:

```hcl
module "ecr_registry" {
  source = "terraform-aws-modules/ecr/aws"

  create_repository = false

  registry_pull_through_cache_rules = {
    pub = {
      ecr_repository_prefix = "ecr-public"
      upstream_registry_url = "public.ecr.aws"
    }
    dockerhub = {
      ecr_repository_prefix = "dockerhub"
      upstream_registry_url = "registry-1.docker.io"
      credential_arn        = "arn:aws:secretsmanager:us-east-1:123456789:secret:ecr-pullthroughcache/dockerhub"
    }
  }
}
```

### Lifecycle Policies

Automated image cleanup with lifecycle policies:

```hcl
module "ecr" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name = "my-app"

  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 30 tagged images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = 30
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Keep untagged images for 7 days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 7
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
```

## Repository Configuration Options

### Image Tag Mutability

Control whether image tags can be overwritten:

```hcl
module "ecr" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name               = "my-app"
  repository_image_tag_mutability = "IMMUTABLE"  # or "MUTABLE"
}
```

### Image Scanning

Enable automatic image scanning on push:

```hcl
module "ecr" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name              = "my-app"
  repository_image_scan_on_push = true
}
```

### KMS Encryption

Use KMS encryption for repository images:

```hcl
module "ecr" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name          = "my-app"
  repository_encryption_type = "KMS"
  repository_kms_key       = "arn:aws:kms:us-east-1:012345678901:key/12345678-1234-1234-1234-123456789012"
}
```

## Access Control

### IAM Role Access

Grant read/write or read-only access to IAM roles:

```hcl
module "ecr" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name = "my-app"

  # Read/write access
  repository_read_write_access_arns = [
    "arn:aws:iam::012345678901:role/deploy-role"
  ]

  # Read-only access
  repository_read_access_arns = [
    "arn:aws:iam::012345678901:role/developer-role"
  ]

  # Lambda read access
  repository_lambda_read_access_arns = [
    "arn:aws:iam::012345678901:role/lambda-execution-role"
  ]
}
```

## Examples

For detailed examples, refer to the [official module examples](https://github.com/terraform-aws-modules/terraform-aws-ecr/tree/master/examples):

- [Complete](https://github.com/terraform-aws-modules/terraform-aws-ecr/tree/master/examples/complete) - Comprehensive example with multiple features
- [Repository Template](https://github.com/terraform-aws-modules/terraform-aws-ecr/tree/master/examples/repository-template) - Template for creating multiple similar repositories

## Remote resources

- **Official Module**: [terraform-aws-modules/ecr/aws](https://registry.terraform.io/modules/terraform-aws-modules/ecr/aws/latest)
- **GitHub Repository**: [terraform-aws-modules/terraform-aws-ecr](https://github.com/terraform-aws-modules/terraform-aws-ecr)
- **Full Documentation**: [README.md](https://github.com/terraform-aws-modules/terraform-aws-ecr/blob/master/README.md)

## Support

For issues, questions, or contributions related to this module, please visit the [official repository's issue tracker](https://github.com/terraform-aws-modules/terraform-aws-ecr/issues).

---

**Note**: Always refer to the [official module documentation](https://github.com/terraform-aws-modules/terraform-aws-ecr) for the most up-to-date information.
