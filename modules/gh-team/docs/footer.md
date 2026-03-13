
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
