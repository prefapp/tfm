# **OVHcloud Managed MySQL Terraform Module**

## Overview

This module provisions an OVHcloud Public Cloud Databases for MySQL service and its logical databases in an existing Public Cloud project. It selects the project by `project_id` or `project_name`, checks the requested MySQL version and flavor against live project capabilities, and derives the number of nodes from the selected plan.

By default, every node attaches to an existing private network and subnet discovered by exact network name and subnet CIDR. The module also restricts incoming connections to that subnet unless explicit CIDR restrictions are supplied. Region and flavor-specific disk capacity are finally validated by OVHcloud because the provider capabilities data source does not expose a live region matrix or authoritative disk-size range.

## Key Features

- **Managed MySQL service**: Creates MySQL with a selected version, plan, flavor, disk size and advanced configuration.
- **Plan-derived topology**: Creates one node for `discovery`, two for `production`, or three for `advanced`.
- **Existing private network**: Discovers and attaches the regional network ID and subnet ID without managing the network itself.
- **Private-by-default access**: Defaults the MySQL IP allow-list to the selected subnet; public-wide CIDRs require explicit opt-in.
- **Logical databases**: Creates a set of named databases in the managed service.

## Basic Usage

Configure the `ovh` provider in the caller. The private network and subnet must exist before applying this module.

### Single-node MySQL with private networking

```hcl
module "ovh_mysql" {
  source = "git::https://github.com/prefapp/tfm.git//modules/ovh-mysql?ref=ovh-mysql-vx.y.z"

  project_name = "example-project"
  name         = "example-mysql"
  region       = "GRA"
  engine_version = "8.4"
  plan         = "discovery"
  flavor       = "b3-4"

  network_name = "example-private-network"
  subnet_cidr  = "10.40.0.0/16"
  databases    = ["application"]
}
```

### Production topology with additional backup region

```hcl
module "ovh_mysql_production" {
  source = "git::https://github.com/prefapp/tfm.git//modules/ovh-mysql?ref=ovh-mysql-vx.y.z"

  project_name = "example-project"
  name         = "example-mysql-production"
  region       = "GRA"
  engine_version = "8.4"
  plan         = "production"
  flavor       = "b3-8"

  network_name  = "example-private-network"
  subnet_cidr   = "10.40.0.0/16"
  backup_regions = ["GRA", "SBG"]
  databases      = ["application", "audit"]

  advanced_configuration = {
    "mysql.sql_require_primary_key" = "true"
  }
}
```

The module intentionally does not create database users or application credentials. OVHcloud API-created users have administrator-equivalent privileges; use SQL-managed accounts with least privilege through a separately designed workflow. MySQL connections accept TLS and the module exposes the project's CA; configure clients to require TLS and verify the server identity. Protect Terraform state and plan files because provider-managed values may be recorded there.
