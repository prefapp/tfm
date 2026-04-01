# Advanced Example

This example demonstrates advanced usage of the Azure Private DNS Zone module, including custom link prefix and registration enabled for VNet links.

## Example

```hcl
module "private_dns_zone" {
  source                = "../../.."
  dns_zone_name         = "privatelink.example.com"
  resource_group_name   = "my-rg"
  vnet_ids              = {
    dev  = "<dev_vnet_id>"
    prod = "<prod_vnet_id>"
  }
  link_name_prefix      = "customlink"
  registration_enabled  = true
}
```
