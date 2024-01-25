# Azure resource_groups

## Overview

This module creates only resource groups into Azure provicer.

## DOC

- [Resource terraform - resource-group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group).

## Advertisement

This module ignore some key tags for the resource group, this tags are:

- cliente
- producto
- env

## Usage

### Set a module

```terraform
module "githuib-oidc" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-resource-group?ref=<version>"
}
```

#### Example

```terraform
module "githuib-oidc" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-resource-group?ref=v1.2.3"
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
