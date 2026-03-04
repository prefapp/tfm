**## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | = 4.16.0 |

## Resources

- azurerm_nat_gateway - [azurerm_nat_gateway](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway)
- azurerm_nat_gateway_public_ip_association - [azurerm_subnet_nat_gateway_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway_public_ip_association)
- azurerm_subnet_nat_gateway_association - [azurerm_subnet_nat_gateway_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_nat_gateway_association)
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| resource_group_name | The name of the resource group in which to create the Public IP. | `string` | n/a | yes |
| nat_gateway_name | The name of the NAT Gateway. | `string` | n/a | yes |
| location | The location/region where the Public IP should be created. | `string` | n/a | yes |
| nat_gateway_timeout | The idle timeout which should be used. | `number` | 4 | no |
| nat_gateway_sku | The SKU of the NAT Gateway. | `string` | `"Standard"` | no |
| nat_gateway_zones | Availability zones to allocate the NAT Gateway. | `list(string)` | `[]` | no |
| public_ip_id | The ID of the public IP to be attached to the NAT Gateway. | `string` | n/a | yes |
| subnet_id | The ID of the subnet where the NAT Gateway will connect. | `string` | n/a | yes |
| tags | A map of tags to add to the public IP | `map(string)` | `{}` | no |
| tags_from_rg | Use the tags from the resource group, if true, the tags set in the tags variable will be ignored. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| nat_gateway_id | The ID of the NAT Gateway. |

## Example

### HCL
```hcl
resource_group_name = "example-resources"
nat_gateway_name = "example-nat_gateway"
location = "East US"
nat_gateway_timeout = 3
nat_gateway_sku = "Standard"
nat_gateway_zones = ["1","2","3"]
public_ip_id = "example_public_ip_id"
subnet_id = "example_subnet_id"
tags = {
  environment = "production"
  cost_center = "it"
}
tags_from_rg = false
```

