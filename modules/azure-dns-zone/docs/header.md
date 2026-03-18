# **Azure DNS Zone Terraform Module**

## Overview

This module provisions a standard Azure DNS Zone. It is designed for scenarios where you need to manage public DNS zones for your domains in Azure, supporting use cases such as application hosting, hybrid cloud, and multi-environment deployments (dev, staging, production).

Key capabilities include:
- Automated creation of a DNS zone
- Tagging support for resource management
- Integration with Azure Resource Groups

This module is ideal for teams seeking a simple, reusable way to manage DNS zones as code.

## Key Features

- **DNS Zone Creation**: Provisions a standard Azure DNS Zone.
- **Tagging Support**: Allows custom tags for resource organization.
- **Resource Group Integration**: DNS zone is created in the specified resource group.

## Basic Usage

### Minimal Example

```hcl
module "dns_zone" {
  source              = "git::https://github.com/prefapp/tfm.git//modules/azure-dns-zone"
  dns_zone_name       = "example.com"
  resource_group_name = "my-rg"
}
```

### With Custom Tags

```hcl
module "dns_zone" {
  source              = "git::https://github.com/prefapp/tfm.git//modules/azure-dns-zone"
  dns_zone_name       = "example.com"
  resource_group_name = "my-rg"
  tags = {
    environment = "production"
    owner       = "network-team"
  }
}
```
