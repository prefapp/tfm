# Basic Example

This example demonstrates minimal usage of the Azure DNS Zone module, creating a DNS zone with default settings.

## Example

```hcl
module "dns_zone" {
  source              = "../../.."
  dns_zone_name       = "example.com"
  resource_group_name = "my-rg"
}
```
