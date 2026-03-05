## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.16.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.16.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_nat_gateway.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway) | resource |
| [azurerm_nat_gateway_public_ip_association.nat_gateway_public_ip_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway_public_ip_association) | resource |
| [azurerm_subnet_nat_gateway_association.subnet_nat_gateway_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_nat_gateway_association) | resource |
| [azurerm_resource_group.resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | The location/region where the NAT Gateway will be created | `string` | n/a | yes |
| <a name="input_nat_gateway_name"></a> [nat\_gateway\_name](#input\_nat\_gateway\_name) | The name of the NAT Gateway | `string` | n/a | yes |
| <a name="input_nat_gateway_sku"></a> [nat\_gateway\_sku](#input\_nat\_gateway\_sku) | The SKU of the NAT Gateway | `string` | `"Standard"` | no |
| <a name="input_nat_gateway_timeout"></a> [nat\_gateway\_timeout](#input\_nat\_gateway\_timeout) | The idle timeout which should be used | `number` | `4` | no |
| <a name="input_nat_gateway_zones"></a> [nat\_gateway\_zones](#input\_nat\_gateway\_zones) | Availability zones where the NAT Gateway should be deployed | `list(string)` | `[]` | no |
| <a name="input_public_ip_id"></a> [public\_ip\_id](#input\_public\_ip\_id) | The ID of the public IP to be attached to the NAT Gateway | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which to create the NAT Gateway | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The ID of the subnet where the NAT Gateway will connect | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to the NAT Gateway | `map(string)` | `{}` | no |
| <a name="input_tags_from_rg"></a> [tags\_from\_rg](#input\_tags\_from\_rg) | Use the tags from the resource group | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_nat_gateway_id"></a> [nat\_gateway\_id](#output\_nat\_gateway\_id) | Outputs |

<!-- BEGIN_TF_DOCS -->
# **Azure NAT Gateway Terraform Module**

## Overview

This module provisions and manages a complete Azure NAT Gateway resource, including SKU and zone allocation.

It is suitable for development, staging, and production environments, and can be easily extended or embedded in larger Terraform projects.

## Key Features

- **Nat Gateway Provisioning**: Deploys a fully managed Azure Nat Gateway resource with customizable name, SKU and zone allocation.
- **Availability zone allocation**: Define in which availability zones deploy the NAT Gateway.

## Basic Usage

### Example 1: Base NAT Gateway

```hcl
module "nat_gateway" {
  source = "../../"

  nat_gateway = {
    name                = "nat-gateway-name"
    resource_group_name = "resource-group-name"
    nat_gateway_name    = "nat-gateway-name"
    location            = "westeurope"
    nat_gateway_timeout = 4
    nat_gateway_sku     = "Standard"
    public_ip_id        = "public-ip-id"
    subnet_id           = "subnet-id"
    tags_from_rg        = true
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.16.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.16.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_nat_gateway.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway) | resource |
| [azurerm_nat_gateway_public_ip_association.nat_gateway_public_ip_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway_public_ip_association) | resource |
| [azurerm_subnet_nat_gateway_association.subnet_nat_gateway_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_nat_gateway_association) | resource |
| [azurerm_resource_group.resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | The location/region where the NAT Gateway will be created | `string` | n/a | yes |
| <a name="input_nat_gateway_name"></a> [nat\_gateway\_name](#input\_nat\_gateway\_name) | The name of the NAT Gateway | `string` | n/a | yes |
| <a name="input_nat_gateway_sku"></a> [nat\_gateway\_sku](#input\_nat\_gateway\_sku) | The SKU of the NAT Gateway | `string` | `"Standard"` | no |
| <a name="input_nat_gateway_timeout"></a> [nat\_gateway\_timeout](#input\_nat\_gateway\_timeout) | The idle timeout which should be used | `number` | `4` | no |
| <a name="input_nat_gateway_zones"></a> [nat\_gateway\_zones](#input\_nat\_gateway\_zones) | Availability zones where the NAT Gateway should be deployed | `list(string)` | `[]` | no |
| <a name="input_public_ip_id"></a> [public\_ip\_id](#input\_public\_ip\_id) | The ID of the public IP to be attached to the NAT Gateway | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which to create the NAT Gateway | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The ID of the subnet where the NAT Gateway will connect | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to the NAT Gateway | `map(string)` | `{}` | no |
| <a name="input_tags_from_rg"></a> [tags\_from\_rg](#input\_tags\_from\_rg) | Use the tags from the resource group | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_nat_gateway_id"></a> [nat\_gateway\_id](#output\_nat\_gateway\_id) | Outputs |

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-nat-gateway/_examples):

- [base\\_nat\\_gateway](https://github.com/prefapp/tfm/tree/main/modules/azure-nat-gateway/_examples/base\\_nat\\_gateway) - Example creating a basic NAT Gateway (without zones and Standard SKU)

## Remote resources

- **Azure NAT Gateway**: [azurerm\\_nat\\_gateway documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway)
- **Public IP and Nat Gateway Association**: [azurerm\\_nat\\_gateway\\_public\\_ip\\_association\\_documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway\\_public\\_ip\\_association)
- **Subnet and NAT Gateway Association**: [azurerm\\_subnet\\_nat\\_gateway\\_association\\_documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_nat_gateway_association)
- **Terraform Azure Provider**: [Terraform Provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->