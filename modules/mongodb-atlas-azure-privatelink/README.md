# MongoDB Atlas Azure Private Link

## Overview

This module creates a MongoDB Atlas private link with Azure private endpoint.

## DOC

- [Resource terraform - mongodbatlas_privatelink_endpoint](https://registry.terraform.io/providers/mongodb/mongodbatlas/1.23.0/docs/resources/privatelink_endpoint)
- [Resource terraform - mongodbatlas_privatelink_endpoint_service](https://registry.terraform.io/providers/mongodb/mongodbatlas/1.23.0/docs/resources/privatelink_endpoint_service)
- [Resource terraform - azurerm_private_endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/4.14.0/docs/resources/private_endpoint)

## Notes

- This module presupposes that:
  - The `org` and `project` are already created in MongoDB Atlas.
  - The `vnet` and `subnet` are already created in Azure into a `resource_group`.

## Usage

### Set a module

```terraform
module "mongodb-atlas-azure-privatelink" {
  source = "git::https://github.com/prefapp/tfm.git//modules/mongodb-atlas-azure-privatelink?ref=<version>"
}
```

### Set a data .tfvars

#### Example

```hcl
mongo_region = "westeurope"
provider_name = "Azure"
project_id = "XXXXXXXXXXXXXXXXXXXXXXXX"
endpoint_name = "mongodb-atlas-privatelink"
endpoint_location = "westeurope"
endpoint_resource_group_name = "rg-mongodb-atlas-privatelink"
endpoint_connection_is_manual_connection = false
endpoint_connection_request_message = "Please approve the connection to the MongoDB Atlas service."
azure_subnet_id = "/subscriptions/XXXXXXXXXXXXXXXXXXXXXXXX/resourceGroups/rg-mongodb-atlas-privatelink/providers/Microsoft.Network/virtualNetworks/vnet-mongodb-atlas-privatelink/subnets/subnet-mongodb-atlas-privatelink"
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_mongo_region"></a> [mongo_region](#input_mongo_region) | The region of the MongoDB Atlas cluster | `string` | n/a | yes |
| <a name="input_provider_name"></a> [provider_name](#input_provider_name) | The name of the provider | `string` | n/a | yes |
| <a name="input_project_id"></a> [project_id](#input_project_id) | The ID of the project in MongoDB Atlas | `string` | n/a | yes |
| <a name="input_endpoint_name"></a> [endpoint_name](#input_endpoint_name) | The name of the private endpoint | `string` | n/a | yes |
| <a name="input_endpoint_location"></a> [endpoint_location](#input_endpoint_location) | The location of the private endpoint | `string` | n/a | yes |
| <a name="input_endpoint_resource_group_name"></a> [endpoint_resource_group_name](#input_endpoint_resource_group_name) | The name of the resource group of the private endpoint | `string` | n/a | yes |
| <a name="input_endpoint_connection_is_manual_connection"></a> [endpoint_connection_is_manual_connection](#input_endpoint_connection_is_manual_connection) | The connection is manual | `bool` | n/a | yes |
| <a name="input_endpoint_connection_request_message"></a> [endpoint_connection_request_message](#input_endpoint_connection_request_message) | The message of the connection request | `string` | n/a | yes |
| <a name="input_azure_subnet_id"></a> [azure_subnet_id](#input_azure_subnet_id) | The ID of the subnet in Azure | `string` | n/a | yes |
