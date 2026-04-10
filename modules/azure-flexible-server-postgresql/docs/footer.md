## Examples

- [Basic](https://github.com/prefapp/tfm/tree/main/modules/azure-flexible-server-postgresql/_examples/basic)
- [Comprehensive](https://github.com/prefapp/tfm/tree/main/modules/azure-flexible-server-postgresql/_examples/comprehensive)

## Provider documentation (aligned with `versions.tf` / typical pins)

- [azurerm_postgresql_flexible_server](https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/resources/postgresql_flexible_server)
- [azurerm_key_vault_secret](https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/resources/key_vault_secret)
- [azurerm_resources](https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/data-sources/resources)
- [random_password](https://registry.terraform.io/providers/hashicorp/random/3.6.0/docs/resources/password) (uses `hashicorp/random`; Terraform installs it implicitly because `random_password` is declared in this module)

## Point-in-time restore

For `create_mode = "PointInTimeRestore"`, provide `source_server_id` and `point_in_time_restore_time_in_utc` within retention. Example CLI:

```bash
az postgres flexible-server backup list --resource-group my-resource-group --name my-server-name
```

## Issues

[https://github.com/prefapp/tfm/issues](https://github.com/prefapp/tfm/issues)
