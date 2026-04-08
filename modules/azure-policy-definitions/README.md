<!-- BEGIN_TF_DOCS -->
# Azure Policy definitions Terraform module (`azure-policy-definitions`)

## Overview

This module creates one or more **custom Azure Policy definitions** (`azurerm_policy_definition`) from a **list** of policy objects. Each item supplies name, type, mode, display name, and optional rule JSON, metadata, parameters, and management group scope.

An empty **`policies`** list (`[]`, default) creates no definitions.

## Key features

- **`for_each`** keyed by **`policy.name`** (must be unique per entry); reordering the list does not change resource addresses. Output list order follows **lexicographic sort of `name`**, not the input list order.
- **Outputs**: collected IDs and names of created definitions.

## Notes

- **State migration**: If you previously used a module version that keyed `for_each` by **list index**, upgrading to **`policy.name` keys** changes resource addresses. Use `terraform state mv` (from `azurerm_policy_definition.this[\"0\"]` to `azurerm_policy_definition.this[\"<policy-name>\"]`) or accept one-time replacement—plan carefully.

## Prerequisites

- **azurerm** provider configured with permissions to create policy definitions (subscription and/or management group, depending on `management_group_id`).

## Basic usage

```hcl
module "policy_definitions" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-policy-definitions?ref=<version>"

  policies = [
    {
      name         = "example-audit-location"
      policy_type  = "Custom"
      mode         = "All"
      display_name = "Audit specific location"
      description  = "Sample policy."
      policy_rule = jsonencode({
        if = {
          field  = "location"
          equals = "westeurope"
        }
        then = {
          effect = "audit"
        }
      })
    }
  ]
}
```

## File structure

```
.
├── CHANGELOG.md
├── main.tf
├── variables.tf
├── versions.tf
├── outputs.tf
├── docs
│   ├── footer.md
│   └── header.md
├── _examples
│   ├── basic
│   └── comprehensive
├── README.md
└── .terraform-docs.yml
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.22.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.22.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_policy_definition.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/policy_definition) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_policies"></a> [policies](#input\_policies) | Policy definitions to create; empty list creates no resources. | <pre>list(object({<br/>    name                = string<br/>    policy_type         = string<br/>    mode                = string<br/>    display_name        = string<br/>    description         = optional(string)<br/>    management_group_id = optional(string)<br/>    policy_rule         = optional(string)<br/>    metadata            = optional(string)<br/>    parameters          = optional(string)<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_policy_definition_ids"></a> [policy\_definition\_ids](#output\_policy\_definition\_ids) | IDs of created policy definitions, in lexicographic order of `name` (for\_each key)—not necessarily input list order. |
| <a name="output_policy_definition_names"></a> [policy\_definition\_names](#output\_policy\_definition\_names) | Names of created policy definitions, in lexicographic order of `name`. |

## Examples

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-policy-definitions/_examples/basic) — Minimal module call with `jsonencode` policy rules.
- [comprehensive](https://github.com/prefapp/tfm/tree/main/modules/azure-policy-definitions/_examples/comprehensive) — **`values.reference.yaml`**: illustrative list of policies (wire with `yamldecode` or copy into HCL).

## Remote resources

- **Terraform `azurerm_policy_definition`**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/policy_definition](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/policy_definition)
- **Azure Policy overview**: [https://learn.microsoft.com/azure/governance/policy/overview](https://learn.microsoft.com/azure/governance/policy/overview)
- **Terraform AzureRM provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest](https://registry.terraform.io/providers/hashicorp/azurerm/latest)

## Support

For issues, questions, or contributions related to this module, please visit the repository’s issue tracker: [https://github.com/prefapp/tfm/issues](https://github.com/prefapp/tfm/issues)
<!-- END_TF_DOCS -->