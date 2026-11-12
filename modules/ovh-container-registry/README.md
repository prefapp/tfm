<!-- BEGIN_TF_DOCS -->
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

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_ovh"></a> [ovh](#requirement\_ovh) | >= 2.24.0, < 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_ovh"></a> [ovh](#provider\_ovh) | >= 2.24.0, < 3.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [ovh_cloud_project_containerregistry.registry](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_containerregistry) | resource |
| [ovh_cloud_project_containerregistry_ip_restrictions_management.management](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_containerregistry_ip_restrictions_management) | resource |
| [ovh_cloud_project_containerregistry_ip_restrictions_registry.registry](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_containerregistry_ip_restrictions_registry) | resource |
| [ovh_cloud_project_containerregistry_user.admin](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_containerregistry_user) | resource |
| [ovh_okms_secret.admin](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/okms_secret) | resource |
| [ovh_cloud_project_capabilities_containerregistry_filter.plan](https://registry.terraform.io/providers/ovh/ovh/latest/docs/data-sources/cloud_project_capabilities_containerregistry_filter) | data source |
| [ovh_cloud_projects.projects](https://registry.terraform.io/providers/ovh/ovh/latest/docs/data-sources/cloud_projects) | data source |
| [ovh_okms_resource.kms](https://registry.terraform.io/providers/ovh/ovh/latest/docs/data-sources/okms_resource) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_email"></a> [admin\_email](#input\_admin\_email) | Email of the local Harbor admin user. | `string` | n/a | yes |
| <a name="input_admin_login"></a> [admin\_login](#input\_admin\_login) | Login of the local Harbor admin user used to manage projects and robot accounts. | `string` | `"root"` | no |
| <a name="input_ip_restrictions_management"></a> [ip\_restrictions\_management](#input\_ip\_restrictions\_management) | CIDRs allowed to reach the Harbor UI and API. An empty list means no restriction. | <pre>list(object({<br/>    ip_block    = string<br/>    description = optional(string, "")<br/>  }))</pre> | `[]` | no |
| <a name="input_ip_restrictions_registry"></a> [ip\_restrictions\_registry](#input\_ip\_restrictions\_registry) | CIDRs allowed to reach the registry endpoint (docker push and pull). An empty list means no restriction. | <pre>list(object({<br/>    ip_block    = string<br/>    description = optional(string, "")<br/>  }))</pre> | `[]` | no |
| <a name="input_kms_id"></a> [kms\_id](#input\_kms\_id) | ID of the OVHcloud KMS (OKMS) where the Harbor admin credentials are stored. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the Managed Private Registry. Also used as the KMS path prefix of its secrets. | `string` | n/a | yes |
| <a name="input_plan_name"></a> [plan\_name](#input\_plan\_name) | Registry plan: SMALL, MEDIUM or LARGE. OVHcloud only allows upgrading the plan, never downgrading it. | `string` | `"SMALL"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Optional Public Cloud project ID or service\_name; takes precedence over project\_name. | `string` | `null` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Optional Public Cloud project name; matched against OVHcloud project\_name and description. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | Registry region as listed in the container registry capabilities, such as GRA. | `string` | `"GRA"` | no |
| <a name="input_secret_custom_metadata"></a> [secret\_custom\_metadata](#input\_secret\_custom\_metadata) | Custom metadata added to the admin KMS secret. The registry key is always set to the registry name. | `map(string)` | <pre>{<br/>  "owner": "firestartr"<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_admin_secret_path"></a> [admin\_secret\_path](#output\_admin\_secret\_path) | KMS path of the Harbor admin credentials ({username, password, email}). |
| <a name="output_kms_id"></a> [kms\_id](#output\_kms\_id) | ID of the OKMS that holds the Harbor admin credentials. |
| <a name="output_registry_id"></a> [registry\_id](#output\_registry\_id) | ID of the Managed Private Registry. |
| <a name="output_registry_name"></a> [registry\_name](#output\_registry\_name) | Name of the Managed Private Registry. |
| <a name="output_registry_plan"></a> [registry\_plan](#output\_registry\_plan) | Plan name of the registry. |
| <a name="output_registry_url"></a> [registry\_url](#output\_registry\_url) | Access URL of the registry (Harbor UI, API and image endpoint). |
| <a name="output_service_name"></a> [service\_name](#output\_service\_name) | OVHcloud Public Cloud service name resolved for the selected project. |

## Import and Lifecycle

The module manages these Terraform resources (addresses assume the caller names the module `ovh_container_registry`):

- Registry: `module.ovh_container_registry.ovh_cloud_project_containerregistry.registry`
- Harbor admin user: `module.ovh_container_registry.ovh_cloud_project_containerregistry_user.admin`
- Admin KMS secret: `module.ovh_container_registry.ovh_okms_secret.admin`
- Management IP restrictions: `module.ovh_container_registry.ovh_cloud_project_containerregistry_ip_restrictions_management.management[0]` (only when the list is not empty)
- Registry IP restrictions: `module.ovh_container_registry.ovh_cloud_project_containerregistry_ip_restrictions_registry.registry[0]` (only when the list is not empty)

Import an existing registry and its IP restrictions with the Public Cloud `service_name` and the registry ID:

```sh
terraform import 'module.ovh_container_registry.ovh_cloud_project_containerregistry.registry' '<service_name>/<registry_id>'
terraform import 'module.ovh_container_registry.ovh_cloud_project_containerregistry_ip_restrictions_management.management[0]' '<service_name>/<registry_id>'
terraform import 'module.ovh_container_registry.ovh_cloud_project_containerregistry_ip_restrictions_registry.registry[0]' '<service_name>/<registry_id>'
```

The admin user can be imported with `<service_name>/<registry_id>/<user_id>`, but its password is only returned by OVHcloud when the user is created. An imported user leaves the admin KMS secret without a usable password, so let the module create a new admin user instead. The OVHcloud provider does not document an import ID for `ovh_okms_secret`.

**Destroy order.** Destroy the `harbor` submodule state **before** this module. The `harbor` provider reads the admin secret from the KMS to configure itself; if the registry or the admin secret is destroyed first, the `harbor` destroy cannot authenticate and the robot secrets stay in the KMS.

Destroying this module deletes the registry **and every image, chart and Harbor setting stored in it**, the admin user, the admin KMS secret and the IP restrictions. It does not delete the OKMS itself or the Public Cloud project.

Other lifecycle notes:

- `plan_name` can only be upgraded (`SMALL` → `MEDIUM` → `LARGE`). OVHcloud rejects downgrades.
- `name` is updated in place. `region` and the project are not marked as replace-on-change by the provider, but OVHcloud cannot move a registry: do not change them on an existing registry. Create a new registry and migrate the images instead.
- Changing `admin_login` or `admin_email` replaces the admin user, which gets a new password; the admin KMS secret is updated with it. The `harbor` submodule picks up the new credentials on its next plan.
- Changing `name` or `admin_login` also changes the admin secret path; update the `harbor` submodule `admin_secret_path` input in the same change.
- Emptying an IP restriction list destroys the restriction resource, which removes the allow-list and opens that endpoint again.
- The admin password is stored in Terraform state (as a sensitive value) and in the KMS. Protect the state backend.

## Examples

The examples are self-contained Terraform configurations that call this module:

- [Basic](https://github.com/prefapp/tfm/tree/main/modules/ovh-container-registry/_examples/basic) — `SMALL` registry in Gravelines with its admin credentials in KMS.
- [IP restrictions](https://github.com/prefapp/tfm/tree/main/modules/ovh-container-registry/_examples/ip-restrictions) — separate allow-lists for the Harbor UI/API and the image endpoint.
- [Harbor projects and robots](https://github.com/prefapp/tfm/tree/main/modules/ovh-container-registry/_examples/harbor-projects-and-robots) — `harbor` submodule with global robots, a private project and a public project with its own robot.

## Resources

- **OVHcloud Managed Private Registry**: [Product documentation](https://help.ovhcloud.com/csm/en-public-cloud-private-registry-creation?id=kb_article_view&sysparm_article=KB0050345)
- **OVHcloud Terraform provider**: [`ovh_cloud_project_containerregistry`](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_containerregistry), [`ovh_cloud_project_containerregistry_user`](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_containerregistry\_user) and [`ovh_okms_secret`](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/okms_secret)
- **Harbor Terraform provider**: [`goharbor/harbor`](https://registry.terraform.io/providers/goharbor/harbor/latest/docs)
- **Harbor submodule**: [`modules/harbor`](https://github.com/prefapp/tfm/tree/main/modules/ovh-container-registry/modules/harbor)

## Support

For questions, issues, or contributions related to this module, visit the [repository issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->