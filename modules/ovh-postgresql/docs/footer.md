## Extensions

This module does not run SQL. Apply required extensions separately in each target database:

```sql
CREATE EXTENSION IF NOT EXISTS "pgvector";
```

The provider has no managed PostgreSQL extension resource and OVHcloud's capabilities data source does not return extensions. The module therefore checks extension names against the [OVHcloud extension catalogue](https://docs.ovhcloud.com/en/guides/public-cloud/databases/postgresql-extensions/) and enforces documented constraints for TimescaleDB (not available on PostgreSQL 18) and pgvectorscale (documented for PostgreSQL 16 and 17). Confirm other extension/version combinations with OVHcloud before deployment. `CREATE EXTENSION` permissions and required activation order are the caller's responsibility.

## Secrets and External Secrets Operator

Each user secret is JSON with `host`, `port`, `username`, `password` and `database`. Each pool secret is JSON with `uri`. The module outputs only secret paths; configure External Secrets Operator to read the relevant OKMS paths and map JSON properties to Kubernetes Secret keys. Passwords and pool URIs remain sensitive in Terraform state despite not being outputs.

New PostgreSQL users have no privileges on database objects by default. Manage required database/schema/table grants with SQL migrations; the OVHcloud API only manages the `replication` role.

## Backup, SLA and Pool Guidance

OVHcloud automatically backs up databases and supports point-in-time recovery within the plan's retention window. Current PostgreSQL plan documentation lists:

| Plan | Nodes | Backup retention |
|---|---:|---:|
| `discovery` | 1 | 2 days |
| `production` | 2 | 14 days |
| `advanced` | 3 | 30 days |

SLA availability and current offer terms depend on the plan and region and can change. OVHcloud's public capabilities page does not specify a numeric SLA for each plan; confirm the applicable SLA in the service contract. Review the [PostgreSQL capabilities](https://docs.ovhcloud.com/en/guides/public-cloud/databases/postgresql-capabilities/) and [automated backup](https://docs.ovhcloud.com/en/guides/public-cloud/databases/backups/) documentation for the selected region and plan.

Use the direct endpoint for workloads relying on session affinity or features incompatible with PgBouncer transaction mode. Pools are useful when many application connections need multiplexing over fewer backend connections. OVHcloud's [pool guide](https://docs.ovhcloud.com/en/guides/public-cloud/databases/postgresql-pool/) describes mode-specific limitations.

## Import and Lifecycle

Resource addresses assume the caller names the module `postgresql`:

- Cluster: `module.postgresql.ovh_cloud_project_database.postgresql`, import ID `<service_name>/postgresql/<cluster_id>`.
- Database: `module.postgresql.ovh_cloud_project_database_database.database["<key>"]`, import ID `<service_name>/postgresql/<cluster_id>/<database_id>`.
- User: `module.postgresql.ovh_cloud_project_database_postgresql_user.user["<key>"]`, import ID `<service_name>/<cluster_id>/<user_id>`.
- Pool: `module.postgresql.ovh_cloud_project_database_postgresql_connection_pool.pool["<key>"]`, import ID `<service_name>/<cluster_id>/<pool_id>`.
- OKMS secret: the provider does not document import support for `ovh_okms_secret`; existing secrets at generated paths cannot be adopted through a documented import workflow.

For `ovh_cloud_project_database` import, the documented provider ID is `<service_name>/postgresql/<cluster_id>`. For the other resources, use the import formats documented by the OVH provider; user and pool resource IDs omit the engine segment.

Destroying the module deletes the managed cluster and all data in it, its declared databases/users/pools, and the OKMS secrets at the configured paths. It does not delete the Public Cloud project, private network, subnet or OKMS. Disable deletion protection before intentional destroy; use backups and verify retention first. Changing network/subnet triggers a service rebuild and may temporarily interrupt connectivity. Changing the region recreates the cluster. Changing a database or user key changes its Terraform address and can cause replacement unless state is migrated. The OVHcloud capabilities data source is project-scoped rather than region-scoped, so flavor/version availability in a particular region and disk-size min/max are ultimately enforced by OVHcloud at apply.

## Examples

- [discovery-private-network](https://github.com/prefapp/tfm/tree/main/modules/ovh-postgresql/_examples/discovery-private-network) — one private node, one database and one user.
- [production-pooling](https://github.com/prefapp/tfm/tree/main/modules/ovh-postgresql/_examples/production-pooling) — two nodes and a transaction-mode connection pool.

## Resources

- **OVHcloud PostgreSQL capabilities**: [Versions, plans, networking, roles, backups and retention](https://docs.ovhcloud.com/en/guides/public-cloud/databases/postgresql-capabilities/)
- **OVHcloud PostgreSQL extensions**: [Supported extension catalogue](https://docs.ovhcloud.com/en/guides/public-cloud/databases/postgresql-extensions/)
- **OVHcloud PostgreSQL pools**: [Modes and client limitations](https://docs.ovhcloud.com/en/guides/public-cloud/databases/postgresql-pool/)
- **OVHcloud Terraform provider**: [`ovh_cloud_project_database`](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_database), [`ovh_cloud_project_database_postgresql_user`](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_database_postgresql_user), [`ovh_cloud_project_database_postgresql_connection_pool`](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_database_postgresql_connection_pool), [`ovh_okms_secret`](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/okms_secret)

## Support

For questions, issues or contributions related to this module, visit the [repository issue tracker](https://github.com/prefapp/tfm/issues).
