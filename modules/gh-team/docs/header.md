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
