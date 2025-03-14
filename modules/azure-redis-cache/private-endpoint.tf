# https://registry.terraform.io/providers/hashicorp/azurerm/1.43.0/docs/resources/private_endpoint
resource "azurerm_private_endpoint" "this" {
  name                          = var.private_endpoint.name
  location                      = var.redis.location
  resource_group_name           = local.azurerm_resource_group.resource_group
  subnet_id                     = var.private_endpoint.subnet_id
  custom_network_interface_name = var.private_endpoint.custom_network_interface_name
  private_dns_zone_group {
    name = "default"
    private_dns_zone_ids = [ #Uso de data aqui para non introducir manualmente o dns_id
      var.dns_zone_id,
    ]
  }
  private_service_connection {
    is_manual_connection           = false
    name                           = var.private_endpoint.name
    private_connection_resource_id = azurerm_redis_cache.this.id
    subresource_names = [
      "redisCache",
    ]
  }
  depends_on = [azurerm_redis_cache.this]
}
