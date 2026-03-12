# MongoDB Atlas Cluster

## Overview

This module creates a MongoDB Atlas cluster.

## DOC

- [Resource terraform - mongodbatlas_cluster](https://registry.terraform.io/providers/mongodb/mongodbatlas/1.23.0/docs/resources/cluster)
- [Resource terraform - mongodbatlas_cloud_backup_snapshot_restore_job](https://registry.terraform.io/providers/mongodb/mongodbatlas/1.23.0/docs/resources/cloud_backup_snapshot_restore_job)

## Notes

- This module presupposes that:
  - The `org` and `project` are already created.
- The following cluster attributes will be skipped once the resource is created:
  - replication_specs
  - provider_name
  - provider_disk_type_name
  - provider_instance_size_name
- It is possible to create a cluster:
  - Empty
  - From a snapshot (incompatible with the PiTR)
  - From a PiTR (incompatible with the snapshot)
- It is mandatory to configure `snapshot_execution_config` even if you do not want to configure backup policies.

## Usage

### Set a module

```terraform
module "mongodb-atlas-cluster" {
  source = "git::https://github.com/prefapp/tfm.git//modules/mongodb-atlas-cluster?ref=<version>"
}
```

### Set a data .tfvars

#### Example clear cluster


# Snapshot execution config variables
variable "snapshot_execution_config" {
  description = "Configuration for snapshot execution"
  type = object({
    reference_hour_of_day    = number
    reference_minute_of_hour = number
    restore_window_days      = number
  })
}

# Scheduled retention policies for snapshots
# Scheduled retention policies for snapshots
variable "scheduled_retention_policies" {
  description = "Scheduled retention policies for snapshots"
  type = object({
    hourly   = optional(object({ frequency_interval = number, retention_unit = string, retention_value = number }))
    daily    = optional(object({ frequency_interval = number, retention_unit = string, retention_value = number }))
    weekly   = optional(object({ frequency_interval = number, retention_unit = string, retention_value = number }))
    monthly  = optional(object({ frequency_interval = number, retention_unit = string, retention_value = number }))
    yearly   = optional(object({ frequency_interval = number, retention_unit = string, retention_value = number }))
  })
}

```hcl
project_id = "XXXXXXXXXXXXXXXXXXXXXXXX"
mongo_region = "US_EAST_1"
provider_name = "azure"

cluster_name = "cluster-name"
cluster_type = "REPLICASET"
cluster_replication_specs_config_analytics_nodes = 0
cluster_replication_specs_config_electable_nodes = 3
cluster_replication_specs_config_priority = 7
cluster_replication_specs_config_read_only_nodes = 0
cluster_cloud_backup = true
cluster_auto_scaling_disk_gb_enabled = true
cluster_mongo_db_major_version = "4.4"
cluster_provider_disk_type_name = "PREMIUM"
cluster_provider_instance_size_name = "M10"
cluster_num_shards = 1
cluster_zone = "US_EAST_1A"
snapshot_execution_config {
  reference_hour_of_day    = 0
  reference_minute_of_hour = 0
  restore_window_days      = 30
}
scheduled_retention_policies {
  hourly = {
    frequency_interval = 1
    retention_unit     = "HOURS"
    retention_value    = 24
  }
  daily = {
    frequency_interval = 1
    retention_unit     = "DAYS"
    retention_value    = 7
  }
  weekly = {
    frequency_interval = 1
    retention_unit     = "WEEKS"
    retention_value    = 4
  }
}
```

#### Example cluster from snapshot

```hcl
project_id = "XXXXXXXXXXXXXXXXXXXXXXXX"
mongo_region = "US_EAST_1"
provider_name = "azure"

cluster_name = "cluster-name"
cluster_type = "REPLICASET"
cluster_replication_specs_config_analytics_nodes = 0
cluster_replication_specs_config_electable_nodes = 3
cluster_replication_specs_config_priority = 7
cluster_replication_specs_config_read_only_nodes = 0
cluster_cloud_backup = true
cluster_auto_scaling_disk_gb_enabled = true
cluster_mongo_db_major_version = "4.4"
cluster_provider_disk_type_name = "PREMIUM"
cluster_provider_instance_size_name = "M10"
cluster_num_shards = 1
cluster_zone = "US_EAST_1A"
snapshot_execution_config {
  reference_hour_of_day    = 0
  reference_minute_of_hour = 0
  restore_window_days      = 30
}

create_cluster_from_snapshot = true
# create_cluster_from_pit = false
origin_project_id = "ZZZZZZZZZZZZZZZZZZZZZZZZ"
origin_cluster_name = "origin-cluster-name"
```

#### Example cluster from PiTR

```hcl
project_id = "XXXXXXXXXXXXXXXXXXXXXXXX"
mongo_region = "US_EAST_1"
provider_name = "azure"

cluster_name = "cluster-name"
cluster_type = "REPLICASET"
cluster_replication_specs_config_analytics_nodes = 0
cluster_replication_specs_config_electable_nodes = 3
cluster_replication_specs_config_priority = 7
cluster_replication_specs_config_read_only_nodes = 0
cluster_cloud_backup = true
cluster_auto_scaling_disk_gb_enabled = true
cluster_mongo_db_major_version = "4.4"
cluster_provider_disk_type_name = "PREMIUM"
cluster_provider_instance_size_name = "M10"
cluster_num_shards = 1
cluster_zone = "US_EAST_1A"
snapshot_execution_config {
  reference_hour_of_day    = 0
  reference_minute_of_hour = 0
  restore_window_days      = 30
}

create_cluster_from_pitr = true
# create_cluster_from_snapshot = false
pitr_timestamp = "1734481935" # UNIX timestamp
```

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_id"></a> [project_id](#input\_project\_id) | The project ID to create the cluster in | `string` | n/a | yes |
| <a name="input_mongo_region"></a> [mongo_region](#input\_mongo\_region) | The region to create the cluster in | `string` | n/a | yes |
| <a name="input_provider_name"></a> [provider_name](#input\_provider\_name) | The provider name | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster_name](#input\_cluster\_name) | The name of the cluster | `string` | n/a | yes |
| <a name="input_cluster_type"></a> [cluster_type](#input\_cluster\_type) | The type of the cluster | `string` | n/a | yes |
| <a name="input_cluster_replication_specs_config_analytics_nodes"></a> [cluster_replication_specs_config_analytics_nodes](#input\_cluster\_replication\_specs\_config\_analytics\_nodes) | The number of analytics nodes | `number` | n/a | yes |
| <a name="input_cluster_replication_specs_config_electable_nodes"></a> [cluster_replication_specs_config_electable_nodes](#input\_cluster\_replication\_specs\_config\_electable\_nodes) | The number of electable nodes | `number` | n/a | yes |
| <a name="input_cluster_replication_specs_config_priority"></a> [cluster_replication_specs_config_priority](#input\_cluster\_replication\_specs\_config\_priority) | Priority value | `number` | n/a | yes |
| <a name="input_cluster_replication_specs_config_read_only_nodes"></a> [cluster_replication_specs_config_read_only_nodes](#input\_cluster\_replication\_specs\_config\_read\_only\_nodes) | The number of read only nodes | `number` | n/a | yes |
| <a name="input_cluster_cloud_backup"></a> [cluster_cloud_backup](#input\_cluster\_cloud\_backup) | Whether or not cloud backup is enabled | `bool` | n/a | yes |
| <a name="input_cluster_auto_scaling_disk_gb_enabled"></a> [cluster_auto_scaling_disk_gb_enabled](#input\_cluster\_auto\_scaling\_disk\_gb\_enabled) | Whether or not disk autoscaling is enabled | `bool` | n/a | yes |
| <a name="input_cluster_mongo_db_major_version"></a> [cluster_mongo_db_major_version](#input\_cluster\_mongo\_db\_major\_version) | MongoDB major version | `string` | n/a | yes |
| <a name="input_cluster_provider_disk_type_name"></a> [cluster_provider_disk_type_name](#input\_cluster\_provider\_disk\_type\_name) | Provider disk type name | `string` | n/a | yes |
| <a name="input_cluster_provider_instance_size_name"></a> [cluster_provider_instance_size_name](#input\_cluster\_provider\_instance\_size\_name) | Provider instance size name | `string` | n/a | yes |
| <a name="input_cluster_num_shards"></a> [cluster_num_shards](#input\_cluster\_num\_shards) | The number of shards | `number` | n/a | yes |
| <a name="input_cluster_zone"></a> [cluster_zone](#input\_cluster\_zone) | The zones of the cluster | `string` | n/a | yes |
| <a name="input_create_cluster_from_snapshot"></a> [create_cluster_from_snapshot](#input\_create\_cluster\_from\_snapshot) | Whether or not to create a cluster from a snapshot (incompatible with the PiTR) | `bool` | `false` | no |
| <a name="input_origin_project_id"></a> [origin_project_id](#input\_origin\_project\_id) | The origin project ID | `string` | `null` | yes (only if create_cluster_from_snapshot is true) |
| <a name="input_origin_cluster_name"></a> [origin_cluster_name](#input\_origin\_cluster\_name) | The origin cluster name | `string` | `null` | yes (only if create_cluster_from_snapshot is true) |
| <a name="input_create_cluster_from_pitr"></a> [create_cluster_from_pitr](#input\_create\_cluster\_from\_pitr) | Whether or not to create a cluster from a point in time restore (incompatible with the snapshot) | `bool` | `false` | no |
| <a name="input_pitr_timestamp"></a> [pitr_timestamp](#input\_pitr\_timestamp) | The point in time to restore from | `number` | `null` | yes (only if create_cluster_from_pitr is true) |
| <a name="input_snapshot_execution_config"></a> [snapshot_execution_config](#input\_snapshot\_execution\_config) | Configuration for snapshot execution | `object` | `{ reference_hour_of_day = 0, reference_minute_of_hour = 0, restore_window_days = 30 }` | yes |
| <a name="input_scheduled_retention_policies"></a> [scheduled_retention_policies](#input\_scheduled\_retention\_policies) | Scheduled retention policies for snapshots | `object` | `{ hourly = null, daily = null, weekly = null, monthly = null, yearly = null }` | no |
