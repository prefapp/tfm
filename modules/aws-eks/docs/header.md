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

