# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint
moved {
  from = azurerm_private_endpoint.this[0]
  to   = azurerm_private_endpoint.this["default"]
}
resource "azurerm_private_endpoint" "this" {
  for_each = var.private_endpoints

  name                          = each.value.name
  location                      = var.managed_redis.location
  resource_group_name           = data.azurerm_resource_group.resource_group.name
  subnet_id                     = data.azurerm_subnet.subnet[each.key].id
  custom_network_interface_name = each.value.custom_network_interface_name
  tags                          = local.tags

  private_dns_zone_group {
    name = each.value.dns_zone_group_name
    private_dns_zone_ids = [
      local.private_dns_zone_ids[each.key],
    ]
  }

  private_service_connection {
    is_manual_connection           = each.value.private_service_connection.is_manual_connection
    name                           = each.value.name
    private_connection_resource_id = azurerm_managed_redis.this.id
    subresource_names = [
      "redisEnterprise",
    ]
  }

  depends_on = [azurerm_managed_redis.this]
}
