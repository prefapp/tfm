# Azure Public IP Prefix Terraform Module

## Overview

This Terraform module allows you to create and manage an Azure Public IP Prefix, supporting all configuration options for version, SKU, tier, zones, and tags.

## Main features
- Create a Public IP Prefix with custom name, location, and resource group.
- Support for IPv4/IPv6, SKU, tier, prefix length, and availability zones.
- Flexible tagging for resource organization.
- Realistic configuration example.

## Complete usage example

```yaml
values:
  name: "example_name"
  resource_group_name: "example_rg"
  location: "westeurope"
  sku: "Standard"
  sku_tier: "Regional"
  ip_version: "IPv4"
  prefix_length: 29
  zones: ["1"]
  tags:
    application: "example_app"
    env: "example_env"
    tenant: "example_tenant"
```

## Notes
- You can specify IPv4 or IPv6, and configure all SKU and tier options.
- Use the `zones` input for high availability.
- Tags help organize and identify your resources.

## File structure

```
.
├── main.tf
├── variables.tf
├── outputs.tf
├── README.md
├── CHANGELOG.md
└── docs/
    ├── header.md
    └── footer.md
```