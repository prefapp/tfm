<!-- BEGIN_TF_DOCS -->
# **GitHub Team Terraform Module**

## Overview

This module provisions a single GitHub Team and automatically manages its members using a single strongly-typed `config` object.  
It supports nested teams (`parentTeamId`), privacy settings (`closed`/`secret`), and manages all members with the standard `member` role while keeping the external interface minimal and JSON-friendly.

The module is designed for Prefapp’s Internal Developer Platform and automated team provisioning pipelines. It accepts input directly from external programs (Python, Node.js, Go, etc.) via JSON, leveraging Terraform's built-in validation and type safety.

## Key Features

- **Single complex object**: All configuration lives in one `config` variable — perfect for programmatic generation.
- **Config validation**: Enforces team name, privacy setting, and required fields at plan time.
- **Nested team support**: Automatic `parent_team_id` handling.
- **JSON-native**: Feed `jsondecode(file("team-config.json"))` directly.
- **Clean outputs**: Every value is exposed as a separate output for easy consumption in larger pipelines.
- **GitHub Provider v6+**: Uses the latest official `integrations/github` provider.

## Basic Usage

### Minimal team with members

```hcl
module "my_team" {
  source = "git::https://github.com/prefapp/tfm.git//modules/gh-team"

  config = jsondecode(file("${path.root}/team-config.json"))
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
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
| [github_team.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team) | resource |
| [github_team_membership.members](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team_membership) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_config"></a> [config](#input\_config) | GitHub team configuration as a single complex object | <pre>object({<br/>    group = object({<br/>      name         = string<br/>      description  = optional(string, "")<br/>      privacy      = optional(string, "closed")<br/>      parentTeamId = optional(number, null)   # null or team ID (number)<br/>    })<br/><br/>    group_members = optional(list(object({<br/>      username = string<br/>      teamId   = optional(string)   # kept for compatibility, ignored during creation<br/>    })), [])<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_team_description"></a> [team\_description](#output\_team\_description) | Description of the created GitHub team |
| <a name="output_team_id"></a> [team\_id](#output\_team\_id) | ID of the created GitHub team |
| <a name="output_team_members"></a> [team\_members](#output\_team\_members) | List of usernames added to the team |
| <a name="output_team_name"></a> [team\_name](#output\_team\_name) | Name of the created GitHub team |
| <a name="output_team_parent_id"></a> [team\_parent\_id](#output\_team\_parent\_id) | Parent team ID (null if none) |
| <a name="output_team_privacy"></a> [team\_privacy](#output\_team\_privacy) | Privacy setting of the team (closed/secret) |
| <a name="output_team_slug"></a> [team\_slug](#output\_team\_slug) | Slug of the created GitHub team |

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/gh-team/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/gh-team/_examples/basic) - Minimal team creation with JSON input

## Resources

- **github\_team**: [Official Documentation](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team)
- **github\_team\_membership**: [Official Documentation](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team_membership)
- **GitHub Terraform Provider**: [Official Documentation](https://registry.terraform.io/providers/integrations/github/latest/docs)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->
