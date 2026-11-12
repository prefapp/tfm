<!-- BEGIN_TF_DOCS -->
# **OVHcloud Managed PostgreSQL Terraform Module**

## Overview

This module provisions one OVHcloud Public Cloud Databases for PostgreSQL cluster in an existing Public Cloud project and private network. It creates the service with one, two or three nodes according to the selected plan, restricts incoming addresses to the private subnet by default, and manages database settings, backup windows and deletion protection.

It also manages declared databases, PostgreSQL users and PgBouncer connection pools. User passwords and pool connection URIs are written as JSON secrets to an existing OVHcloud KMS (OKMS). Sensitive values remain in Terraform state, so the state backend must be encrypted and access-restricted. No password or credential-bearing URI is exposed as a module output.

The module validates the selected PostgreSQL version, plan, region, flavor and disk size against a maintained static snapshot of OVHcloud's stable private-network offers in `data/postgresql-offers.json`. The snapshot comes from an authenticated Public Cloud availability query and is scoped to the project used for that query; refresh and review it deliberately. OVHcloud remains authoritative if offers change after the snapshot is updated. The module resolves the private network and subnet separately from the caller's existing infrastructure. The provider does not expose a PostgreSQL extension resource or an extension-by-version capabilities data source: required extensions are checked against the documented OVHcloud catalogue and known version constraints, but must be activated separately with `CREATE EXTENSION` by a database migration or operator.

## Key Features

- **Private by default**: discovers one existing private network and subnet; defaults IP restrictions to the subnet CIDR.
- **Plan-sized clusters**: generates one node for `discovery`, two for `production`, and three for `advanced`.
- **Maintained offer catalogue**: checks version, plan, region, flavor and disk size against stable private-network offers.
- **Disk range and increment**: enforces the selected offer's minimum, maximum and storage increment before apply.
- **Database identities**: provisions databases, users with the supported `replication` role, and managed PgBouncer pools.
- **Credentials in OKMS**: writes direct connection JSON and pool URIs to distinct secret paths; outputs paths, never credentials.
- **Lifecycle safety**: deletion protection defaults to enabled; disabling it outside `discovery` emits a plan warning.

## Basic Usage

The caller configures the `ovh` provider. Use the `discovery-private-network` example for a single-node cluster, or `production-pooling` to see a pool in transaction mode.

```hcl
module "postgresql" {
  source = "git::https://github.com/prefapp/tfm.git//modules/ovh-postgresql?ref=ovh-postgresql-vx.y.z"

  project_name = "example-project"
  name         = "authz"
  region       = "GRA"
  network_name = "predev-private"
  subnet_cidr  = "10.20.0.0/16"

  engine_version = "18"
  plan           = "discovery"
  flavor         = "b3-4"
  disk_size      = 80

  databases = { authz = "authz" }
  users = {
    authz = { name = "authz", database = "authz" }
  }

  kms_id = "<okms-id>"
}
```

### PostgreSQL with a transaction pool

```hcl
module "postgresql" {
  source = "git::https://github.com/prefapp/tfm.git//modules/ovh-postgresql?ref=ovh-postgresql-vx.y.z"

  project_id  = "<public-cloud-service-name>"
  name        = "application-db"
  region      = "GRA"
  network_name = "applications-private"
  subnet_cidr  = "10.30.0.0/16"

  engine_version = "17"
  plan           = "production"
  flavor         = "b3-8"
  disk_size      = 160

  databases = { app = "application" }
  users = {
    app = { name = "application", database = "app", roles = [] }
  }
  connection_pools = {
    app = {
      name     = "application-pool"
      database = "app"
      user     = "app"
      mode     = "transaction"
      size     = 20
    }
  }

  required_extensions = ["pgvector"]
  kms_id              = "<okms-id>"
}
```

With transaction pooling, review application use of prepared statements, temporary tables, session-level settings and advisory locks. Use session mode when the application depends on session state.

## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_ovh"></a> [ovh](#requirement\_ovh) | >= 2.24.0, < 3.0.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_ovh"></a> [ovh](#provider\_ovh) | 2.24.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [ovh_cloud_project_database.postgresql](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_database) | resource |
| [ovh_cloud_project_database_database.database](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_database_database) | resource |
| [ovh_cloud_project_database_postgresql_connection_pool.pool](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_database_postgresql_connection_pool) | resource |
| [ovh_cloud_project_database_postgresql_user.user](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_database_postgresql_user) | resource |
| [ovh_okms_secret.pool](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/okms_secret) | resource |
| [ovh_okms_secret.user](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/okms_secret) | resource |
| [ovh_cloud_project_database_certificates.certificates](https://registry.terraform.io/providers/ovh/ovh/latest/docs/data-sources/cloud_project_database_certificates) | data source |
| [ovh_cloud_project_network_private_subnets.subnets](https://registry.terraform.io/providers/ovh/ovh/latest/docs/data-sources/cloud_project_network_private_subnets) | data source |
| [ovh_cloud_project_network_privates.networks](https://registry.terraform.io/providers/ovh/ovh/latest/docs/data-sources/cloud_project_network_privates) | data source |
| [ovh_cloud_projects.projects](https://registry.terraform.io/providers/ovh/ovh/latest/docs/data-sources/cloud_projects) | data source |
| [ovh_okms_resource.kms](https://registry.terraform.io/providers/ovh/ovh/latest/docs/data-sources/okms_resource) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_advanced_configuration"></a> [advanced\_configuration](#input\_advanced\_configuration) | PostgreSQL advanced configuration key/value pairs supported by OVHcloud. | `map(string)` | `{}` | no |
| <a name="input_allow_all_ips"></a> [allow\_all\_ips](#input\_allow\_all\_ips) | Explicit opt-in required before allowing 0.0.0.0/0 or ::/0 in ip\_restrictions. | `bool` | `false` | no |
| <a name="input_backup_regions"></a> [backup\_regions](#input\_backup\_regions) | One or two backup regions; one must be the database region. | `list(string)` | `[]` | no |
| <a name="input_backup_time"></a> [backup\_time](#input\_backup\_time) | Daily backup start time in UTC, formatted as hh:mm:ss. | `string` | `null` | no |
| <a name="input_connection_pools"></a> [connection\_pools](#input\_connection\_pools) | PgBouncer pools keyed by stable Terraform identifier. | <pre>map(object({<br/>    name        = string<br/>    database    = string<br/>    mode        = string<br/>    size        = number<br/>    user        = optional(string)<br/>    secret_path = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_databases"></a> [databases](#input\_databases) | Databases to create, keyed by stable Terraform identifier and mapped to their OVHcloud names. | `map(string)` | n/a | yes |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Protect the database service from deletion. Disable only for discovery environments. | `bool` | `true` | no |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | Database disk size in GB. Must meet the maintained OVHcloud offer's minimum, maximum and increment for the selected plan and flavor. | `number` | n/a | yes |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | Required PostgreSQL engine major version. Must appear in the maintained OVHcloud offer catalogue. | `string` | n/a | yes |
| <a name="input_flavor"></a> [flavor](#input\_flavor) | Database node flavor available for the selected plan, region and PostgreSQL version in the maintained OVHcloud offer catalogue. | `string` | n/a | yes |
| <a name="input_ip_restrictions"></a> [ip\_restrictions](#input\_ip\_restrictions) | Optional CIDR allow-list. When empty, only subnet\_cidr is allowed. | <pre>list(object({<br/>    ip          = string<br/>    description = optional(string, "")<br/>  }))</pre> | `[]` | no |
| <a name="input_kms_id"></a> [kms\_id](#input\_kms\_id) | ID of the existing OVHcloud KMS (OKMS) where database credentials are stored. | `string` | n/a | yes |
| <a name="input_maintenance_time"></a> [maintenance\_time](#input\_maintenance\_time) | Daily maintenance start time in UTC, formatted as hh:mm:ss. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Database service description and prefix for generated OKMS secret paths. | `string` | n/a | yes |
| <a name="input_network_name"></a> [network\_name](#input\_network\_name) | Exact name of the existing private network to attach to the cluster. | `string` | n/a | yes |
| <a name="input_plan"></a> [plan](#input\_plan) | OVHcloud database plan. discovery has one node, production two, and advanced three. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Optional Public Cloud project ID or service\_name; takes precedence over project\_name. | `string` | `null` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Optional Public Cloud project name; matched against project\_name and description. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | OVHcloud region for the cluster and all its nodes. Must be in the maintained PostgreSQL offer catalogue. | `string` | n/a | yes |
| <a name="input_required_extensions"></a> [required\_extensions](#input\_required\_extensions) | Extensions required by the workload. Checked against the OVHcloud catalogue and documented PostgreSQL version constraints; extensions are activated separately with CREATE EXTENSION. | `list(string)` | `[]` | no |
| <a name="input_secret_custom_metadata"></a> [secret\_custom\_metadata](#input\_secret\_custom\_metadata) | Custom metadata added to generated OKMS secrets. | `map(string)` | <pre>{<br/>  "owner": "firestartr"<br/>}</pre> | no |
| <a name="input_subnet_cidr"></a> [subnet\_cidr](#input\_subnet\_cidr) | CIDR of the existing subnet to attach to the cluster. | `string` | n/a | yes |
| <a name="input_users"></a> [users](#input\_users) | PostgreSQL users. Each user references one declared database and gets a direct-connection secret in OKMS. | <pre>map(object({<br/>    name           = string<br/>    database       = string<br/>    roles          = optional(list(string), [])<br/>    password_reset = optional(string)<br/>    secret_path    = optional(string)<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_ca_certificate"></a> [ca\_certificate](#output\_ca\_certificate) | Certificate authority certificate for verified TLS connections. |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | ID of the managed PostgreSQL cluster. |
| <a name="output_database_ids"></a> [database\_ids](#output\_database\_ids) | OVHcloud database IDs by configured database key. |
| <a name="output_endpoints"></a> [endpoints](#output\_endpoints) | PostgreSQL service endpoint domains, ports and TLS modes; connection URIs are omitted. |
| <a name="output_kms_id"></a> [kms\_id](#output\_kms\_id) | ID of the OKMS holding database credentials. |
| <a name="output_pool_endpoints"></a> [pool\_endpoints](#output\_pool\_endpoints) | Non-sensitive connection pool details by pool key. URIs are deliberately omitted. |
| <a name="output_pool_secret_paths"></a> [pool\_secret\_paths](#output\_pool\_secret\_paths) | OKMS paths containing pooled connection URIs by pool key. |
| <a name="output_service_name"></a> [service\_name](#output\_service\_name) | OVHcloud Public Cloud project service name. |
| <a name="output_status"></a> [status](#output\_status) | Current OVHcloud service status. |
| <a name="output_user_secret_paths"></a> [user\_secret\_paths](#output\_user\_secret\_paths) | OKMS paths containing direct-connection credentials by user key. |

## Extensions

This module does not run SQL. Apply required extensions separately in each target database:

```sql
CREATE EXTENSION IF NOT EXISTS "pgvector";
```

The provider has no managed PostgreSQL extension resource and OVHcloud's capabilities data source does not return extensions. The module therefore checks extension names against the [OVHcloud extension catalogue](https://docs.ovhcloud.com/en/guides/public-cloud/databases/postgresql-extensions/) and enforces documented constraints for TimescaleDB (not available on PostgreSQL 18) and pgvectorscale (documented for PostgreSQL 16 and 17). Confirm other extension/version combinations with OVHcloud before deployment. `CREATE EXTENSION` permissions and required activation order are the caller's responsibility.

## Secrets and External Secrets Operator

Each user secret is JSON with `host`, `port`, `username`, `password` and `database`. Each pool secret is JSON with `uri`. The module outputs only secret paths; configure External Secrets Operator to read the relevant OKMS paths and map JSON properties to Kubernetes Secret keys. Passwords and pool URIs remain sensitive in Terraform state despite not being outputs.

New PostgreSQL users have no privileges on database objects by default. Manage required database/schema/table grants with SQL migrations; the OVHcloud API only manages the `replication` role.

## Maintained Offer Catalogue

`data/postgresql-offers.json` contains the maintained snapshot of stable PostgreSQL private-network offers. It records versions, regions, supported plan/flavor combinations, plan node counts and per-offer disk minimum, maximum and increment. It was captured from an authenticated OVHcloud availability query for one Public Cloud project on the recorded date. Update it from a fresh availability query and review the diff when OVHcloud offers change; the snapshot is not a live availability guarantee for every project. In the captured data, each listed version and region is available across all listed plan/flavor offers.

The catalogue represents private networking because the module always attaches to an existing private network and subnet. Database node count is derived from the selected plan. The network name and subnet CIDR are resolved from the caller's project and are not part of OVHcloud's offer catalogue. OVHcloud remains authoritative and may reject a configuration if its offers change after the snapshot.

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
- OKMS secret: OVH provider v2.24.0 does not implement import for `ovh_okms_secret`; existing secrets at generated paths cannot be adopted with `terraform import`.

Destroying the module deletes the managed cluster and all data in it, its declared databases/users/pools, and the OKMS secrets at the configured paths. It does not delete the Public Cloud project, private network, subnet or OKMS. Disable deletion protection before intentional destroy; use backups and verify retention first. Changing network/subnet triggers a service rebuild and may temporarily interrupt connectivity. Changing the region recreates the cluster. Changing a database or user key changes its Terraform address and can cause replacement unless state is migrated. The maintained offer catalogue validates the requested database configuration during plan; OVHcloud remains authoritative during apply.

## Examples

- [discovery-private-network](https://github.com/prefapp/tfm/tree/main/modules/ovh-postgresql/_examples/discovery-private-network) — one private node, one database and one user.
- [production-pooling](https://github.com/prefapp/tfm/tree/main/modules/ovh-postgresql/_examples/production-pooling) — two nodes and a transaction-mode connection pool.

## Resources

- **OVHcloud PostgreSQL capabilities**: [Versions, plans, networking, roles, backups and retention](https://docs.ovhcloud.com/en/guides/public-cloud/databases/postgresql-capabilities/)
- **OVHcloud PostgreSQL extensions**: [Supported extension catalogue](https://docs.ovhcloud.com/en/guides/public-cloud/databases/postgresql-extensions/)
- **OVHcloud PostgreSQL pools**: [Modes and client limitations](https://docs.ovhcloud.com/en/guides/public-cloud/databases/postgresql-pool/)
- **OVHcloud API authentication**: [Classic API signatures](https://docs.ovhcloud.com/en/guides/manage-and-operate/api/first-steps/) and [service-account OAuth2](https://docs.ovhcloud.com/en/guides/account-and-service-management/account-information/authenticate-api-with-service-account/)
- **OVHcloud Public Cloud pricing**: [Database flavor and storage offers](https://www.ovhcloud.com/en-gb/public-cloud/prices/#postgresql)
- **OVHcloud Terraform provider v2.24.0**: [`ovh_cloud_project_database`](https://registry.terraform.io/providers/ovh/ovh/2.24.0/docs/resources/cloud_project_database), [`ovh_cloud_project_database_database`](https://registry.terraform.io/providers/ovh/ovh/2.24.0/docs/resources/cloud_project_database\_database), [`ovh_cloud_project_database_postgresql_user`](https://registry.terraform.io/providers/ovh/ovh/2.24.0/docs/resources/cloud_project_database\_postgresql\_user), [`ovh_cloud_project_database_postgresql_connection_pool`](https://registry.terraform.io/providers/ovh/ovh/2.24.0/docs/resources/cloud_project_database\_postgresql\_connection\_pool), [`ovh_okms_secret`](https://registry.terraform.io/providers/ovh/ovh/2.24.0/docs/resources/okms_secret)

## Support

For questions, issues or contributions related to this module, visit the [repository issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->