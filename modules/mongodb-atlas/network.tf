# Network Access section
# https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/project_ip_access_list
resource "mongodbatlas_project_ip_access_list" "test" {
  for_each = {
    for index, ip in var.whitelist_ips :
    ip.ip => ip
  }
  project_id = mongodbatlas_project.project.id
  ip_address = each.value.ip
  comment    = each.value.name

  # Ensure IP access list is created after the cluster
  depends_on = [mongodbatlas_cluster.cluster]
}

# Private Link section
# https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/privatelink_endpoint
resource "mongodbatlas_privatelink_endpoint" "privatelink_endpoint" {
  project_id    = mongodbatlas_project.project.id
  provider_name = var.provider_name
  region        = var.mongo_region

  # Ensure private link endpoint is created after the cluster
  depends_on = [mongodbatlas_cluster.cluster]
}

# Azure Subnet data source
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet
data "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.vnet_resource_group_name != "" ? var.vnet_resource_group_name : var.global_resource_group_name
}

# Azure Private Endpoint resource
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint
resource "azurerm_private_endpoint" "private_endpoint" {
  name                = var.endpoint_name
  location            = var.endpoint_location
  resource_group_name = var.endpoint_resource_group_name != "" ? var.endpoint_resource_group_name : var.global_resource_group_name
  subnet_id           = data.azurerm_subnet.subnet.id

  # Private service connection block
  private_service_connection {
    name                           = mongodbatlas_privatelink_endpoint.privatelink_endpoint.private_link_service_name
    private_connection_resource_id = mongodbatlas_privatelink_endpoint.privatelink_endpoint.private_link_service_resource_id
    is_manual_connection           = var.endpoint_connection_is_manual_connection
    request_message                = var.endpoint_connection_request_message
  }

  # Ensure private endpoint is created after the private link endpoint
  depends_on = [mongodbatlas_privatelink_endpoint.privatelink_endpoint]

  # Ignore changes to tags
  lifecycle {
    ignore_changes = [tags]
  }
}

# MongoDB Atlas Private Link Endpoint Service resource
# https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/privatelink_endpoint_service
resource "mongodbatlas_privatelink_endpoint_service" "privatelink_endpoint_service" {
  project_id                  = mongodbatlas_privatelink_endpoint.privatelink_endpoint.project_id
  private_link_id             = mongodbatlas_privatelink_endpoint.privatelink_endpoint.private_link_id
  endpoint_service_id         = azurerm_private_endpoint.private_endpoint.id
  private_endpoint_ip_address = azurerm_private_endpoint.private_endpoint.private_service_connection.0.private_ip_address
  provider_name               = var.provider_name

  # Ensure private link endpoint service is created after the private endpoint
  depends_on = [azurerm_private_endpoint.private_endpoint]
}
