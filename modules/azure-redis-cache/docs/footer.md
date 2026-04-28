## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-redis-cache/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-redis-cache/_examples/basic) — Standard-tier Redis with private endpoint; wire RG, VNet, subnet, and private DNS zone (see folder README).
- [comprehensive](https://github.com/prefapp/tfm/tree/main/modules/azure-redis-cache/_examples/comprehensive) — Illustrative YAML for Standard- vs Premium-style inputs (`values.reference.yaml`; see folder README).

## Resources

Terraform resource docs use **4.23.0** as a baseline aligned with the `azurerm` constraint in `versions.tf` (`>= 4.23.0`).

- **Azure Cache for Redis**: [https://learn.microsoft.com/azure/azure-cache-for-redis/](https://learn.microsoft.com/azure/azure-cache-for-redis/)
- **azurerm_redis_cache**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.23.0/docs/resources/redis_cache](https://registry.terraform.io/providers/hashicorp/azurerm/4.23.0/docs/resources/redis_cache)
- **azurerm_private_endpoint**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.23.0/docs/resources/private_endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/4.23.0/docs/resources/private_endpoint)
- **Terraform AzureRM provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.23.0](https://registry.terraform.io/providers/hashicorp/azurerm/4.23.0)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
