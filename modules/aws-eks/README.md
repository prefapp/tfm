<!-- BEGIN_TF_DOCS -->
# AWS EKS Terraform Module

## Overview

This Terraform module provides a comprehensive and production-ready solution for deploying and managing **Amazon Elastic Kubernetes Service (EKS)** clusters on AWS. It abstracts the complexity of EKS infrastructure provisioning while maintaining flexibility and following AWS best practices for security, networking, and operational excellence.

The module is designed to handle both simple and complex EKS deployments, from basic development clusters to enterprise-grade production environments with advanced networking, security, and observability requirements. It seamlessly integrates with existing VPC infrastructure through flexible resource discovery mechanisms and provides extensive customization options for nodes, addons, IAM roles, and security policies.

Below is a description of the main features and components of the module:

- **EKS Configuration**: Allows the creation of an EKS cluster with custom options such as the _Kubernetes_ version, API access, and efficient node management.
- **Node Group Management**: Facilitates the creation and management of node groups with various configurations, such as instance types, desired, minimum, and maximum capacity, and tags.
- **IAM Authentication and Authorization**: Offers flexibility in managing IAM users and roles for authentication in the EKS cluster, allowing the addition of additional IAM users and roles.
- **Addon Configuration**: Includes options to enable essential addons such as \_CoreDNS\_, \_kube-proxy\_, and \_VPC CNI\_, as well as the ability to add custom addons.
- **Additional Security**: Allows the addition of extra security rules to control traffic, as well as the creation of specific IAM roles for services like \_ALB Ingress Controller\_, \_CloudWatch\_, \_EFS CSI Driver\_, and \_ExternalDNS\_.

## Key Features

- **EKS Cluster Provisioning**: Automatically provisions an Amazon EKS cluster for scalable and managed Kubernetes workloads.
- **Karpenter Integration (Optional)**: Generates required data and IAM roles for seamless integration with Karpenter, an open-source Kubernetes autoscaler.
- **IAM Roles Creation for Addons**:
  - **EBS (Elastic Block Store)**: Enables dynamic provisioning and management of EBS volumes via the EBS CSI driver.
  - **EFS (Elastic File System)**: Supports EFS CSI driver for persistent, scalable file storage in Kubernetes pods.
  - **External DNS**: Allows ExternalDNS to manage DNS records in Route53 automatically from Kubernetes resources.
  - **Parameter Store**: Grants access to AWS Systems Manager Parameter Store for secure configuration and secrets management in workloads.

## Basic Usage

### Module Usage

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

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.83 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.35 |
| <a name="requirement_time"></a> [time](#requirement\_time) | ~> 0.12 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.83 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | 20.33.1 |
| <a name="module_karpenter"></a> [karpenter](#module\_karpenter) | terraform-aws-modules/eks/aws//modules/karpenter | 20.33.1 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.external_dns_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.iam_policy_EFS_CSI_DriverRole](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.iam_policy_alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.iam_policy_extra_karpenter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
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
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_subnets.filtered](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc.by_tags](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |
| [aws_vpc.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_entries"></a> [access\_entries](#input\_access\_entries) | Access entries to apply to the EKS cluster | `any` | `{}` | no |
| <a name="input_alb_ingress_role_name"></a> [alb\_ingress\_role\_name](#input\_alb\_ingress\_role\_name) | IAM role name for ALB Ingress. Leave null to auto-generate per cluster (format: k8s-<project>-<env>-oidc-role-<cluster\_name>). For backward compatibility, use: k8s-<tags.project>-<tags.env>-oidc-role. | `string` | `null` | no |
| <a name="input_cloudwatch_log_group_class"></a> [cloudwatch\_log\_group\_class](#input\_cloudwatch\_log\_group\_class) | The class of the CloudWatch log group to create, e.g., 'STANDARD' or 'INFREQUENT\_ACCESS'. | `string` | `null` | no |
| <a name="input_cloudwatch_log_group_retention_in_days"></a> [cloudwatch\_log\_group\_retention\_in\_days](#input\_cloudwatch\_log\_group\_retention\_in\_days) | Number of days to retain log events | `number` | `14` | no |
| <a name="input_cluster_addons"></a> [cluster\_addons](#input\_cluster\_addons) | Addons to deploy to the cluster | `any` | `{}` | no |
| <a name="input_cluster_encryption_config"></a> [cluster\_encryption\_config](#input\_cluster\_encryption\_config) | Cluster encryption config | `any` | `{}` | no |
| <a name="input_cluster_endpoint_private_access"></a> [cluster\_endpoint\_private\_access](#input\_cluster\_endpoint\_private\_access) | Indicates whether or not the Amazon EKS private API server endpoint is enabled. Default is true. | `bool` | `true` | no |
| <a name="input_cluster_endpoint_public_access"></a> [cluster\_endpoint\_public\_access](#input\_cluster\_endpoint\_public\_access) | Indicates whether or not the Amazon EKS public API server endpoint is enabled. Default is false. | `bool` | `false` | no |
| <a name="input_cluster_iam_role_arn"></a> [cluster\_iam\_role\_arn](#input\_cluster\_iam\_role\_arn) | ARN of an existing IAM role to use for the EKS cluster. If not provided and create\_cluster\_iam\_role is true, a new IAM role will be created. | `string` | `null` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster | `string` | n/a | yes |
| <a name="input_cluster_security_group_additional_rules"></a> [cluster\_security\_group\_additional\_rules](#input\_cluster\_security\_group\_additional\_rules) | Additional rules for the cluster security group | `any` | `{}` | no |
| <a name="input_cluster_security_group_id"></a> [cluster\_security\_group\_id](#input\_cluster\_security\_group\_id) | Existing cluster security group ID to use. If not provided, a new security group will be created. | `string` | `""` | no |
| <a name="input_cluster_tags"></a> [cluster\_tags](#input\_cluster\_tags) | Tags to apply to the EKS cluster | `map(string)` | `{}` | no |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | Kubernetes version for the EKS cluster | `string` | n/a | yes |
| <a name="input_create_alb_ingress_iam"></a> [create\_alb\_ingress\_iam](#input\_create\_alb\_ingress\_iam) | Create IAM resources for alb-ingress | `bool` | `false` | no |
| <a name="input_create_cloudwatch_iam"></a> [create\_cloudwatch\_iam](#input\_create\_cloudwatch\_iam) | Create IAM resources for cloudwatch | `bool` | `false` | no |
| <a name="input_create_cloudwatch_log_group"></a> [create\_cloudwatch\_log\_group](#input\_create\_cloudwatch\_log\_group) | Create CloudWatch log group for the EKS cluster | `bool` | `true` | no |
| <a name="input_create_cluster_iam_role"></a> [create\_cluster\_iam\_role](#input\_create\_cluster\_iam\_role) | Create IAM role for cluster | `bool` | `true` | no |
| <a name="input_create_cluster_security_group"></a> [create\_cluster\_security\_group](#input\_create\_cluster\_security\_group) | Create cluster security group | `bool` | `true` | no |
| <a name="input_create_efs_driver_iam"></a> [create\_efs\_driver\_iam](#input\_create\_efs\_driver\_iam) | Create IAM resources for efs-driver | `bool` | `false` | no |
| <a name="input_create_external_dns_iam"></a> [create\_external\_dns\_iam](#input\_create\_external\_dns\_iam) | Create IAM resources for external-dns | `bool` | `false` | no |
| <a name="input_create_kms_key"></a> [create\_kms\_key](#input\_create\_kms\_key) | Create KMS key for cluster | `bool` | `true` | no |
| <a name="input_create_parameter_store_iam"></a> [create\_parameter\_store\_iam](#input\_create\_parameter\_store\_iam) | Create IAM resources for parameter-store | `bool` | `false` | no |
| <a name="input_enable_irsa"></a> [enable\_irsa](#input\_enable\_irsa) | Enable IRSA | `bool` | `true` | no |
| <a name="input_enable_karpenter"></a> [enable\_karpenter](#input\_enable\_karpenter) | Enable Karpenter provisioning | `bool` | `false` | no |
| <a name="input_enabled_log_types"></a> [enabled\_log\_types](#input\_enabled\_log\_types) | A list of the desired control plane logs to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html) | `list(string)` | <pre>[<br/>  "audit",<br/>  "api",<br/>  "authenticator"<br/>]</pre> | no |
| <a name="input_external_dns_role_name"></a> [external\_dns\_role\_name](#input\_external\_dns\_role\_name) | IAM role name for external-dns. Leave null to auto-generate using the cluster name. For backward compatibility, set to 'external-dns-Kubernetes'. | `string` | `null` | no |
| <a name="input_externaldns_tags"></a> [externaldns\_tags](#input\_externaldns\_tags) | Tags to apply to the ExternalDNS IAM resources | `map(any)` | `{}` | no |
| <a name="input_fargate_profiles"></a> [fargate\_profiles](#input\_fargate\_profiles) | Define dynamically the different fargate profiles | <pre>list(object({<br/>    name = string<br/>    selectors = list(object({<br/>      namespace = string<br/>      labels    = map(string)<br/>    }))<br/>    tags = map(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_node_groups"></a> [node\_groups](#input\_node\_groups) | Define dynamically the different k8s node groups | `any` | `{}` | no |
| <a name="input_node_security_group_additional_rules"></a> [node\_security\_group\_additional\_rules](#input\_node\_security\_group\_additional\_rules) | Additional rules to add to the node security group | `any` | n/a | yes |
| <a name="input_parameter_store_role_name"></a> [parameter\_store\_role\_name](#input\_parameter\_store\_role\_name) | IAM role name for Parameter Store. Leave null to auto-generate per cluster (format: iam\_role\_parameter\_store\_all-<cluster\_name>). For backward compatibility, use: iam\_role\_parameter\_store\_all. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region where the EKS cluster will be deployed | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs for the EKS cluster | `list(string)` | `null` | no |
| <a name="input_subnet_tags"></a> [subnet\_tags](#input\_subnet\_tags) | Map of subnet tags to filter which subnets we want | `map(string)` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(any)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID for the EKS cluster | `string` | `null` | no |
| <a name="input_vpc_tags"></a> [vpc\_tags](#input\_vpc\_tags) | Map of VPC tags to filter which VPC we want | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | AWS Account ID where the EKS cluster is deployed |
| <a name="output_debug"></a> [debug](#output\_debug) | Debug information for mixed addons |
| <a name="output_eks"></a> [eks](#output\_eks) | EKS module details |
| <a name="output_summary"></a> [summary](#output\_summary) | Summary of the EKS cluster configuration |

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/aws-eks/_examples):

- [karpenter](https://github.com/prefapp/tfm/tree/main/modules/aws-eks/_examples/karpenter) - Configuration with karpenter module.
- [with\_import](https://github.com/prefapp/tfm/tree/main/modules/aws-eks/_examples/with\_import) - Import existing eks.
- [with\_vpc](https://github.com/prefapp/tfm/tree/main/modules/aws-eks/_examples/with\_vpc) - We generate an EKS specifying the VPC name, not its tags.

## Remote resources

- **EKS**: [https://aws.amazon.com/eks/](https://aws.amazon.com/eks/)
- **Terraform-aws-modules/eks/aws**: [https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest)
- **Terraform-aws-modules/eks/aws/latest/submodules/karpenter**: [https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest/submodules/karpenter](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest/submodules/karpenter)
- **Terraform AWS Provider**: [https://registry.terraform.io/providers/hashicorp/aws/latest](https://registry.terraform.io/providers/hashicorp/aws/latest)

## Support

For issues, questions, or contributions related to this module, please visit the repository’s issue tracker: [https://github.com/prefapp/tfm/issues](https://github.com/prefapp/tfm/issues)
<!-- END_TF_DOCS -->