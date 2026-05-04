## Examples

### Minimal repository

```hcl
module "repository" {
  source = "git::https://github.com/prefapp/tfm.git//modules/github-repo"

  config = {
    repository = {
      name     = "my-repo"
      autoInit = true
    }

    default_branch = {
      branch = "main"
    }
  }
}
```

### Full-featured repository with labels

```hcl
module "repository" {
  source = "git::https://github.com/prefapp/tfm.git//modules/github-repo"

  config = {
    repository = {
      name                = "my-repo"
      description         = "A fully configured repository"
      visibility          = "private"
      topics              = ["terraform", "iac"]
      autoInit            = true
      allowMergeCommit    = false
      allowSquashMerge    = true
      deleteBranchOnMerge = true
      hasIssues           = true
    }

    default_branch = {
      branch = "main"
    }

    labels = [
      {
        name        = "bug"
        description = "Something isn't working"
        color       = "d73a4a"
      },
      {
        name        = "enhancement"
        description = "New feature or request"
        color       = "a2eeef"
      },
      {
        name        = "documentation"
        description = "Improvements or additions to documentation"
        color       = "0075ca"
      },
      {
        name        = "good first issue"
        description = "Good for newcomers"
        color       = "7057ff"
      },
    ]

    teams = [
      { teamId = 123456, permission = "push" },
      { teamId = 789012, permission = "maintain" },
    ]

    collaborators = [
      { username = "octocat", permission = "push" },
    ]
  }
}
```

### Via `terraform.tfvars.json` with labels

```json
{
  "config": {
    "repository": {
      "name": "my-repo",
      "description": "Managed by Terraform",
      "visibility": "private",
      "autoInit": true
    },
    "default_branch": {
      "branch": "main"
    },
    "labels": [
      {
        "name": "bug",
        "description": "Something isn't working",
        "color": "d73a4a"
      },
      {
        "name": "enhancement",
        "description": "New feature or request",
        "color": "a2eeef"
      }
    ]
  }
}
```

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
