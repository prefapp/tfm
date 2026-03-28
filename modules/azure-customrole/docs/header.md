# Azure Custom Role Terraform Module

## Overview

This Terraform module allows you to create a custom role in Azure, specifying actions, data actions, and the assignable scopes.

## Main features
- Create custom roles in Azure.
- Flexible definition of actions, data actions, not actions, and not data actions.
- Support for multiple assignable scopes.

## Full example

You can find a full example in [`_examples/basic/values.yaml`](../_examples/basic/values.yaml).

## File structure

```
.
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── README.md
├── CHANGELOG.md
└── docs/
    ├── header.md
    └── footer.md
```
