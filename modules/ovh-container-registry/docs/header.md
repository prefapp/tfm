# **OVHcloud Managed Private Registry Terraform Module**

## Overview

This module provisions an OVHcloud Managed Private Registry (a managed Harbor instance) in an existing Public Cloud project. It selects the project by `project_id` or `project_name`, resolves the requested plan in the requested region, and creates the registry.

It also creates a local Harbor admin user and stores its credentials as JSON (`{username, password, email}`) in an existing OVHcloud KMS (OKMS) at `<name>/<admin_login>`. That admin is what the bundled [`harbor` submodule](https://github.com/prefapp/tfm/tree/main/modules/ovh-container-registry/modules/harbor) uses to manage Harbor projects and robot accounts. Optional IP allow-lists can restrict the Harbor UI/API and the image endpoint separately.

The registry and its Harbor content are deliberately managed in **two Terraform states**: this module first, then the `harbor` submodule fed from this module's outputs. The `goharbor/harbor` provider needs the registry URL and admin credentials while planning, and those only exist after this module is applied.

## Key Features

- **Managed Harbor registry**: Creates an OVHcloud Managed Private Registry with the `SMALL`, `MEDIUM` or `LARGE` plan in the selected region.
- **Project discovery**: Selects the Public Cloud project by ID/service name, or by name matched against both `project_name` and `description`.
- **Admin credentials in KMS**: Creates a local Harbor admin user and stores its credentials in OKMS instead of exposing them as outputs.
- **IP restrictions**: Optional, independent allow-lists for the management plane (UI/API) and the registry endpoint (push/pull).
- **Harbor submodule**: `modules/harbor` manages projects, global and project-scoped robot accounts, and stores robot credentials in OKMS.

## Basic Usage

Use a released module tag in the Git source. The `ovh` provider is configured by the caller; this module declares no provider block.

### Registry with its admin credentials in KMS

```hcl
module "ovh_container_registry" {
  source = "git::https://github.com/prefapp/tfm.git//modules/ovh-container-registry?ref=ovh-container-registry-vx.y.z"

  project_name = "example-project"
  name         = "example-registry"
  region       = "GRA"
  plan_name    = "SMALL"

  kms_id      = "<okms-id>"
  admin_email = "platform@example.com"
}
```

### Harbor projects and robots (separate state)

```hcl
module "harbor" {
  source = "git::https://github.com/prefapp/tfm.git//modules/ovh-container-registry/modules/harbor?ref=ovh-container-registry-vx.y.z"

  # Outputs of the registry module, read from its state.
  kms_id            = "<okms-id>"
  registry_name     = "example-registry"
  registry_url      = "https://xxxxxxxx.c1.gra9.container-registry.ovh.net"
  admin_secret_path = "example-registry/root"

  global_robots = {
    cicd = { access = "write" }
    k8s  = { access = "read" }
  }

  projects = {
    apps = {}
  }
}
```

> [!WARNING]
> **Do not enable OVHcloud IAM on this registry.** Enabling IAM on a Managed Private Registry deletes every local Harbor user, including the admin created by this module, and Harbor robot accounts cannot create or manage other robots. The `harbor` submodule would lose its credentials. See [ADR 0001](https://github.com/prefapp/tfm/tree/main/modules/ovh-container-registry/docs/adr/0001-local-harbor-admin-without-ovh-iam.md).
