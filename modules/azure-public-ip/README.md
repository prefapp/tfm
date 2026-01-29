<!-- BEGIN_TF_DOCS -->
# **Azure Windows Virtual Machine Terraform Module**

## Overview

This module provisions and manages a complete Azure Public IP resource, including SKU or allocation method and supports the definition of a custom domain name.

It is suitable for development, staging, and production environments, and can be easily extended or embedded in larger Terraform projects.

## Key Features

- **Public IP Provisioning**: Deploys a fully managed Azure Public Ip resource with customizable name, SKU, allocation method.
- **Domain Name Label Definition**: Capacity to define a custom domain name label
- **Availability zone allocation**: Define in which availability zones deploy the public ip

## Outputs

| Name | Description |
|------|-------------|
| public\_ip\_id | The ID of the Public IP. |
| public\_ip\_address | The IP address of the Public IP. |

## Basic Usage

### Example 1: Base Public IP

```hcl
module "public_ip" {
  source = "../../"

  public_ip = {
    name                = "public-ip-name"
    resource_group_name = "resource-group-name"
    location            = "westeurope"
    sku                 = "Standard"
    allocation_method   = "Static"
    tags_from_rg        = true
}
```

### Example 2: Public IP with domain name label

```hcl
module "public_ip" {
  source = "../../"

  public_ip = {
    name                = "public-ip-name"
    resource_group_name = "resource-group-name"
    location            = "westeurope"
    sku                 = "Standard"
    allocation_method   = "Static"
    domain_name_label   = "domain-name"
    tags_from_rg        = true
}
```

### Example 3: Public IP with availability zone

```hcl
module "public_ip" {
  source = "../../"

  public_ip = {
    name                = "public-ip-name"
    resource_group_name = "resource-group-name"
    location            = "westeurope"
    sku                 = "Standard"
    allocation_method   = "Static"
    public_ip_zones     = ["1","2","3"]
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
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.16.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_public_ip.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_resource_group.resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | The location/region where the public IP will be created | `string` | n/a | yes |
| <a name="input_public_ip_allocation_method"></a> [public\_ip\_allocation\_method](#input\_public\_ip\_allocation\_method) | The allocation method of the public IP | `string` | `"Static"` | no |
| <a name="input_public_ip_domain_name_label"></a> [public\_ip\_domain\_name\_label](#input\_public\_ip\_domain\_name\_label) | Label for the Domain Name | `string` | `null` | no |
| <a name="input_public_ip_name"></a> [public\_ip\_name](#input\_public\_ip\_name) | The name of the public IP | `string` | n/a | yes |
| <a name="input_public_ip_sku"></a> [public\_ip\_sku](#input\_public\_ip\_sku) | The SKU of the public IP | `string` | `"Standard"` | no |
| <a name="input_public_ip_zones"></a> [public\_ip\_zones](#input\_public\_ip\_zones) | Availability zones where the Public IP should be deployed | `list(string)` | `[]` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which to create the public IP | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to the public IP | `map(string)` | `{}` | no |
| <a name="input_tags_from_rg"></a> [tags\_from\_rg](#input\_tags\_from\_rg) | Use the tags from the resource group | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_public_ip_address"></a> [public\_ip\_address](#output\_public\_ip\_address) | n/a |
| <a name="output_public_ip_id"></a> [public\_ip\_id](#output\_public\_ip\_id) | Outputs |

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-public-ip/_examples):

- [base\_public\_ip](https://github.com/prefapp/tfm/tree/main/modules/azure-public-ip/_examples/base\_public\_ip) - Example creating a basic public ip (without zones and domain name label)
- [with\_domain\_name\_label](https://github.com/prefapp/tfm/tree/main/modules/azure-public-ip/_examples/with\_domain\_name\_label) - Example creating a public ip with a defined domain name label
- [with\_zones](https://github.com/prefapp/tfm/tree/main/modules/azure-public-ip/_examples/with\_zones) - Example creating a public ip deployed on the specified availability zones

## Remote resources

- **Azure Public IP**: [azurerm\_public\_ip documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip)
- **Terraform Azure Provider**: [Terraform Provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->