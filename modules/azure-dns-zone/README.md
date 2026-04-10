<!-- BEGIN_TF_DOCS -->
# Azure DNS Zone Terraform Module

## Overview

This module provisions an Azure DNS Zone and manages multiple DNS record types in the same zone. It is designed for scenarios where you need DNS management as code for environments such as dev, staging, and production.

Key capabilities include:
- Automated creation of a DNS zone
- Tag inheritance from Resource Group with override support
- Management of A, AAAA, CNAME, MX, TXT, NS, CAA, PTR, and SRV records
- Optional tag support on MX, TXT, NS, CAA, and SRV records

This module is ideal for teams seeking a reusable way to manage DNS zones and records from a single Terraform module.

## Key Features

- **DNS Zone Creation**: Provisions an Azure DNS Zone.
- **Record Management**: Supports A, AAAA, CNAME, MX, TXT, NS, CAA, PTR, and SRV records.
- **Individual TTL Control**: Each record can have its own TTL configuration.
- **Duplicate Prevention**: Automatic validation to prevent duplicate record names within the same record type.
- **Tag Strategy**: Supports direct tags or inheriting tags from the Resource Group and merging with custom tags.
- **Record-Level Tags**: Supports optional `tags` per MX, TXT, NS, CAA, and SRV record.

## Validation Rules

This module enforces the following validation rules to prevent configuration errors and DNS inconsistencies:

- **Unique Record Names per Type**: Each record type (A, AAAA, CNAME, MX, TXT, NS, CAA, PTR, SRV) must have unique names within that type. Duplicate record names will cause the plan to fail with a clear error message.
  
  Example error:
  ```
  Error: Invalid value for variable
  
  CNAME records must have unique names. Found duplicate record names.
  ```

This validation helps avoid:
- **Redundancy**: Preventing accidental duplicate entries
- **Collision Detection**: Catching configuration mistakes early
- **DNS Consistency**: Ensuring each record name is defined only once per type

## Basic Usage

### Minimal Example

```hcl
module "dns_zone" {
  source              = "git::https://github.com/prefapp/tfm.git//modules/azure-dns-zone"
  dns_zone_name       = "example.com"
  resource_group_name = "my-rg"
}
```

### With Tags Inherited From Resource Group

```hcl
module "dns_zone" {
  source              = "git::https://github.com/prefapp/tfm.git//modules/azure-dns-zone"
  dns_zone_name       = "example.com"
  resource_group_name = "my-rg"
  tags_from_rg        = true
  tags = {
    environment = "dev"
    owner       = "network-team"
  }
}
```

### With DNS Records

```hcl
module "dns_zone" {
  source              = "git::https://github.com/prefapp/tfm.git//modules/azure-dns-zone"
  dns_zone_name       = "example.com"
  resource_group_name = "my-rg"

  a_records = [
    {
      name    = "www"
      ttl     = 3600
      records = ["1.2.3.4"]
    },
    {
      name    = "api"
      ttl     = 300
      records = ["1.2.3.4", "5.6.7.8"]
    }
  ]

  aaaa_records = [
    {
      name    = "ipv6"
      ttl     = 300
      records = ["2001:db8::1"]
    }
  ]

  cname_records = [
    {
      name   = "mail"
      ttl    = 3600
      record = "mail.external.com."
    }
  ]

  mx_records = [
    {
      name = "@"
      records = [
        { preference = 10, exchange = "mx1.example.com." },
        { preference = 20, exchange = "mx2.example.com." }
      ]
      tags = {
        service = "mail"
      }
    }
  ]

  txt_records = [
    {
      name = "@"
      records = [
        { value = "v=spf1 include:mailgun.org ~all" }
      ]
      tags = {
        service = "mail"
      }
    }
  ]
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3.0 |
| azurerm   | >= 4.21.1 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 4.21.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| n/a | n/a | n/a |

## Resources

| Name | Type |
|------|------|
| azurerm_dns_a_record.this | resource |
| azurerm_dns_aaaa_record.this | resource |
| azurerm_dns_caa_record.this | resource |
| azurerm_dns_cname_record.this | resource |
| azurerm_dns_mx_record.this | resource |
| azurerm_dns_ns_record.this | resource |
| azurerm_dns_ptr_record.this | resource |
| azurerm_dns_srv_record.this | resource |
| azurerm_dns_txt_record.this | resource |
| azurerm_dns_zone.this | resource |
| azurerm_resource_group.resource_group | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| a_records | A records to create. List of objects: { name, ttl (optional, default 60), records (list of IPs) } | list(object({ name = string, ttl = optional(number, 60), records = list(string) })) | [] | no |
| aaaa_records | AAAA records to create. List of objects: { name, ttl, records (list of IPs) } | list(object({ name = string, ttl = optional(number, 60), records = list(string) })) | [] | no |
| caa_records | CAA records to create. List of objects: { name, ttl, records (list of { flags, tag, value }) } | list(object({ name = string, ttl = optional(number, 60), records = list(object({ flags = number, tag = string, value = string })), tags = optional(map(string), {}) })) | [] | no |
| cname_records | CNAME records to create. List of objects: { name, ttl (optional, default 60), record (target) } | list(object({ name = string, ttl = optional(number, 60), record = string })) | [] | no |
| dns_zone_name | Name of the Azure DNS Zone. | string | n/a | yes |
| mx_records | MX records to create. List of objects: { name, ttl, records (list of { preference, exchange }) } | list(object({ name = string, ttl = optional(number, 60), records = list(object({ preference = number, exchange = string })), tags = optional(map(string), {}) })) | [] | no |
| ns_records | NS records to create. List of objects: { name, ttl, records (list of strings) } | list(object({ name = string, ttl = optional(number, 60), records = list(string), tags = optional(map(string), {}) })) | [] | no |
| ptr_records | PTR records to create. List of objects: { name, ttl, records (list of strings) } | list(object({ name = string, ttl = optional(number, 60), records = list(string) })) | [] | no |
| resource_group_name | Resource group name where DNS zone will be created. | string | n/a | yes |
| srv_records | SRV records to create. List of objects: { name, ttl, records (list of { priority, weight, port, target }) } | list(object({ name = string, ttl = optional(number, 60), records = list(object({ priority = number, weight = number, port = number, target = string })), tags = optional(map(string), {}) })) | [] | no |
| tags | Tags to apply to the DNS zone. | map(string) | {} | no |
| tags_from_rg | Use the tags from the resource group | bool | false | no |
| txt_records | TXT records to create. List of objects: { name, ttl, records (list of { value }) } | list(object({ name = string, ttl = optional(number, 60), records = list(object({ value = string })), tags = optional(map(string), {}) })) | [] | no |

## Outputs

| Name | Description |
|------|-------------|
| dns_zone_id | ID of the DNS Zone. |
| dns_zone_name | Name of the DNS Zone. |

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-dns-zone/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-dns-zone/_examples/basic) - Minimal configuration for a DNS zone

## Resources

- **Azure DNS Zone**: [https://learn.microsoft.com/en-us/azure/dns/dns-overview](https://learn.microsoft.com/en-us/azure/dns/dns-overview)
- **Terraform Azure Provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_zone](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_zone)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->
