# **GitHub Organization Webhook Terraform Module**

## Overview

This module creates and manages a GitHub **organization-level webhook** using a single strongly-typed `config` object.

It is designed for Prefapp’s Internal Developer Platform and automated webhook provisioning pipelines. The module accepts input directly from external programs via JSON.

## Key Features

- **Single config object**: All webhook settings in one `config` variable
- **Full event support**: Subscribe to any GitHub organization webhook event
- **Secure by default**: Supports secret, content type, and SSL validation
- **JSON-native**: Perfect for programmatic generation
- **Strong validation**: Ensures only valid events and required fields

## Supported Events

The module supports **all standard GitHub organization webhook events**.

Common events include:

- `push`
- `pull_request`
- `issues`
- `workflow_run`
- `workflow_dispatch`
- `release`
- `create`
- `delete`
- `fork`
- `member`
- `public`
- `repository`
- `status`
- `watch`
- `commit_comment`
- `gollum`
- `team_add`
- `team`
- `organization`
- `project`
- `project_card`
- `project_column`
- `milestone`
- `deployment`
- `deployment_status`
- `discussion`
- `discussion_comment`

For the **complete and up-to-date list** of all available webhook events and their payloads, see the official GitHub documentation:

→ **[Webhook events and payloads](https://docs.github.com/en/webhooks/webhook-events-and-payloads)**

## Basic Usage

### Using `terraform.tfvars.json` (recommended)

```hcl
module "org_webhook" {
  source = "git::https://github.com/prefapp/tfm.git//modules/gh-org-webhook"

  config = var.config
}

### Inline example

```hcl
module "org_webhook" {
  source = "git::https://github.com/prefapp/tfm.git//modules/gh-org-webhook"

  config = {
    webhook = {
      active = true
      events = ["push", "pull_request", "issues", "workflow_run"]
      configuration = {
        url         = "https://example.com/webhook"
        contentType = "json"
        secret      = "secret-xxx"
        insecureSsl = false
      }
    }
  }
}
```
