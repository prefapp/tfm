terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.21.1"
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/4.21.1/docs/resources/dns_zone
resource "azurerm_dns_zone" "this" {
  name                = var.dns_zone_name
  resource_group_name = var.resource_group_name
  tags                = local.tags
}

# https://registry.terraform.io/providers/hashicorp/azurerm/4.21.1/docs/data-sources/resource_group
data "azurerm_resource_group" "resource_group" {
  count = var.tags_from_rg ? 1 : 0
  name  = var.resource_group_name
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_a_record
# DNS A records (one or multiple IPs)
resource "azurerm_dns_a_record" "this" {
  for_each            = { for rec in var.a_records : rec.name => rec }
  name                = each.value.name
  zone_name           = azurerm_dns_zone.this.name
  resource_group_name = var.resource_group_name
  ttl                 = each.value.ttl
  records             = each.value.records
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_aaaa_record
# DNS AAAA records
resource "azurerm_dns_aaaa_record" "this" {
  for_each            = { for rec in var.aaaa_records : rec.name => rec }
  name                = each.value.name
  zone_name           = azurerm_dns_zone.this.name
  resource_group_name = var.resource_group_name
  ttl                 = each.value.ttl
  records             = each.value.records
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_cname_record
# DNS CNAME records
resource "azurerm_dns_cname_record" "this" {
  for_each            = { for rec in var.cname_records : rec.name => rec }
  name                = each.value.name
  zone_name           = azurerm_dns_zone.this.name
  resource_group_name = var.resource_group_name
  ttl                 = each.value.ttl
  record              = each.value.record
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_mx_record
# DNS MX records
resource "azurerm_dns_mx_record" "this" {
  for_each            = { for rec in var.mx_records : "${rec.name}" => rec }
  name                = each.value.name
  zone_name           = azurerm_dns_zone.this.name
  resource_group_name = var.resource_group_name
  ttl                 = each.value.ttl
  dynamic "record" {
    for_each = each.value.records
    content {
      preference = record.value.preference
      exchange   = record.value.exchange
    }
  }
  tags                = each.value.tags
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_txt_record
# DNS TXT records
resource "azurerm_dns_txt_record" "this" {
  for_each            = { for rec in var.txt_records : "${rec.name}" => rec }
  name                = each.value.name
  zone_name           = azurerm_dns_zone.this.name
  resource_group_name = var.resource_group_name
  ttl                 = each.value.ttl
  dynamic "record" {
    for_each = each.value.records
    content {
      value = record.value.value
    }
  }
  tags                = each.value.tags
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_ns_record
# DNS NS records
resource "azurerm_dns_ns_record" "this" {
  for_each            = { for rec in var.ns_records : rec.name => rec }
  name                = each.value.name
  zone_name           = azurerm_dns_zone.this.name
  resource_group_name = var.resource_group_name
  ttl                 = each.value.ttl
  records             = each.value.records
  tags                = each.value.tags
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_caa_record
# DNS CAA records
resource "azurerm_dns_caa_record" "this" {
  for_each            = { for rec in var.caa_records : "${rec.name}" => rec }
  name                = each.value.name
  zone_name           = azurerm_dns_zone.this.name
  resource_group_name = var.resource_group_name
  ttl                 = each.value.ttl
  dynamic "record" {
    for_each = each.value.records
    content {
      flags = record.value.flags
      tag   = record.value.tag
      value = record.value.value
    }
  }
  tags                = each.value.tags
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_ptr_record
# DNS PTR records
resource "azurerm_dns_ptr_record" "this" {
  for_each            = { for rec in var.ptr_records : rec.name => rec }
  name                = each.value.name
  zone_name           = azurerm_dns_zone.this.name
  resource_group_name = var.resource_group_name
  ttl                 = each.value.ttl
  records             = each.value.records
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_srv_record
# DNS SRV records
resource "azurerm_dns_srv_record" "this" {
  for_each            = { for rec in var.srv_records : "${rec.name}" => rec }
  name                = each.value.name
  zone_name           = azurerm_dns_zone.this.name
  resource_group_name = var.resource_group_name
  ttl                 = each.value.ttl
  dynamic "record" {
    for_each = each.value.records
    content {
      priority = record.value.priority
      weight   = record.value.weight
      port     = record.value.port
      target   = record.value.target
    }
  }
  tags                = each.value.tags
}
