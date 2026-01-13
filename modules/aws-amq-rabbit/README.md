<!-- BEGIN_TF_DOCS -->
# **AWS Amazon MQ (RabbitMQ) Terraform Module**

## Overview

This Terraform module provisions and manages an Amazon MQ (RabbitMQ) broker on AWS. It automates the deployment of RabbitMQ brokers with flexible networking, security, and access options, supporting both public and private deployments, as well as integration with AWS Network Load Balancer (NLB) for advanced connectivity scenarios.

The module is designed for production-ready messaging infrastructure, supporting secure credential management, VPC/subnet discovery, and customizable tagging. It is suitable for both new and existing AWS environments, and can be integrated into larger cloud architectures.

This module provisions an **Amazon MQ RabbitMQ broker**, including:

- RabbitMQ broker (Amazon MQ)
- VPC and subnet selection (by ID or tags)
- Security group (custom or managed)
- Optional Network Load Balancer (NLB) for private access
- Flexible access modes: public, private, or private with NLB
- Tagging and environment metadata

It is designed to be flexible, secure, and easy to integrate into existing AWS infrastructures.

## Key Features

- **Amazon MQ RabbitMQ Broker**: Deploys a managed RabbitMQ broker with configurable engine version and instance type.
- **Flexible Networking**: Supports VPC and subnet selection by ID or tag, for both brokers and load balancers.
- **Access Modes**: Choose between public, private, or private with NLB for secure and scalable connectivity.
- **Security Group Management**: Use an existing security group or let the module create one with customizable ingress/egress rules.
- **Network Load Balancer (NLB)**: Optionally deploys an NLB for private brokers, with target group and listener configuration.
- **Tagging and Metadata**: Apply custom tags, project, and environment labels to all resources.
- **Sensitive Credentials**: Securely manage RabbitMQ admin username and password via Terraform variables.
- **Custom Port Exposure**: Expose one or more ports for RabbitMQ (default: 5671). All security group rules are generated for the specified ports. For NLB, a listener and target group will be created for each port in the list, so all specified ports are exposed through the load balancer.

## Important Note: Two-Step NLB Setup

When deploying a private RabbitMQ broker with a Network Load Balancer (NLB), you must apply Terraform in two steps:

1. **First apply:** Deploy the broker with `access_mode = "private"` (or omit the NLB-related variables). This creates the broker and allocates its private IP addresses.
2. **Second apply:** Update the configuration to set `access_mode = "private_with_nlb"` and provide the NLB variables, then apply again. Now the NLB and its target group can be created, and the broker's private IPs will be registered as targets.

**Why is this necessary?**

The NLB target group uses `target_type = "ip"` and requires the broker's private IP addresses to register as targets. These IPs are not available until the broker is fully created. If you try to create both the broker and the NLB in a single Terraform run, the apply will fail because the broker's IPs do not exist yet. The two-step process ensures the broker is ready before the NLB is attached.

This is a limitation of how AWS and Terraform handle resource dependencies for dynamic IP targets.

---

The following examples demonstrate common ways to use this module to provision an Amazon MQ RabbitMQ broker, including default settings and optional configuration patterns such as custom port exposure.

## Resolving Broker IPs for NLB Registration

When using `access_mode = "private_with_nlb"`, you must provide the private IP addresses of the broker instances to the module so that the NLB can register them as targets. The module outputs a list of broker URLs (hostnames) and their private IPs:

* `broker_urls`: The DNS hostnames for each broker instance (e.g., `b-xxxx.mq.us-east-1.amazonaws.com`).
* `broker_ips`: The private IP addresses for each broker instance.

To resolve the private IPs from the broker URLs, you can use the `dig` or `nslookup` command:

```sh
dig +short b-xxxx.mq.us-east-1.amazonaws.com
# or
nslookup b-xxxx.mq.us-east-1.amazonaws.com
```

You can then provide these IPs to the module using the `nlb_listener_ips` variable, mapping each port to the list of broker IPs you want to register for that port:

```hcl
nlb_listener_ips = {
  "5671"  = ["10.0.1.10", "10.0.2.10"] # AMQPS
  "15672" = ["10.0.1.11"]               # Management UI
}
```

If you do not provide IPs for a port, no NLB listener or target group will be created for that port.

This approach allows you to run the module multiple times: first to create the broker and get the URLs, then to resolve the IPs and configure the NLB listeners as needed, without destroying or recreating the NLB.

## Basic Usage

### Exposing Custom Ports

You can expose one or more ports for RabbitMQ by setting the `exposed_ports` variable. By default, only port 5671 (AMQPS) is exposed. Example:

```hcl
module "rabbitmq" {
  # ...existing code...
  exposed_ports = [5671, 15672] # Exposes AMQPS and management UI
}
```

> **Note:** If using a Network Load Balancer (NLB), a listener and target group will be created for each port in `exposed_ports`. All specified ports will be open in the security group and accessible through the NLB.

### Minimal Example (Private Broker)

```hcl
module "rabbitmq" {
  source        = "github.com/prefapp/tfm/modules/aws-amq-rabbit"
  project_name  = "demo-project"
  environment   = "dev"
  mq_username   = "admin"
  mq_password   = "supersecret"
  vpc_id        = "vpc-xxxxxxxx"
  broker_subnet_ids = ["subnet-xxxxxxxx"]
}
```

### Example: Private Broker with NLB

```hcl
module "rabbitmq" {
  source        = "github.com/prefapp/tfm/modules/aws-amq-rabbit"
  project_name  = "demo-project"
  environment   = "dev"
  mq_username   = "admin"
  mq_password   = "supersecret"
  vpc_id        = "vpc-xxxxxxxx"
  broker_subnet_ids = ["subnet-xxxxxxxx"]
  access_mode   = "private_with_nlb"
  lb_subnet_ids = ["subnet-yyyyyyyy"]
  lb_certificate_arn = "arn:aws:acm:..."
}
```

## File Structure

The module is organized with the following directory and file structure:

```
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── _examples/
│   ├── private_broker/
│   ├── private_broker_with_nlb/
│   └── public_broker/
├── docs/
│   ├── header.md
│   └── footer.md
```

- **`main.tf`**: Main module logic and resource definitions.
- **`variables.tf`**: Input variables for module configuration.
- **`outputs.tf`**: Outputs for integration and reference.
- **`versions.tf`**: Provider and module version constraints.
- **`_examples/`**: Example configurations for different deployment scenarios.
- **`docs/`**: Documentation files for the module.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_lb.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group_attachment.broker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |
| [aws_mq_broker.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/mq_broker) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_mq_broker.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/mq_broker) | data source |
| [aws_subnets.broker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_subnets.lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_mode"></a> [access\_mode](#input\_access\_mode) | Access mode for the broker: 'public', 'private', or 'private\_with\_nlb'. | `string` | `"private"` | no |
| <a name="input_allowed_ingress_cidrs"></a> [allowed\_ingress\_cidrs](#input\_allowed\_ingress\_cidrs) | CIDR ranges allowed to connect to the AMQPS/HTTPS ports | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_broker_subnet_filter_tags"></a> [broker\_subnet\_filter\_tags](#input\_broker\_subnet\_filter\_tags) | Tags used to discover subnets for the Broker (e.g., { 'NetworkTier' = 'Private' }). | `map(string)` | `{}` | no |
| <a name="input_broker_subnet_ids"></a> [broker\_subnet\_ids](#input\_broker\_subnet\_ids) | List of private subnet IDs for the Broker. Takes precedence over filters. | `list(string)` | `[]` | no |
| <a name="input_deployment_mode"></a> [deployment\_mode](#input\_deployment\_mode) | Broker deployment strategy: SINGLE\_INSTANCE or CLUSTER\_MULTI\_AZ | `string` | `"SINGLE_INSTANCE"` | no |
| <a name="input_enable_cloudwatch_logs"></a> [enable\_cloudwatch\_logs](#input\_enable\_cloudwatch\_logs) | Toggle for CloudWatch logging | `bool` | `true` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | Version of the RabbitMQ engine | `string` | `"3.13"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Target environment for the deployment (e.g., 'prod', 'staging') | `string` | n/a | yes |
| <a name="input_existing_security_group_id"></a> [existing\_security\_group\_id](#input\_existing\_security\_group\_id) | ID of an existing Security Group to use. If not set, a new one will be created. | `string` | `null` | no |
| <a name="input_exposed_ports"></a> [exposed\_ports](#input\_exposed\_ports) | List of ports to expose for RabbitMQ broker (AMQPS, management, etc.). Default is [5671]. | `list(number)` | <pre>[<br/>  5671<br/>]</pre> | no |
| <a name="input_host_instance_type"></a> [host\_instance\_type](#input\_host\_instance\_type) | Instance class for the broker (e.g., mq.t3.micro) | `string` | `"mq.t3.micro"` | no |
| <a name="input_lb_certificate_arn"></a> [lb\_certificate\_arn](#input\_lb\_certificate\_arn) | ARN of the ACM certificate for the TLS listener | `string` | n/a | yes |
| <a name="input_lb_subnet_filter_tags"></a> [lb\_subnet\_filter\_tags](#input\_lb\_subnet\_filter\_tags) | Tags used to discover subnets for the NLB (e.g., { 'NetworkTier' = 'Public' }). | `map(string)` | `{}` | no |
| <a name="input_lb_subnet_ids"></a> [lb\_subnet\_ids](#input\_lb\_subnet\_ids) | List of subnet IDs for the NLB. Takes precedence over filters. | `list(string)` | `[]` | no |
| <a name="input_mq_password"></a> [mq\_password](#input\_mq\_password) | Administrative password for the RabbitMQ broker | `string` | n/a | yes |
| <a name="input_mq_username"></a> [mq\_username](#input\_mq\_username) | Administrative username for the RabbitMQ broker | `string` | n/a | yes |
| <a name="input_nlb_listener_ips"></a> [nlb\_listener\_ips](#input\_nlb\_listener\_ips) | Map of port numbers to lists of IP addresses for NLB listeners. If provided for a port, a listener will be created for that port and the specified IPs will be registered as targets. If not provided for a port, no listener will be created for that port.<br/>    Example: { "5671" = ["10.0.1.10", "10.0.2.10"], "15672" = ["10.0.1.11"] } | `map(list(string))` | `{}` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Generic project identifier used for resource naming (e.g., 'messaging-hub') | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional metadata tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the target VPC. Takes precedence over 'vpc\_name'. | `string` | `null` | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | Value of the 'Name' tag for VPC lookup if 'vpc\_id' is null. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_broker_arn"></a> [broker\_arn](#output\_broker\_arn) | ARN for the Amazon MQ Broker |
| <a name="output_broker_console_url"></a> [broker\_console\_url](#output\_broker\_console\_url) | Direct web console endpoint for the broker |
| <a name="output_broker_id"></a> [broker\_id](#output\_broker\_id) | Identifier for the Amazon MQ Broker |
| <a name="output_broker_urls"></a> [broker\_urls](#output\_broker\_urls) | List of broker endpoints (hostnames) for the Amazon MQ Broker. Use these to resolve the private IPs for NLB registration. |
| <a name="output_nlb_arn"></a> [nlb\_arn](#output\_nlb\_arn) | ARN of the Network Load Balancer used for the broker. |
| <a name="output_target_group_arn"></a> [target\_group\_arn](#output\_target\_group\_arn) | ARN of the first Target Group used for the broker. If multiple ports are exposed, this is the first. |
| <a name="output_target_group_arns"></a> [target\_group\_arns](#output\_target\_group\_arns) | List of all Target Group ARNs used for the broker. |
| <a name="output_target_group_name"></a> [target\_group\_name](#output\_target\_group\_name) | Name of the first Target Group used for the broker. If multiple ports are exposed, this is the first. |
| <a name="output_target_group_names"></a> [target\_group\_names](#output\_target\_group\_names) | List of all Target Group names used for the broker. |

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/aws-amq-rabbit/_examples):

- [Private Broker](https://github.com/prefapp/tfm/tree/main/modules/aws-amq-rabbit/_examples/private\_broker) - Deploy a RabbitMQ broker in a private subnet
- [Private Broker with NLB](https://github.com/prefapp/tfm/tree/main/modules/aws-amq-rabbit/_examples/private\_broker\_with\_nlb) - Deploy a private RabbitMQ broker with a Network Load Balancer
- [Public Broker](https://github.com/prefapp/tfm/tree/main/modules/aws-amq-rabbit/_examples/public\_broker) - Deploy a RabbitMQ broker accessible from the public internet

## Remote resources
- Terraform: https://www.terraform.io/
- Terraform AWS Provider: https://registry.terraform.io/providers/hashicorp/aws/latest
- Amazon MQ (RabbitMQ): https://docs.aws.amazon.com/amazon-mq/latest/developer-guide/what-is-amazon-mq.html
- aws\_mq\_broker: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/mq_broker
- AWS VPC: https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html
- aws\_vpc: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc
- AWS Subnets: https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Subnets.html
- aws\_subnets: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets
- AWS Security Group: https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html
- aws\_security\_group: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
- AWS Network Load Balancer: https://docs.aws.amazon.com/elasticloadbalancing/latest/network/introduction.html
- aws\_lb: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb
- aws\_lb\_target\_group: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group
- aws\_lb\_listener: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener

## Support

For issues, questions, or contributions related to this module, please visit the [repository’s issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->