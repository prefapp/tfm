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
  tags                = var.tags_from_rg ? data.azurerm_resource_group.resource_group[0].tags : var.tags
}

# https://registry.terraform.io/providers/hashicorp/azurerm/4.21.1/docs/data-sources/resource_group
data "azurerm_resource_group" "resource_group" {
  count = var.tags_from_rg ? 1 : 0
  name  = var.resource_group_name
}
