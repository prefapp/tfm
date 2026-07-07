## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-managed-redis/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-managed-redis/_examples/basic) — Balanced_B1 cluster with a private endpoint and DNS zone group; minimal configuration covering the required inputs.
- [complete](https://github.com/prefapp/tfm/tree/main/modules/azure-managed-redis/_examples/complete) — Production-grade MemoryOptimized cluster with zone-redundant HA, Customer-Managed Key encryption, UserAssigned managed identity, RediSearch and RedisJSON modules, RDB persistence, access policy assignments, and a private endpoint.

## Resources

- **Azure Managed Redis overview**: [https://learn.microsoft.com/azure/redis/overview](https://learn.microsoft.com/azure/redis/overview)
- **azurerm_managed_redis**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_redis](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_redis)
- **azurerm_managed_redis_access_policy_assignment**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_redis_access_policy_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_redis_access_policy_assignment)
- **azurerm_managed_redis_geo_replication**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_redis_geo_replication](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_redis_geo_replication)
- **azurerm_private_endpoint**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint)
- **Private endpoint subresources (Azure Managed Redis = redisEnterprise)**: [https://learn.microsoft.com/azure/private-link/private-endpoint-overview#private-link-resource](https://learn.microsoft.com/azure/private-link/private-endpoint-overview#private-link-resource)
- **Azure Managed Redis SKUs**: [https://learn.microsoft.com/azure/redis/overview-sku-selection](https://learn.microsoft.com/azure/redis/overview-sku-selection)
- **Azure Managed Redis persistence**: [https://learn.microsoft.com/azure/redis/how-to-persistence](https://learn.microsoft.com/azure/redis/how-to-persistence)
- **Azure Managed Redis geo-replication**: [https://learn.microsoft.com/azure/redis/how-to-active-geo-replication](https://learn.microsoft.com/azure/redis/how-to-active-geo-replication)
- **Azure Managed Redis modules**: [https://learn.microsoft.com/azure/redis/redis-modules](https://learn.microsoft.com/azure/redis/redis-modules)
- **Migrating from Redis Enterprise to Managed Redis**: [https://learn.microsoft.com/azure/redis/migrate/migrate-overview](https://learn.microsoft.com/azure/redis/migrate/migrate-overview)
- **Terraform AzureRM Provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest](https://registry.terraform.io/providers/hashicorp/azurerm/latest)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
