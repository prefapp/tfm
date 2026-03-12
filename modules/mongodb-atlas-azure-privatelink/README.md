## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.14.0 |
| <a name="requirement_mongodbatlas"></a> [mongodbatlas](#requirement\_mongodbatlas) | >= 1.23.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.14.0 |
| <a name="provider_mongodbatlas"></a> [mongodbatlas](#provider\_mongodbatlas) | >= 1.23.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [mongodbatlas_privatelink_endpoint.this](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/privatelink_endpoint) | resource |
| [mongodbatlas_privatelink_endpoint_service.this](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/privatelink_endpoint_service) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azure_subnet_id"></a> [azure\_subnet\_id](#input\_azure\_subnet\_id) | The azure subnet id | `string` | n/a | yes |
| <a name="input_endpoint_connection_is_manual_connection"></a> [endpoint\_connection\_is\_manual\_connection](#input\_endpoint\_connection\_is\_manual\_connection) | Whether or not the endpoint's private service connection is manual | `bool` | n/a | yes |
| <a name="input_endpoint_connection_request_message"></a> [endpoint\_connection\_request\_message](#input\_endpoint\_connection\_request\_message) | Request message of the endpoint's private service connection | `string` | n/a | yes |
| <a name="input_endpoint_location"></a> [endpoint\_location](#input\_endpoint\_location) | Location of the Azure endpoint | `string` | n/a | yes |
| <a name="input_endpoint_name"></a> [endpoint\_name](#input\_endpoint\_name) | Name of the Azure endpoint | `string` | n/a | yes |
| <a name="input_endpoint_resource_group_name"></a> [endpoint\_resource\_group\_name](#input\_endpoint\_resource\_group\_name) | Name of the Azure endpoint resource group | `string` | n/a | yes |
| <a name="input_mongo_region"></a> [mongo\_region](#input\_mongo\_region) | The mongo region | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The project id | `string` | n/a | yes |
| <a name="input_provider_name"></a> [provider\_name](#input\_provider\_name) | The provider name | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_tags_from_rg"></a> [tags\_from\_rg](#input\_tags\_from\_rg) | Use resource group tags as base for module tags | `bool` | `false` | no |

## Outputs

No outputs.

## Notes

- This module presupposes that:
  - The `org` and `project` are already created in MongoDB Atlas.
  - The `vnet` and `subnet` are already created in Azure into a `resource_group`.

#### Example
**HCL**
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
tags_from_rg = true
```
**YAML**
```yaml
    values:
      mongo_region: "westeurope"
      provider_name: "Azure"
      project_id: "XXXXXXXXXXXXXXXXXXXXXXXX"
      endpoint_name: "mongodb-atlas-privatelink"
      endpoint_location: "westeurope"
      endpoint_resource_group_name: "rg-mongodb-atlas-privatelink"
      endpoint_connection_is_manual_connection: false
      endpoint_connection_request_message: "Please approve the connection to the MongoDB Atlas service."
      azure_subnet_id: "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/rg-mongodb-atlas-privatelink/providers/Microsoft.Network/virtualNetworks/vnet-mongodb-atlas-privatelink/subnets/subnet-mongodb-atlas-privatelink"
      tags_from_rg: true
```
