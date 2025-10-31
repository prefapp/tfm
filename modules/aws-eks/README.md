# EKS Module

This Terraform module simplifies the creation and configuration of an **Amazon Elastic Kubernetes Service (EKS)** cluster on AWS. Below is a description of the main features and components of the module:

- **EKS Configuration**: Allows the creation of an EKS cluster with custom options such as the _Kubernetes_ version, API access, and efficient node management.
- **Node Group Management**: Facilitates the creation and management of node groups with various configurations, such as instance types, desired, minimum, and maximum capacity, and tags.
- **IAM Authentication and Authorization**: Offers flexibility in managing IAM users and roles for authentication in the EKS cluster, allowing the addition of additional IAM users and roles.
- **Addon Configuration**: Includes options to enable essential addons such as _CoreDNS_, _kube-proxy_, and _VPC CNI_, as well as the ability to add custom addons.
- **Additional Security**: Allows the addition of extra security rules to control traffic, as well as the creation of specific IAM roles for services like _ALB Ingress Controller_, _CloudWatch_, _EFS CSI Driver_, and _ExternalDNS_.

## Module Usage

- **Variable Configuration**: Fill in the variables in the `variables.tf` file according to the specific requirements of your environment, such as the AWS region, _Kubernetes_ version, and VPC configuration.
  - For **VPC** configuration, there are two available methods: based on **ids** and based on **tags**.
    - Direct configuration with `vpc_id` and `subnet_ids`. The EKS will be attached to the provided resources. If this variables are provided, they will take precedence over the variables for configuration based on tags.

    - Configuration based on tags, with `vpc_tags` and `subnet_tags`. The module will search for the resources with the corresponding tags and values, and the EKS will be attached to the found resources. All provided tags must match. **Important**: When filtering subnets by tags, the module only considers private subnets (`tag:kubernetes.io/role/internal-elb = 1`).

      Example:

      ```terraform
      # Create the VPC first and add its vpc-id here
      vpc_id = "vpc-0123456789abcdef1"

      # If we don't want to use the VPC ID, we can search for a VPC
      # With the correct tag map. All tags must match. For example purposes we use Name, application and environment, but you can use whatever tag key you need.
      vpc_tags = {
        Name        = "vpc-name-here"
        application = "application-name-here"
        environment = "environment"
        other-tag   = "other-tag-value"
      }

      # For subnets, an analogous system is used.
      # If we know the subnet ids we want to use to attach the eks, we can reference them directly
      subnet_ids = ["subnet-0123456789abcdef1", "subnet-34567890abcdef123"]

      # If we don't know or don't want to use subnet ids, you can use a tag map. This map is only an example, you can use your own tag keys and values.
      subnet_tags = {
        custom-tag 	= "custom-value"
        application   = "application-name-here"
        Tier          = "Private"
        environment   = "environment-here"
      }

      ```



- **Terraform Execution**: Run `terraform init` and `terraform apply` to create and configure the EKS cluster. Terraform will manage the creation of resources on AWS based on the provided configuration.

- **Advanced Customization**: Adjust the configuration as needed, such as adding IAM users and roles, tweaking node settings, and enabling additional addons.

- **Scalability and Maintenance**: Utilize Terraform's capabilities to scale and maintain the EKS cluster easily as environment requirements evolve.

## File Structure

The module is organized with the following directory and file structure:
```
.
├── addons_locals.tf
├── checks_addons.tf
├── data.tf
├── _examples
│   ├── with_import
│   ├── with_vpc
│   └── with_yaml_file
├── iam_alb.tf
├── iam_cloudwatch.tf
├── iam_ebs_csi_driver.tf
├── iam_efs_csi_driver.tf
├── iam_external_dns.tf
├── iam_parameter_store.tf
├── main.tf
├── outputs.tf
├── providers.tf
├── README.md
├── variables.tf
└── versions.tf
```

- **`addons_locals.tf`**: Configuration file for local variables related to addons.

- **`checks_addons.tf`**: Configuration file for checking and validating addons.

- **`data.tf`**: Data source definitions for retrieving existing information from the infrastructure.

- **`eks_prefix_delegation.tf`**: Configuration file for prefix delegation in EKS.

- **`_examples`**: Directory containing examples of module usage.

  - **`with_import`**: Example using module import.

  - **`with_vpc`**: Example integrating with an existing VPC.

  - **`with_yaml_file`**: Example utilizing a YAML file for configuration.

- **`iam_alb.tf`**: Configuration file for IAM roles related to Application Load Balancer (ALB).

- **`iam_cloudwatch.tf`**: Configuration file for IAM roles related to CloudWatch.

- **`iam_ebs_csi_driver.tf`**: Configuration file for IAM roles related to Elastic Block Store (EBS) CSI driver.

- **`iam_efs_csi_driver.tf`**: Configuration file for IAM roles related to Elastic File System (EFS) CSI driver.

- **`iam_external_dns.tf`**: Configuration file for IAM roles related to ExternalDNS.

- **`iam_parameter_store.tf`**: Configuration file for IAM roles related to Parameter Store.

- **`main.tf`**: Main Terraform configuration file where the primary resources and modules are defined.

- **`outputs.tf`**: Configuration file for defining Terraform outputs.

- **`providers.tf`**: Configuration file specifying Terraform providers and associated configurations.

- **`variables.tf`**: Configuration file containing variable definitions used in `main.tf` and modules.

- **`versions.tf`**: Configuration file specifying required Terraform and provider versions.

- **`README.md`**: Project documentation containing information on module usage, prerequisites, and a directory structure overview.

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
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.67 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.23 |
| <a name="requirement_time"></a> [time](#requirement\_time) | ~> 0.9 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.67 |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | 19.20.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.external_dns_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.iam_policy_EFS_CSI_DriverRole](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.iam_policy_alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.iam_policy_parameter_store](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.policy_additional_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.ebs_driver_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.external-dns-Kubernetes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.iam_role_EKS_EFS_CSI_DriverRole](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.iam_role_fluentd](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.iam_role_oidc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.iam_role_parameter_store_all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ebs_driver_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.external-dns-AmazonEKSClusterPolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.iam_role_EKS_EFS_CSI_DriverRole_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.iam_role_fluentd_CloudWatchAdditionalPolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.iam_role_fluentd_CloudWatchAgentServerPolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.iam_role_parameter_store_all_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.iam_role_scm_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [null_resource.prefix_delegation](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster_auth.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudwatch_log_group_retention_in_days"></a> [cloudwatch\_log\_group\_retention\_in\_days](#input\_cloudwatch\_log\_group\_retention\_in\_days) | Number of days to retain log events | `number` | `14` | no |
| <a name="input_cluster_addons"></a> [cluster\_addons](#input\_cluster\_addons) | Addons to deploy to the cluster | <pre>map(object({<br><br>    addon_version = optional(string)<br><br>    enabled = optional(bool)<br><br>    resolve_conflicts = optional(string)<br><br>    configuration_values = optional(object({<br><br>      env = optional(map(string))<br><br>    }))<br><br>    service_account_role_arn = optional(string)<br><br>  }))</pre> | n/a | yes |
| <a name="input_cluster_encryption_config"></a> [cluster\_encryption\_config](#input\_cluster\_encryption\_config) | Cluster encryption config | `any` | `{}` | no |
| <a name="input_cluster_endpoint_private_access"></a> [cluster\_endpoint\_private\_access](#input\_cluster\_endpoint\_private\_access) | Indicates whether or not the Amazon EKS private API server endpoint is enabled. Default is true. | `bool` | `true` | no |
| <a name="input_cluster_endpoint_public_access"></a> [cluster\_endpoint\_public\_access](#input\_cluster\_endpoint\_public\_access) | Indicates whether or not the Amazon EKS public API server endpoint is enabled. Default is false. | `bool` | `false` | no |
| <a name="input_cluster_iam_role_arn"></a> [cluster\_iam\_role\_arn](#input\_cluster\_iam\_role\_arn) | n/a | `string` | `null` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | n/a | `string` | n/a | yes |
| <a name="input_cluster_security_group_id"></a> [cluster\_security\_group\_id](#input\_cluster\_security\_group\_id) | n/a | `string` | n/a | yes |
| <a name="input_cluster_tags"></a> [cluster\_tags](#input\_cluster\_tags) | Tags to apply to the EKS cluster | `map(string)` | `{}` | no |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | n/a | `string` | n/a | yes |
| <a name="input_create_alb_ingress_iam"></a> [create\_alb\_ingress\_iam](#input\_create\_alb\_ingress\_iam) | Create IAM resources for alb-ingress | `bool` | `false` | no |
| <a name="input_create_cloudwatch_iam"></a> [create\_cloudwatch\_iam](#input\_create\_cloudwatch\_iam) | Create IAM resources for cloudwatch | `bool` | `false` | no |
| <a name="input_create_cluster_iam_role"></a> [create\_cluster\_iam\_role](#input\_create\_cluster\_iam\_role) | Create IAM role for cluster | `bool` | `true` | no |
| <a name="input_create_cluster_security_group"></a> [create\_cluster\_security\_group](#input\_create\_cluster\_security\_group) | Create cluster security group | `bool` | `true` | no |
| <a name="input_create_efs_driver_iam"></a> [create\_efs\_driver\_iam](#input\_create\_efs\_driver\_iam) | Create IAM resources for efs-driver | `bool` | `false` | no |
| <a name="input_create_external_dns_iam"></a> [create\_external\_dns\_iam](#input\_create\_external\_dns\_iam) | Create IAM resources for external-dns | `bool` | `false` | no |
| <a name="input_create_kms_key"></a> [create\_kms\_key](#input\_create\_kms\_key) | Create KMS key for cluster | `bool` | `true` | no |
| <a name="input_create_parameter_store_iam"></a> [create\_parameter\_store\_iam](#input\_create\_parameter\_store\_iam) | Create IAM resources for parameter-store | `bool` | `false` | no |
| <a name="input_enable_irsa"></a> [enable\_irsa](#input\_enable\_irsa) | Enable IRSA | `bool` | `false` | no |
| <a name="input_externaldns_tags"></a> [externaldns\_tags](#input\_externaldns\_tags) | n/a | `map(any)` | `{}` | no |
| <a name="input_fargate_profiles"></a> [fargate\_profiles](#input\_fargate\_profiles) | Define dynamically the different fargate profiles | <pre>list(object({<br><br>    name = string<br><br>    selectors = list(object({<br><br>      namespace = string<br><br>      labels = map(string)<br><br>    }))<br><br>    tags = map(string)<br><br>  }))</pre> | `[]` | no |
| <a name="input_node_groups"></a> [node\_groups](#input\_node\_groups) | Define dynamically the different k8s node groups | `any` | n/a | yes |
| <a name="input_node_security_group_additional_rules"></a> [node\_security\_group\_additional\_rules](#input\_node\_security\_group\_additional\_rules) | Additional rules to add to the node security group | `any` | n/a | yes |
| <a name="cluster_security_group_additional_rules"></a> [cluster\_security\_group\_additional\_rules](#input\_cluster\_security\_group\_additional\_rules) | Additional rules for the cluster security group | `any` | `{}` | no |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet ids (Mandatory if *subnet_tags* is not present). They need to be attached to the provided VPC. | `list(string)` | n/a | no |
| <a name="subnet_tags"></a> [subnet\_tags](#input\_subnet\_tags) | Subnet tags to select subnets ; mandatory if *subnet_ids* are not present. They need to be attached to the provided VPC. Only private subnets (`tag kubernetes.io/role/internal-elb = 1`) will be considered when filtering. | `map(string)` | "custom-internal-elb" | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(any)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC Id (Mandatory if *vpc_tags* is not present) | `string` | n/a | no |
| <a name="input_vpc_tags"></a> [vpc\_tags](#input\_vpc\_name) | VPC tags (tag Name) (Mandatory if *vpc_id* is not present) | `map(string)` | n/a | no |
| <a name="access_entries"></a> [access\_entries](#input\access\_entries) | Access entries to apply to the EKS cluster | `any` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | n/a |
| <a name="output_debug"></a> [debug](#output\_debug) | n/a |
| <a name="output_eks"></a> [eks](#output\_eks) | n/a |
| <a name="output_summary"></a> [summary](#output\_summary) | n/a |
<!-- END_TF_DOCS -->
