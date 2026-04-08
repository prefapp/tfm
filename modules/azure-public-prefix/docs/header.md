# Azure public IP prefix Terraform module (`azure-public-prefix`)

## Overview

This module creates an **`azurerm_public_ip_prefix`** in an existing resource group. Public IP prefixes provide a contiguous range of public addresses for use with Standard SKU public IPs (NAT gateways, load balancers, etc.).

Optional **tag merge** from the resource group is available via `tags_from_rg`.

## Key features

- **Standard SKU** public IP prefix with configurable **prefix length**, **IP version** (IPv4), **SKU tier** (Regional/Global), and optional **availability zones**.
- **Tags**: `tags` plus optional merge from the resource group when `tags_from_rg = true`.

## Prerequisites

- Existing **resource group** (`resource_group_name`).
- **azurerm** provider configured.

## Basic usage

```hcl
module "public_ip_prefix" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-public-prefix?ref=<version>"

  name                = "example-prefix"
  resource_group_name = "example-rg"
  location            = "westeurope"

  prefix_length = 29
  zones         = ["1"]

  tags_from_rg = false
  tags = {
    environment = "dev"
  }
}
```

## File structure

```
.
├── CHANGELOG.md
├── main.tf
├── locals.tf
├── variables.tf
├── versions.tf
├── outputs.tf
├── docs
│   ├── footer.md
│   └── header.md
├── _examples
│   ├── basic
│   └── comprehensive
├── README.md
└── .terraform-docs.yml
```
