# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association
# Resource block for creating Azure network security group associations
resource "azurerm_subnet_network_security_group_association" "association" {
  for_each = { for subnet_name, subnet in var.subnets : subnet_name => subnet if subnet.network_security_group != null }

  subnet_id                 = azurerm_subnet.subnet[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id
}
