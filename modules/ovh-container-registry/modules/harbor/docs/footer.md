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
