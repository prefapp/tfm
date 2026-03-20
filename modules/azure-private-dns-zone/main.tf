terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.64.0"
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/4.64.0/docs/resources/private_dns_zone
resource "azurerm_private_dns_zone" "this" {
  name                = var.dns_zone_name
  resource_group_name = var.resource_group_name
  tags                = var.tags_from_rg ? data.azurerm_resource_group.resource_group.tags : var.tags
}

# https://registry.terraform.io/providers/hashicorp/azurerm/4.64.0/docs/resources/private_dns_zone_virtual_network_link
resource "azurerm_private_dns_zone_virtual_network_link" "link" {
  for_each = var.vnet_ids

  name                  = "${var.link_name_prefix}-${each.key}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.this.name
  virtual_network_id    = each.value
  registration_enabled  = var.registration_enabled
  tags                  = var.tags_from_rg ? data.azurerm_resource_group.resource_group.tags : var.tags
}
# https://registry.terraform.io/providers/hashicorp/azurerm/4.64.0/docs/data-sources/resource_group
data "azurerm_resource_group" "resource_group" {
  name = var.resource_group_name
}
