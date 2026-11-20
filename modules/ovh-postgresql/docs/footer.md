## Extensions

This module does not run SQL. Apply required extensions separately in each target database:

```sql
CREATE EXTENSION IF NOT EXISTS vector;
```

The provider has no managed PostgreSQL extension resource and OVHcloud's capabilities data source does not return extensions. The module therefore checks extension names against the [OVHcloud extension catalogue](https://docs.ovhcloud.com/en/guides/public-cloud/databases/postgresql-extensions.md) and enforces its explicit constraints for TimescaleDB and pgvectorscale. The catalogue lists TimescaleDB and says **"Not yet available on PG18"**. It does not publish a TimescaleDB compatibility matrix by plan or region, nor specify a TimescaleDB extension version or edition. OVHcloud's [general PostgreSQL capabilities](https://docs.ovhcloud.com/en/guides/public-cloud/databases/postgresql-capabilities.md) say the database service is available in all Public Cloud 1-AZ and 3-AZ regions and describe the Discovery, Production and Advanced plans, but do not establish TimescaleDB availability for every plan/region combination. Accordingly, the module rejects TimescaleDB on PostgreSQL 18 only; passing that check is not confirmation that the extension is available for a particular offer. Confirm the intended combination with OVHcloud before deployment. The same catalogue documents pgvectorscale for PostgreSQL 16 and 17. For pgvector, the module catalogue label is `pgvector`, while its SQL extension name is `vector`. `CREATE EXTENSION` permissions and required activation order are the caller's responsibility.

## Secrets and External Secrets Operator

Each user secret is JSON with `host`, `port`, `username`, `password` and `database`. Each pool secret is JSON with `uri`. The module outputs only secret paths; configure External Secrets Operator to read the relevant OKMS paths and map JSON properties to Kubernetes Secret keys. Passwords and pool URIs remain in Terraform state despite not being outputs. OVH provider v2.25.0 does not mark the computed pool URI as sensitive, so Terraform plan output and saved plan files may contain it; provider debug logging can include the full pool response. Do not expose plan output, saved plan files or `TF_LOG=DEBUG` logs to broad audiences, and restrict access to Terraform state and CI logs. This provider limitation cannot be fixed by the module without changing the provider.

The common service outputs follow the `ovh-mysql` naming pattern: `service_name`, `postgresql_id`, `postgresql_description`, `postgresql_status`, `postgresql_host`, `postgresql_port`, `postgresql_ca`, and `database_names`. PostgreSQL-specific outputs include `postgresql_endpoints`, `database_ids`, `user_secret_paths`, `pool_secret_paths`, and non-sensitive `pool_endpoints`. No output contains a password or credential-bearing URI. `disk_size` is required for this module and is validated against the maintained plan/flavor catalogue.

New PostgreSQL users have no privileges on database objects by default. Manage required database/schema/table grants with SQL migrations; the OVHcloud API only manages the `replication` role.

## Maintained Offer Catalogue

`data/postgresql-offers.json` contains a maintained snapshot derived from stable PostgreSQL private-network offers captured from one Public Cloud project on the recorded date. The module uses it as separate allowlists for engine versions and regions, plus plan-specific flavor and disk minimum, maximum and increment values. It does not record or validate whether a particular version, plan, region and flavor combination is offered together, nor whether an offer is currently available to the caller's project. The module consumer is responsible for choosing a valid combination; OVHcloud remains authoritative and may reject it during apply. Refresh the snapshot from a new availability query and review the diff when offers change.

The catalogue represents private networking because the module always attaches to an existing private network and subnet. Database node count is derived from the selected plan. The network name and subnet CIDR are resolved from the caller's project and are not part of OVHcloud's offer catalogue.

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
- OKMS secret: OVH provider v2.25.0 does not implement import for `ovh_okms_secret`; existing secrets at generated paths cannot be adopted with `terraform import`.

For example, with the module call named `postgresql`, import the cluster with:

```shell
terraform import 'module.postgresql.ovh_cloud_project_database.postgresql' '<service_name>/postgresql/<cluster_id>'
```

The provider's import formats are documented for [clusters](https://registry.terraform.io/providers/ovh/ovh/2.25.0/docs/resources/cloud_project_database), [databases](https://registry.terraform.io/providers/ovh/ovh/2.25.0/docs/resources/cloud_project_database_database), [PostgreSQL users](https://registry.terraform.io/providers/ovh/ovh/2.25.0/docs/resources/cloud_project_database_postgresql_user) and [connection pools](https://registry.terraform.io/providers/ovh/ovh/2.25.0/docs/resources/cloud_project_database_postgresql_connection_pool). The module uses provider v2.25.x; use each resource's corresponding address and ID format above. The ID components are the Public Cloud project service name, cluster ID, and child resource ID as applicable.

Destroying the module deletes the managed cluster and all data in it, its declared databases/users/pools, and the OKMS secrets at the configured paths. It does not delete the Public Cloud project, private network, subnet or OKMS. OVHcloud deletion protection protects the cluster; Terraform destroy-time guards also protect each managed database, user, pool and OKMS secret, with a barrier preventing parallel child deletion during a full destroy. For an intentional destroy or removal of one of these resources, set `deletion_protection = false` and apply before destroying or changing the configuration. Keep the module configuration present during destroy so Terraform can run its guards. Use backups and verify retention first. The local lifecycle harness `bash scripts/test_deletion_guards.sh` verifies protected full destroy, child removal/replacement and the allowed destroy path. Changing network/subnet triggers a service rebuild and may temporarily interrupt connectivity. Changing the region recreates the cluster. Changing a database or user key changes its Terraform address and can cause replacement unless state is migrated. Plan validates catalogue membership and plan-specific flavor/disk limits, not cross-dimension offer compatibility or live availability; OVHcloud remains authoritative during apply.

Changing a pool's optional user restriction recreates that pool because OVHcloud provider v2.25.0 models `user_id` as Optional+Computed and omits empty IDs from update requests. This also causes existing pools to be recreated once when adopting this lifecycle rule; schedule the rollout for the possible connection interruption.

Changing `password_reset` or replacing a user restricted to a pool also recreates that pool so its connection URI and OKMS secret are refreshed with the current credentials. This interrupts pool connections during the apply. Provider v2.25.0 still cannot revoke the `replication` role by updating `roles` to an empty list because its update payload omits empty roles. To revoke it without dropping the user or affecting its grants and owned objects, set `roles = []` and run `ALTER ROLE "user_name" NOREPLICATION;` through an approved database-administration procedure; the provider cannot perform this transition itself.

## Examples

- [discovery-private-network](https://github.com/prefapp/tfm/tree/main/modules/ovh-postgresql/_examples/discovery-private-network) — one private node, one database and one user.
- [production-pooling](https://github.com/prefapp/tfm/tree/main/modules/ovh-postgresql/_examples/production-pooling) — two nodes and a transaction-mode connection pool.

## Resources

- **OVHcloud PostgreSQL capabilities**: [Versions, plans, networking, roles, backups and retention](https://docs.ovhcloud.com/en/guides/public-cloud/databases/postgresql-capabilities/)
- **OVHcloud PostgreSQL extensions**: [Supported extension catalogue](https://docs.ovhcloud.com/en/guides/public-cloud/databases/postgresql-extensions/)
- **OVHcloud PostgreSQL pools**: [Modes and client limitations](https://docs.ovhcloud.com/en/guides/public-cloud/databases/postgresql-pool/)
- **OVHcloud API authentication**: [Classic API signatures](https://docs.ovhcloud.com/en/guides/manage-and-operate/api/first-steps/) and [service-account OAuth2](https://docs.ovhcloud.com/en/guides/account-and-service-management/account-information/authenticate-api-with-service-account/)
- **OVHcloud Public Cloud pricing**: [Database flavor and storage offers](https://www.ovhcloud.com/en-gb/public-cloud/prices/#postgresql)
- **OVHcloud Terraform provider v2.25.0**: [`ovh_cloud_project_database`](https://registry.terraform.io/providers/ovh/ovh/2.25.0/docs/resources/cloud_project_database), [`ovh_cloud_project_database_database`](https://registry.terraform.io/providers/ovh/ovh/2.25.0/docs/resources/cloud_project_database_database), [`ovh_cloud_project_database_postgresql_user`](https://registry.terraform.io/providers/ovh/ovh/2.25.0/docs/resources/cloud_project_database_postgresql_user), [`ovh_cloud_project_database_postgresql_connection_pool`](https://registry.terraform.io/providers/ovh/ovh/2.25.0/docs/resources/cloud_project_database_postgresql_connection_pool), [`ovh_okms_secret`](https://registry.terraform.io/providers/ovh/ovh/2.25.0/docs/resources/okms_secret)

The module uses OVH provider v2.25.x, which fixes the built-in `avnadmin` user adoption panic introduced in v2.23.0.

## Support

For questions, issues or contributions related to this module, visit the [repository issue tracker](https://github.com/prefapp/tfm/issues).
