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
name     = "group_one"
location = "westEurope"
```

```hcl
name     = "group_two"
location = "westEurope"
tags     = {
  foo: "bar"
  bar: "foo"
}
```