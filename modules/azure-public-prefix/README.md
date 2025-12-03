## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.16.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.16.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_public_ip_prefix.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip_prefix) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ip_version"></a> [ip\_version](#input\_ip\_version) | The IP version of the Public IP Prefix. | `optional(s)` | `IPv4` | no |
| <a name="input_location"></a> [location](#input\_location) | The location/region where the Public IP Prefix is created. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the Public IP Prefix. | `string` | n/a | yes |
| <a name="input_prefix_length"></a> [prefix\_length](#input\_prefix\_length) | The length of the Public IP Prefix. | `optional(number)` | `28` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which to create the Public IP Prefix. | `string` | n/a | yes |
| <a name="input_sku"></a> [sku](#input\_sku) | The SKU of the Public IP Prefix. | `optional(string)` | `Standard` | no |
| <a name="input_sku_tier"></a> [sku\_tier](#input\_sku\_tier) | The SKU tier of the Public IP Prefix. | `optional(string)` | `Regional` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource. | `optional(map(string))` | `{}` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | The availability zone to allocate the Public IP Prefix in. | `optional(list(string))` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | # OUTPUTS SECTION Public IP Prefix |
| <a name="output_ip_prefix"></a> [ip\_prefix](#output\_ip\_prefix) | n/a |

## Example

```yaml
    values:
      name: "example_name"
      resource_group_name: "example_rg"
      location: "westeurope"
      sku: "Standard"
      sku_tier: "Regional"
      ip_version: "IPv4"
      prefix_length: 29
      zones: ["1"]
      tags:
        application: "example_app"
        env: "example_env"
        tenant: "example_tenant"
```
