
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


## Basic Usage

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
