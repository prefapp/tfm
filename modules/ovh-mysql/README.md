<!-- BEGIN_TF_DOCS -->
# **OVHcloud Managed MySQL Terraform Module**

## Overview

This module provisions an OVHcloud Public Cloud Databases for MySQL service, its logical databases, and the service's OVH-managed `avnadmin` account in an existing Public Cloud project. The generated administrator credentials are stored in an OVHcloud Key Management Service (OKMS) secret. It selects the project by `project_id` or `project_name`, checks the requested MySQL version and flavor against live project capabilities, and derives the number of nodes from the selected plan.

By default, every node attaches to an existing private network and subnet discovered by exact network name and subnet CIDR. The MySQL service region and private-network region are separate inputs: for example, OVH may use `GRA` for managed databases and `GRA11` for the network's regional OpenStack identifiers. The module also restricts incoming connections to that subnet unless explicit CIDR restrictions are supplied. Flavor availability and disk capacity are finally validated by OVHcloud when creating the service.

## Key Features

- **Managed MySQL service**: Creates MySQL with a selected version, plan, flavor, disk size and advanced configuration.
- **Plan-derived topology**: Creates one node for `discovery`, two for `production`, or three for `advanced`.
- **Existing private network**: Discovers and attaches the regional network ID and subnet ID without managing the network itself.
- **Private-by-default access**: Defaults the MySQL IP allow-list to the selected subnet; public-wide CIDRs require explicit opt-in.
- **Logical databases**: Creates a set of named databases in the managed service.
- **Administrator credential storage**: Resets the existing OVH-managed `avnadmin` password and publishes username/password JSON to OKMS.

## Basic Usage

Configure the `ovh` provider in the caller. The private network and subnet must exist before applying this module.

### Single-node MySQL with private networking

```hcl
module "ovh_mysql" {
  source = "git::https://github.com/prefapp/tfm.git//modules/ovh-mysql?ref=ovh-mysql-vx.y.z"

  project_name = "example-project"
  okms_id      = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  name         = "example-mysql"
  region         = "GRA"
  network_region = "GRA11"
  engine_version = "8.4"
  plan           = "discovery"
  flavor         = "b3-4"

  network_name   = "example-private-network"
  subnet_cidr    = "10.40.0.0/16"
  databases      = ["application"]
}
```

### Production topology with additional backup region

```hcl
module "ovh_mysql_production" {
  source = "git::https://github.com/prefapp/tfm.git//modules/ovh-mysql?ref=ovh-mysql-vx.y.z"

  project_name = "example-project"
  okms_id      = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  name         = "example-mysql-production"
  region         = "GRA"
  network_region = "GRA11"
  engine_version = "8.4"
  plan           = "production"
  flavor         = "b3-8"

  network_name   = "example-private-network"
  subnet_cidr    = "10.40.0.0/16"
  backup_regions = ["GRA", "SBG"]
  databases      = ["application", "audit"]

  advanced_configuration = {
    "mysql.sql_require_primary_key" = "true"
  }
}
```

The module manages only the OVH-provided `avnadmin` account; it does not create application users. `avnadmin` has administrator-equivalent privileges and must not be used by applications; create SQL-managed accounts with least privilege through a separate workflow. The `okms_id` input is required and `admin_secret_path` optionally overrides the default path `mysql/<name>/avnadmin`. The default `admin_password_reset = "initial"` resets the OVH-managed password when the account is first managed. Change that value to request later rotations and publish a new OKMS version. MySQL connections accept TLS and the module exposes the project's CA; configure clients to require TLS and verify the server identity. Both Terraform state and plan files can contain the password, so protect them with encryption and access controls.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_ovh"></a> [ovh](#requirement\_ovh) | = 2.23.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_ovh"></a> [ovh](#provider\_ovh) | 2.23.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [ovh_cloud_project_database.mysql](https://registry.terraform.io/providers/ovh/ovh/2.23.0/docs/resources/cloud_project_database) | resource |
| [ovh_cloud_project_database_database.databases](https://registry.terraform.io/providers/ovh/ovh/2.23.0/docs/resources/cloud_project_database_database) | resource |
| [ovh_cloud_project_database_user.admin](https://registry.terraform.io/providers/ovh/ovh/2.23.0/docs/resources/cloud_project_database_user) | resource |
| [ovh_okms_secret.admin](https://registry.terraform.io/providers/ovh/ovh/2.23.0/docs/resources/okms_secret) | resource |
| [ovh_cloud_project_database_capabilities.capabilities](https://registry.terraform.io/providers/ovh/ovh/2.23.0/docs/data-sources/cloud_project_database_capabilities) | data source |
| [ovh_cloud_project_database_certificates.ca](https://registry.terraform.io/providers/ovh/ovh/2.23.0/docs/data-sources/cloud_project_database_certificates) | data source |
| [ovh_cloud_project_network_private_subnets.subnets](https://registry.terraform.io/providers/ovh/ovh/2.23.0/docs/data-sources/cloud_project_network_private_subnets) | data source |
| [ovh_cloud_project_network_privates.networks](https://registry.terraform.io/providers/ovh/ovh/2.23.0/docs/data-sources/cloud_project_network_privates) | data source |
| [ovh_cloud_projects.projects](https://registry.terraform.io/providers/ovh/ovh/2.23.0/docs/data-sources/cloud_projects) | data source |
| [ovh_okms_resource.kms](https://registry.terraform.io/providers/ovh/ovh/2.23.0/docs/data-sources/okms_resource) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_password_reset"></a> [admin\_password\_reset](#input\_admin\_password\_reset) | Reset trigger for the OVHcloud avnadmin password. Defaults to an initial reset; change this value to rotate the password and publish a new OKMS secret version. | `string` | `"initial"` | no |
| <a name="input_admin_secret_path"></a> [admin\_secret\_path](#input\_admin\_secret\_path) | Optional OKMS path for the JSON document containing the MySQL administrator username and password. Defaults to mysql/<name>/avnadmin. | `string` | `null` | no |
| <a name="input_advanced_configuration"></a> [advanced\_configuration](#input\_advanced\_configuration) | Optional MySQL advanced configuration settings supported by OVHcloud. | `map(string)` | `{}` | no |
| <a name="input_allow_public_access"></a> [allow\_public\_access](#input\_allow\_public\_access) | Explicitly allow 0.0.0.0/0 or ::/0 in ip\_restrictions. Avoid this outside temporary testing. | `bool` | `false` | no |
| <a name="input_backup_regions"></a> [backup\_regions](#input\_backup\_regions) | Optional backup destination regions, with at most two regions and including the MySQL node region. OVHcloud validates availability of each backup region. | `set(string)` | `null` | no |
| <a name="input_backup_time"></a> [backup\_time](#input\_backup\_time) | Optional daily backup start time in UTC, formatted as hh:mm:ss. | `string` | `null` | no |
| <a name="input_databases"></a> [databases](#input\_databases) | List of MySQL database names to create in the service; names must be unique. | `list(string)` | `[]` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Enable OVHcloud deletion protection. Disable and apply it before destroying the service. | `bool` | `true` | no |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | Optional database disk size in GB. OVHcloud validates its supported range for the selected MySQL flavor. | `number` | `null` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | MySQL engine version; must be present in the selected project's live capabilities. | `string` | n/a | yes |
| <a name="input_flavor"></a> [flavor](#input\_flavor) | MySQL node flavor; must be present in the selected project's live capabilities. | `string` | n/a | yes |
| <a name="input_ip_restrictions"></a> [ip\_restrictions](#input\_ip\_restrictions) | Allowed source CIDRs. null defaults to the private subnet CIDR (or no allowed IPs without private networking); an empty list denies all incoming IP connections. | <pre>list(object({<br/>    ip          = string<br/>    description = optional(string, "")<br/>  }))</pre> | `null` | no |
| <a name="input_maintenance_time"></a> [maintenance\_time](#input\_maintenance\_time) | Optional daily maintenance start time in UTC, formatted as hh:mm:ss. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Description assigned to the managed MySQL service. | `string` | n/a | yes |
| <a name="input_network_name"></a> [network\_name](#input\_network\_name) | Exact name of the existing private network. Required when use\_private\_network is true. | `string` | `null` | no |
| <a name="input_network_region"></a> [network\_region](#input\_network\_region) | Optional OVHcloud region identifier used to discover the private network and subnet. Defaults to region; set it when network IDs use a different regional identifier, such as GRA11 for a MySQL region GRA. | `string` | `null` | no |
| <a name="input_okms_id"></a> [okms\_id](#input\_okms\_id) | ID of the OVHcloud KMS (OKMS) where the MySQL administrator credentials are stored. | `string` | n/a | yes |
| <a name="input_plan"></a> [plan](#input\_plan) | MySQL plan: discovery (1 node), production (2 nodes), or advanced (3 nodes). | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Optional Public Cloud project ID or service\_name; takes precedence over project\_name. | `string` | `null` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Optional Public Cloud project name; matched against OVHcloud project\_name and description. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | OVHcloud MySQL region where all service nodes are deployed. | `string` | n/a | yes |
| <a name="input_subnet_cidr"></a> [subnet\_cidr](#input\_subnet\_cidr) | CIDR of the existing subnet to attach and, by default, allow through the MySQL IP restriction list. Required when use\_private\_network is true. | `string` | `null` | no |
| <a name="input_use_private_network"></a> [use\_private\_network](#input\_use\_private\_network) | Attach every MySQL node to an existing private network and subnet. Set false explicitly for a service without private-network attachment. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_admin_secret_path"></a> [admin\_secret\_path](#output\_admin\_secret\_path) | OKMS path storing the JSON MySQL administrator credentials. |
| <a name="output_admin_username"></a> [admin\_username](#output\_admin\_username) | OVHcloud MySQL administrator username. |
| <a name="output_database_names"></a> [database\_names](#output\_database\_names) | Names of MySQL databases managed by this module. |
| <a name="output_mysql_ca"></a> [mysql\_ca](#output\_mysql\_ca) | Service CA certificate required for TLS connections. |
| <a name="output_mysql_description"></a> [mysql\_description](#output\_mysql\_description) | Description assigned to the managed MySQL service. |
| <a name="output_mysql_host"></a> [mysql\_host](#output\_mysql\_host) | MySQL endpoint hostname for TLS connections. |
| <a name="output_mysql_id"></a> [mysql\_id](#output\_mysql\_id) | ID of the managed MySQL service. |
| <a name="output_mysql_port"></a> [mysql\_port](#output\_mysql\_port) | MySQL endpoint port. |
| <a name="output_mysql_status"></a> [mysql\_status](#output\_mysql\_status) | Current service status reported by OVHcloud. |
| <a name="output_node_count"></a> [node\_count](#output\_node\_count) | Number of nodes created for the selected MySQL plan. |
| <a name="output_private_network_id"></a> [private\_network\_id](#output\_private\_network\_id) | Regional OpenStack ID of the attached private network, or null when private networking is disabled. |
| <a name="output_service_name"></a> [service\_name](#output\_service\_name) | OVHcloud Public Cloud service name resolved for the selected project. |
| <a name="output_subnet_id"></a> [subnet\_id](#output\_subnet\_id) | ID of the attached private subnet, or null when private networking is disabled. |

## Import and Lifecycle

The module manages these Terraform resources (addresses assume the caller names the module `ovh_mysql`):

- MySQL service: `module.ovh_mysql.ovh_cloud_project_database.mysql`
- Databases: `module.ovh_mysql.ovh_cloud_project_database_database.databases["<database-name>"]`
- OVH-managed administrator: `module.ovh_mysql.ovh_cloud_project_database_user.admin`
- OKMS administrator secret: `module.ovh_mysql.ovh_okms_secret.admin`

Import an existing MySQL service with `<service_name>/mysql/<cluster_id>`:

```sh
terraform import 'module.ovh_mysql.ovh_cloud_project_database.mysql' '<service_name>/mysql/<cluster_id>'
```

Import each database with `<service_name>/mysql/<cluster_id>/<database_id>`:

```sh
terraform import 'module.ovh_mysql.ovh_cloud_project_database_database.databases["<database-name>"]' '<service_name>/mysql/<cluster_id>/<database_id>'
```

Import the OVH-managed administrator user with `<service_name>/mysql/<cluster_id>/<user_id>`:

```sh
terraform import 'module.ovh_mysql.ovh_cloud_project_database_user.admin' '<service_name>/mysql/<cluster_id>/<user_id>'
```

The OVH provider does not document import for `ovh_okms_secret`; create the managed secret through this module or manage/import it outside this module before adoption.

Destroying the module deletes all managed databases and the MySQL service, including any data and backups retained by OVHcloud. It does not delete the Public Cloud project, private network, subnet or gateway. With `deletion_protection = true`, OVHcloud rejects deletion; set it to `false`, apply that change, and only then run destroy.

Changing the MySQL service `region` forces replacement and can destroy all database data. `network_region` is used only to discover the private network's regional OpenStack ID and subnet; it defaults to `region` but can differ when OVH uses distinct identifiers such as MySQL `GRA` and network `GRA11`. Changing the network attachment triggers a service rebuild and clears IP restrictions while the network changes; review connectivity and restore the intended allow-list after the update. Flavor changes are applied as node upgrades. OVHcloud validates flavor availability and flavor-specific `disk_size` limits against its service availability when applying.

OVHcloud currently documents automatic daily backup retention of 2 days for `discovery`, 14 days for `production`, and 30 days for `advanced`. MySQL backups use point-in-time recovery (PITR), with recovery points within the selected plan's retention period; OVHcloud currently documents continuous backups and an RPO of a few minutes. The plan also determines the service SLA; consult the current [MySQL capabilities and limitations](https://docs.ovhcloud.com/en/guides/public-cloud/databases/mysql-capabilities/) and [automated backups guide](https://docs.ovhcloud.com/en/guides/public-cloud/databases/backups/) before choosing a plan.

Automated plan-mode tests use Terraform provider mocking, which requires Terraform 1.7 or later.

The module maps `avnadmin` to OVHcloud's pre-existing administrator and resets its password during initial management. Removing the Terraform user resource does not delete that account or revoke its password. Removing `ovh_okms_secret.admin` deletes the credential secret from OKMS; retain or migrate the secret before destroying the module if consumers still need the credentials. The MySQL service's `deletion_protection` does not protect the separate OKMS secret.

The default `admin_password_reset = "initial"` ensures the existing administrator's password is reset when the resource is first managed. Changing `admin_password_reset` later requests another reset and publishes a new OKMS secret version. The password is not exported as a Terraform output. However, the OVH user resource password and OKMS `version.data` are stored in Terraform state; encrypt the state and restrict access to state and plan files. OKMS retains prior versions according to its secret metadata.

The administrator is for operations and must not be used as an application identity. OVHcloud API-created users receive administrator-equivalent privileges; least-privilege application users require SQL management outside this module.

MySQL's OVHcloud connection URI uses TLS, but the server also accepts unencrypted connections. Require TLS in every client; use the exposed project CA for server verification, and configure SQL-managed application accounts to require SSL where appropriate. The CA is shared by Public Cloud Databases services in the project.

## Examples

- [Discovery with private network](https://github.com/prefapp/tfm/tree/main/modules/ovh-mysql/_examples/discovery-private-network) — one-node MySQL service, private subnet access and one logical database.
- [Production HA](https://github.com/prefapp/tfm/tree/main/modules/ovh-mysql/_examples/production-ha) — two-node service, advanced settings and backups in two regions.

## Resources

- **OVHcloud MySQL capabilities**: [Plans, versions, flavors, storage and supported regions](https://docs.ovhcloud.com/en/guides/public-cloud/databases/mysql-capabilities.md); [project database availability API](https://docs.ovhcloud.com/en/guides/public-cloud/databases/getting-started.md)
- **OVHcloud MySQL connections and users**: [Network access and user privileges](https://docs.ovhcloud.com/en/guides/public-cloud/databases/mysql-prepare-for-incoming-connections/)
- **OVHcloud deletion protection**: [Managed database deletion protection](https://docs.ovhcloud.com/en/guides/public-cloud/databases/databases-deletion-protection/)
- **OVHcloud Terraform provider**: [`ovh_cloud_project_database`](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_database), [`ovh_cloud_project_database_database`](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_database\_database), [`ovh_cloud_project_database_capabilities`](https://registry.terraform.io/providers/ovh/ovh/latest/docs/data-sources/cloud_project_database_capabilities), and [`ovh_cloud_project_database_certificates`](https://registry.terraform.io/providers/ovh/ovh/latest/docs/data-sources/cloud_project_database_certificates)
- **OVHcloud private network module**: [`ovh-network`](https://github.com/prefapp/tfm/tree/main/modules/ovh-network)

## Support

For questions, issues, or contributions related to this module, visit the [repository issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->