## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-flexible-server-postgresql/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-flexible-server-postgresql/_examples/basic) — Minimal wiring for `init` / `validate`; set credentials and names before apply, and pass `postgresql_flexible_server_configuration` (use `{}` if none — see folder README).
- [comprehensive](https://github.com/prefapp/tfm/tree/main/modules/azure-flexible-server-postgresql/_examples/comprehensive) — Illustrative `values.reference.yaml` for wrappers or pipelines (placeholders only — see folder README).

## Resources

Terraform **azurerm** docs use **4.35.0** as a baseline aligned with `versions.tf` (`>= 4.35.0`). **random** uses **3.8.1** (see the module lockfile; `random_password` is used without a separate `required_providers` block for `random` in `versions.tf`).

- **Azure Database for PostgreSQL — Flexible Server**: [https://learn.microsoft.com/azure/postgresql/flexible-server/overview](https://learn.microsoft.com/azure/postgresql/flexible-server/overview)
- **azurerm_postgresql_flexible_server**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/resources/postgresql_flexible_server](https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/resources/postgresql_flexible_server)
- **azurerm_postgresql_flexible_server_configuration**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/resources/postgresql_flexible_server_configuration](https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/resources/postgresql_flexible_server_configuration)
- **azurerm_postgresql_flexible_server_firewall_rule**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/resources/postgresql_flexible_server_firewall_rule](https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/resources/postgresql_flexible_server_firewall_rule)
- **azurerm_key_vault_secret**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/resources/key_vault_secret](https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/resources/key_vault_secret)
- **azurerm_resources** (data source): [https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/data-sources/resources](https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/data-sources/resources)
- **random_password**: [https://registry.terraform.io/providers/hashicorp/random/3.8.1/docs/resources/password](https://registry.terraform.io/providers/hashicorp/random/3.8.1/docs/resources/password)
- **Terraform AzureRM provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0](https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0)
- **Terraform Random provider**: [https://registry.terraform.io/providers/hashicorp/random/3.8.1](https://registry.terraform.io/providers/hashicorp/random/3.8.1)

## Point-in-time restore

For `create_mode = "PointInTimeRestore"`, provide `source_server_id` and `point_in_time_restore_time_in_utc` within retention. Example CLI:

```bash
az postgres flexible-server backup list --resource-group my-resource-group --name my-server-name
```

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
