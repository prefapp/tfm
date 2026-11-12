# **OVHcloud Managed Private Registry Harbor Terraform Submodule**

## Overview

This submodule manages the Harbor content of an existing OVHcloud Managed Private Registry created with the parent [`ovh-container-registry`](https://github.com/prefapp/tfm/tree/main/modules/ovh-container-registry) module: Harbor projects, system-level robot accounts with access to every project, and project-scoped robot accounts.

It configures its own `harbor` provider from the local Harbor admin credentials that the parent module stored in OVHcloud KMS (OKMS). Each robot gets a generated secret, and its credentials (`{username, password}`) are stored back in the same OKMS so that CI systems and Kubernetes clusters can read them without Terraform outputs exposing them.

Apply it in a **separate Terraform state** from the parent module, after the registry exists. The `goharbor/harbor` provider needs the registry URL and admin credentials while planning, so it cannot be planned in the same run that creates the registry.

## Key Features

- **Harbor projects**: Creates private (default) or public projects keyed by name.
- **Global robots**: System-level robots with `read` (pull) or `write` (pull and push) access to every project, present and future.
- **Project robots**: Robots scoped to a single project, with the same `read`/`write` access levels.
- **Credentials in KMS**: Robot credentials are stored in OKMS at `<registry_name>/<robot>` or `<registry_name>/<project>/<robot>`.
- **Push commands**: Outputs the `docker`, `podman`, `helm` and `cnab-to-oci` push commands for each project.

## Basic Usage

Use a released module tag in the Git source. The `ovh` provider is configured by the caller; the `harbor` provider is configured inside this submodule.

### CI and Kubernetes robots for every project

```hcl
module "harbor" {
  source = "git::https://github.com/prefapp/tfm.git//modules/ovh-container-registry/modules/harbor?ref=ovh-container-registry-vx.y.z"

  kms_id            = "<okms-id>"
  registry_name     = "example-registry"
  registry_url      = "https://xxxxxxxx.c1.gra9.container-registry.ovh.net"
  admin_secret_path = "example-registry/root"

  global_robots = {
    cicd = { access = "write", description = "CI/CD push and pull" }
    k8s  = { access = "read", description = "Kubernetes image pull" }
  }

  projects = {
    apps = {}
  }
}
```

### Public project with its own publisher robot

```hcl
module "harbor" {
  source = "git::https://github.com/prefapp/tfm.git//modules/ovh-container-registry/modules/harbor?ref=ovh-container-registry-vx.y.z"

  kms_id            = "<okms-id>"
  registry_name     = "example-registry"
  registry_url      = "https://xxxxxxxx.c1.gra9.container-registry.ovh.net"
  admin_secret_path = "example-registry/root"

  projects = {
    charts = {
      public = true
      robots = {
        publisher = { access = "write" }
      }
    }
  }
}
```

> [!NOTE]
> This submodule contains a `provider "harbor"` block, which makes it a legacy Terraform module: callers cannot use `count`, `for_each` or `depends_on` on the `module` block, and the block cannot be removed from the configuration until its resources are destroyed. See [ADR 0002](https://github.com/prefapp/tfm/tree/main/modules/ovh-container-registry/docs/adr/0002-harbor-in-a-separate-state.md).
