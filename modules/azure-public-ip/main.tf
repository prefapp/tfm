# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group
data "azurerm_resource_group" "resource_group" {
  name = var.resource_group_name
}

resource "azurerm_public_ip" "inss-common-predev-public-ip" {
  name                = var.public_ip_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.public_ip_sku
  allocation_method   = var.public_ip_allocation_method

tags = var.tags_from_rg ? data.azurerm_resource_group.resource_group.tags : var.tags

  lifecycle {
    # https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle#prevent_destroy
    prevent_destroy = true
  }
}
