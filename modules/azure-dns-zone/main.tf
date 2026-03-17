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
  tags                = var.tags
}
