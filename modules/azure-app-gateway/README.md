<!-- BEGIN_TF_DOCS -->
# Azure Application Gateway Terraform module

## Overview

This module deploys an **Azure Application Gateway (WAF\_v2-capable SKU)** with a **dedicated public IP**, attaches a **Web Application Firewall policy**, and wires **Key Vault–backed TLS certificates**, optional **mutual TLS profiles** (trusted client certificates fetched from **GitHub** via `external` data sources), **rewrite rule sets**, and a structured **`application_gateway.blocks`** model for listeners, backends, probes, redirects, and routing rules.

Use it when you already have a **resource group**, **delegated subnet**, and **user-assigned managed identity** (for Key Vault access and gateway identity) and want Terraform to own the Application Gateway plus WAF policy lifecycle.

## Key features

- **Application Gateway**: `azurerm_application_gateway` with SKU/autoscale, identity, frontend ports/IP, backend pools and HTTP settings, health probes, HTTP listeners, redirect and request routing rules, SSL certificates from Key Vault, gateway-level **SSL policy**, optional **SSL profiles** and **trusted client certificates**.
- **WAF**: `azurerm_web_application_firewall_policy` linked through `firewall_policy_id`, driven by `web_application_firewall_policy` (managed rule sets, optional custom rules, policy settings).
- **Public IP**: `azurerm_public_ip` from `public_ip` input.
- **Networking & identity**: Data sources for **resource group**, **subnet**, and **user-assigned identity** referenced by name and resource group.
- **Tags**: Optional merge of resource group tags via `tags_from_rg` plus explicit `tags` (see `locals_rg.tf`).
- **SSL profiles & CA bundles**: When `ssl_profiles` is non-empty, **`data.external`** scripts list and download `.pem`/`.cer` assets from the **GitHub Contents API** (`wget`, `jq`, `bash` required at plan/apply time and outbound HTTPS access).

## Prerequisites

- **AzureRM** provider configured (this module pins **`azurerm`** in `versions.tf`).
- **`hashicorp/external`** is declared in `versions.tf` because of the GitHub certificate fetch logic.
- Subnet delegated/sized appropriately for Application Gateway; managed identity with permissions to referenced Key Vault secrets for TLS.

## Basic usage

Point the module at your resource group, subnet, identity, and pass the large **`application_gateway`**, **`public_ip`**, **`web_application_firewall_policy`**, and optional **`ssl_profiles`** / **`rewrite_rule_sets`** objects. See `_examples/comprehensive/values.reference.yaml` for a full illustrative `values` tree.

```hcl
module "app_gateway" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-app-gateway?ref=<version>"

  resource_group_name = "example-rg"
  location            = "westeurope"
  user_assigned_identity = "example-uami"
  subnet = {
    name                 = "appgw-subnet"
    virtual_network_name = "example-vnet"
  }
  public_ip = {
    name                = "example-pip"
    sku                 = "Standard"
    allocation_method   = "Static"
  }
  web_application_firewall_policy = { /* see variable type and example YAML */ }
  application_gateway             = { /* see example YAML */ }
}
```

## File structure

```
.
├── CHANGELOG.md
├── main.tf
├── data.tf
├── public_ip.tf
├── web_application_firewall_policy.tf
├── locals_*.tf
├── variables.tf
├── outputs.tf
├── versions.tf
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
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 4.47.0 |
| <a name="requirement_external"></a> [external](#requirement\_external) | ~> 2.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.47.0 |
| <a name="provider_external"></a> [external](#provider\_external) | 2.3.5 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_application_gateway.application_gateway](https://registry.terraform.io/providers/hashicorp/azurerm/4.47.0/docs/resources/application_gateway) | resource |
| [azurerm_public_ip.public_ip](https://registry.terraform.io/providers/hashicorp/azurerm/4.47.0/docs/resources/public_ip) | resource |
| [azurerm_web_application_firewall_policy.default_waf_policy](https://registry.terraform.io/providers/hashicorp/azurerm/4.47.0/docs/resources/web_application_firewall_policy) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.47.0/docs/data-sources/resource_group) | data source |
| [azurerm_subnet.that](https://registry.terraform.io/providers/hashicorp/azurerm/4.47.0/docs/data-sources/subnet) | data source |
| [azurerm_user_assigned_identity.that](https://registry.terraform.io/providers/hashicorp/azurerm/4.47.0/docs/data-sources/user_assigned_identity) | data source |
| [external_external.cert_content_base64](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |
| [external_external.list_cert_files](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_gateway"></a> [application\_gateway](#input\_application\_gateway) | Structured Application Gateway configuration (SKU, autoscale, identity, listeners, `blocks_defaults`, `blocks`, SSL certificates, etc.). See `_examples/comprehensive/values.reference.yaml` for a full shape. | `any` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The location/region where the Application Gateway should be created. | `string` | `"westeurope"` | no |
| <a name="input_public_ip"></a> [public\_ip](#input\_public\_ip) | Public IP for the Application Gateway frontend (`name`, `sku`, `allocation_method`, etc.). | `any` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which to create the Application Gateway. | `string` | n/a | yes |
| <a name="input_rewrite_rule_sets"></a> [rewrite\_rule\_sets](#input\_rewrite\_rule\_sets) | List of Rewrite Rule Sets for Application Gateway | <pre>list(object({<br/>    name = string<br/>    rewrite_rules = list(object({<br/>      name          = string<br/>      rule_sequence = number<br/>      conditions = optional(list(object({<br/>        variable    = string<br/>        pattern     = string<br/>        ignore_case = optional(bool, false)<br/>        negate      = optional(bool, false)<br/>      })), [])<br/>      request_header_configurations = optional(list(object({<br/>        header_name  = string<br/>        header_value = string<br/>      })), [])<br/>      response_header_configurations = optional(list(object({<br/>        header_name  = string<br/>        header_value = string<br/>      })), [])<br/>      url_rewrite = optional(object({<br/>        source_path = optional(string)<br/>        query_string = optional(string)<br/>        components = optional(string)<br/>        reroute = optional(bool)<br/>      }))<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_ssl_policy"></a> [ssl\_policy](#input\_ssl\_policy) | Gateway-level SSL policy (`policy_type`, optional `policy_name`, `cipher_suites`, `min_protocol_version`). | <pre>object({<br/>    policy_type          = string<br/>    policy_name          = optional(string)<br/>    cipher_suites        = optional(list(string))<br/>    min_protocol_version = optional(string)<br/>  })</pre> | <pre>{<br/>  "policy_name": "AppGwSslPolicy20220101",<br/>  "policy_type": "Predefined"<br/>}</pre> | no |
| <a name="input_ssl_profiles"></a> [ssl\_profiles](#input\_ssl\_profiles) | List of SSL profiles for Application Gateway. | <pre>list(object({<br/>    name                                     = string<br/>    trusted_client_certificate_names         = optional(list(string))<br/>    verify_client_cert_issuer_dn             = optional(bool, false)<br/>    verify_client_certificate_revocation     = optional(string)<br/>    ssl_policy = optional(object({<br/>      disabled_protocols                     = optional(list(string))<br/>      min_protocol_version                   = optional(string)<br/>      policy_name                            = optional(string)<br/>      cipher_suites                          = optional(list(string))<br/>    }))<br/>    ca_certs_origin = object({<br/>      github_owner       = string<br/>      github_repository  = string<br/>      github_branch      = string<br/>      github_directory   = string<br/>    })<br/>  }))</pre> | `[]` | no |
| <a name="input_subnet"></a> [subnet](#input\_subnet) | Subnet where the gateway is deployed (`name`, `virtual_network_name` within `resource_group_name`). | `any` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_tags_from_rg"></a> [tags\_from\_rg](#input\_tags\_from\_rg) | Use resource group tags as base for module tags | `bool` | `false` | no |
| <a name="input_user_assigned_identity"></a> [user\_assigned\_identity](#input\_user\_assigned\_identity) | The name of the User Assigned Identity. | `string` | n/a | yes |
| <a name="input_web_application_firewall_policy"></a> [web\_application\_firewall\_policy](#input\_web\_application\_firewall\_policy) | Configuration for the web application firewall policy | <pre>object({<br/>    name = string<br/>    policy_settings = optional(object({<br/>      enabled                     = optional(bool)<br/>      mode                        = optional(string)<br/>      request_body_check          = optional(bool)<br/>      file_upload_limit_in_mb     = optional(number)<br/>      max_request_body_size_in_kb = optional(number)<br/>      request_body_enforcement    = optional(string)<br/>    }))<br/>    custom_rules = optional(list(object({<br/>      enabled               = optional(bool, true)<br/>      name                  = string<br/>      priority              = number<br/>      rule_type             = string<br/>      action                = string<br/>      rate_limit_duration   = optional(string)<br/>      rate_limit_threshold  = optional(number)<br/>      group_rate_limit_by   = optional(string)<br/>      match_conditions      = list(object({<br/>        operator           = string<br/>        negation_condition = optional(bool, false)<br/>        match_values       = optional(list(string))<br/>        transforms         = optional(list(string))<br/>        match_variables    = list(object({<br/>          variable_name = string<br/>          selector      = optional(string)<br/>        }))<br/>      }))<br/>    })), [])<br/>    managed_rule_set = list(object({<br/>      type                = optional(string)<br/>      version             = string<br/>      rule_group_override = optional(list(object({<br/>        rule_group_name = string<br/>        rule = optional(list(object({<br/>          id      = number<br/>          enabled = optional(bool)<br/>          action  = optional(string)<br/>        })))<br/>      })))<br/>    }))<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | Resource ID of the Application Gateway. |

## Examples

- [comprehensive](https://github.com/prefapp/tfm/tree/main/modules/azure-app-gateway/_examples/comprehensive) — Large **`values.reference.yaml`** migrated from the legacy README (Prefapp-style `values:` root); adapt placeholders for your tenant.
- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-app-gateway/_examples/basic) — Pointers and prerequisites only (this module is driven by rich input objects rather than a tiny HCL snippet).

## Operational notes

- **`external` data sources** run `bash` with `wget` and `jq` against **api.github.com** when `ssl_profiles` pulls CA material. Ensure the Terraform runtime has those tools and network egress, or keep `ssl_profiles` empty if you do not need that path.

## Remote resources

- **Application Gateway**: [https://learn.microsoft.com/azure/application-gateway/overview](https://learn.microsoft.com/azure/application-gateway/overview)
- **WAF policy**: [https://learn.microsoft.com/azure/web-application-firewall/ag/application-gateway-waf-overview](https://learn.microsoft.com/azure/web-application-firewall/ag/application-gateway-waf-overview)
- **Terraform AzureRM provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest](https://registry.terraform.io/providers/hashicorp/azurerm/latest)

## Support

For issues, questions, or contributions related to this module, please visit the repository’s issue tracker: [https://github.com/prefapp/tfm/issues](https://github.com/prefapp/tfm/issues)
<!-- END_TF_DOCS -->
