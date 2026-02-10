# Azure Resource Group Terraform Module

## Overview

This Terraform module allows you to create Azure Resource Groups with optional tags.

## Main features
- Create one or more resource groups in Azure.
- Support for custom tags for each resource group.
- Simple usage for both single and multiple groups.
- Realistic configuration example.

## Complete usage example

```terraform
module "github-oidc" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-resource-group?ref=<version>"
}

### HCL
```hcl
name     = "group_one"
location = "westEurope"
```

```hcl
name     = "group_two"
location = "westEurope"
tags     = {
  foo = "bar"
  bar = "foo"
}
```

## Notes
- You can define as many resource groups as needed, each with its own tags.
- Tags help organize and identify your resources.

## File structure

```
.
├── main.tf
├── variables.tf
├── outputs.tf
├── resource_groups.tf
├── README.md
├── CHANGELOG.md
└── docs/
    ├── header.md
    └── footer.md
```
