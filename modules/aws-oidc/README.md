<!-- BEGIN_TF_DOCS -->
# **AWS OIDC Terraform Module**

## Overview

This module enables **OIDC-based authentication between GitHub and an AWS account**, allowing GitHub Actions workflows to **push Docker images to Amazon ECR repositories** without using long-lived AWS credentials.

Access is controlled through the `subs` variable, which defines which GitHub repositories, branches, or tags are allowed to assume the IAM role.

---

## Key Features

- **AWS IAM OIDC Provider**  
  Creates an IAM OIDC provider using GitHub’s OIDC endpoint and thumbprint.

- **IAM Policy for ECR**  
  Creates an IAM policy with the required permissions to push images to Amazon ECR.

- **IAM Role**  
  Creates an IAM role that can be assumed via OIDC and is attached to the ECR policy.

---

## Basic Usage

### Minimal Example

```hcl
module "oidc" {
  source = "git::https://github.com/prefapp/tfm.git//modules/aws-oidc"
  organization = "1111111111111"
  subs = [
    "repo:ORG/repo-a:*",
    "repo:ORG/repo-b:*",
    "repo:ORG-B/repo-a:ref:refs/heads/dev",
    "repo:ORG-B/repo-z:ref:refs/tags/*"
  ]
}
```

---

### Allow uploads only from specific tags

```hcl
module "oidc" {
  source = "git::https://github.com/prefapp/tfm.git//modules/aws-oidc"
  organization = "1111111111111"
  subs = [
    "repo:ORG-B/repo-z:ref:refs/tags/*"
  ]
}
```

---

### Allow uploads only from a specific branch

```hcl
module "oidc" {
  source = "git::https://github.com/prefapp/tfm.git//modules/aws-oidc"
  organization = "1111111111111"
  subs = [
    "repo:ORG-B/repo-a:ref:refs/heads/dev"
  ]
}
```

---

## File Structure

The module is organized as follows:

```
├── main.tf
├── outputs.tf
├── README.md
└── variables.tf
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.4 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_openid_connect_provider.gh_oidc_entity_provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_role.gh_oidc_rol](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.gh_oidc_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_region"></a> [region](#input\_region) | Region to deploy resources | `string` | `"eu-west-1"` | no |
| <a name="input_subs"></a> [subs](#input\_subs) | List of GitHub OIDC subject claims allowed to assume the role | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_oidc_role_arn"></a> [oidc\_role\_arn](#output\_oidc\_role\_arn) | Role needed to authenticate by the workflow |

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/aws-oidc/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/aws-oidc/_examples/basic) - Simple configuration.
- [specific\_tags](https://github.com/prefapp/tfm/tree/main/modules/aws-oidc/_examples/specific-tags) - Demonstrates tag-based filtering for OIDC-authenticated ECR access.
- [specific\_branch](https://github.com/prefapp/tfm/tree/main/modules/aws-oidc/_examples/specific-branch) - Demonstrates branch-based filtering for OIDC-authenticated ECR access.

## Remote resources

- **OIDC**: [https://docs.aws.amazon.com/es_es/IAM/latest/UserGuide/id_roles_providers_oidc.html](https://docs.aws.amazon.com/es_es/IAM/latest/UserGuide/id_roles_providers_oidc.html)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->