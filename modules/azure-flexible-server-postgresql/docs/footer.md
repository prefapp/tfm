## Examples

- [Basic](https://github.com/prefapp/tfm/tree/main/modules/azure-flexible-server-postgresql/_examples/basic)
- [Comprehensive](https://github.com/prefapp/tfm/tree/main/modules/azure-flexible-server-postgresql/_examples/comprehensive)

## Provider documentation (aligned with `versions.tf`)

- [azurerm_postgresql_flexible_server](https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/resources/postgresql_flexible_server)
- [azurerm_postgresql_flexible_server_configuration](https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/resources/postgresql_flexible_server_configuration)
- [azurerm_postgresql_flexible_server_firewall_rule](https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/resources/postgresql_flexible_server_firewall_rule)
- [azurerm_key_vault_secret](https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/resources/key_vault_secret)
- [azurerm_resources](https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/data-sources/resources)
- [azurerm_key_vault_secret (data)](https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/data-sources/key_vault_secret)
- [random_password](https://registry.terraform.io/providers/hashicorp/random/3.6.0/docs/resources/password)

## Point-in-time restore (`create_mode = "PointInTimeRestore"`)

When restoring to a new server:

1. Provide `source_server_id` (resource ID of the source flexible server) and `point_in_time_restore_time_in_utc` within the backup retention window.
2. Azure creates a **new** server; the source server is not modified.
3. After a successful restore, consider moving `create_mode` back to default/`Default` behaviour so later applies do not re-apply restore semantics (the module ignores several of these attributes after create, but operator workflow should still follow Azure guidance).
4. Timestamp format must be valid ISO 8601 UTC (for example `2025-03-14T08:26:31Z`).

List backups (Azure CLI):

```bash
az postgres flexible-server backup list --resource-group my-resource-group --name my-server-name
```

## Issues

[https://github.com/prefapp/tfm/issues](https://github.com/prefapp/tfm/issues)
