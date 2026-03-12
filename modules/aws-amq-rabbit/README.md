<!-- BEGIN_TF_DOCS -->
# **AWS Amazon MQ (RabbitMQ) Terraform Module**

## Overview

This Terraform module provisions and manages an Amazon MQ (RabbitMQ) broker on AWS. It automates the deployment of RabbitMQ brokers with flexible networking, security, and access options, supporting both public and private deployments, as well as integration with AWS Network Load Balancer (NLB) for advanced connectivity scenarios.

The module is designed for production-ready messaging infrastructure, supporting secure credential management, VPC/subnet discovery, and customizable tagging. It is suitable for both new and existing AWS environments, and can be integrated into larger cloud architectures.

## Key Features

- **Amazon MQ RabbitMQ Broker**: Deploys a managed RabbitMQ broker with configurable engine version and instance type.
- **Flexible Networking**: Supports VPC and subnet selection by ID or tag, for both brokers and load balancers.
- **Access Modes**: Choose between public, private, or private with NLB for secure and scalable connectivity.
- **Security Group Management**: Use an existing security group or let the module create one with customizable ingress/egress rules.
- **Network Load Balancer (NLB)**: Optionally deploys an NLB for private brokers, with target group and listener configuration.
- **Tagging and Metadata**: Apply custom tags, project, and environment labels to all resources.
- **Sensitive Credentials**: Securely manage RabbitMQ admin username and password via Terraform variables.

## Broker Password Generation

This module automatically generates a secure, random password for the Amazon MQ broker using Terraform's `random_password` resource. The generated password:

- Is 30 characters long and includes upper/lowercase letters, numbers, and a restricted set of special characters.
- Excludes characters not allowed by Amazon MQ: `[`, `]`, `:`, `=`, and `,`.
- Is stored securely in AWS SSM Parameter Store as a `SecureString` under the path: `/${project_name}/${environment}/mq/broker_password`.
- Is referenced automatically by the broker resource; you do not need to supply it manually.

To retrieve the password, you can use the AWS Console or AWS CLI:

```sh
aws ssm get-parameter --name "/<project_name>/<environment>/mq/broker_password" --with-decryption
```

If you wish to override this behavior, you can modify the module to accept a custom password as a variable.

## Important Note: Two-Step NLB Setup

When deploying a private RabbitMQ broker with a Network Load Balancer (NLB), you must apply Terraform in two steps:

1. **First apply:** Deploy the broker with `access_mode = "private"` (or omit the NLB-related variables). This creates the broker and allocates its private IP addresses.
2. **Second apply:** Update the configuration to set `access_mode = "private_with_nlb"` and provide the NLB variables, then apply again. Now the NLB and its target group can be created, and the broker's private IPs will be registered as targets.

**Why is this necessary?**

For Amazon MQ brokers with the RabbitMQ engine type, AWS does not expose the broker's private IP addresses as Terraform resource attributes. However, these IPs do exist and can be resolved via DNS lookups on the broker hostnames (e.g., using `dig` or `nslookup`). Because Terraform cannot access these IPs directly, you must manually resolve and provide them to the module using the `nlb_listener_ips` variable if you want to register the broker with an NLB. This is a limitation of the AWS provider and the Amazon MQ API. As of now, there is no official AWS documentation page describing this limitation, but it is a known behavior observed by the community and in practice.

### Resolving Broker IPs for NLB Registration

When using `access_mode = "private_with_nlb"`, you must provide the private IP addresses of the broker instances to the module so that the NLB can register them as targets. The module outputs a list of broker URLs (hostnames):

* `broker_urls`: The DNS hostnames for each broker instance (e.g., `b-xxxx.mq.us-east-1.amazonaws.com`).

#### Note on `expose_all_ports`

When you set `expose_all_ports = true` in the `nlb_listener_ips` block, the module will expose all ports defined in its internal `rabbitmq_port_names` map. As currently configured, this means **only the following ports will be exposed**:

- 5671 (AMQPS)
- 443 (Management UI)

If you need to expose additional ports, you must add them to the `rabbitmq_port_names` map in the module's `locals.tf` file. The phrase "all RabbitMQ ports" refers specifically to the ports listed in this map, not every possible RabbitMQ port.

To resolve the private IPs from the broker URLs, you can use the `dig` or `nslookup` command:

```sh
dig +short b-xxxx.mq.us-east-1.amazonaws.com
# or
nslookup b-xxxx.mq.us-east-1.amazonaws.com
```

You can then provide these IPs to the module using the `nlb_listener_ips` variable, mapping each port to the list of broker IPs you want to register for that port:

```hcl
nlb_listener_ips = [
  {
    ips = ["10.0.1.10", "10.0.2.10"]
    target_port = 5671 # AMQPS
    listener_port = 8081 # Optional, NLB will listen on 8081 and forward to 5671
  },
  {
    ips = ["10.0.1.11"]
    target_port = "Management UI" # You can use the port number or the name
    listener_port = 443 # Optional, NLB will listen on 443 and forward to the Management UI
  }
  # Or, to expose all RabbitMQ ports (AMQPS and Management UI) for the same set of IPs:
  {
    ips = ["10.0.1.10", "10.0.2.10"]
    expose_all_ports = true # Optional, will expose all RabbitMQ ports (5671 and 443)
  }
]
```

If you do not provide IPs for a port, no NLB listener or target group will be created for that port.

This approach allows you to run the module multiple times: first to create the broker and get the URLs, then to resolve the IPs and configure the NLB listeners as needed, without destroying or recreating the NLB.

## Basic Usage

### Exposing Custom Ports

You can expose one or more ports for RabbitMQ by setting the `exposed_ports` variable. By default, only port 5671 (AMQPS) is exposed. Example:

```hcl
module "rabbitmq" {
  # ...existing code...
  exposed_ports = [5671, 443] # Exposes AMQPS and management UI
}
```

> **Note:** If using a Network Load Balancer (NLB), a listener and target group will be created for each port in `exposed_ports`. All specified ports will be open in the security group and accessible through the NLB.

---
The following examples demonstrate common ways to use this module to provision an Amazon MQ RabbitMQ broker, including default settings and optional configuration patterns such as custom port exposure.

### Minimal Example (Private Broker)

```hcl
module "rabbitmq" {
  source                 = "github.com/prefapp/tfm/modules/aws-amq-rabbit"
  project_name           = "demo-project"
  environment            = "dev"
  mq_username            = "admin"
  vpc_id                 = "vpc-xxxxxxxx"
  broker_subnet_ids      = ["subnet-xxxxxxxx"]
  exposed_ports          = [5671]
  host_instance_type     = "mq.t3.micro"
  engine_version         = "3.13"
  deployment_mode        = "SINGLE_INSTANCE"
  enable_cloudwatch_logs = true
  tags = {
    Owner      = "DevOps"
    CostCenter = "IT"
  }
}
```

### Example: Private Broker with NLB

```hcl
module "rabbitmq" {
  source                 = "github.com/prefapp/tfm/modules/aws-amq-rabbit"
  project_name           = "demo-project"
  environment            = "dev"
  mq_username            = "admin"
  vpc_id                 = "vpc-xxxxxxxx"
  broker_subnet_ids      = ["subnet-xxxxxxxx"]
  access_mode            = "private_with_nlb"
  lb_subnet_ids          = ["subnet-yyyyyyyy"]
  lb_certificate_arn     = "arn:aws:acm:..."
  exposed_ports          = [5671, 443]
  nlb_listener_ips = [
    {
      ips = ["10.0.1.10", "10.0.2.10"]
      target_port = 5671 # AMQPS
      listener_port = 8081 # Optional, NLB will listen on 8081 and forward to 5671
    },
    {
      ips = ["10.0.1.11"]
      target_port = "Management UI" # You can use the port number or the name
      listener_port = 443 # Optional, NLB will listen on 443 and forward to the Management UI
    }
  ]
  host_instance_type     = "mq.t3.micro"
  engine_version         = "3.13"
  deployment_mode        = "SINGLE_INSTANCE"
  enable_cloudwatch_logs = true
  tags = {
    Owner      = "DevOps"
    CostCenter = "IT"
  }
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
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.0 |

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
| [aws_ssm_parameter.mq_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [random_password.mq_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_subnets.broker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_subnets.lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc.by_name](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_mode"></a> [access\_mode](#input\_access\_mode) | Access mode for the broker: 'public', 'private', or 'private\_with\_nlb'. | `string` | `"private"` | no |
| <a name="input_allowed_ingress_cidrs"></a> [allowed\_ingress\_cidrs](#input\_allowed\_ingress\_cidrs) | CIDR ranges allowed to connect to all exposed ports (e.g., AMQPS, AMQP, STOMP, MQTT, Management UI, etc.) | `list(string)` | `[]` | no |
| <a name="input_broker_subnet_filter_tags"></a> [broker\_subnet\_filter\_tags](#input\_broker\_subnet\_filter\_tags) | Tags used to discover subnets for the Broker (e.g., { 'NetworkTier' = 'Private' }). | `map(string)` | `{}` | no |
| <a name="input_broker_subnet_ids"></a> [broker\_subnet\_ids](#input\_broker\_subnet\_ids) | List of private subnet IDs for the Broker. Takes precedence over filters. | `list(string)` | `[]` | no |
| <a name="input_deployment_mode"></a> [deployment\_mode](#input\_deployment\_mode) | Broker deployment strategy: SINGLE\_INSTANCE or CLUSTER\_MULTI\_AZ | `string` | `"SINGLE_INSTANCE"` | no |
| <a name="input_enable_cloudwatch_logs"></a> [enable\_cloudwatch\_logs](#input\_enable\_cloudwatch\_logs) | Toggle for CloudWatch logging | `bool` | `true` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | Version of the RabbitMQ engine | `string` | `"3.13"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Target environment for the deployment (e.g., 'prod', 'staging') | `string` | n/a | yes |
| <a name="input_existing_security_group_id"></a> [existing\_security\_group\_id](#input\_existing\_security\_group\_id) | ID of an existing Security Group to use. If not set, a new one will be created. | `string` | `null` | no |
| <a name="input_exposed_ports"></a> [exposed\_ports](#input\_exposed\_ports) | List of ports to expose for RabbitMQ broker (AMQPS, management, etc.). Default is [5671]. | `list(number)` | <pre>[<br/>  5671<br/>]</pre> | no |
| <a name="input_host_instance_type"></a> [host\_instance\_type](#input\_host\_instance\_type) | Instance class for the broker (e.g., mq.t3.micro) | `string` | `"mq.t3.micro"` | no |
| <a name="input_lb_certificate_arn"></a> [lb\_certificate\_arn](#input\_lb\_certificate\_arn) | ARN of the ACM certificate for the TLS listener. Required only if access\_mode is 'private\_with\_nlb'. | `string` | `null` | no |
| <a name="input_lb_ssl_policy"></a> [lb\_ssl\_policy](#input\_lb\_ssl\_policy) | TLS policy for the NLB listener. Default is 'ELBSecurityPolicy-TLS-1-2-2017-01' for compatibility with TLS 1.2 and 1.3. See AWS documentation for available policies. | `string` | `"ELBSecurityPolicy-TLS-1-2-2017-01"` | no |
| <a name="input_lb_subnet_filter_tags"></a> [lb\_subnet\_filter\_tags](#input\_lb\_subnet\_filter\_tags) | Tags used to discover subnets for the NLB (e.g., { 'NetworkTier' = 'Public' }). | `map(string)` | `{}` | no |
| <a name="input_lb_subnet_ids"></a> [lb\_subnet\_ids](#input\_lb\_subnet\_ids) | List of subnet IDs for the NLB. Takes precedence over filters. | `list(string)` | `[]` | no |
| <a name="input_mq_username"></a> [mq\_username](#input\_mq\_username) | Administrative username for the RabbitMQ broker | `string` | n/a | yes |
| <a name="input_nlb_listener_ips"></a> [nlb\_listener\_ips](#input\_nlb\_listener\_ips) | List of objects to define NLB listeners and targets. Each object can specify:<br/>      - ips: List of broker IPs to register as targets<br/>      - target\_port: Port number or name (e.g., 5671, 443, "AMQPS", "Management UI")<br/>      - listener\_port: (Optional) Port number for the NLB listener. If not set, uses target\_port.<br/>    Example:<br/>      [<br/>        {<br/>          ips = ["10.0.1.10", "10.0.2.10"]<br/>          target\_port = 5671<br/>          listener\_port = 8081<br/>        },<br/>        {<br/>          ips = ["10.0.1.11"]<br/>          target\_port = "Management UI"<br/>          listener\_port = 443<br/>        }<br/>      ] | <pre>list(object({<br/>    ips              = list(string)<br/>    target_port      = optional(any) # number or string (name)<br/>    listener_port    = optional(number)<br/>    expose_all_ports = optional(bool)<br/>  }))</pre> | `[]` | no |
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
| <a name="output_broker_urls"></a> [broker\_urls](#output\_broker\_urls) | Nested list of broker endpoints for the Amazon MQ Broker. Each element is a list of endpoints for a broker instance (e.g., [[hostname1, hostname2, ...], ...]). Use these to resolve the private IPs for NLB registration. |
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
