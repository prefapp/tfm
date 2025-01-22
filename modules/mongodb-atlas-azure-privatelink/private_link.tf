# https://registry.terraform.io/providers/mongodb/mongodbatlas/1.23.0/docs/resources/privatelink_endpoint
resource "mongodbatlas_privatelink_endpoint" "this" {
  project_id    = var.project_id
  provider_name = var.provider_name
  region        = var.mongo_region
}

# https://registry.terraform.io/providers/mongodb/mongodbatlas/1.23.0/docs/resources/privatelink_endpoint_service
resource "mongodbatlas_privatelink_endpoint_service" "this" {
  project_id                  = mongodbatlas_privatelink_endpoint.this.project_id
  private_link_id             = mongodbatlas_privatelink_endpoint.this.private_link_id
  endpoint_service_id         = azurerm_private_endpoint.this.id
  private_endpoint_ip_address = azurerm_private_endpoint.this.private_service_connection.0.private_ip_address
  provider_name               = var.provider_name
  depends_on                  = [azurerm_private_endpoint.this]
}
