<!-- BEGIN_TF_DOCS -->
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
module "org\_webhook" {
  source = "git::https://github.com/prefapp/tfm.git//modules/gh-org-webhook"

  config = {
    webhook = {
      active = true
      events = ["push", "pull\_request", "issues", "workflow\_run"]
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
| [github_organization_webhook.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/organization_webhook) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_config"></a> [config](#input\_config) | GitHub organization webhook configuration | <pre>object({<br/>    webhook = object({<br/>      active = optional(bool, true)<br/>      events = list(string)<br/><br/>      configuration = object({<br/>        url           = string<br/>        contentType   = optional(string, "json")<br/>        secret        = optional(string)<br/>        insecureSsl   = optional(bool, false)<br/>      })<br/>    })<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_active"></a> [active](#output\_active) | Whether the webhook is active |
| <a name="output_events"></a> [events](#output\_events) | Events the webhook is subscribed to |
| <a name="output_webhook_id"></a> [webhook\_id](#output\_webhook\_id) | ID of the created organization webhook |
| <a name="output_webhook_url"></a> [webhook\_url](#output\_webhook\_url) | URL of the webhook |

### `docs/footer.md`
```markdown
## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/gh-org-webhook/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/gh-org-webhook/_examples/basic) - Organization webhook with push/pull_request/issues

## Resources

- **github_organization_webhook**: [Official Documentation](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/organization_webhook)
- **GitHub Terraform Provider**: [Official Documentation](https://registry.terraform.io/providers/integrations/github/latest/docs)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
```
<!-- END_TF_DOCS -->