# **AWS Amazon MQ (RabbitMQ) Terraform Module**


## Overview

This Terraform module provisions and manages an Amazon MQ (RabbitMQ) broker on AWS. It automates the deployment of RabbitMQ brokers with flexible networking, security, and access options, supporting both public and private deployments, as well as integration with AWS Network Load Balancer (NLB) for advanced connectivity scenarios.

The module is designed for production-ready messaging infrastructure, supporting secure credential management, VPC/subnet discovery, and customizable tagging. It is suitable for both new and existing AWS environments, and can be integrated into larger cloud architectures.

It is designed to be flexible, secure, and easy to integrate into existing AWS infrastructures.




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


For Amazon MQ brokers with the RabbitMQ engine type, AWS does not expose the private IP addresses of the broker instances. This means you cannot directly register the broker’s private IPs as targets in a Network Load Balancer (NLB) target group using `target_type = "ip"`. As a result, it is not possible to attach the NLB to the broker in a single Terraform run, since the required IP addresses are never made available. This is a restriction imposed by AWS for RabbitMQ brokers, as documented in the [Amazon MQ documentation](https://aws.amazon.com/documentation-overview/amazon-mq/).

---

The following examples demonstrate common ways to use this module to provision an Amazon MQ RabbitMQ broker, including default settings and optional configuration patterns such as custom port exposure.



### Resolving Broker IPs for NLB Registration


When using `access_mode = "private_with_nlb"`, you must provide the private IP addresses of the broker instances to the module so that the NLB can register them as targets. The module outputs a list of broker URLs (hostnames):

* `broker_urls`: The DNS hostnames for each broker instance (e.g., `b-xxxx.mq.us-east-1.amazonaws.com`).

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
  exposed_ports          = [5671, 15672]
  nlb_listener_ips = {
    "5671"  = ["10.0.1.10", "10.0.2.10"] # AMQPS
    "15672" = ["10.0.1.11"]               # Management UI
  }
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
