# EKS Module

This Terraform module simplifies the creation and configuration of an **Amazon Elastic Kubernetes Service (EKS)** cluster on AWS. Below is a description of the main features and components of the module:

- **VPC Configuration**: The module provides a pre-configured VPC with public and private subnets, facilitating the creation of secure and isolated environments.
- **EKS Configuration**: Allows the creation of an EKS cluster with custom options such as the _Kubernetes_ version, API access, and efficient node management.
- **Node Group Management**: Facilitates the creation and management of node groups with various configurations, such as instance types, desired, minimum, and maximum capacity, and tags.
- **IAM Authentication and Authorization**: Offers flexibility in managing IAM users and roles for authentication in the EKS cluster, allowing the addition of additional IAM users and roles.
- **Addon Configuration**: Includes options to enable essential addons such as _CoreDNS_, _kube-proxy_, and _VPC CNI_, as well as the ability to add custom addons.
- **Additional Security**: Allows the addition of extra security rules to control traffic, as well as the creation of specific IAM roles for services like _ALB Ingress Controller_, _CloudWatch_, _EFS CSI Driver_, and _ExternalDNS_.

## Module Usage

- **Variable Configuration**: Fill in the variables in the `variables.tf` file according to the specific requirements of your environment, such as the AWS region, _Kubernetes_ version, and VPC configuration.
- **Terraform Execution**: Run `terraform init` and `terraform apply` to create and configure the EKS cluster. Terraform will manage the creation of resources on AWS based on the provided configuration.
- **Advanced Customization**: Adjust the configuration as needed, such as adding IAM users and roles, tweaking node settings, and enabling additional addons.
- **Scalability and Maintenance**: Utilize Terraform's capabilities to scale and maintain the EKS cluster easily as environment requirements evolve.

## File Structure
.
├── data.tf
├── locals.tf
├── main.tf
├── modules
│   ├── alb
│   │   ├── iam.tf
│   │   ├── main.tf
│   │   └── variables.tf
│   ├── cloudwatch
│   │   ├── iam.tf
│   │   ├── main.tf
│   │   └── variables.tf
│   ├── efs_csi_driver
│   │   ├── iam.tf
│   │   ├── main.tf
│   │   └── variables.tf
│   ├── external_dns
│   │   ├── iam.tf
│   │   ├── main.tf
│   │   └── variables.tf
│   └── parameter_store
│       ├── iam.tf
│       ├── main.tf
│       └── variables.tf
├── outputs.tf
├── providers.tf
├── README.md
└── variables.tf


- **`data.tf`**: This file usually contains data source definitions that retrieve existing information from the infrastructure. It could include information about existing resources in the cloud provider (AWS in this case).

- **`locals.tf`**: In this file, local variables are defined to store intermediate values or complex calculations. This helps keep the main code clean and readable.

- **`main.tf`**: This is the main Terraform file where the primary configuration of resources and modules is defined. This is where infrastructure resources are instantiated and configured.

- **`modules`**: This directory contains subdirectories for different reusable modules. Each subdirectory represents a specific module, such as `alb`, `cloudwatch`, `efs_csi_driver`, `external_dns`, and `parameter_store`. Each of these modules has its own `main.tf`, `variables.tf`, and `iam.tf` files containing specific configuration for that module.

    - **`iam.tf`**: This file generally contains the configuration of IAM roles and policies necessary for the respective module.

    - **`main.tf`**: Here, the main configuration of the module is defined. It may include specific resources for the module and any related configuration.

    - **`variables.tf`**: Contains the definition of module-specific variables that can be used to parameterize the configuration.

- **`outputs.tf`**: In this file, Terraform outputs are defined. Outputs are values that can be useful for other components of the system or for users utilizing the Terraform code.

- **`providers.tf`**: This file specifies the Terraform providers to be used in the project. For example, the AWS provider would be defined here along with any associated specific configurations.

- **`README.md`**: Project documentation that may contain information on how to use the code, prerequisites, and any other relevant information.

- **`variables.tf`**: Contains variable definitions used in the `main.tf` file and in the modules. Variables are used to parameterize the configuration and make it more flexible.


## Useful Links
- Terraform: https://www.terraform.io/
- Amazon Elastic Kubernetes Service (EKS): https://aws.amazon.com/eks/
- Terraform AWS Provider: https://registry.terraform.io/providers/hashicorp/aws/latest
- Terraform Kubernetes Provider: https://registry.terraform.io/providers/hashicorp/kubernetes/latest
- Kubernetes: https://kubernetes.io/
- Terraform-aws-modules/eks/aws Module: https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest
- Terraform-aws-modules/vpc/aws Module: https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.57 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.23 |
| <a name="requirement_time"></a> [time](#requirement\_time) | ~> 0.9 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.57 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alb"></a> [alb](#module\_alb) | ./modules/alb | n/a |
| <a name="module_cloudwatch"></a> [cloudwatch](#module\_cloudwatch) | ./modules/cloudwatch | n/a |
| <a name="module_efs_csi_driver"></a> [efs\_csi\_driver](#module\_efs\_csi\_driver) | ./modules/efs_csi_driver | n/a |
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | 19.20.0 |
| <a name="module_external_dns"></a> [external\_dns](#module\_external\_dns) | ./modules/external_dns | n/a |
| <a name="module_parameter_store"></a> [parameter\_store](#module\_parameter\_store) | ./modules/parameter_store | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster_auth.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_ingress_enabled"></a> [alb\_ingress\_enabled](#input\_alb\_ingress\_enabled) | Create resources for alb-ingress | `bool` | `false` | no |
| <a name="input_aws_auth_roles"></a> [aws\_auth\_roles](#input\_aws\_auth\_roles) | Additional IAM roles to add to the aws-auth configmap. | <pre>list(object({<br><br>    rolearn = string<br><br>    username = string<br><br>    groups = list(string)<br><br>  }))</pre> | `[]` | no |
| <a name="input_aws_auth_users"></a> [aws\_auth\_users](#input\_aws\_auth\_users) | Additional IAM users to add to the aws-auth configmap. | <pre>list(object({<br><br>    userarn = string<br><br>    username = string<br><br>    groups = list(string)<br><br>  }))</pre> | `[]` | no |
| <a name="input_cloudwatch_enabled"></a> [cloudwatch\_enabled](#input\_cloudwatch\_enabled) | Create resources for cloudwatch | `bool` | `false` | no |
| <a name="input_cloudwatch_log_group_retention_in_days"></a> [cloudwatch\_log\_group\_retention\_in\_days](#input\_cloudwatch\_log\_group\_retention\_in\_days) | Number of days to retain log events | `number` | `14` | no |
| <a name="input_cluster_addons"></a> [cluster\_addons](#input\_cluster\_addons) | n/a | `any` | n/a | yes |
| <a name="input_cluster_encryption_config"></a> [cluster\_encryption\_config](#input\_cluster\_encryption\_config) | Cluster encryption config | `any` | `{}` | no |
| <a name="input_cluster_endpoint_private_access"></a> [cluster\_endpoint\_private\_access](#input\_cluster\_endpoint\_private\_access) | Indicates whether or not the Amazon EKS private API server endpoint is enabled. Default is true. | `bool` | `true` | no |
| <a name="input_cluster_endpoint_public_access"></a> [cluster\_endpoint\_public\_access](#input\_cluster\_endpoint\_public\_access) | Indicates whether or not the Amazon EKS public API server endpoint is enabled. Default is false. | `bool` | `false` | no |
| <a name="input_cluster_iam_role_arn"></a> [cluster\_iam\_role\_arn](#input\_cluster\_iam\_role\_arn) | n/a | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | n/a | `string` | n/a | yes |
| <a name="input_cluster_security_group_id"></a> [cluster\_security\_group\_id](#input\_cluster\_security\_group\_id) | n/a | `string` | n/a | yes |
| <a name="input_cluster_tags"></a> [cluster\_tags](#input\_cluster\_tags) | n/a | `map(any)` | n/a | yes |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | n/a | `string` | n/a | yes |
| <a name="input_create_cluster_iam_role"></a> [create\_cluster\_iam\_role](#input\_create\_cluster\_iam\_role) | Create IAM role for cluster | `bool` | `false` | no |
| <a name="input_create_kms_key"></a> [create\_kms\_key](#input\_create\_kms\_key) | Create KMS key for cluster | `bool` | `true` | no |
| <a name="input_efs_driver_enabled"></a> [efs\_driver\_enabled](#input\_efs\_driver\_enabled) | Create resources for efs-driver | `bool` | `false` | no |
| <a name="input_enable_irsa"></a> [enable\_irsa](#input\_enable\_irsa) | Enable IRSA | `bool` | `false` | no |
| <a name="input_external_dns_enabled"></a> [external\_dns\_enabled](#input\_external\_dns\_enabled) | Create resources for external-dns | `bool` | `false` | no |
| <a name="input_fargate_profiles"></a> [fargate\_profiles](#input\_fargate\_profiles) | Define dynamically the different fargate profiles | <pre>list(object({<br><br>    name = string<br><br>    selectors = list(object({<br><br>      namespace = string<br><br>      labels = map(string)<br><br>    }))<br><br>    tags = map(string)<br><br>  }))</pre> | `[]` | no |
| <a name="input_manage_aws_auth_configmap"></a> [manage\_aws\_auth\_configmap](#input\_manage\_aws\_auth\_configmap) | Whether to manage aws-auth configmap | `bool` | `false` | no |
| <a name="input_node_groups"></a> [node\_groups](#input\_node\_groups) | Define dynamically the different k8s node groups | `any` | n/a | yes |
| <a name="input_node_security_group_additional_rules"></a> [node\_security\_group\_additional\_rules](#input\_node\_security\_group\_additional\_rules) | Additional rules to add to the node security group | <pre>map(object({<br><br>    description = string<br><br>    protocol = string<br><br>    source_cluster_security_group = optional(bool)<br><br>    from_port = number<br><br>    to_port = number<br><br>    type = string<br><br>    cidr_blocks = optional(list(string))<br><br>    ipv6_cidr_blocks = optional(list(string))<br><br>    self = optional(bool)<br><br>  }))</pre> | n/a | yes |
| <a name="input_parameter_store_enabled"></a> [parameter\_store\_enabled](#input\_parameter\_store\_enabled) | Create resources for parameter-store | `bool` | `false` | no |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | n/a | yes |
| <a name="input_security_groups_ids"></a> [security\_groups\_ids](#input\_security\_groups\_ids) | Security group ids | `list(string)` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet ids | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | n/a |
<!-- END_TF_DOCS -->
