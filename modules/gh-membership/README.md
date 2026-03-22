<!-- BEGIN_TF_DOCS -->
# **GitHub Membership Terraform Module**

## Overview

This module manages GitHub organization-level membership (admin/member) and team memberships using a single strongly-typed `config` object.

It is designed for Prefapp’s Internal Developer Platform and automated user/team provisioning pipelines. The module accepts input directly from external programs via JSON.

## Key Features

- **Organization role**: Assign `member` or `admin` at organization level
- **Team relationships**: Add users to teams with `member` or `maintainer` roles
- **Single config object**: Everything in one `config` variable
- **Full validation**: Role enforcement and required fields
- **JSON-native**: Perfect for programmatic generation

## Basic Usage

### Using `terraform.tfvars.json` (recommended)

```hcl
module "membership" {
  source = "git::https://github.com/prefapp/tfm.git//modules/gh-membership"

  config = var.config
}

#### Inline example
```hcl
module "membership" {
  source = "git::https://github.com/prefapp/tfm.git//modules/gh-membership"

  config = {
    user = {
      username = "johndoe"
      role     = "admin"
    }
    relationships = [
      {
        username = "johndoe"
        teamId   = "foo-all"
        role     = "member"
      }
    ]
  }
}
```
```

## Requirements

| Name | Version |
|------|---------|
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
| [github_membership.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/membership) | resource |
| [github_team_membership.relationships](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team_membership) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_config"></a> [config](#input\_config) | GitHub membership configuration (organization role + team relationships) | <pre>object({<br/>    relationships = optional(list(object({<br/>      username = string<br/>      teamId   = string   # team slug (e.g. "jvazquez-prefapp-all")<br/>      role     = optional(string, "member")  # member | maintainer<br/>    })), [])<br/><br/>    user = optional(object({<br/>      username = string<br/>      role     = optional(string, "member")  # member | admin<br/>    }))<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_organization_membership"></a> [organization\_membership](#output\_organization\_membership) | Organization-level membership |
| <a name="output_team_memberships"></a> [team\_memberships](#output\_team\_memberships) | Team memberships created |
| <a name="output_user"></a> [user](#output\_user) | User details |

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/gh-membership/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/gh-membership/_examples/basic) - Organization membership + team relationship

## Resources

- **github\_membership**: [Official Documentation](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/membership)
- **github\_team\_membership**: [Official Documentation](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team_membership)
- **GitHub Terraform Provider**: [Official Documentation](https://registry.terraform.io/providers/integrations/github/latest/docs)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->