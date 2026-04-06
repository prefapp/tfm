<!-- BEGIN_TF_DOCS -->
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

## User's Guide

> [https://docs.aws.amazon.com/singlesignon/latest/userguide/what-is.html](https://docs.aws.amazon.com/singlesignon/latest/userguide/what-is.html)

The SSO process is as follows:

  1. When a user logs into an application, the application generates an SSO token and sends an authentication request to the SSO service. 
  2. The service checks if the user was previously authenticated in the system. If so, it sends a confirmed authentication response to the application to grant access to the user. 
  3. If the user does not have a validated credential, the SSO service redirects the user to a central login system and prompts the user to submit his or her username and password.
  4. After submission, the service validates the user's credentials and sends the positive response to the application. 
  5. Otherwise, the user receives an error message and must re-enter the credentials. Multiple failed login attempts may result in the service blocking the user from further attempts for a fixed period of time.

## Security obligations

> [https://docs.aws.amazon.com/singlesignon/latest/userguide/security.html](https://docs.aws.amazon.com/singlesignon/latest/userguide/security.html)

  1. Only the owner of the organization (product, CTO, CEO...) should have the AWS root account.
  2. Keep users updated in their account. Do not leave inactive users enabled.
  3. Do not allow access to the AWS account through the root account.
  4. Be very careful with administrator permissions.
  5. Do not allow any user to embed credentials in code.
  6. Do not allow any user to lack MFA.
  7. Validate that IAM policies are not too permissive.
  8. Do not overlook any threat warnings that are presented to you.
  9. Rotate account passwords systematically and periodically.
  10. Force users to change their passwords as frequently.

## Recommendations on user migration from IAM

1. Write down in a list which users are to be migrated and which users are not to be migrated.
2. The users that will not be migrated must be disabled from the AWS organization by inactivating their access. Subsequently, once they have waited a reasonable time and confirmed that they have been migrated properly, they can be deleted.
3. Before disabling users, verify that they do not have any associated resources.
4. Standardize the user names, to improve readability and avoid duplicity problems.
5. Make sure that the users to be migrated have a valid e-mail address.
6. Organize users into groups, to make it easier to manage permissions.
7. Check if the users have administrator permissions, and if so, remove them.
8. Review the permissions of the associates, and if necessary, remove or restrict them.
9. Gradually migrate users, so that there are no availability problems.
10. Never start migrating users without being sure that the permissions are properly configured.

## SSO Terraform

The main document where [users](#users), [groups](#groups), [user/group association](#user) and [policies](#policies) should be entered is in sso.yaml.

### Users

Users must be in `users` with the following structure:

```yaml
users:
  - name: "userA"
    email: "test@test.test"
    fullname: "userA"
  - name: "userB"
    email: "test-2@test.test"
    fullname: "userB"
```

### Groups

The groups must be in `groups` with the following structure:

```yaml
  - name: "operadores-admin"
    description: "The operadores-admin group"
    users:
      - userA
      - userB
```

### `users>group` attachments

Users and groups must be associated using `attachments` with the following structure:

```yaml
attachments:
  "123456789012":
    permission-set-foo:
      groups:
        - groupA
      users:
        - userA
```

### Policies

Policies can be added in 3 different ways:

- [Customized policies](#customized-policies).
- [Managed policies](#managed-policies).
- [Inline policies](#inline-policies).

#### Customized policies
  - Policies (unmanaged).
  - They can be created in advance using terraform.
  - Only the policy name needs to be added.
  - It is not necessary to add the arn.
  - Are defined in `custom-policies` with the following structure:

```yaml
permission-sets:
  - name: "permission-set-foo"
    custom-policies:
      - name: "custom-policy-foo"
```

#### Managed policies

  - The arn of the policy must be added.
  - Are defined in `managed-policies` with the following structure:

```yaml
permission-sets:
  - name: "permission-set-foo"
    managed-policies:
      - "arn:aws:iam::aws:policy/AmazonS3FullAccess"
      - "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
```

#### Inline policies

Policies created in the same yaml document. ⚠️ NOT RECOMMENDED. Its use is for testing.
  - It is necessary to add the policy name.
  - It is necessary to add the content of the policy.
  - The content of the policy must be in json format and must be indented with 2 spaces.
  - Are defined in `inline-policies` with the following structure:

```yaml
permission-sets:
  - name: "permission-set-foo"
    inline-policies:
      - name: "inline-policy-foo"
        policy: |
          {
            "Version": "2012-10-17",
            "Statement": [
              {
                "Effect": "Allow",
                "Action": [
                  "ec2:Describe*"
                ],
                "Resource": "*"
              }
            ]
          }
```

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_time"></a> [time](#provider\_time) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_identitystore_group.groups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/identitystore_group) | resource |
| [aws_identitystore_group_membership.groups-users](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/identitystore_group_membership) | resource |
| [aws_identitystore_user.users](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/identitystore_user) | resource |
| [aws_ssoadmin_account_assignment.accounts-permissions-groups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_account_assignment) | resource |
| [aws_ssoadmin_account_assignment.accounts-permissions-users](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_account_assignment) | resource |
| [aws_ssoadmin_customer_managed_policy_attachment.permissions-custom-policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_customer_managed_policy_attachment) | resource |
| [aws_ssoadmin_managed_policy_attachment.permissions-managed-policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_managed_policy_attachment) | resource |
| [aws_ssoadmin_permission_set.permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_permission_set) | resource |
| [aws_ssoadmin_permission_set_inline_policy.permissions-inline-policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_permission_set_inline_policy) | resource |
| [time_sleep.wait_30seg](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_data_file"></a> [data\_file](#input\_data\_file) | absolute path of the data to use (in YAML format) | `string` | n/a | yes |
| <a name="input_identity_store_arn"></a> [identity\_store\_arn](#input\_identity\_store\_arn) | the arn of the SSO instance | `string` | n/a | yes |
| <a name="input_store_id"></a> [store\_id](#input\_store\_id) | the Identity store id | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_debug"></a> [debug](#output\_debug) | n/a |

## Additional configuration details

### YAML Configuration File

The module relies on a YAML file (specified via `data_file`) for all SSO configurations. Key sections include:
- **users**: List of users with name, email, and fullname.
- **groups**: List of groups with name, description, and associated users.
- **permission-sets**: Definitions for permission sets, including custom-policies, managed-policies, and inline-policies.
- **attachments**: Account-specific assignments of permission sets to groups and users.

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/aws-sso/_examples):

- [Basic](https://github.com/prefapp/tfm/tree/main/modules/aws-sso/_examples/basic) - Basic SSO setup with users, groups, and simple permission sets.
- [Advanced](https://github.com/prefapp/tfm/tree/main/modules/aws-sso/_examples/advanced) - Advanced configuration with mixed policies and multi-account assignments.

## Remote resources

- **AWS IAM Identity Center (SSO)**: [https://docs.aws.amazon.com/singlesignon/latest/userguide/what-is.html](https://docs.aws.amazon.com/singlesignon/latest/userguide/what-is.html)
- **AWS SSO Admin Resources**: [https://docs.aws.amazon.com/singlesignon/latest/developerguide/what-is-scim.html](https://docs.aws.amazon.com/singlesignon/latest/developerguide/what-is-scim.html)
- **Terraform AWS Provider**: [https://registry.terraform.io/providers/hashicorp/aws/latest/docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->