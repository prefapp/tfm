# https://registry.terraform.io/providers/hashicorp/azurerm/4.14.0/docs/resources/private_endpoint
resource "azurerm_private_endpoint" "this" {
  name                = var.endpoint_name
  location            = var.endpoint_location
  resource_group_name = var.endpoint_resource_group_name
  subnet_id           = var.azure_subnet_id
  tags                = local.tags
  private_service_connection {
    name                           = mongodbatlas_privatelink_endpoint.this.private_link_service_name
    private_connection_resource_id = mongodbatlas_privatelink_endpoint.this.private_link_service_resource_id
    is_manual_connection           = var.endpoint_connection_is_manual_connection
    request_message                = var.endpoint_connection_request_message
  }
  depends_on = [mongodbatlas_privatelink_endpoint.this]
}

