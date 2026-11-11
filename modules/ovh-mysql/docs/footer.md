## Import and Lifecycle

The module manages these Terraform resources (addresses assume the caller names the module `ovh_mysql`):

- MySQL service: `module.ovh_mysql.ovh_cloud_project_database.mysql`
- Databases: `module.ovh_mysql.ovh_cloud_project_database_database.databases["<database-name>"]`

Import an existing MySQL service with `<service_name>/mysql/<cluster_id>`:

```sh
terraform import 'module.ovh_mysql.ovh_cloud_project_database.mysql' '<service_name>/mysql/<cluster_id>'
```

Import each database with `<service_name>/mysql/<cluster_id>/<database_id>`:

```sh
terraform import 'module.ovh_mysql.ovh_cloud_project_database_database.databases["<database-name>"]' '<service_name>/mysql/<cluster_id>/<database_id>'
```

Destroying the module deletes all managed databases and the MySQL service, including any data and backups retained by OVHcloud. It does not delete the Public Cloud project, private network, subnet or gateway. With `deletion_protection = true`, OVHcloud rejects deletion; set it to `false`, apply that change, and only then run destroy.

Changing the service region forces replacement and can destroy all database data. Changing the network attachment triggers a service rebuild and clears IP restrictions while the network changes; review connectivity and restore the intended allow-list after the update. Flavor changes are applied as node upgrades. OVHcloud validates the requested region and the flavor-specific `disk_size` limits against its service availability when applying, because the provider's project capabilities data source does not expose a region matrix or a documented maximum disk-size range.

OVHcloud currently documents automatic daily backup retention of 2 days for `discovery`, 14 days for `production`, and 30 days for `advanced`. MySQL backups use point-in-time recovery (PITR), with recovery points within the selected plan's retention period; OVHcloud currently documents continuous backups and an RPO of a few minutes. The plan also determines the service SLA; consult the current [MySQL capabilities and limitations](https://docs.ovhcloud.com/en/guides/public-cloud/databases/mysql-capabilities/) and [automated backups guide](https://docs.ovhcloud.com/en/guides/public-cloud/databases/backups/) before choosing a plan.

Automated plan-mode tests use Terraform provider mocking, which requires Terraform 1.7 or later.

The service module does not manage user accounts or passwords. OVHcloud API-created users receive administrator-equivalent privileges and must not be used as application identities. Database users with least privilege require SQL management outside this module.

MySQL's OVHcloud connection URI uses TLS, but the server also accepts unencrypted connections. Require TLS in every client; use the exposed project CA for server verification, and configure SQL-managed application accounts to require SSL where appropriate. The CA is shared by Public Cloud Databases services in the project.

## Examples

- [Discovery with private network](https://github.com/prefapp/tfm/tree/main/modules/ovh-mysql/_examples/discovery-private-network) — one-node MySQL service, private subnet access and one logical database.
- [Production HA](https://github.com/prefapp/tfm/tree/main/modules/ovh-mysql/_examples/production-ha) — two-node service, advanced settings and backups in two regions.

## Resources

- **OVHcloud MySQL capabilities**: [Plans, versions, flavors, storage and supported regions](https://docs.ovhcloud.com/en/guides/public-cloud/databases/mysql-capabilities/)
- **OVHcloud MySQL connections and users**: [Network access and user privileges](https://docs.ovhcloud.com/en/guides/public-cloud/databases/mysql-prepare-for-incoming-connections/)
- **OVHcloud deletion protection**: [Managed database deletion protection](https://docs.ovhcloud.com/en/guides/public-cloud/databases/databases-deletion-protection/)
- **OVHcloud Terraform provider**: [`ovh_cloud_project_database`](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_database), [`ovh_cloud_project_database_database`](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_database_database), [`ovh_cloud_project_database_capabilities`](https://registry.terraform.io/providers/ovh/ovh/latest/docs/data-sources/cloud_project_database_capabilities), and [`ovh_cloud_project_database_certificates`](https://registry.terraform.io/providers/ovh/ovh/latest/docs/data-sources/cloud_project_database_certificates)
- **OVHcloud private network module**: [`ovh-network`](https://github.com/prefapp/tfm/tree/main/modules/ovh-network)

## Support

For questions, issues, or contributions related to this module, visit the [repository issue tracker](https://github.com/prefapp/tfm/issues).
