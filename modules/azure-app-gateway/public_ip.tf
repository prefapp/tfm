# https://registry.terraform.io/providers/hashicorp/azurerm/2.2.0/docs/resources/public_ip
resource "azurerm_public_ip" "public_ip" {
  name                = var.public_ip.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.public_ip.sku
  allocation_method   = var.public_ip.allocation_method
  tags                = local.tags
}
