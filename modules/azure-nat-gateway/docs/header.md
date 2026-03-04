# **Azure NAT Gateway Terraform Module**

## Overview

This module provisions and manages a complete Azure NAT Gateway resource, including SKU and zone allocation.

It is suitable for development, staging, and production environments, and can be easily extended or embedded in larger Terraform projects.

## Key Features

- **Nat Gateway Provisioning**: Deploys a fully managed Azure Nat Gateway resource with customizable name, SKU and zone allocation.
- **Availability zone allocation**: Define in which availability zones deploy the NAT Gateway.

## Basic Usage

### Example 1: Base NAT Gateway

```hcl
module "nat_gateway" {
  source = "../../"

  nat_gateway = {
    name                = "nat-gateway-name"
    resource_group_name = "resource-group-name"
    location            = "westeurope"
    nat_gateway_timeout = 4
    nat_gateway_sku     = "Standard"
    public_ip_id        = "public-ip-id"
    subnet_id           = "subnet-id"
    tags_from_rg        = true
}
```

