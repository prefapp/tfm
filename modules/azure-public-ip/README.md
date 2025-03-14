**## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | = 4.16.0 |

## Resources

- azurerm_public_ip - [azurerm_public_ip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| resource_group_name | The name of the resource group in which to create the Public IP. | `string` | n/a | yes |
| public_ip_name | The name of the Public IP. | `string` | n/a | yes |
| location | The location/region where the Public IP should be created. | `string` | n/a | yes |
| public_ip_sku | The SKU of the Public IP. | `string` | `"Standard"` | no |
| public_ip_allocation_method | The allocation method of the Public IP. | `string` | `"Static"` | no |
| tags | A map of tags to add to the public IP | `map(string)` | `{}` | no |
| tags_from_rg | Use the tags from the resource group, if true, the tags set in the tags variable will be ignored. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| public_ip_id | The ID of the Public IP. |
| public_ip_address | The IP address of the Public IP. |

## Example

### HCL
```hcl
resource_group_name = "example-resources"
public_ip_name = "example-public-ip"
location = "East US"
public_ip_sku = "Standard"
public_ip_allocation_method = "Static"
tags = {
  environment = "production"
  cost_center = "it"
}
tags_from_rg = false
```

