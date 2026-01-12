# **Azure Windows Virtual Machine Terraform Module**

## Overview

This module provisions and manages a complete Azure Public IP resource, including SKU or allocation method and supports the definition of a custom domain name.

It is suitable for development, staging, and production environments, and can be easily extended or embedded in larger Terraform projects.

## Key Features

- **Public IP Provisioning**: Deploys a fully managed Azure Public Ip resource with customizable name, SKU, allocation method and domain name.

## Basic Usage

### Example 1: Public IP without domain name label

```hcl
module "public_ip" {
  source = "../../"

  public_ip = {
    name                = "public-ip-name"
    resource_group_name = "resource-group-name"
    location            = "westeurope"
    sku                 = "Standard"
    allocation_method   = "Static"
    tags_from_rg        = true
}
```

### Example 2: Public IP with domain name label

```hcl
module "public_ip" {
  source = "../../"

  public_ip = {
    name                = "public-ip-name"
    resource_group_name = "resource-group-name"
    location            = "westeurope"
    sku                 = "Standard"
    allocation_method   = "Static"
    domain_name_label   = "domain-name"
    tags_from_rg        = true
}
```
