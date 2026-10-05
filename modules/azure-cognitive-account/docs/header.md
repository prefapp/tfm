# **Azure Cognitive Services Account Terraform Module**

## Overview

This module creates and manages one Azure Cognitive Services account using
`azurerm_cognitive_account`. It supports Azure OpenAI accounts and other account kinds
supported by the AzureRM provider. The target resource group must already exist. Model
deployments are separate resources and are not created by this module.

The module exposes the account endpoint, resource ID, name, custom subdomain, and tags.
It configures public network access and account network ACLs, with optional IP and
virtual network rules. Tags can be supplied directly or merged with the resource
group's existing tags.

## Key features

- **One account per module instance**: clear Terraform state ownership for a single account.
- **Azure OpenAI support**: defaults the account kind to `OpenAI` and exposes its endpoint.
- **Network ACLs**: supports allow/deny defaults, IP rules, subnet rules, and trusted-service bypass.
- **Tag inheritance**: optionally merges resource group tags with module tags; module values take precedence.
- **Model deployment separation**: model name, version, and capacity are outside this module.

## Prerequisites

- The resource group must exist before applying this module.
- The AzureRM provider identity needs permission to manage Cognitive Services accounts and, when enabled, read the resource group for tag inheritance.
- The account name and custom subdomain must be available in Azure.

## Examples

Each example directory contains exactly two files: `example.tf` for the Terraform
module call and `example.yaml` showing the equivalent values in YAML. The **basic**
example uses public access and direct tags. The **restricted** example uses a
default-deny ACL, a subnet rule, and inherited resource group tags.

The subnet in a virtual network rule must have the Microsoft Cognitive Services
service endpoint enabled. A default-deny ACL only allows matching configured rules.

## Import and lifecycle

The AzureRM provider supports importing this resource by its full Azure resource ID:

```text
/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.CognitiveServices/accounts/<account-name>
```

The resource address inside this module is `azurerm_cognitive_account.this` (for a module call named `cognitive_account`, the root address is `module.cognitive_account.azurerm_cognitive_account.this`). Destroying the module deletes the Cognitive Services account and can make dependent model deployments or data inaccessible. Before replacing an existing inline claim with this module, migrate the existing state to the module resource address or import the existing account; do not apply with an empty state against an account already in Azure.

The AzureRM provider attempts to purge the account during deletion. Review the provider's `features.cognitive_account.purge_soft_delete_on_destroy` setting before enabling destroy workflows, especially when soft-delete recovery is required.

## File structure

```
.
├── data.tf
├── locals.tf
├── main.tf
├── variables.tf
├── versions.tf
├── outputs.tf
├── docs/
└── _examples/
```
