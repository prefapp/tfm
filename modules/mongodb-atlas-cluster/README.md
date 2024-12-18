# MongoDB Atlas Cluster

## Overview

This module creates a MongoDB Atlas cluster.

## DOC

- [Resource terraform - mongodbatlas_cluster](https://registry.terraform.io/providers/mongodb/mongodbatlas/1.23.0/docs/resources/cluster)

## Notes

- This module presupposes that:
  - The `org` and `project` are already created.
- The following cluster attributes will be skipped once the resource is created:
  - replication_specs
  - provider_name
  - provider_disk_type_name
  - provider_instance_size_name

## Usage

### Set a module

```terraform
module "mongodb-atlas-cluster" {
  source = "git::https://github.com/prefapp/tfm.git//modules/mongodb-atlas-cluster?ref=<version>"
}
```

### Set a data .tfvars

#### Example

```hcl
project_id = "XXXXXXXXXXXXXXXXXXXXXXXX"
clusters = {
  "cluster-1" = {
    name                         = "cluster-1"
    cluster_type                 = "REPLICASET"
    num_shards                   = 1
    zone_name                    = "Zone 1"
    region_name                  = "EUROPE_WEST_1"
    analytics_nodes              = 0
    electable_nodes              = 3
    priority                     = 7
    read_only_nodes              = 0
    cloud_backup                 = true
    auto_scaling_disk_gb_enabled = true
    mongo_db_major_version       = "4.4"
    provider_name                = "AWS"
    provider_disk_type_name      = "STANDARD"
    provider_instance_size_name  = "M10"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_id"></a> [project_id](#input\_project\_id) | The project ID to create the cluster in | `string` | n/a | yes |
| <a name="input_clusters"></a> [clusters](#input\_clusters) | A map of clusters to create | `map(object({ name = string, cluster_type = string, num_shards = number, zone_name = string, region_name = string, analytics_nodes = number, electable_nodes = number, priority = number, read_only_nodes = number, cloud_backup = bool, auto_scaling_disk_gb_enabled = bool, mongo_db_major_version = string, provider_name = string, provider_disk_type_name = string, provider_instance_size_name = string }))` | n/a | yes |
