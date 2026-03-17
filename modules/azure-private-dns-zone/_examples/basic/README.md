# Basic Example

This example demonstrates minimal usage of the Azure Private DNS Zone module, creating a single DNS zone and linking it to two VNets.

## Example

```hcl
module "private_dns_zone" {
  source              = "../../.."
  dns_zone_name       = "privatelink.example.com"
  resource_group_name = "my-rg"
  vnet_ids            = {
    vnet1 = "<vnet1_id>"
    vnet2 = "<vnet2_id>"
  }
}
```
