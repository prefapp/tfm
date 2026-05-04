# Azure Application Gateway Terraform module

## Overview

This module deploys an **Azure Application Gateway (WAF_v2-capable SKU)** with a **dedicated public IP**, attaches a **Web Application Firewall policy**, and wires **Key Vault–backed TLS certificates**, optional **mutual TLS profiles** (trusted client certificates fetched from **GitHub** via `external` data sources), **rewrite rule sets**, and a structured **`application_gateway.blocks`** model for listeners, backends, probes, redirects, and routing rules.

Use it when you already have a **resource group**, **delegated subnet**, and **user-assigned managed identity** (for Key Vault access and gateway identity) and want Terraform to own the Application Gateway plus WAF policy lifecycle.

## Key features

- **Application Gateway**: `azurerm_application_gateway` with SKU/autoscale, identity, frontend ports/IP, backend pools and HTTP settings, health probes, HTTP listeners, redirect and request routing rules, SSL certificates from Key Vault, gateway-level **SSL policy**, optional **SSL profiles** and **trusted client certificates**.
- **WAF**: `azurerm_web_application_firewall_policy` linked through `firewall_policy_id`, driven by `web_application_firewall_policy` (managed rule sets, optional custom rules, policy settings).
- **Public IP**: `azurerm_public_ip` from `public_ip` input.
- **Networking & identity**: Data sources for **resource group**, **subnet**, and **user-assigned identity** referenced by name and resource group.
- **Tags**: Optional merge of resource group tags via `tags_from_rg` plus explicit `tags` (see `locals_rg.tf`).
- **SSL profiles & CA bundles**: When `ssl_profiles` is non-empty, **`data.external`** scripts list and download `.pem`/`.cer` assets from the **GitHub Contents API** (`wget`, `jq`, `bash` required at plan/apply time and outbound HTTPS access). The script calls `/contents/<directory>` **without** a `ref=` query parameter, so it follows the repository **default branch**; `ca_certs_origin.github_branch` in the variable schema is **not currently honored** by that fetch (see also `ssl_profiles` variable description).

## Prerequisites

- **AzureRM** provider configured (this module pins **`azurerm`** in `versions.tf`).
- **`hashicorp/external`** is declared in `versions.tf` because of the GitHub certificate fetch logic.
- Subnet delegated/sized appropriately for Application Gateway; managed identity with permissions to referenced Key Vault secrets for TLS.
- If you load CA bundles from GitHub, place the `.pem`/`.cer` files on the repo **default branch** path you configure; do not rely on `github_branch` until `data.tf` is updated to pass a Git ref to the Contents API.

## Basic usage

Point the module at your resource group, subnet, identity, and pass the large **`application_gateway`**, **`public_ip`**, **`web_application_firewall_policy`**, and optional **`ssl_profiles`** / **`rewrite_rule_sets`** objects. See `_examples/comprehensive/values.reference.yaml` for a full illustrative `values` tree.

> **GitHub CA fetch:** unauthenticated `wget` to `api.github.com` (see footer). For Git-backed CAs, the module currently uses the **default branch** only; `ca_certs_origin.github_branch` does not select another branch unless the implementation is extended.

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
