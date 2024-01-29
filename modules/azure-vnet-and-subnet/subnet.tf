# Resource block for creating Azure subnets
# See: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet
resource "azurerm_subnet" "subnet" {
  for_each = var.subnets

  # el nombre de la subnet será la key del objeto subnet
  name                                          = each.key
  resource_group_name                           = var.resource_group
  virtual_network_name                          = azurerm_virtual_network.vnet.name
  address_prefixes                              = each.value.address_prefixes
  private_endpoint_network_policies_enabled     = each.value.private_endpoint_network_policies_enabled
  private_link_service_network_policies_enabled = each.value.private_link_service_network_policies_enabled
  service_endpoints                             = each.value.service_endpoints

  # Dynamic block for creating service delegations
  dynamic "delegation" {
    for_each = each.value.delegation != null ? each.value.delegation : []
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = delegation.value.service_delegation.actions
      }
    }
  }
  depends_on = [
    azurerm_virtual_network.vnet
  ]
}

# Resource block for creating Azure network security groups
resource "azurerm_network_security_group" "nsg" {
  for_each = { for subnet_name, subnet in var.subnets : subnet_name => subnet if subnet.network_security_group != null }

  name                = each.value.network_security_group.name
  location            = var.location
  resource_group_name = var.resource_group

  dynamic "security_rule" {
    for_each = each.value.network_security_group.security_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
}

# Resource block for creating Azure network security group associations
resource "azurerm_subnet_network_security_group_association" "association" {
  for_each = { for subnet_name, subnet in var.subnets : subnet_name => subnet if subnet.network_security_group != null }

  subnet_id                 = azurerm_subnet.subnet[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id
}

