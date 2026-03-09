# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group
data "azurerm_resource_group" "resource_group" {
  name = var.resource_group_name
}

resource "azurerm_nat_gateway" "this" {
  name                    = var.nat_gateway_name
  resource_group_name     = var.resource_group_name
  location                = var.location
  idle_timeout_in_minutes = var.nat_gateway_timeout
  sku_name                = var.nat_gateway_sku
  zones                   = var.nat_gateway_zones

  tags = var.tags_from_rg ? data.azurerm_resource_group.resource_group.tags : var.tags

  lifecycle {
    # https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle#prevent_destroy
    prevent_destroy = true
  }
}

resource "azurerm_nat_gateway_public_ip_association" "nat_gateway_public_ip_association" {
  nat_gateway_id       = azurerm_nat_gateway.this.id
  public_ip_address_id = var.public_ip_id
}

resource "azurerm_subnet_nat_gateway_association" "subnet_nat_gateway_association" {
  subnet_id      = var.subnet_id
  nat_gateway_id = azurerm_nat_gateway.this.id
}
