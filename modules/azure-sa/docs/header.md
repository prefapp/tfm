# Azure Storage Account Terraform Module

## Overview

This Terraform module allows you to create and manage an Azure Storage Account, including:
- Advanced account configuration (tier, replication, network, TLS, etc.)
- Support for blobs, queues, tables, and shares
- Lifecycle policies and network rules
- Integration with subnets and advanced threat protection
- Flexible tagging and inheritance from the Resource Group

## Main features
- Create Storage Account with advanced configuration
- Support for containers, queues, tables, and shares
- Customizable lifecycle policies and network rules
- Integration with subnets and advanced protection
- Tag management and inheritance from Resource Group

## Requirements
- Terraform >= 1.7.0
- Provider azurerm ~> 4.38.1

## File structure

```
.
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── README.md
├── CHANGELOG.md
├── docs/
│   ├── header.md
│   └── footer.md
└── _examples/
    ├── basic/
    │   └── main.tf
    └── complete/
        ├── main.tf
        └── values.yaml
```

## Basic usage example

```yaml
values:
  resource_group_name: "rg_test"
  storage_account:
    name: "mystorageaccount"
    account_tier: "Standard"
    account_replication_type: "LRS"
```

> For a complete and advanced example, see the file at `_examples/complete/values.yaml`.