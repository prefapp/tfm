# Data section
#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group
data "azurerm_resource_group" "resource_group" {
  name = var.resource_group
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet
data "azurerm_subnet" "subnet" {
  name                 = var.subnet.name
  virtual_network_name = var.subnet.vnet_name
  resource_group_name  = var.subnet.vnet_resource_group_name
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/private_dns_zone
data "azurerm_private_dns_zone" "dns_private_zone" {
  name                = var.dns_private_zone.name
  resource_group_name = var.dns_private_zone.resource_group_name
}

#KeyVault
data "azurerm_resources" "key_vault" {
  type = "Microsoft.KeyVault/vaults"
  required_tags = {
    Producto = "${data.azurerm_resource_group.resource_group.tags.Producto}"
    tenant   = "${data.azurerm_resource_group.resource_group.tags.cliente}"
    env      = "${data.azurerm_resource_group.resource_group.tags.env}"
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secrets
data "azurerm_key_vault_secret" "administrator_password" {
  name         = var.administrator_password_key_vault_secret_name
  key_vault_id = data.azurerm_resources.key_vault.id
}
