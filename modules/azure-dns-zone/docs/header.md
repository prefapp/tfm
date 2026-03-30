# **Azure DNS Zone Terraform Module**

## Overview

This module provisions an Azure DNS Zone and manages multiple DNS record types in the same zone. It is designed for scenarios where you need DNS management as code for environments such as dev, staging, and production.

Key capabilities include:
- Automated creation of a DNS zone
- Tag inheritance from Resource Group with override support
- Management of A, AAAA, CNAME, MX, TXT, NS, CAA, PTR, and SRV records

This module is ideal for teams seeking a reusable way to manage DNS zones and records from a single Terraform module.

## Key Features

- **DNS Zone Creation**: Provisions an Azure DNS Zone.
- **Record Management**: Supports A, AAAA, CNAME, MX, TXT, NS, CAA, PTR, and SRV records.
- **Tag Strategy**: Supports direct tags or inheriting tags from the Resource Group and merging with custom tags.

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

  a_records = {
    "www" = ["1.2.3.4"]
    "api" = ["1.2.3.4", "5.6.7.8"]
  }

  aaaa_records = [
    {
      name    = "ipv6"
      ttl     = 300
      records = ["2001:db8::1"]
    }
  ]

  cname_records = {
    "mail" = "mail.external.com."
  }

  mx_records = [
    {
      name = "@"
      records = [
        { preference = 10, exchange = "mx1.example.com." },
        { preference = 20, exchange = "mx2.example.com." }
      ]
    }
  ]

  txt_records = [
    {
      name = "@"
      records = [
        { value = "v=spf1 include:mailgun.org ~all" }
      ]
    }
  ]
}
```
