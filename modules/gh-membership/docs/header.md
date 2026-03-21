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
