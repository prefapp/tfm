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

# DNS A records (one or multiple IPs)
resource "azurerm_dns_a_record" "this" {
  for_each            = var.a_records
  name                = each.key
  zone_name           = azurerm_dns_zone.this.name
  resource_group_name = var.resource_group_name
  ttl                 = var.a_record_ttl
  records             = each.value
}

# DNS CNAME records
resource "azurerm_dns_cname_record" "this" {
  for_each            = var.cname_records
  name                = each.key
  zone_name           = azurerm_dns_zone.this.name
  resource_group_name = var.resource_group_name
  ttl                 = var.cname_record_ttl
  record              = each.value
}

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
}

# DNS TXT records
resource "azurerm_dns_txt_record" "this" {
  for_each            = var.txt_records
  name                = each.key
  zone_name           = azurerm_dns_zone.this.name
  resource_group_name = var.resource_group_name
  ttl                 = 3600
  records             = each.value
}

# # DNS NS records
# resource "azurerm_dns_ns_record" "this" {
#   for_each            = { for rec in var.ns_records : rec.name => rec }
#   name                = each.value.name
#   zone_name           = azurerm_dns_zone.this.name
#   resource_group_name = var.resource_group_name
#   ttl                 = each.value.ttl
#   records             = each.value.records
# }
