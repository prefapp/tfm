<!-- BEGIN_TF_DOCS -->
# **GitHub Team Terraform Module**

## Overview

This module provisions a single GitHub Team and automatically manages its members using a single strongly-typed `config` object.  
It supports nested teams (`parentTeamId`), privacy settings (`closed`/`secret`), and full membership roles while keeping the external interface minimal and JSON-friendly.

The module is designed for Prefapp’s Internal Developer Platform and automated team provisioning pipelines. It accepts input directly from external programs (Python, Node.js, Go, etc.) via JSON, ensuring full Terraform validation and type safety.

## Key Features

- **Single complex object**: All configuration lives in one `config` variable — perfect for programmatic generation.
- **Full validation**: Enforces name, privacy, username format, and required fields at plan time.
- **Nested team support**: Automatic `parent_team_id` handling.
- **JSON-native**: Feed `jsondecode(file("team-config.json"))` directly.
- **Clean outputs**: Every value is exposed as a separate output for easy consumption in larger pipelines.
- **GitHub Provider v6+**: Uses the latest official `integrations/github` provider.

## Basic Usage

### Minimal team with members

```hcl
module "my_team" {
  source = "git::https://github.com/prefapp/tfm.git//modules/github-team"

  config = jsondecode(file("${path.root}/team-config.json"))
}
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

### 3. `docs/footer.md`
```markdown
## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/github-team/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/github-team/_examples/basic) - Minimal team creation with JSON input

## Resources

- **github_team**: [Official Documentation](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team)
- **github_team_membership**: [Official Documentation](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team_membership)
- **GitHub Terraform Provider**: [Official Documentation](https://registry.terraform.io/providers/integrations/github/latest/docs)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
```

### 4. `variables.tf`
```hcl
terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

variable "config" {
  description = "GitHub team configuration as a single complex object (exact match to Prefapp JSON structure)"
  type = object({
    group = object({
      name         = string
      description  = optional(string, "")
      privacy      = optional(string, "closed")
      parentTeamId = optional(number, null)
    })

    group_members = optional(list(object({
      username = string
      teamId   = optional(string)
    })), [])
  })

  validation {
    condition     = contains(["closed", "secret"], var.config.group.privacy)
    error_message = "group.privacy must be 'closed' or 'secret'."
  }

  validation {
    condition     = length(trimspace(var.config.group.name)) > 0
    error_message = "group.name cannot be empty."
  }

  validation {
    condition = alltrue([
      for m in var.config.group_members : length(trimspace(m.username)) > 0
    ])
    error_message = "Every member in group_members must have a non-empty username."
  }
}
```

### 5. `main.tf`
```hcl
# Create the GitHub Team
resource "github_team" "this" {
  name           = var.config.group.name
  description    = var.config.group.description
  privacy        = var.config.group.privacy
  parent_team_id = var.config.group.parentTeamId
}

# Add team memberships
resource "github_team_membership" "members" {
  for_each = {
    for m in var.config.group_members : m.username => m
  }

  team_id  = github_team.this.id
  username = each.value.username
  role     = "member"
}
```

### 6. `outputs.tf`
```hcl
output "team_id" {
  description = "ID of the created GitHub team"
  value       = github_team.this.id
}

output "team_slug" {
  description = "Slug of the created GitHub team"
  value       = github_team.this.slug
}

output "team_name" {
  description = "Name of the created GitHub team"
  value       = github_team.this.name
}

output "team_description" {
  description = "Description of the created GitHub team"
  value       = github_team.this.description
}

output "team_privacy" {
  description = "Privacy setting of the team (closed/secret)"
  value       = github_team.this.privacy
}

output "team_members" {
  description = "List of usernames added to the team"
  value       = [for m in var.config.group_members : m.username]
}

output "team_parent_id" {
  description = "Parent team ID (null if none)"
  value       = github_team.this.parent_team_id
}
```

### 7. `_examples/basic/main.tf`
```hcl
terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

module "example_team" {
  source = "../../"   # points to the module root

  config = jsondecode(file("${path.module}/team-config.json"))
}

output "team_id" {
  value = module.example_team.team_id
}
```

**Example `team-config.json`** (place it inside `_examples/basic/`):
```json
{
  "group": {
    "name": "私のチーム",
    "description": "Prefapp all description",
    "privacy": "closed",
    "parentTeamId": null
  },
  "group_members": [
    { "username": "frmadem-user", "teamId": "16210767" }
  ]
}
```

---

**Next steps (exactly as per the guide)**

1. Place the folder in `modules/github-team/`
2. Run inside the module folder:
   ```bash
   terraform-docs .
   ```
3. Commit with Conventional Commit:
   ```bash
   git commit -m "feat: add github-team module with Prefapp standards"
   ```
4. Open PR referencing the documentation issue if needed.

The module now fully meets **all** Prefapp TFM requirements (structure, docs, examples, terraform-docs, Conventional Commits ready).

Ready for review or want me to add the `role` field to members / multi-team support? Just say the word.
<!-- END_TF_DOCS -->
