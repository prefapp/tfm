<!-- BEGIN_TF_DOCS -->
# **OVHcloud Managed PostgreSQL Terraform Module**

## Overview

This module provisions one OVHcloud Public Cloud Databases for PostgreSQL cluster in an existing Public Cloud project and private network. It creates the service with one, two or three nodes according to the selected plan, restricts incoming addresses to the private subnet by default, and manages database settings, backup windows and deletion protection.

It also manages declared databases, PostgreSQL users and PgBouncer connection pools. User passwords and pool connection URIs are written as JSON secrets to an existing OVHcloud KMS (OKMS). Sensitive values remain in Terraform state, so the state backend must be encrypted and access-restricted. No password or credential-bearing URI is exposed as a module output.

The module validates PostgreSQL versions and regions against separate allowlists in a maintained static snapshot, and validates plans, flavors and disk limits using the plan-specific entries in `data/postgresql-offers.json`. These checks do not verify that the selected version, plan, region and flavor are offered together, or that the offer is currently available to the caller's project. The module consumer is responsible for selecting a valid combination; OVHcloud remains authoritative and may reject it during apply. The snapshot comes from an authenticated Public Cloud availability query for one project; refresh and review it deliberately. The module resolves the private network and subnet separately from the caller's existing infrastructure. The provider does not expose a PostgreSQL extension resource or an extension-by-version capabilities data source: required extensions are checked against the documented OVHcloud catalogue and its stated version restrictions, but must be activated separately with `CREATE EXTENSION` by a database migration or operator. For TimescaleDB, OVHcloud explicitly says it is not yet available on PostgreSQL 18; its public documentation does not specify supported plans, regions, extension versions or editions.

## Key Features

- **Private by default**: discovers one existing private network and subnet; defaults IP restrictions to the subnet CIDR.
- **Plan-sized clusters**: generates one node for `discovery`, two for `production`, and three for `advanced`.
- **Maintained option catalogue**: checks version, region, plan, flavor and disk size against separate allowlists and plan-specific limits; it does not validate combinations or live availability.
- **Disk range and increment**: enforces the catalogue minimum, maximum and storage increment for the selected plan and flavor before apply.
- **Database identities**: provisions databases, users with the supported `replication` role, and managed PgBouncer pools.
- **Credentials in OKMS**: writes direct connection JSON and pool URIs to distinct secret paths; outputs paths, never credentials.
- **Lifecycle safety**: deletion protection defaults to enabled; destroy-time guards protect managed databases, users, pools and OKMS secrets.
- **Common service outputs**: exposes the service ID, description, status, direct endpoint, CA, service name and database names following the `ovh-mysql` output pattern.

## Basic Usage

The caller configures the `ovh` provider. Use the `discovery-private-network` example for a single-node cluster, or `production-pooling` to see a pool in transaction mode.

```hcl
module "postgresql" {
  source = "git::https://github.com/prefapp/tfm.git//modules/ovh-postgresql?ref=ovh-postgresql-vx.y.z"

  project_name   = "example-project"
  name           = "authz"
  region         = "GRA"
  network_name   = "predev-private"
  subnet_cidr    = "10.20.0.0/16"

  # Set only when the network API uses a different OpenStack region name.
  # network_region = "GRA11"

  engine_version = "18"
  plan           = "discovery"
  flavor         = "b3-4"
  disk_size      = 80

  databases = { authz = "authz" }
  users = {
    authz = { name = "authz", database = "authz" }
  }

  okms_id = "<okms-id>"
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
  okms_id             = "<okms-id>"
}
```

With transaction pooling, review application use of prepared statements, temporary tables, session-level settings and advisory locks. Use session mode when the application depends on session state.

`disk_size` is required for PostgreSQL and must fit the selected plan and flavor limits in the maintained offer catalogue. The module outputs `postgresql_id`, `postgresql_description`, `postgresql_status`, `postgresql_host`, `postgresql_port`, and `postgresql_ca`, matching the MySQL module's service output pattern. PostgreSQL-specific outputs expose endpoint TLS details and separate direct-user and pool secret paths.

## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_ovh"></a> [ovh](#requirement\_ovh) | ~> 2.25 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_ovh"></a> [ovh](#provider\_ovh) | 2.25.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

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
| [terraform_data.deletion_guard](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.deletion_guard_barrier](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.pool_user](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.secret_okms_deletion_guard](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [ovh_cloud_project_database_certificates.certificates](https://registry.terraform.io/providers/ovh/ovh/latest/docs/data-sources/cloud_project_database_certificates) | data source |
| [ovh_cloud_project_network_private_subnets.subnets](https://registry.terraform.io/providers/ovh/ovh/latest/docs/data-sources/cloud_project_network_private_subnets) | data source |
| [ovh_cloud_project_network_privates.networks](https://registry.terraform.io/providers/ovh/ovh/latest/docs/data-sources/cloud_project_network_privates) | data source |
| [ovh_cloud_projects.projects](https://registry.terraform.io/providers/ovh/ovh/latest/docs/data-sources/cloud_projects) | data source |
| [ovh_okms_resource.kms](https://registry.terraform.io/providers/ovh/ovh/latest/docs/data-sources/okms_resource) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_advanced_configuration"></a> [advanced\_configuration](#input\_advanced\_configuration) | PostgreSQL advanced configuration key/value pairs supported by OVHcloud. | `map(string)` | `{}` | no |
| <a name="input_allow_public_access"></a> [allow\_public\_access](#input\_allow\_public\_access) | Explicit opt-in required before allowing 0.0.0.0/0 or ::/0 in ip\_restrictions. | `bool` | `false` | no |
| <a name="input_backup_regions"></a> [backup\_regions](#input\_backup\_regions) | Optional backup regions; when empty, OVHcloud's default is left unchanged. When set, one or two regions are allowed and one must be the database region. | `list(string)` | `[]` | no |
| <a name="input_backup_time"></a> [backup\_time](#input\_backup\_time) | Daily backup start time in UTC, formatted as hh:mm:ss. | `string` | `null` | no |
| <a name="input_connection_pools"></a> [connection\_pools](#input\_connection\_pools) | PgBouncer pools keyed by stable Terraform identifier. | <pre>map(object({<br/>    name        = string<br/>    database    = string<br/>    mode        = string<br/>    size        = number<br/>    user        = optional(string)<br/>    secret_path = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_databases"></a> [databases](#input\_databases) | Databases to create, keyed by stable Terraform identifier and mapped to their OVHcloud names. | `map(string)` | n/a | yes |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Protect the database service from deletion. Disable only for discovery environments. | `bool` | `true` | no |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | Required database disk size in GB. Must meet the maintained catalogue's minimum, maximum and increment for the selected plan and flavor. | `number` | n/a | yes |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | Required PostgreSQL engine major version. Must appear in the maintained OVHcloud offer catalogue. | `string` | n/a | yes |
| <a name="input_flavor"></a> [flavor](#input\_flavor) | Database node flavor listed for the selected plan in the maintained OVHcloud catalogue. | `string` | n/a | yes |
| <a name="input_ip_restrictions"></a> [ip\_restrictions](#input\_ip\_restrictions) | Optional CIDR allow-list. When empty, only subnet\_cidr is allowed. | <pre>list(object({<br/>    ip          = string<br/>    description = optional(string, "")<br/>  }))</pre> | `[]` | no |
| <a name="input_maintenance_time"></a> [maintenance\_time](#input\_maintenance\_time) | Daily maintenance start time in UTC, formatted as hh:mm:ss. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Database service description and prefix for generated OKMS secret paths. | `string` | n/a | yes |
| <a name="input_network_name"></a> [network\_name](#input\_network\_name) | Exact name of the existing private network to attach to the cluster. | `string` | n/a | yes |
| <a name="input_network_region"></a> [network\_region](#input\_network\_region) | Optional OpenStack region identifier for the existing private network and subnet; defaults to region when both APIs use the same region name. | `string` | `null` | no |
| <a name="input_okms_id"></a> [okms\_id](#input\_okms\_id) | ID of the existing OVHcloud KMS (OKMS) where database credentials are stored. | `string` | n/a | yes |
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
| <a name="output_database_ids"></a> [database\_ids](#output\_database\_ids) | OVHcloud database IDs by configured database key. |
| <a name="output_database_names"></a> [database\_names](#output\_database\_names) | Names of PostgreSQL databases managed by this module, keyed by configuration key. |
| <a name="output_pool_endpoints"></a> [pool\_endpoints](#output\_pool\_endpoints) | Non-sensitive connection pool details by pool key. URIs are deliberately omitted. |
| <a name="output_pool_secret_paths"></a> [pool\_secret\_paths](#output\_pool\_secret\_paths) | OKMS paths containing pooled connection URIs by configured pool key. |
| <a name="output_postgresql_ca"></a> [postgresql\_ca](#output\_postgresql\_ca) | Certificate authority certificate for verified TLS connections. |
| <a name="output_postgresql_description"></a> [postgresql\_description](#output\_postgresql\_description) | Description assigned to the managed PostgreSQL service. |
| <a name="output_postgresql_endpoints"></a> [postgresql\_endpoints](#output\_postgresql\_endpoints) | PostgreSQL service endpoint domains, ports and TLS modes; connection URIs are omitted. |
| <a name="output_postgresql_host"></a> [postgresql\_host](#output\_postgresql\_host) | PostgreSQL direct endpoint hostname. |
| <a name="output_postgresql_id"></a> [postgresql\_id](#output\_postgresql\_id) | ID of the managed PostgreSQL cluster. |
| <a name="output_postgresql_port"></a> [postgresql\_port](#output\_postgresql\_port) | PostgreSQL direct endpoint port. |
| <a name="output_postgresql_status"></a> [postgresql\_status](#output\_postgresql\_status) | Current OVHcloud service status. |
| <a name="output_service_name"></a> [service\_name](#output\_service\_name) | OVHcloud Public Cloud project service name. |
| <a name="output_user_secret_paths"></a> [user\_secret\_paths](#output\_user\_secret\_paths) | OKMS paths containing direct-connection credentials by configured user key. |

## Extensions

This module does not run SQL. Apply required extensions separately in each target database:

```sql
CREATE EXTENSION IF NOT EXISTS vector;
```

The provider has no managed PostgreSQL extension resource and OVHcloud's capabilities data source does not return extensions. The module therefore checks extension names against the [OVHcloud extension catalogue](https://docs.ovhcloud.com/en/guides/public-cloud/databases/postgresql-extensions.md) and enforces its explicit constraints for TimescaleDB and pgvectorscale. The catalogue lists TimescaleDB and says **"Not yet available on PG18"**. It does not publish a TimescaleDB compatibility matrix by plan or region, nor specify a TimescaleDB extension version or edition. OVHcloud's [general PostgreSQL capabilities](https://docs.ovhcloud.com/en/guides/public-cloud/databases/postgresql-capabilities.md) say the database service is available in all Public Cloud 1-AZ and 3-AZ regions and describe the Discovery, Production and Advanced plans, but do not establish TimescaleDB availability for every plan/region combination. Accordingly, the module rejects TimescaleDB on PostgreSQL 18 only; passing that check is not confirmation that the extension is available for a particular offer. Confirm the intended combination with OVHcloud before deployment. The same catalogue documents pgvectorscale for PostgreSQL 16 and 17. For pgvector, the module catalogue label is `pgvector`, while its SQL extension name is `vector`. `CREATE EXTENSION` permissions and required activation order are the caller's responsibility.

## Secrets and External Secrets Operator

Each user secret is JSON with `host`, `port`, `username`, `password` and `database`. Each pool secret is JSON with `uri`. The module outputs only secret paths; configure External Secrets Operator to read the relevant OKMS paths and map JSON properties to Kubernetes Secret keys. Passwords and pool URIs remain sensitive in Terraform state despite not being outputs.

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

The provider's import formats are documented for [clusters](https://registry.terraform.io/providers/ovh/ovh/2.25.0/docs/resources/cloud_project_database), [databases](https://registry.terraform.io/providers/ovh/ovh/2.25.0/docs/resources/cloud_project_database\_database), [PostgreSQL users](https://registry.terraform.io/providers/ovh/ovh/2.25.0/docs/resources/cloud_project_database\_postgresql\_user) and [connection pools](https://registry.terraform.io/providers/ovh/ovh/2.25.0/docs/resources/cloud_project_database\_postgresql\_connection\_pool). The module uses provider v2.25.x; use each resource's corresponding address and ID format above. The ID components are the Public Cloud project service name, cluster ID, and child resource ID as applicable.

Destroying the module deletes the managed cluster and all data in it, its declared databases/users/pools, and the OKMS secrets at the configured paths. It does not delete the Public Cloud project, private network, subnet or OKMS. OVHcloud deletion protection protects the cluster; Terraform destroy-time guards also protect each managed database, user, pool and OKMS secret, with a barrier preventing parallel child deletion during a full destroy. For an intentional destroy or removal of one of these resources, set `deletion_protection = false` and apply before destroying or changing the configuration. Keep the module configuration present during destroy so Terraform can run its guards. Use backups and verify retention first. Changing network/subnet triggers a service rebuild and may temporarily interrupt connectivity. Changing the region recreates the cluster. Changing a database or user key changes its Terraform address and can cause replacement unless state is migrated. Plan validates catalogue membership and plan-specific flavor/disk limits, not cross-dimension offer compatibility or live availability; OVHcloud remains authoritative during apply.

Changing a pool's optional user restriction recreates that pool because OVHcloud provider v2.25.0 models `user_id` as Optional+Computed and omits empty IDs from update requests. This also causes existing pools to be recreated once when adopting this lifecycle rule; schedule the rollout for the possible connection interruption.

Changing `password_reset` for a user restricted to a pool also recreates that pool so its connection URI and OKMS secret are refreshed with the rotated credentials. This interrupts pool connections during the apply. Provider v2.25.0 still cannot revoke the `replication` role by updating `roles` to an empty list because its update payload omits empty roles. To revoke it without dropping the user or affecting its grants and owned objects, set `roles = []` and run `ALTER ROLE "user_name" NOREPLICATION;` through an approved database-administration procedure; the provider cannot perform this transition itself.

## Examples

- [discovery-private-network](https://github.com/prefapp/tfm/tree/main/modules/ovh-postgresql/_examples/discovery-private-network) — one private node, one database and one user.
- [production-pooling](https://github.com/prefapp/tfm/tree/main/modules/ovh-postgresql/_examples/production-pooling) — two nodes and a transaction-mode connection pool.

## Resources

- **OVHcloud PostgreSQL capabilities**: [Versions, plans, networking, roles, backups and retention](https://docs.ovhcloud.com/en/guides/public-cloud/databases/postgresql-capabilities/)
- **OVHcloud PostgreSQL extensions**: [Supported extension catalogue](https://docs.ovhcloud.com/en/guides/public-cloud/databases/postgresql-extensions/)
- **OVHcloud PostgreSQL pools**: [Modes and client limitations](https://docs.ovhcloud.com/en/guides/public-cloud/databases/postgresql-pool/)
- **OVHcloud API authentication**: [Classic API signatures](https://docs.ovhcloud.com/en/guides/manage-and-operate/api/first-steps/) and [service-account OAuth2](https://docs.ovhcloud.com/en/guides/account-and-service-management/account-information/authenticate-api-with-service-account/)
- **OVHcloud Public Cloud pricing**: [Database flavor and storage offers](https://www.ovhcloud.com/en-gb/public-cloud/prices/#postgresql)
- **OVHcloud Terraform provider v2.25.0**: [`ovh_cloud_project_database`](https://registry.terraform.io/providers/ovh/ovh/2.25.0/docs/resources/cloud_project_database), [`ovh_cloud_project_database_database`](https://registry.terraform.io/providers/ovh/ovh/2.25.0/docs/resources/cloud_project_database\_database), [`ovh_cloud_project_database_postgresql_user`](https://registry.terraform.io/providers/ovh/ovh/2.25.0/docs/resources/cloud_project_database\_postgresql\_user), [`ovh_cloud_project_database_postgresql_connection_pool`](https://registry.terraform.io/providers/ovh/ovh/2.25.0/docs/resources/cloud_project_database\_postgresql\_connection\_pool), [`ovh_okms_secret`](https://registry.terraform.io/providers/ovh/ovh/2.25.0/docs/resources/okms_secret)

The module uses OVH provider v2.25.x, which fixes the built-in `avnadmin` user adoption panic introduced in v2.23.0.

## Support

For questions, issues or contributions related to this module, visit the [repository issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->
