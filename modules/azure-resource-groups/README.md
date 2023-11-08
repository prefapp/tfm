# Azure resource_groups

## Overview

This module creates only resource groups into Azure provicer.

## DOC

- [Resource terraform - resource-group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group).

## Usage

### Set a module

```terraform
module "githuib-oidc" {
  source = "git::https://github.com/prefapp/tfm.git//modules/resource-groups?ref=<version>"
}
```

#### Example

```terraform
module "githuib-oidc" {
  source = "git::https://github.com/prefapp/tfm.git//modules/resource-groups?ref=v1.2.3"
}
```

### Set a data .tfvars

#### Example

```hcl
resource_groups = {
  group1 = {
    location = "East US"
    tags     = {
      tag1 = "value1"
      tag2 = "value2"
    }
  }
  group2 = {
    location = "West Europe"
    tags     = {
      tag3 = "value3"
      tag4 = "value4"
    }
  }
  group3 = {
    location = "Central US"
    tags     = {
      tag5 = "value5"
      tag6 = "value6"
    }
  }
}
```
