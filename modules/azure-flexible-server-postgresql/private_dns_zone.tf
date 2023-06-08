data "azurerm_private_dns_zone" "private_dns_zone" {
  name                = local.data.dns.private.name
  resource_group_name = local.data.dns.private.resource_group
}