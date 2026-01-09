# DATA SECTION
data "azurerm_subnet" "this" {
  count                = var.nic != null ? 1 : 0
  name                 = var.nic.subnet_name
  virtual_network_name = var.nic.virtual_network_name
  resource_group_name  = var.nic.virtual_network_resource_group_name
}

# https://registry.terraform.io/providers/hashicorp/azurerm/3.91.0/docs/data-sources/resource_group
data "azurerm_resource_group" "this" {
  name = var.common.resource_group_name
}

data "azurerm_key_vault" "this" {
  count               = var.admin_password != null ? 1 : 0
  name                = try(var.admin_password.key_vault_name, null)
  resource_group_name = try(var.admin_password.resource_group_name, null)
}

data "azurerm_key_vault_secret" "this" {
  count        = var.admin_password != null ? 1 : 0
  name         = try(var.admin_password.secret_name, null)
  key_vault_id = try(data.azurerm_key_vault.this[0].id, null)
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources
data "azurerm_network_security_group" "this" {
  count               = var.nic.nsg != null ? 1 : 0
  name                = var.nic.nsg.name
  resource_group_name = var.nic.nsg.resource_group_name
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources
data "azurerm_public_ip" "this" {
  count               = var.nic.public_ip != null ? 1 : 0
  name                = var.nic.public_ip.name
  resource_group_name = var.nic.public_ip.resource_group_name
}
