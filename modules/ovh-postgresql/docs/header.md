# **OVHcloud Managed PostgreSQL Terraform Module**

## Overview

This module provisions one OVHcloud Public Cloud Databases for PostgreSQL cluster in an existing Public Cloud project and private network. It creates the service with one, two or three nodes according to the selected plan, restricts incoming addresses to the private subnet by default, and manages database settings, backup windows and deletion protection.

It also manages declared databases, PostgreSQL users and PgBouncer connection pools. User passwords and pool connection URIs are written as JSON secrets to an existing OVHcloud KMS (OKMS). Sensitive values remain in Terraform state, so the state backend must be encrypted and access-restricted. No password or credential-bearing URI is exposed as a module output.

OVHcloud currently supports PostgreSQL 15, 16, 17 and 18. The module checks versions, plans and flavors against the Public Cloud Database capabilities data source, and resolves the requested network and subnet by name and CIDR. That capabilities endpoint does not include region-specific flavor availability or disk-size bounds; the availability preflight checks those against published offers, and OVHcloud validates them definitively at apply. The provider does not expose a PostgreSQL extension resource or an extension-by-version capabilities data source: required extensions are checked against the documented OVHcloud catalogue and known version constraints, but must be activated separately with `CREATE EXTENSION` by a database migration or operator.

During `plan`, the module also queries OVHcloud's published database availability catalogue and fails unless an offer matches the requested PostgreSQL version, plan, region, flavor, private network, node count and disk size. This is a point-in-time offer check, not a capacity reservation or a guarantee that a later apply will succeed. It uses a Python 3 standard-library helper through the `hashicorp/external` provider; runners must install Python 3, Terraform/OpenTofu and the external provider, and permit HTTPS access to the matching OVH API and authentication endpoints. Authentication compatibility with this exact OVH operation has not been verified live; source research and mock-based tests do not establish that each method is accepted by the endpoint.

## Key Features

- **Private by default**: discovers one existing private network and subnet; defaults IP restrictions to the subnet CIDR.
- **Plan-sized clusters**: generates one node for `discovery`, two for `production`, and three for `advanced`.
- **Capabilities checks**: checks PostgreSQL version, plan and flavor against OVHcloud's published project capabilities.
- **Offer preflight**: checks the full requested configuration against OVHcloud's published offers during plan and fails closed on API or response errors.
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
  disk_size      = 20

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
  disk_size      = 50

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
