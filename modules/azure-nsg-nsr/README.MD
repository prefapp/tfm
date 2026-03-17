## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.16.0 |

---

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.16.0 |

---

## Resources

| Name | Type |
|------|------|
| [azurerm_network_security_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0/docs/resources/network_security_group) | resource |
| [azurerm_network_security_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0/docs/resources/network_security_rule) | resource |

---

## Inputs

### Network Security Group Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | The name of the Network Security Group. | `string` | - | yes |
| `location` | The Azure region where the NSG will be created. | `string` | - | yes |
| `resource_group_name` | The name of the resource group in which to create the NSG. | `string` | - | yes |
| `tags_from_rg` | Boolean to indicate if tags should be inherited from the resource group. | `bool` | `true` | no |
| `tags` | A map of tags to assign to the NSG. | `map(string)` | `{}` | no |

### Network Security Rules

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | The name of the security rule. | `string` | - | yes |
| `priority` | The priority of the rule. | `number` | - | yes |
| `direction` | The direction of the rule (Inbound/Outbound). | `string` | - | yes |
| `access` | The access type (Allow/Deny). | `string` | - | yes |
| `protocol` | The network protocol (Tcp, Udp, Icmp, etc.). | `string` | - | yes |
| `source_port_range` | The source port range. | `string` | - | show bellow |
| `source_port_ranges` | A list of source port ranges. | `list(string)` | - | show bellow |
| `destination_port_range` | The destination port range. | `string` | - | show bellow |
| `destination_port_ranges` | A list of destination port ranges. | `list(string)` | - | show bellow |
| `source_address_prefix` | The source address prefix. | `string` | - | show bellow |
| `source_address_prefixes` | A list of source address prefixes. | `list(string)` | - | show bellow |
| `destination_address_prefix` | The destination address prefix. | `string` | - | show bellow |
| `destination_address_prefixes` | A list of destination address prefixes. | `list(string)` | - | show bellow |

**source_port_range** and **source_port_ranges** are required to have at least one of them but you can't have both at the same time.

**destination_port_range** and **destination_port_ranges** are required to have at least one of them but you can't have both at the same time.

**source_address_prefix** and **source_address_prefixes** are required to have at least one of them but you can't have both at the same time.

**destination_address_prefix** and **destination_address_prefixes** are required to have at least one of them but you can't have both at the same time.

## Example Usage

### HCL
```hcl

tags_from_rg        = false
tags = {
  env = "Production"
}

nsg = { 
  name                = "example-nsg"
  location            = "East US"
  resource_group_name = "example-rg"
}

rules = {
  rule1 = {
    name                       = "AllowSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.0.0/24"
    destination_address_prefix = "*"
  }
  rule2 = {
    name                       = "AllowHTTP"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "0.0.0.0/0"
    destination_address_prefix = "*"
  }
} 
```

### YAML
```yaml
values:
  tags_from_rg: false
  tags:
    env: "Production"
  nsg:
    name: "example-nsg"
    location: "East US"
    resource_group_name: "example-rg"

  rules:
    rule1:
      name: "AllowSSH"
      priority: 100
      direction: "Inbound"
      access: "Allow"
      protocol: "Tcp"
      source_port_range: "*"
      destination_port_range: "22"
      source_address_prefix: "10.0.0.0/24"
      destination_address_prefix: "*"
    rule2:
      name: "AllowHTTP"
      priority: 200
      direction: "Inbound"
      access: "Allow"
      protocol: "Tcp"
      source_port_range: "*"
      destination_port_range: "80"
      source_address_prefix: "0.0.0.0/0"
      destination_address_prefix: "*"
```

<!-- BEGIN_TF_DOCS -->
# Azure Network Security Group & Rules Terraform Module

## Overview

This Terraform module allows you to create and manage an Azure Network Security Group (NSG) and its rules, with support for:
- Custom NSG and security rule definitions.
- Tag inheritance from the resource group.
- Flexible configuration for ports, protocols, and address prefixes.

## Main features
- Create an NSG with custom tags and location.
- Define multiple security rules with granular control.
- Support for both single and multiple port/address fields.
- Realistic configuration example.

## Complete usage example

### HCL
```hcl
tags_from_rg        = false
tags = {
  env = "Production"
}
nsg = {
  name                = "example-nsg"
  location            = "East US"
  resource_group_name = "example-rg"
}
rules = {
  rule1 = {
    name                       = "AllowSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.0.0/24"
    destination_address_prefix = "*"
  }
  rule2 = {
    name                       = "AllowHTTP"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "0.0.0.0/0"
    destination_address_prefix = "*"
  }
}
```

### YAML
```yaml
values:
  tags_from_rg: false
  tags:
    env: "Production"
  nsg:
    name: "example-nsg"
    location: "East US"
    resource_group_name: "example-rg"
  rules:
    rule1:
      name: "AllowSSH"
      priority: 100
      direction: "Inbound"
      access: "Allow"
      protocol: "Tcp"
      source_port_range: "*"
      destination_port_range: "22"
      source_address_prefix: "10.0.0.0/24"
      destination_address_prefix: "*"
    rule2:
      name: "AllowHTTP"
      priority: 200
      direction: "Inbound"
      access: "Allow"
      protocol: "Tcp"
      source_port_range: "*"
      destination_port_range: "80"
      source_address_prefix: "0.0.0.0/0"
      destination_address_prefix: "*"
```

## Notes
- You must provide at least one of each: `*_range` or `*_ranges` and `*_prefix` or `*_prefixes`, but not both at the same time.
- You can use `tags_from_rg` to inherit tags exclusively from the resource group.

## File structure

```
.
├── main.tf
├── variables.tf
├── outputs.tf
├── README.MD
├── CHANGELOG.md
└── docs/
    ├── header.md
    └── footer.md
```

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
| [azurerm_network_security_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_nsg"></a> [nsg](#input\_nsg) | Network Security Group configuration | <pre>object({<br/>    name                = string<br/>    location            = string<br/>    resource_group_name = string<br/>  })</pre> | n/a | yes |
| <a name="input_rules"></a> [rules](#input\_rules) | Network Security Rule configuration | <pre>map(object({<br/>    name                         = string<br/>    priority                     = number<br/>    direction                    = string<br/>    access                       = string<br/>    protocol                     = string<br/>    source_port_range            = optional(string)<br/>    source_port_ranges           = optional(list(string))<br/>    destination_port_range       = optional(string)<br/>    destination_port_ranges      = optional(list(string))<br/>    source_address_prefix        = optional(string)<br/>    source_address_prefixes      = optional(list(string))<br/>    destination_address_prefix   = optional(string)<br/>    destination_address_prefixes = optional(list(string))<br/>  }))</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_tags_from_rg"></a> [tags\_from\_rg](#input\_tags\_from\_rg) | Use resource group tags as base for module tags | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | OUTPUTS SECTION |

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-nsg-nsr/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-nsg-nsr/_examples/basic) - Network Security Group with a set of common inbound and outbound rules.

## Resources and support

- [Official Azure Network Security Group documentation](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview)
- [Terraform reference for azurerm\_network\_security\_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group)
- [Terraform reference for azurerm\_network\_security\_rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->