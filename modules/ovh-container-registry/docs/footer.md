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
- **OVHcloud Terraform provider**: [`ovh_cloud_project_containerregistry`](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_containerregistry), [`ovh_cloud_project_containerregistry_user`](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_containerregistry_user) and [`ovh_okms_secret`](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/okms_secret)
- **Harbor Terraform provider**: [`goharbor/harbor`](https://registry.terraform.io/providers/goharbor/harbor/latest/docs)
- **Harbor submodule**: [`modules/harbor`](https://github.com/prefapp/tfm/tree/main/modules/ovh-container-registry/modules/harbor)

## Support

For questions, issues, or contributions related to this module, visit the [repository issue tracker](https://github.com/prefapp/tfm/issues).
