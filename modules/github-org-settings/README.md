<!-- BEGIN_TF_DOCS -->
# **GitHub Organization Settings Terraform Module**

## Overview

This module creates and manages the basic settings of a GitHub organization using the `github_organization_settings` Terraform resource. It is designed to be consumed by Firestartr `gh_provisioner` through a single strongly typed `config` object generated as `terraform.tfvars.json`.

The module centralizes organization profile fields, repository creation policies, project settings, member permissions, and default security settings for new repositories. It intentionally manages one organization settings resource so it maps cleanly to one Firestartr custom resource and one Terraform state.

This module does not create or delete a GitHub organization. It only updates settings for the organization configured in the GitHub provider.

## Key Features

- **gh-provisioner compatible**: Accepts one top-level `config` object suitable for generated `terraform.tfvars.json`.
- **Basic organization settings**: Manages billing email, company, blog, public email, location, display name, and description.
- **Repository creation policy**: Controls default repository permission and which repository types members can create.
- **Page and fork controls**: Manages Pages creation and private repository fork permissions.
- **Security defaults**: Configures Advanced Security, Dependabot, dependency graph, secret scanning, and push protection defaults for new repositories.

## Firestartr Compatibility

Expected generated input:

```json
{
  "config": {
    "billingEmail": "platform@example.com",
    "defaultRepositoryPermission": "read",
    "membersCanCreateRepositories": true
  }
}
```

The matching `gh_provisioner` entity should map the Firestartr CR spec to this `config` shape and use the Terraform address `github_organization_settings.this` for imports.

## Basic Usage

### Using `terraform.tfvars.json` (recommended for Firestartr)

```hcl
module "org_settings" {
  source = "git::https://github.com/prefapp/tfm.git//modules/github-org-settings"

  config = var.config
}
```

### Inline example

```hcl
module "org_settings" {
  source = "git::https://github.com/prefapp/tfm.git//modules/github-org-settings"

  config = {
    billingEmail                              = "platform@example.com"
    name                                      = "Example Organization"
    description                               = "Managed by Firestartr"
    defaultRepositoryPermission               = "read"
    membersCanCreateRepositories              = true
    membersCanCreatePublicRepositories        = false
    membersCanCreatePrivateRepositories       = true
    dependencyGraphEnabledForNewRepositories = true
    secretScanningEnabledForNewRepositories   = true
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_github"></a> [github](#requirement\_github) | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_github"></a> [github](#provider\_github) | ~> 6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [github_organization_settings.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/organization_settings) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_config"></a> [config](#input\_config) | GitHub organization settings configuration | <pre>object({<br/>    billingEmail = string<br/><br/>    company         = optional(string)<br/>    blog            = optional(string)<br/>    email           = optional(string)<br/>    twitterUsername = optional(string)<br/>    location        = optional(string)<br/>    name            = optional(string)<br/>    description     = optional(string)<br/><br/>    hasOrganizationProjects              = optional(bool, true)<br/>    hasRepositoryProjects                = optional(bool, true)<br/>    defaultRepositoryPermission          = optional(string, "read")<br/>    membersCanCreateRepositories         = optional(bool, true)<br/>    membersCanCreatePublicRepositories   = optional(bool, true)<br/>    membersCanCreatePrivateRepositories  = optional(bool, true)<br/>    membersCanCreateInternalRepositories = optional(bool)<br/>    membersCanCreatePages                = optional(bool, true)<br/>    membersCanCreatePublicPages          = optional(bool, true)<br/>    membersCanCreatePrivatePages         = optional(bool, true)<br/>    membersCanForkPrivateRepositories    = optional(bool, false)<br/>    webCommitSignoffRequired             = optional(bool, false)<br/><br/>    advancedSecurityEnabledForNewRepositories             = optional(bool, false)<br/>    dependabotAlertsEnabledForNewRepositories             = optional(bool, false)<br/>    dependabotSecurityUpdatesEnabledForNewRepositories    = optional(bool, false)<br/>    dependencyGraphEnabledForNewRepositories              = optional(bool, false)<br/>    secretScanningEnabledForNewRepositories               = optional(bool, false)<br/>    secretScanningPushProtectionEnabledForNewRepositories = optional(bool, false)<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_advanced_security_enabled_for_new_repositories"></a> [advanced\_security\_enabled\_for\_new\_repositories](#output\_advanced\_security\_enabled\_for\_new\_repositories) | Whether GitHub Advanced Security is enabled for new repositories. |
| <a name="output_billing_email"></a> [billing\_email](#output\_billing\_email) | Billing email configured for the organization. |
| <a name="output_default_repository_permission"></a> [default\_repository\_permission](#output\_default\_repository\_permission) | Default repository permission configured for organization members. |
| <a name="output_members_can_create_repositories"></a> [members\_can\_create\_repositories](#output\_members\_can\_create\_repositories) | Whether members can create repositories in the organization. |
| <a name="output_organization_settings_id"></a> [organization\_settings\_id](#output\_organization\_settings\_id) | GitHub organization ID used by github\_organization\_settings. |

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/github-org-settings/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/github-org-settings/_examples/basic) - Minimal organization settings managed through a `config.json` file.

## Import Behavior

This module manages one Terraform resource:

- Terraform address: `github_organization_settings.this`
- Import ID: GitHub organization numeric ID

The organization ID can be discovered with the GitHub REST API `GET /orgs/{org}`. Firestartr `gh_provisioner` should import using that numeric ID when adopting existing organization settings.

## Delete Behavior

`github_organization_settings` does not delete the GitHub organization. Terraform provider delete semantics reset organization settings to provider defaults. This is unsafe for normal Firestartr deletion because deleting the CR could unexpectedly mutate organization-wide settings.

Firestartr integrations should treat deletion of the corresponding CR as non-destructive unmanagement, for example by removing Terraform state only instead of running `terraform destroy`.

## Resources

- **github\_organization\_settings**: [Official Documentation](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/organization_settings)
- **GitHub REST API - Get an organization**: [Official Documentation](https://docs.github.com/en/rest/orgs/orgs#get-an-organization)
- **GitHub Terraform Provider**: [Official Documentation](https://registry.terraform.io/providers/integrations/github/latest/docs)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->
