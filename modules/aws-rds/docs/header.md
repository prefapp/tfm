# **AWS RDS Terraform Module**

## Overview

This Terraform module provisions and manages AWS RDS (Relational Database Service) instances with comprehensive configuration options and security best practices. It simplifies the deployment of production-ready database instances by handling associated resources such as security groups, subnet groups, and credential management.

The module supports multiple database engines including PostgreSQL, MySQL, and MariaDB, providing flexibility for different application requirements. It offers seamless integration with AWS Systems Manager Parameter Store and AWS Secrets Manager for secure credential storage and management. Additionally, it supports native RDS-managed password rotation through Secrets Manager for enhanced security compliance.

Built with operational excellence in mind, the module enables customization of networking, backup strategies, performance monitoring, and security configurations, making it suitable for development, staging, and production environments.

## Key Features

- **Multi-Engine Support**: Compatible with PostgreSQL, MySQL, MariaDB, and other RDS-supported database engines with configurable versions and parameter groups.
- **Flexible Credential Management**: Choose between AWS Systems Manager Parameter Store, AWS Secrets Manager, or native RDS-managed Secrets Manager with automatic password rotation.
- **Advanced Networking Configuration**: Deploy instances using VPC/subnet IDs or tags, with customizable security groups and additional security rules for fine-grained access control.
- **High Availability & Backup**: Configurable Multi-AZ deployments, automated backups with retention policies, and customizable maintenance windows for production workloads.
- **Performance Monitoring**: Built-in support for Performance Insights with configurable retention periods to monitor and optimize database performance.
- **Storage Flexibility**: Supports multiple storage types (gp2, gp3, io1, standard) with autoscaling capabilities and provisioned IOPS for demanding workloads.

## Basic Usage

### PostgreSQL Database

```hcl
module "rds_postgres" {
  source = "git::https://github.com/prefapp/tfm.git//modules/aws-rds"

  region        = "eu-west-1"
  environment   = "dev"
  db_identifier = "main"

  vpc_tag_name    = "k8s-org-vpc"
  subnet_tag_name = "private"

  engine         = "postgres"
  engine_version = "17.2"
  family         = "postgres17"
  db_port        = 5432
  db_name        = "main"
  db_username    = "postgres"

  instance_class    = "db.t3.micro"
  storage_type      = "gp3"
  allocated_storage = 50

  manage_master_user_password = false
}
```

### MySQL Database

```hcl
module "rds_mysql" {
  source = "git::https://github.com/prefapp/tfm.git//modules/aws-rds"

  region        = "eu-west-1"
  environment   = "pro"
  db_identifier = "myapp"

  vpc_tag_name    = "main-vpc"
  subnet_tag_name = "rds"

  engine         = "mysql"
  engine_version = "8.0"
  family         = "mysql8.0"
  db_port        = 3306
  db_name        = "production"
  db_username    = "admin"

  instance_class    = "db.t3.small"
  storage_type      = "gp3"
  allocated_storage = 100

  manage_master_user_password = false
}
```

## File Structure

The module is organized with the following directory and file structure:

```
aws-rds/
├── main.tf                   # Core RDS instance and DB subnet group resources
├── variables.tf              # Input variable definitions
├── outputs.tf                # Output value definitions
├── locals.tf                 # Local value computations and logic
├── _examples/                # Usage examples for different scenarios
│   ├── mysql/                # MySQL database example
│   ├── postgres/             # PostgreSQL database example
│   ├── secret-manager/       # Secrets Manager integration
│   └── ssm-parameter-store/  # SSM Parameter Store integration
└── docs/                     # Documentation files
    ├── header.md             # This file - module overview and usage
    └── footer.md             # Additional resources and support
```

**Key Files**:

- **main.tf**: Defines the RDS instance, security groups, subnet groups, and SSM/Secrets Manager resources.
- **variables.tf**: Comprehensive input variables for networking, database configuration, credential management, and security settings.
- **outputs.tf**: Exports instance endpoints, credential references, and resource identifiers for downstream modules.
- **locals.tf**: Contains conditional logic for credential management (SSM vs Secrets Manager vs RDS-managed) and resource naming conventions.
