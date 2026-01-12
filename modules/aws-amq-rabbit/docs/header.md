
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
