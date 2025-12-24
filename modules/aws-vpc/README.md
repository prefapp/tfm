# AWS VPC Terraform Module

> [!WARNING]
> This directory **DOES NOT contain a Terraform module managed by Prefapp**. For managing VPCs on AWS, you **must use directly the official AWS community module**: [terraform-aws-modules/vpc/aws](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest).
>
> This document provides only reference information about the official module you should use in your projects.

## Overview

The official AWS VPC Terraform module provides a comprehensive solution for creating and managing Virtual Private Cloud (VPC) resources on AWS. This module handles the creation of VPCs, subnets, route tables, internet gateways, NAT gateways, and other networking components following best practices.

## Key Features

- **Complete VPC Setup**: Creates VPC with public, private, database, elasticache, redshift, intra, and outpost subnets
- **NAT Gateway Scenarios**: Supports multiple NAT gateway configurations (one per subnet, single NAT gateway, or one per availability zone)
- **IPv6 Support**: Full support for dual-stack (IPv4/IPv6) and IPv6-only configurations
- **Network ACLs**: Dedicated network ACLs with custom rules for different subnet types
- **VPC Flow Logs**: Built-in support for VPC Flow Logs to CloudWatch or S3
- **VPN Gateway**: Optional VPN gateway attachment for hybrid connectivity
- **Transit Gateway Integration**: Compatible with AWS Transit Gateway for multi-VPC architectures
- **IPAM Support**: Integration with AWS IP Address Manager (IPAM) for CIDR allocation

## Basic Usage

```hcl
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
```

## NAT Gateway Scenarios

### One NAT Gateway per Subnet (Default)

```hcl
enable_nat_gateway = true
single_nat_gateway = false
one_nat_gateway_per_az = false
```

### Single NAT Gateway

```hcl
enable_nat_gateway = true
single_nat_gateway = true
```

### One NAT Gateway per Availability Zone

```hcl
enable_nat_gateway = true
single_nat_gateway = false
one_nat_gateway_per_az = true
```

## Subnet Types

- **Public Subnets**: Subnets with routes to an Internet Gateway
- **Private Subnets**: Subnets with routes to NAT Gateway for internet access
- **Intra Subnets**: Subnets with no internet routing (RFC1918 private networks)
- **Database Subnets**: Dedicated subnets for RDS instances with optional subnet groups
- **Elasticache Subnets**: Dedicated subnets for ElastiCache clusters
- **Redshift Subnets**: Dedicated subnets for Redshift clusters
- **Outpost Subnets**: Subnets for AWS Outpost resources

## Advanced Features

### External NAT Gateway IPs

Reuse existing Elastic IPs for NAT Gateways:

```hcl
resource "aws_eip" "nat" {
  count = 3
  vpc   = true
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  enable_nat_gateway  = true
  reuse_nat_ips       = true
  external_nat_ip_ids = aws_eip.nat[*].id
}
```

### VPC Flow Logs

Enable VPC Flow Logs to CloudWatch:

```hcl
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  enable_flow_log                      = true
  create_flow_log_cloudwatch_iam_role  = true
  create_flow_log_cloudwatch_log_group = true
}
```

### Network ACLs

Configure dedicated network ACLs for subnet types:

```hcl
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  public_dedicated_network_acl = true
  public_inbound_acl_rules     = [...]
  public_outbound_acl_rules    = [...]
}
```

## Examples

For detailed examples, refer to the [official module examples](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples):

- [Complete VPC](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/complete) - Full-featured VPC with multiple subnet types
- [Simple VPC](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/simple) - Basic VPC setup
- [VPC with IPv6](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/ipv6-dualstack) - Dual-stack IPv4/IPv6 configuration
- [VPC with IPAM](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/ipam) - CIDR allocation from IPAM
- [VPC with Flow Logs](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/flow-log) - Flow logs configuration

## Remote resources

- **Official Module**: [terraform-aws-modules/vpc/aws](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest)
- **GitHub Repository**: [terraform-aws-modules/terraform-aws-vpc](https://github.com/terraform-aws-modules/terraform-aws-vpc)
- **Full Documentation**: [README.md](https://github.com/terraform-aws-modules/terraform-aws-vpc/blob/master/README.md)

## Support

For issues, questions, or contributions related to this module, please visit the [official repository's issue tracker](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues).

---

**Note**: Always refer to the [official module documentation](https://github.com/terraform-aws-modules/terraform-aws-vpc) for the most up-to-date information.
