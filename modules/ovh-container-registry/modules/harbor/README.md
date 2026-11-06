<!-- BEGIN_TF_DOCS -->
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

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_harbor"></a> [harbor](#requirement\_harbor) | >= 3.12.0, < 4.0.0 |
| <a name="requirement_ovh"></a> [ovh](#requirement\_ovh) | >= 2.24.0, < 3.0.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.9.0, < 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_harbor"></a> [harbor](#provider\_harbor) | >= 3.12.0, < 4.0.0 |
| <a name="provider_ovh"></a> [ovh](#provider\_ovh) | >= 2.24.0, < 3.0.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.9.0, < 4.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [harbor_project.project](https://registry.terraform.io/providers/goharbor/harbor/latest/docs/resources/project) | resource |
| [harbor_robot_account.global](https://registry.terraform.io/providers/goharbor/harbor/latest/docs/resources/robot_account) | resource |
| [harbor_robot_account.project](https://registry.terraform.io/providers/goharbor/harbor/latest/docs/resources/robot_account) | resource |
| [ovh_okms_secret.global_robot](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/okms_secret) | resource |
| [ovh_okms_secret.project_robot](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/okms_secret) | resource |
| [random_password.global_robot](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.project_robot](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [ovh_okms_secret.admin](https://registry.terraform.io/providers/ovh/ovh/latest/docs/data-sources/okms_secret) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_secret_path"></a> [admin\_secret\_path](#input\_admin\_secret\_path) | KMS path of the Harbor admin credentials ({username, password}), as returned by the root module admin\_secret\_path output. | `string` | n/a | yes |
| <a name="input_global_robots"></a> [global\_robots](#input\_global\_robots) | System robot accounts with access to every Harbor project, keyed by robot name. access: write (pull and push) or read (pull). | <pre>map(object({<br/>    access      = string<br/>    description = optional(string, "")<br/>  }))</pre> | `{}` | no |
| <a name="input_kms_id"></a> [kms\_id](#input\_kms\_id) | ID of the OKMS that holds the Harbor admin credentials and receives the robot credentials. | `string` | n/a | yes |
| <a name="input_projects"></a> [projects](#input\_projects) | Harbor projects to create, keyed by project name. public allows anonymous pull (default false). robots are optional project-scoped robot accounts. | <pre>map(object({<br/>    public = optional(bool, false)<br/>    robots = optional(map(object({<br/>      access      = string<br/>      description = optional(string, "")<br/>    })), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_registry_name"></a> [registry\_name](#input\_registry\_name) | Name of the Managed Private Registry. Used as the KMS path prefix of the robot secrets. | `string` | n/a | yes |
| <a name="input_registry_url"></a> [registry\_url](#input\_registry\_url) | Access URL of the registry, as returned by the root module registry\_url output. | `string` | n/a | yes |
| <a name="input_secret_custom_metadata"></a> [secret\_custom\_metadata](#input\_secret\_custom\_metadata) | Custom metadata added to every robot KMS secret. The registry, access and project keys are always set by the module. | `map(string)` | <pre>{<br/>  "owner": "firestartr"<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_projects"></a> [projects](#output\_projects) | Names of the Harbor projects managed by this module. |
| <a name="output_push_commands"></a> [push\_commands](#output\_push\_commands) | Push commands per Harbor project, as shown in the Harbor UI. |
| <a name="output_robot_secret_paths"></a> [robot\_secret\_paths](#output\_robot\_secret\_paths) | KMS paths of the robot credentials ({username, password}), keyed by robot name for global robots and by <project>/<robot> for project robots. |

## Import and Lifecycle

The submodule manages these Terraform resources (addresses assume the caller names the module `harbor`):

- Project: `module.harbor.harbor_project.project["<project>"]`
- Global robot: `module.harbor.harbor_robot_account.global["<robot>"]` and `module.harbor.random_password.global_robot["<robot>"]`
- Project robot: `module.harbor.harbor_robot_account.project["<project>/<robot>"]` and `module.harbor.random_password.project_robot["<project>/<robot>"]`
- Robot KMS secrets: `module.harbor.ovh_okms_secret.global_robot["<robot>"]` and `module.harbor.ovh_okms_secret.project_robot["<project>/<robot>"]`

Existing Harbor projects can be imported with their Harbor API path:

```sh
terraform import 'module.harbor.harbor_project.project["<project>"]' '/projects/<project_id>'
```

Robot accounts can be imported with `/robots/<robot_id>`, but Harbor never returns a robot secret. Importing a robot does not recover its secret, so the KMS secret cannot be filled; let the submodule create the robots instead.

**Destroy order.** Destroy this submodule **before** the parent registry module. It reads the admin secret from the KMS to configure the `harbor` provider; if the registry or the admin secret is gone, the destroy cannot authenticate and the robot KMS secrets stay behind.

Destroying the submodule deletes its Harbor projects (Harbor refuses to delete a project that still contains repositories), its robot accounts and their KMS secrets. Removing a robot from the inputs deletes it immediately, and any client using its credentials loses access.

Other lifecycle notes:

- The Harbor robot name prefix stays at Harbor's default `robot$`; the full name stored in the KMS secret is `robot$<robot>` for global robots and `robot$<project>+<robot>` for project robots.
- Robot secrets are stored in Terraform state (as sensitive values) and in the KMS. Protect the state backend.
- A global robot must not share the KMS path of the admin secret (for example a robot named `root` when `admin_login` is `root`); a precondition rejects it.

## Examples

- [Harbor projects and robots](https://github.com/prefapp/tfm/tree/main/modules/ovh-container-registry/_examples/harbor-projects-and-robots) — global robots, a private project and a public project with its own robot, fed from the registry outputs.

## Resources

- **Harbor Terraform provider**: [`harbor_project`](https://registry.terraform.io/providers/goharbor/harbor/latest/docs/resources/project) and [`harbor_robot_account`](https://registry.terraform.io/providers/goharbor/harbor/latest/docs/resources/robot_account)
- **OVHcloud Terraform provider**: [`ovh_okms_secret`](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/okms_secret)
- **Harbor robot accounts**: [Harbor documentation](https://goharbor.io/docs/main/administration/robot-accounts/)
- **Parent module**: [`ovh-container-registry`](https://github.com/prefapp/tfm/tree/main/modules/ovh-container-registry)

## Support

For questions, issues, or contributions related to this module, visit the [repository issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->