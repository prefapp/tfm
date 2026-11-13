# OVH PostgreSQL Terraform Import IDs

Verified against OVH Terraform provider v2.24.0, the version used by the module's
examples and the minimum version declared in `modules/ovh-postgresql/versions.tf`.
The provider's tagged source confirms the import formats:

| Resource | Import ID | Import support |
|---|---|---|
| `ovh_cloud_project_database` | `<service_name>/postgresql/<cluster_id>` | Yes |
| `ovh_cloud_project_database_database` | `<service_name>/postgresql/<cluster_id>/<database_id>` | Yes |
| `ovh_cloud_project_database_postgresql_user` | `<service_name>/<cluster_id>/<user_id>` | Yes |
| `ovh_cloud_project_database_postgresql_connection_pool` | `<service_name>/<cluster_id>/<pool_id>` | Yes |
| `ovh_okms_secret` | No documented import ID | No importer implemented in v2.24.0 |

The cluster and database import formats include the `postgresql` engine segment;
user and pool IDs do not. Existing OKMS secrets cannot be adopted using
`terraform import` with provider v2.24.0.

## Official Sources

- [Cluster resource docs, v2.24.0](https://registry.terraform.io/providers/ovh/ovh/2.24.0/docs/resources/cloud_project_database) and [tagged source](https://github.com/ovh/terraform-provider-ovh/blob/v2.24.0/ovh/resource_cloud_project_database.go)
- [Database resource docs, v2.24.0](https://registry.terraform.io/providers/ovh/ovh/2.24.0/docs/resources/cloud_project_database_database) and [tagged source](https://github.com/ovh/terraform-provider-ovh/blob/v2.24.0/ovh/resource_cloud_project_database_database.go)
- [PostgreSQL user resource docs, v2.24.0](https://registry.terraform.io/providers/ovh/ovh/2.24.0/docs/resources/cloud_project_database_postgresql_user) and [tagged source](https://github.com/ovh/terraform-provider-ovh/blob/v2.24.0/ovh/resource_cloud_project_database_postgresql_user.go)
- [Connection pool resource docs, v2.24.0](https://registry.terraform.io/providers/ovh/ovh/2.24.0/docs/resources/cloud_project_database_postgresql_connection_pool) and [tagged source](https://github.com/ovh/terraform-provider-ovh/blob/v2.24.0/ovh/resource_cloud_project_database_postgresql_connection_pool.go)
- [OKMS secret resource docs, v2.24.0](https://registry.terraform.io/providers/ovh/ovh/2.24.0/docs/resources/okms_secret) and [tagged source](https://github.com/ovh/terraform-provider-ovh/blob/v2.24.0/ovh/resource_okms_secret.go)

The Registry documentation pages require JavaScript in this environment. Import
support and resource-specific formats were therefore checked in OVH's tagged
provider source as well. The Registry's latest documentation may describe a newer
provider version than the module currently uses.
