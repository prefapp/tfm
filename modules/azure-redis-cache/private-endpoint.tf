# https://registry.terraform.io/providers/hashicorp/azurerm/1.43.0/docs/resources/private_endpoint
resource "azurerm_private_endpoint" "this" {
  name                          = var.private_endpoint.name
  location                      = var.redis.location
  resource_group_name           = data.azurerm_resource_group.resource_group
  subnet_id                     = data.azurerm_subnet.subnet[0].id
  custom_network_interface_name = var.private_endpoint.custom_network_interface_name
  tags                          = local.tags
  private_dns_zone_group {
    name = data.azurerm_private_dns_zone.dns_private_zone[0].name
    private_dns_zone_ids = [ #Uso de data aqui para non introducir manualmente o dns_id
      data.azurerm_private_dns_zone.dns_private_zone[0].id,
    ]
  }
  private_service_connection {
    is_manual_connection           = var.private_endpoint.private_service_connection.is_manual_connection
    name                           = var.private_endpoint.name
    private_connection_resource_id = azurerm_redis_cache.this.id
    subresource_names = [
      "redisCache",
    ]
  }
  depends_on = [azurerm_redis_cache.this]
}
