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

## Usage

### Set a module

```terraform
module "mongodb-atlas-cluster" {
  source = "git::https://github.com/prefapp/tfm.git//modules/mongodb-atlas-cluster?ref=<version>"
}
```

### Set a data .tfvars

#### Example clear cluster

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

create_cluster_from_pitr = true
# create_cluster_from_snapshot = false
pitr_timestamp = "1734481935" # UNIX timestamp
```

## Inputs


<!-- # Global variables
variable "mongo_region" {
  description = "The mongo region"
  type        = string
}

variable "provider_name" {
  description = "The provider name"
  type        = string
}

variable "project_id" {
  description = "The project ID"
  type        = string
}

# Cluster seccion variables
variable "cluster_name" {
  description = "The name of the cluster"
  type        = string
}

variable "cluster_type" {
  description = "The type of the cluster"
  type        = string
}

variable "cluster_replication_specs_config_analytics_nodes" {
  description = "The number of analytics nodes"
  type        = number
}

variable "cluster_replication_specs_config_electable_nodes" {
  description = "The number of electable nodes"
  type        = number
}

variable "cluster_replication_specs_config_priority" {
  description = "Priority value"
  type        = number
}

variable "cluster_replication_specs_config_read_only_nodes" {
  description = "The number of read only nodes"
  type        = number
}

variable "cluster_cloud_backup" {
  description = "Whether or not cloud backup is enabled"
  type        = bool
}

variable "cluster_auto_scaling_disk_gb_enabled" {
  description = "Whether or not disk autoscaling is enabled"
  type        = bool
}

variable "cluster_mongo_db_major_version" {
  description = "MongoDB major version"
  type        = string
}

variable "cluster_provider_disk_type_name" {
  description = "Provider disk type name"
  type        = string
}

variable "cluster_provider_instance_size_name" {
  description = "Provider instance size name"
  type        = string
}

variable "cluster_num_shards" {
  description = "The number of shards"
  type        = number
}

variable "cluster_zone" {
  description = "The zones of the cluster"
  type        = string
}

# Restore from snapshot variables
variable "create_cluster_from_snapshot" {
  description = "Whether or not to create a cluster from a snapshot"
  type        = bool
  default     = false
  validation {
    condition     = var.create_cluster_from_pitr == true
    error_message = "If create_cluster_from_snapshot is true, create_cluster_from_pitr must be false"
  }
  validation {
    condition     = var.origin_project_id == null
    error_message = "If create_cluster_from_snapshot is true, origin_project_id must be set"
  }
  validation {
    condition     = var.origin_cluster_name == null
    error_message = "If create_cluster_from_snapshot is true, origin_cluster_name must be set"
  }
}

variable "origin_project_id" {
  description = "The origin project ID"
  type        = string
}

variable "origin_cluster_name" {
  description = "The origin cluster name"
  type        = string
}

# Restore from pitr variables
variable "create_cluster_from_pitr" {
  description = "Whether or not to create a cluster from a point in time restore"
  type        = bool
  default     = false
  validation {
    condition     = var.create_cluster_from_snapshot == true
    error_message = "If create_cluster_from_pi is true, create_cluster_from_snapshot must be false"
  }
  validation {
    condition     = var.point_in_time_utc_seconds == null
    error_message = "If create_cluster_from_pi is true, point_in_time_utc_seconds must be set"
  }
}

variable "point_in_time_utc_seconds" {
  description = "The point in time to restore from"
  type        = number
  default     = null
} -->




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
