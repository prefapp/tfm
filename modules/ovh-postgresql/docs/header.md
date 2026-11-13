# **OVHcloud Managed PostgreSQL Terraform Module**

## Overview

This module provisions one OVHcloud Public Cloud Databases for PostgreSQL cluster in an existing Public Cloud project and private network. It creates the service with one, two or three nodes according to the selected plan, restricts incoming addresses to the private subnet by default, and manages database settings, backup windows and deletion protection.

It also manages declared databases, PostgreSQL users and PgBouncer connection pools. User passwords and pool connection URIs are written as JSON secrets to an existing OVHcloud KMS (OKMS). Sensitive values remain in Terraform state, so the state backend must be encrypted and access-restricted. No password or credential-bearing URI is exposed as a module output.

The module validates PostgreSQL versions and regions against separate allowlists in a maintained static snapshot, and validates plans, flavors and disk limits using the plan-specific entries in `data/postgresql-offers.json`. These checks do not verify that the selected version, plan, region and flavor are offered together, or that the offer is currently available to the caller's project. The module consumer is responsible for selecting a valid combination; OVHcloud remains authoritative and may reject it during apply. The snapshot comes from an authenticated Public Cloud availability query for one project; refresh and review it deliberately. The module resolves the private network and subnet separately from the caller's existing infrastructure. The provider does not expose a PostgreSQL extension resource or an extension-by-version capabilities data source: required extensions are checked against the documented OVHcloud catalogue and known version constraints, but must be activated separately with `CREATE EXTENSION` by a database migration or operator.

## Key Features

- **Private by default**: discovers one existing private network and subnet; defaults IP restrictions to the subnet CIDR.
- **Plan-sized clusters**: generates one node for `discovery`, two for `production`, and three for `advanced`.
- **Maintained option catalogue**: checks version, region, plan, flavor and disk size against separate allowlists and plan-specific limits; it does not validate combinations or live availability.
- **Disk range and increment**: enforces the catalogue minimum, maximum and storage increment for the selected plan and flavor before apply.
- **Database identities**: provisions databases, users with the supported `replication` role, and managed PgBouncer pools.
- **Credentials in OKMS**: writes direct connection JSON and pool URIs to distinct secret paths; outputs paths, never credentials.
- **Lifecycle safety**: deletion protection defaults to enabled; disabling it outside `discovery` emits a plan warning.

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
