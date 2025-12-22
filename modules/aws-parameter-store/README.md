<!-- BEGIN_TF_DOCS -->
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

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.parameter_store](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.parameter_store](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.parameter_store](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_ssm_parameter.secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_eks_cluster.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_account"></a> [aws\_account](#input\_aws\_account) | AWS Account ID | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster | `any` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | Environment | `string` | n/a | yes |
| <a name="input_parameters"></a> [parameters](#input\_parameters) | n/a | `any` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"eu-west-1"` | no |
| <a name="input_services"></a> [services](#input\_services) | n/a | <pre>map(object({<br/>    name = string<br/>  }))</pre> | `{}` | no |

## Outputs

No outputs.

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/aws-parameter-store/_examples):

- [Basic](https://github.com/prefapp/tfm/tree/main/modules/aws-parameter-store/_examples/basic) - Basic

## Resources

- **Parameter store**: [https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html)
- **Terraform AWS Provider**: [https://registry.terraform.io/providers/hashicorp/aws/latest](https://registry.terraform.io/providers/hashicorp/aws/latest)

## Support

For issues, questions, or contributions related to this module, please visit the repository’s issue tracker: [https://github.com/prefapp/tfm/issues](https://github.com/prefapp/tfm/issues)
<!-- END_TF_DOCS -->