# Azure Network Security Group & Rules Terraform Module

## Overview

This Terraform module allows you to create and manage an Azure Network Security Group (NSG) and its rules, with support for:
- Custom NSG and security rule definitions.
- Tag inheritance from the resource group.
- Flexible configuration for ports, protocols, and address prefixes.

## Main features
- Create an NSG with custom tags and location.
- Define multiple security rules with granular control.
- Support for both single and multiple port/address fields.
- Realistic configuration example.

## Complete usage example

### HCL
```hcl
tags_from_rg        = false
tags = {
  env = "Production"
}
nsg = { 
  name                = "example-nsg"
  location            = "East US"
  resource_group_name = "example-rg"
}
rules = {
  rule1 = {
    name                       = "AllowSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.0.0/24"
    destination_address_prefix = "*"
  }
  rule2 = {
    name                       = "AllowHTTP"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "0.0.0.0/0"
    destination_address_prefix = "*"
  }
} 
```

### YAML
```yaml
values:
  tags_from_rg: false
  tags:
    env: "Production"
  nsg:
    name: "example-nsg"
    location: "East US"
    resource_group_name: "example-rg"
  rules:
    rule1:
      name: "AllowSSH"
      priority: 100
      direction: "Inbound"
      access: "Allow"
      protocol: "Tcp"
      source_port_range: "*"
      destination_port_range: "22"
      source_address_prefix: "10.0.0.0/24"
      destination_address_prefix: "*"
    rule2:
      name: "AllowHTTP"
      priority: 200
      direction: "Inbound"
      access: "Allow"
      protocol: "Tcp"
      source_port_range: "*"
      destination_port_range: "80"
      source_address_prefix: "0.0.0.0/0"
      destination_address_prefix: "*"
```

## Notes
- You must provide at least one of each: `*_range` or `*_ranges` and `*_prefix` or `*_prefixes`, but not both at the same time.
- You can use `tags_from_rg` to inherit tags exclusively from the resource group.

## File structure

```
.
├── main.tf
├── variables.tf
├── outputs.tf
├── README.MD
├── CHANGELOG.md
└── docs/
    ├── header.md
    └── footer.md
```
