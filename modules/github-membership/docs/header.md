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

Define the module in your `.tf` file, referencing `var.config`:

```hcl
module "membership" {
  source = "git::https://github.com/prefapp/tfm.git//modules/github-membership"

  config = var.config
}
```

Supply the config value in a `terraform.tfvars.json` file:

```json
{
  "config": {
    "user": {
      "username": "johndoe",
      "role": "admin"
    },
    "relationships": [
      {
        "username": "johndoe",
        "teamId": 123456,
        "role": "member"
      }
    ]
  }
}
```

### Inline example

```hcl
module "membership" {
  source = "git::https://github.com/prefapp/tfm.git//modules/github-membership"

  config = {
    user = {
      username = "johndoe"
      role     = "admin"
    }
    relationships = [
      {
        username = "johndoe"
        teamId   = 123456
        role     = "member"
      }
    ]
  }
}
```
