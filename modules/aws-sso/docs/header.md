# AWS SSO Terraform Module

## Overview

This Terraform module provisions and manages AWS Single Sign-On (SSO), now known as IAM Identity Center, resources in a declarative manner.
It handles the creation of users and groups within the Identity Store, defines permission sets with various policy attachments (including custom-managed, AWS-managed, and inline policies), and assigns these permission sets to specific AWS accounts for both groups and users.
The module reads configurations from a YAML file, allowing for centralized management of identity and access controls across AWS environments.
By leveraging Terraform's infrastructure-as-code approach, this module ensures consistent and reproducible SSO setups, reducing manual errors and simplifying compliance. It supports complex scenarios such as multi-account permissions, group-based access control, and policy customizations, making it suitable for organizations scaling their AWS presence. Key integrations include dependencies on AWS SSO admin resources and Identity Store, with built-in waits to handle eventual consistency in AWS services.
This module is ideal for development, staging, and production environments where fine-grained access management is required. It promotes best practices like least privilege through permission sets and helps migrate from traditional IAM users to centralized SSO identities.

## Key Features

- **User and Group Management**: Creates and manages users and groups in AWS Identity Store, including user-group memberships for organized access control.
- **Permission Set Configuration**: Supports multiple policy types including custom-managed policies (by name/path), AWS-managed policies (by ARN), and inline policies (defined in YAML).
- **Account Assignments**: Assigns permission sets to AWS accounts for groups and users, enabling multi-account access management.
- **YAML-Driven Configuration**: All definitions (users, groups, permissions, attachments) are specified in a single YAML file for simplicity and version control.
- **Dependency Management**: Includes explicit dependencies and time sleeps to ensure resources are provisioned in the correct order, handling AWS API eventual consistency.

## Basic Usage

### Standard Configuration with YAML File

This example shows a basic module invocation using a YAML file to define users, groups, permission sets, and account attachments.

```hcl
module "aws_sso" {
  source = "github.com/prefapp/tfm/modules/aws-sso?ref=v0.6.1"  # Use the latest version or a specific tag

  data_file           = "path/to/sso.yaml"
  identity_store_arn  = "arn:aws:sso:::instance/ssoins-1234567890abcdef"
  store_id            = "d-1234567890"
}
```

### Advanced Configuration with Mixed Policies

This example demonstrates defining a permission set with a combination of custom, managed, and inline policies in the YAML file.

```yaml
# Example sso.yaml snippet
permission-sets:
  - name: "permission-set-advanced"
    custom-policies:
      - name: "custom-policy-example"
    managed-policies:
      - "arn:aws:iam::aws:policy/AmazonS3FullAccess"
    inline-policies:
      - name: "inline-policy-example"
        policy: |
          {
            "Version": "2012-10-17",
            "Statement": [
              {
                "Effect": "Allow",
                "Action": ["ec2:Describe*"],
                "Resource": "*"
              }
            ]
          }
```
```hcl
module "aws_sso" {
  source = "github.com/prefapp/tfm/modules/aws-sso?ref=v0.6.1"

  data_file           = "path/to/sso.yaml"
  identity_store_arn  = "arn:aws:sso:::instance/ssoins-1234567890abcdef"
  store_id            = "d-1234567890"
}
```
## File Structure

The module is organized with the following directory and file structure:

```
aws-sso/
├── .terraform-docs.yml       # terraform-docs configuration
├── attachments.tf            # Account assignment resources for groups and users
├── main.tf                   # Core user and group management resources
├── outputs.tf                # Output value definitions
├── permissions.tf            # Permission set definitions and policy attachments
├── variables.tf              # Input variable definitions
├── CHANGELOG.md              # Release history (auto-generated)
├── docs/                     # Documentation files
│   ├── header.md             # This file - module overview and usage
│   └── footer.md             # Additional resources and support
└── _examples/                # Usage examples for different scenarios
    ├── basic/                # Basic SSO setup example
    │   └── main.tf
    └── advanced/             # Advanced permissions example
        └── main.tf
```

**Key Files**:

- **attachments.tf**: Defines account assignments for permission sets to groups and users across AWS accounts.
- **main.tf**: Handles creation of users, groups, and group memberships in the Identity Store.
- **permissions.tf**: Manages permission sets and attachments for custom, managed, and inline policies, including time sleeps for dependencies.
- **variables.tf**: Input variables for YAML data file, Identity Store ARN, and Store ID.
- **outputs.tf**: Exports debug output for user-group associations.
