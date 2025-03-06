# Data section
#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group
data "azurerm_resource_group" "resource_group" {
  name = var.resource_group
}

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet
data "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  virtual_network_name = local.virtual_network_name
  resource_group_name  = local.resource_group_name
}

data "azurerm_resources" "subnet" {
  type = "Microsoft.Network/virtualNetworks"
  required_tags = {
    application = "common"
    tenant      = "${data.azurerm_resource_group.resource_group.tags.tenant}"
    env         = "${data.azurerm_resource_group.resource_group.tags.env == "pro" ? "predev" : data.azurerm_resource_group.resource_group.tags.env}"
  }
}

locals {
  vnet_name                   = data.azurerm_resources.subnet.name
  vnet_resource_group_name    = data.azurerm_resources.subnet.resource_group_name
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/private_dns_zone
data "azurerm_private_dns_zone" "dns_private_zone" {
  name                = var.dns_private_zone.name
  resource_group_name = var.dns_private_zone.resource_group_name
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault
data "azurerm_key_vault" "key_vault" {
  name                = var.key_vault.name
  resource_group_name = var.key_vault.resource_group_name
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secrets
data "azurerm_key_vault_secret" "administrator_password" {
  name         = var.administrator_password_key_vault_secret_name
  key_vault_id = data.azurerm_key_vault.key_vault.id
}
