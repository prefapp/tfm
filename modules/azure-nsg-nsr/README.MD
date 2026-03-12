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
